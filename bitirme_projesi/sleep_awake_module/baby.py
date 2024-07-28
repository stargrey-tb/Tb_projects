import cv2
import numpy as np
import time
import json
from flask import Flask, render_template, request, Response
from flask_cors import CORS, cross_origin
from threading import Timer, Lock, Event, Thread
import os
import shutil
import mediapipe as mp
from collections import deque
import _thread
import logging
import serial
import queue
import statistics
from PIL import Image
from dotenv import load_dotenv
# from cast_service import CastSoundService
from http.server import HTTPServer, SimpleHTTPRequestHandler
from helpers import check_eyes_open, set_hatch, check_mouth_open, maintain_aspect_ratio_resize, gamma_correction
import matplotlib.pyplot as plt
import skimage
from skimage import measure, io, color, data
from skimage.filters import meijering, sato, frangi, hessian
from scipy import ndimage as ndi
from skimage.util import random_noise
from skimage import feature
from skimage.color import rgb2gray
from skimage.filters import gaussian, threshold_otsu, threshold_niblack, threshold_sauvola, threshold_multiotsu
from skimage.segmentation import active_contour, chan_vese, random_walker
from skimage.feature import hog
from skimage import data, exposure, img_as_float
from skimage.feature import shape_index
from skimage.draw import disk
from skimage.data import page, binary_blobs
from skimage.exposure import rescale_intensity
from sklearn import svm
import pickle
import requests
import datetime



frame_q = deque(maxlen=20)
cropped_raw_frame_q = deque(maxlen=1)
debug_frame_q = deque(maxlen=1)
model_proba = ",,"
allow_model_movement_votes = False
vote_reasons = []
model_sees_baby = None
body_found = False
focus_bounding_box = (None, None, None, None)
classifier_resolution = 256

with open('user_defined_crop_area.txt', 'r', encoding="utf-8") as f:
    crop_area = f.read()
    focusRegionArr = crop_area.split(',')
    print('reading focusRegionArr: ', focusRegionArr)
    if focusRegionArr[0] is '':
        focus_bounding_box = (None,None,None,None)
    else:
        x = int(float(focusRegionArr[0]))
        y = int(float(focusRegionArr[1]))
        w = int(float(focusRegionArr[2]))
        h = int(float(focusRegionArr[3]))
        focus_bounding_box = (x,y,w,h)

# load model that finds babies under blankets
lock_model_use = False
creepy_baby_model = None
try:
    with open( 'creepy_baby_model.pkl', 'rb') as f:
        creepy_baby_model = pickle.load(f)
        print("furkan")
except Exception as e:
    print("No blanket model found at startup: ", e)



#BABY CLASS
    
class SleepyBaby():
    # General high level heuristics:
    # 1) no eyes -> no body found -> blanket creeper model: BABY -> baby is asleep
    # 1) no eyes -> no body found -> blanket creeper model: NO_BABY -> baby is awake
    # 1) no eyes -> no body found -> baby is awake
    # 2) no eyes -> body found -> moving -> baby is awake
    # 3) no eyes -> body found -> not moving -> baby is sleeping
    # 4) eyes -> eyes open -> baby is awake (disregard body movement)
    # 5) eyes -> eyes closed -> movement -> baby is awake
    # 6) eyes -> eyes closed -> no movement -> baby is asleep
    # 7) eyes -> eyes closed -> mouth open -> baby is awake

    def __init__(self, creepy_baby_model):
        self.creepy_baby_model = creepy_baby_model
        self.frame_dim = (1920,1080)
        self.next_frame = 0
        # self.fps = 30
        self.fps = 30 # for testing recorded
        self.mpPose = mp.solutions.pose
        self.mpFace = mp.solutions.face_mesh
        self.pose = self.mpPose.Pose(min_detection_confidence=0.3, min_tracking_confidence=0.3)
        # TODO: try turning off refine_landmarks for performance, might not be needed
        self.face = self.mpFace.FaceMesh(max_num_faces=1, refine_landmarks=True, min_detection_confidence=0.3, min_tracking_confidence=0.3)
        self.mpDraw = mp.solutions.drawing_utils
        self.mpDrawStyles = mp.solutions.drawing_styles

        self.eyes_open_q = deque(maxlen=30)
        self.awake_q = deque(maxlen=15)
        self.awake_q.append(0)
        self.movement_q = deque(maxlen=10)
        # self.fd_q = deque(maxlen=2)
        self.image_comparison_q = deque(maxlen=2)
        self.eyes_open_state = False

        self.multi_face_landmarks = []
        self.is_awake = False
        self.ser = None # serial connection to arduino for controlling demon owl

        self.top_lip = frozenset([
            (324, 308), (78, 191), (191, 80), (80, 81), (81, 82),
            (82, 13), (13, 312), (312, 311), (311, 310),
            (310, 415), (415, 308),
            (375, 291), (61, 185), (185, 40), (40, 39), (39, 37),
            (37, 0), (0, 267),
            (267, 269), (269, 270), (270, 409), (409, 291),
        ])
        self.bottom_lip = frozenset([
            (61, 146), (146, 91), (91, 181), (181, 84), (84, 17),
            (17, 314), (314, 405), (405, 321), (321, 375),
            (78, 95), (95, 88), (88, 178), (178, 87), (87, 14),
            (14, 317), (317, 402), (402, 318), (318, 324),
        ]) 


    # Decorator ensures function that can only be called once every `s` seconds.
    def debounce(s):
        def decorate(f):
            t = None

            def wrapped(*args, **kwargs):
                nonlocal t
                t_ = time.time()
                if t is None or t_ - t >= s:
                    result = f(*args, **kwargs)
                    t = time.time()
                    return result
            return wrapped
        return decorate


    @debounce(1)
    def throttled_handle_no_eyes_found(self):
        if(len(self.eyes_open_q) > 0):
            logging.info('No face found, depreciate queue')
            print('No face found, depreciate queue')
            self.eyes_open_q.popleft()


    @debounce(1)
    def throttled_handle_no_body_found(self):
        # TODO: Exploring use of HOG image diffs over time to infer movement
        pass
        # logging.info('No body found, vote awake')
        # print('No body found, vote awake')
        # self.awake_q.append(1)


    def process_baby_image_models(self, img, debug_img):
        results = self.face.process(img)
        results_pose = self.pose.process(img)

        global body_found
        if results_pose.pose_landmarks:
            body_found = True
            # print("\BODYYYYY\n")
            # 15 left-wrist, 16 right-wrist
            shape = img.shape
            left_wrist_coords = (shape[1] * results_pose.pose_landmarks.landmark[15].x, shape[0] * results_pose.pose_landmarks.landmark[15].y)
            right_wrist_coords = (shape[1] * results_pose.pose_landmarks.landmark[16].x, shape[0] * results_pose.pose_landmarks.landmark[16].y)

            # print('left wrist: ', left_wrist_coords)
            # print('right wrist: ', right_wrist_coords)

            self.movement_q.append((left_wrist_coords, right_wrist_coords))

            # debug_img = cv2.putText(debug_img, "Left wrist", (int(left_wrist_coords[0]), int(left_wrist_coords[1])), 2, .5, (255,0,0), 2, 2)
            # debug_img = cv2.putText(debug_img, "Right wrist", (int(right_wrist_coords[0]), int(right_wrist_coords[1])), 2, .5, (255,0,0), 2, 2)

            # if os.getenv("DEBUG", 'False').lower() in ('true', '1'):
            CUTOFF_THRESHOLD = 10  # head and face
            MY_CONNECTIONS = frozenset([t for t in self.mpPose.POSE_CONNECTIONS if t[0] > CUTOFF_THRESHOLD and t[1] > CUTOFF_THRESHOLD])

            # if results_pose.pose_landmarks:  # if it finds the points
            #     for landmark_id, landmark in enumerate(results_pose.pose_landmarks):
            #         if landmark_id <= CUTOFF_THRESHOLD:
            #             landmark.visibility = 0
            #     self.mpDraw.draw_landmarks(debug_img, results_pose.pose_landmarks, MY_CONNECTIONS) 

            for id, lm in enumerate(results_pose.pose_landmarks.landmark):
                if id <= CUTOFF_THRESHOLD:
                    lm.visibility = 0
                    continue
                h, w,c = debug_img.shape
                # print(id, lm)
                cx, cy = int(lm.x*w), int(lm.y*h)
                cv2.circle(debug_img, (cx, cy), 5, (255,0,0), cv2.FILLED)

            self.mpDraw.draw_landmarks(debug_img, results_pose.pose_landmarks, MY_CONNECTIONS, landmark_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 0, 0), thickness=2, circle_radius=2))

                # self.mpDraw.draw_landmarks(debug_img, results_pose.pose_landmarks, MY_CONNECTIONS)
                # for id, lm in enumerate(results_pose.pose_landmarks.landmark):
                #     if id < CUTOFF_THRESHOLD:
                #         continue
                #     self.mpDraw.draw_landmarks(debug_img, results_pose.pose_landmarks, MY_CONNECTIONS)
                #     h, w,c = debug_img.shape
                #     # print(id, lm)
                #     cx, cy = int(lm.x*w), int(lm.y*h)
                #     cv2.circle(debug_img, (cx, cy), 5, (255,0,0), cv2.FILLED)
        else:
            body_found = False
            self.throttled_handle_no_body_found()

        LEFT_EYE = [362, 382, 381, 380, 374, 373, 390, 249, 263, 466, 388, 387, 386, 385, 384, 398]
        RIGHT_EYE = [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246] 
        
        self.multi_face_landmarks = results.multi_face_landmarks
        if results.multi_face_landmarks:
            # print("\nEYESSSSS\n")

            eyes_are_open = check_eyes_open(results.multi_face_landmarks[0].landmark, img, debug_img, LEFT_EYE, RIGHT_EYE)

            # Additionally check if mouth is closed. If not, consider baby crying. Can rely on queue length to ensure
            # yawns don't trigger wake

            # If mouth is open, override and just consider it, "eyes open", pushing in direction of "wake vote"
            if eyes_are_open == 0: # if eyes are closed, then check if mouth is open
                mouth_is_open = check_mouth_open(results.multi_face_landmarks[0].landmark)
                if mouth_is_open:
                    logging.info('Eyes closed, mouth open, crying or yawning, consider awake.')
                    self.eyes_open_q.append(1)
                else:
                    logging.info('Eyes closed, mouth closed, consider sleeping.')
                    self.eyes_open_q.append(0)
            else:
                logging.info('Eyes open, consider awake.')
                self.eyes_open_q.append(1)

        else: # no face results, interpret this as baby is not in crib, i.e. awake
            self.throttled_handle_no_eyes_found()
            print("Bebek yuzu kamerda gozukmuyor ", e)
            print("********************************* ", e)
            
 
        return debug_img, body_found


    # This is placeholder until improve sensitivity of transitioning between waking and sleeping.
    # Explanation: Sometimes when baby is waking up, he'll open and close his eyes for a couple of minutes...
    # TODO: Fine-tune sensitivity of voting, for now, don't allow toggling between wake & sleep within N seconds
    @debounce(5)
    def write_wakeness_event(self, wake_status, img):
        str_timestamp = str(int(time.time()))
        if wake_status: # woke up

            #print(f"uyandi {str_timestamp}")
            # cv2.imwrite(p, img) # store off image of when wake/sleep event occurred. Can help with debugging issues

            # if daytime, send phone notification if baby woke up
            # now = datetime.datetime.now()
            # now_time = now.time()
            # notifications_enabled = False
            # with open(os.getenv("APP_DIR") + '/notifications.txt', 'r', encoding="utf-8") as f:
            #     notifications_enabled_text = f.read()
            #     notifications_enabled = notifications_enabled_text == 'true'
            # if notifications_enabled and now_time >= datetime.time(7,00) or now_time <= datetime.time(22,00): # day time
            #     bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
            #     bot_chat_id = os.getenv("TELEGRAM_BOT_CHAT_ID")
            #     send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chat_id + '&text=' + 'Baby woke up'
            #     response = requests.get(send_text)
            #     # Thread(target=telegram_send.send(messages=["Baby woke up."]), daemon=True).start()

            self.is_awake = True

            if os.getenv("OWL", 'False').lower() in ('true', '1'):
                print("MOVE & MAKE NOISE")
                logging.info("MOVE & MAKE NOISE")
                time.sleep(5)
                self.ser.write(bytes(str(999999) + "\n", "utf-8"))
                self.cast_service.play_sound()
        else: # fell asleep
            log_string = "0," + str_timestamp + "\n"
            print(log_string)
            logging.info(log_string)
            print(f"uyudu {str_timestamp}")
            self.is_awake = False

        # now = datetime.datetime.now()
        # now_time = now.time()
        # if now_time >= ti(22,00) or now_time <= ti(8,00): # night time
        #     set_hatch(self.is_awake)


    @debounce(10)
    def set_wakeness_status(self, img):
        if len(self.awake_q):
            avg_awake = sum(self.awake_q) / len(self.awake_q)
            if avg_awake >= 0.6 and self.is_awake == False:
                self.write_wakeness_event(True, img)
            elif avg_awake < 0.6 and self.is_awake == True:
                self.write_wakeness_event(False, img)


    @debounce(1)
    def awake_voting_logic(self, debug_img):
        if len(self.eyes_open_q) > len(self.eyes_open_q)/2: # dont vote on eyes unless queue is half full
            avg = sum(self.eyes_open_q) / len(self.eyes_open_q)
            global vote_reasons
            if avg > 0.75: # eyes open
                self.eyes_open_state = True
                print("Eyes open: vote awake")
                logging.info("\nvote awake")
                self.awake_q.append(3)
                vote_reasons.append('Eyes Open')
            else: # closed
                self.eyes_open_state = False
                self.awake_q.append(0)
                vote_reasons.append('Eyes Closed')
                print("Eyes closed: vote sleeping")
                logging.info("\nvote sleeping")
        else:
            print("Not voting on eyes, eye queue too short.")


    @debounce(1)
    def movement_voting_logic(self, debug_img, body_found):
        if not body_found:
            #print('No body found, depreciate movement queue.')
            if len(self.movement_q):
                self.movement_q.popleft()

        elif len(self.movement_q) > 5:
            left_wrist_list = [c[0] for c in self.movement_q]
            left_wrist_x_list = [c[0] for c in left_wrist_list]
            left_wrist_y_list = [c[1] for c in left_wrist_list]

            right_wrist_list = [c[1] for c in self.movement_q]
            right_wrist_x_list = [c[0] for c in right_wrist_list]
            right_wrist_y_list = [c[1] for c in right_wrist_list]

            std_left_wrist_x = statistics.pstdev(left_wrist_x_list) - 1
            std_left_wrist_y = statistics.pstdev(left_wrist_y_list) - 1

            std_right_wrist_x = statistics.pstdev(right_wrist_x_list) - 1
            std_right_wrist_y = statistics.pstdev(right_wrist_y_list) - 1

            # average it all together and compare to movement threshold to determine if moving
            avg_std = (((std_left_wrist_x + std_left_wrist_y)/2) + ((std_right_wrist_x + std_right_wrist_y)/2))/2
            # print('movement left: ', (std_left_wrist_x + std_left_wrist_y)/2)
            # print('movement right: ', (std_right_wrist_x + std_right_wrist_y)/2)
            # print('movement value: ', avg_std)
            global vote_reasons
            if int(avg_std) < 30:
                print("No movement, vote sleeping")
                logging.info('No movement, vote sleeping')
                self.awake_q.append(0)
                vote_reasons.append("Not moving")
            else:
                print("Movement, vote awake")
                logging.info("Movement, vote awake")
                self.awake_q.append(1)
                vote_reasons.append("Moving")


    # every N seconds, check if baby is awake & do stuff
    @debounce(5)
    def periodic_wakeness_check(self):
        print('\n', 'Is baby awake:', self.is_awake, '\n')
        logging.info('Is baby awake: {}'.format(str(self.is_awake)))

    @debounce(1)
    def blanket_logic(self, image, body_found, raw_uncropped_image):
        #print("Body not found,  invoking blanket logic.")
        # grayscaled = color.rgb2gray(image)
        image_gaus = cv2.GaussianBlur(image, (3,3), 0)
        # cropped_frame_forced_size = cv2.resize(blurred, (256, 256))
        # print('im shape: ', cropped_frame_forced_size.shape)

        # fd, hog_image = hog(grayscaled, orientations=8, pixels_per_cell=(16, 16),
        #             cells_per_block=(1, 1), channel_axis=None, visualize=True)
        # hog_image_rescaled = exposure.rescale_intensity(hog_image, out_range=(0, 255)).astype("uint8")
        # debug_frame_q.append(hog_image_rescaled)
        # self.fd_q.append(fd)
        self.image_comparison_q.append(image_gaus)

        # print(statistics.pstdev(fd))
        global vote_reasons
        global allow_model_movement_votes
        image_diff = None
        if len(self.image_comparison_q) == 2 and allow_model_movement_votes:
            allow_model_movement_votes = False
            # image_comparison_q
            # image_diff = np.linalg.norm(self.image_comparison_q[0] - self.image_comparison_q[1])
            try:
                image_diff = np.mean(np.abs(self.image_comparison_q[0] - self.image_comparison_q[1]))
            except Exception as e:
                print("Something went wrong, just bail out on blanket logic this round: ", e)
                return
            # print('image_diff: ', image_diff)
            if image_diff > 75:
                print("Movement detected, voting awake.")
                print('increase by: ', image_diff/60)
                self.awake_q.append(image_diff/60)
                vote_reasons.append('Movement')

        global model_sees_baby
        try:
            if not body_found and not lock_model_use:
                # y = creepy_baby_model.predict_proba([fd])
                image_gaus=cv2.resize(image_gaus,(168,256))                     # SVC MODELİNİN İNPUTUNA UYGUN OLMASI İÇİN TEKRAR RESİZE YAPILDI?
                y = creepy_baby_model.predict_proba([image_gaus.flatten()])
                
                allow_model_movement_votes = True
                print('Model proba: ', y[0])
                if y[0][0] > .5:
                    model_sees_baby = True

                    print("Blanket creeper found baby, voting asleep.")
                    self.awake_q.append(0)
                    vote_reasons.append('Baby present')
                    if len(self.image_comparison_q) == 2:
                        if image_diff < 75:
                            print("Baby not moving.")
                            self.awake_q.append(0)
                            vote_reasons.append('Baby not moving')
                else:
                    model_sees_baby = False
                    print("Blanket creeper doesn't see baby, voting awake.")
                    self.awake_q.append(1)
                    vote_reasons.append('No baby present')

                global model_proba
                proba_string = str(y[0][0]) + ',' + str(y[0][1]) + ',' + str(time.time())
                model_proba = proba_string

                # with open(os.getenv("APP_DIR") + '/blanket_model/current_output/proba.txt', 'w', encoding="utf-8") as f:
                #     f.write(proba_string)
                # cv2.imwrite(os.getenv("APP_DIR") + '/blanket_model/current_output/raw.png', image)
        except Exception as e:
            model_sees_baby = None
            print("Something went wrong while invoking creepy blanket model: ", e)

        cv2.imwrite('raw_uncropped.png', raw_uncropped_image)


    def frame_logic(self, raw_img, raw_uncropped_image, debug_frame_q):
        img = raw_img

        debug_img = img.copy()
        img.flags.writeable = False
        # converted_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # beef
        # res = self.process_baby_image_models(converted_img, debug_img)
        res = self.process_baby_image_models(img, debug_img)
        debug_img = res[0]
        body_found = res[1]

        self.awake_voting_logic(debug_img)
        self.movement_voting_logic(debug_img, body_found)
        self.blanket_logic(img.copy(), body_found, raw_uncropped_image)
        self.set_wakeness_status(debug_img)
        self.periodic_wakeness_check()

        # if os.getenv("DEBUG", 'False').lower() in ('true', '1'):
        #     # avg_awake = 1
        #     avg_awake = sum(self.awake_q) / len(self.awake_q)
            
        #     # draw progress bar
        #     bar_y_offset = 0
        #     bar_y_offset = 0

        #     bar_width = 200
        #     w = img.shape[1]
        #     start_point = (int(w/2 - bar_width/2), 350 + bar_y_offset)

        #     end_point = (int(w/2 + bar_width/2), 370 + bar_y_offset)
        #     adj_avg_awake = 1.0 if avg_awake / .6 >= 1.0 else avg_awake / .6
        #     progress_end_point = (int(w/2 - bar_width/2 + (bar_width*(adj_avg_awake))), 370 + bar_y_offset)

        #     color = (255, 255, 117)
        #     progress_color = (0, 0, 255)
        #     thickness = -1

        #     debug_img = cv2.rectangle(debug_img, start_point, end_point, color, thickness)
        #     debug_img = cv2.rectangle(debug_img, start_point, progress_end_point, progress_color, thickness)
        #     display_perc = int((avg_awake * 100) / 0.6)
        #     display_perc = 100 if display_perc >= 100 else display_perc
        #     debug_img = cv2.putText(debug_img, str(display_perc) + "%", (int(w/2 - bar_width/2), 330 + bar_y_offset), 2, 1, (255,0,0), 2, 2)
        #     debug_img = cv2.putText(debug_img, "Awake", (int(w/2 - bar_width/2 + 85), 330 + bar_y_offset), 2, 1, (255,0,0), 2, 2)

        return debug_img


    # This basically does the same thing as the live version, but is very useful for testing
    def recorded(self, debug_frame_q, cropped_raw_frame_q):
        # cap = cv2.VideoCapture(os.getenv("VIDEO_PATH"))
        cap = cv2.VideoCapture('output_file.mp4')
        # cap = cv2.VideoCapture(os.getenv("APP_DIR") + '/raw_data/babywaking.mp4')
        # cap = cv2.VideoCapture(os.getenv("APP_DIR") + '/raw_data/baby_eyes.mp4')
        # cap = cv2.VideoCapture(os.getenv("APP_DIR") + '/raw_data/falling_asleep_eyes.mp4')

        global focus_bounding_box
        global classifier_resolution
        success, img = cap.read()
        while success:
            frame = None
            while frame is None:
                cur_time = time.time()
                if cur_time > self.next_frame:
                    frame = img
                    self.next_frame = max(
                        self.next_frame + 1.0 / self.fps, cur_time + 0.5 / self.fps
                    )

                    success, img = cap.read()

                    if all(e is not None for e in [frame, img]):
                        # bounds to actual run models/analysis on...no need to look for babies outside of the crib
                        x = 0
                        y = 0
                        h = 1079
                        w = 1919
                        #x = focus_bounding_box[0]
                        #y = focus_bounding_box[1]
                        #w = focus_bounding_box[2]
                        #h = focus_bounding_box[3]

                        if img.shape[0] > 1080 and img.shape[1] > 1920: # max res 1080p
                            img, _dim = maintain_aspect_ratio_resize(img, width=self.frame_dim[0], height=self.frame_dim[1])

                        if x is None:
                            cropped_raw_frame_q.append(img)
                            print('Bounds not set, not running AI logic.,otaku')
                            break

                        img_to_process = img[y:y+h, x:x+w]

                        # img = maintain_aspect_ratio_resize(img, width=self.frame_dim[0], height=self.frame_dim[1])
                        img_to_process, dim = maintain_aspect_ratio_resize(img_to_process, width=classifier_resolution)
                        cropped_raw_frame_q.append(img_to_process)

                        debug_img = self.frame_logic(img_to_process, img, debug_frame_q)

                        # reapply cropped and modified/marked up img back to img which is displayed
                        # img[y:y+h, x:x+w] = debug_img

                        # global model_sees_baby
                        # if model_sees_baby is not None:
                        # if model_sees_baby is None:
                        #     text = 'Pose detected'
                        #     text_color = (255,0,0)
                        # else:
                        #     text = 'Baby detected' if model_sees_baby else 'Baby not detected'
                        #     text_color = (255,0,0) if model_sees_baby else (0,140,255)
                        # cv2.putText(debug_img, text, (int(0), int(debug_img.shape[1])), 1, 2, text_color, 2, 2)
                            # cv2.putText(img, text, (int(img.shape[0]/2) + 250, int(img.shape[1]/2)), 2, 3, text_color, 2, 2)

                        # cv2.rectangle(img=img, pt1=(x, y), pt2=(x+w, y+h), color=[153,50,204], thickness=2)
                        # tmp = img[y:y+h, x:x+w]
                        # img = gamma_correction(img, .4)

                        if self.multi_face_landmarks:
                            for face_landmarks in self.multi_face_landmarks:
                                    # INDICIES: https://github.com/tensorflow/tfjs-models/blob/838611c02f51159afdd77469ce67f0e26b7bbb23/face-landmarks-detection/src/mediapipe-facemesh/keypoints.ts
                                    # https://github.com/google/mediapipe/blob/master/mediapipe/python/solutions/face_mesh_connections.py
                                    self.mpDraw.draw_landmarks(
                                        image=debug_img,
                                        landmark_list=face_landmarks,
                                        connections=self.mpFace.FACEMESH_RIGHT_EYE,
                                        landmark_drawing_spec=None,
                                        connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=1, circle_radius=1))
                                        # connection_drawing_spec=self.mpDrawStyles
                                        # .get_default_face_mesh_contours_style())
                                    self.mpDraw.draw_landmarks(
                                        image=debug_img,
                                        landmark_list=face_landmarks,
                                        connections=self.mpFace.FACEMESH_LEFT_EYE,
                                        landmark_drawing_spec=None,
                                        connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 255, 0), thickness=1, circle_radius=1))
                                        # connection_drawing_spec=self.mpDrawStyles
                                        # .get_default_face_mesh_contours_style())

                                    self.mpDraw.draw_landmarks(
                                        image=debug_img,
                                        landmark_list=face_landmarks,
                                        connections=self.top_lip,
                                        landmark_drawing_spec=None,#self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=2, circle_radius=2),
                                        connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=1, circle_radius=1))
                                    self.mpDraw.draw_landmarks(
                                        image=debug_img,
                                        landmark_list=face_landmarks,
                                        connections=self.bottom_lip,
                                        landmark_drawing_spec=None,
                                        connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 255, 0), thickness=1, circle_radius=1))

                            # img[y:y+h, x:x+w] = tmp
                            debug_frame_q.append(debug_img)

                        try:
                            # img = cv2.resize(img, (960, 540))
                            # cv2.imshow('baby', img)
                            cv2.imshow('baby', debug_img)
                            if cv2.waitKey(1) & 0xFF == ord('q'):
                                break
                        except Exception as e:
                            print("Something went wrong: baby videosu debug_img gözükmedi ", e)

    def live(self, consumer_q, debug_frame_q, cropped_raw_frame_q):
        img = None
        global focus_bounding_box
        global classifier_resolution
        while True:
            if len(consumer_q) > 0:
                try:
                    img = consumer_q.pop() # consume image from queue
                except IndexError as e:
                    print('No images in queue: ', e)
                    continue

                # print('img: ', img)
                # bounds to actual run models/analysis on...no need to look for babies outside of the crib
                x = 450
                y = 100
                h = 850
                w = 700
                #x = focus_bounding_box[0]
                #y = focus_bounding_box[1]
                #w = focus_bounding_box[2]
                #h = focus_bounding_box[3]

                if img.shape[0] > 1080 and img.shape[1] > 1920: # max res 1080p
                    # img = maintain_aspect_ratio_resize(img, width=self.frame_dim[0], height=self.frame_dim[1])
                    img, _dim = maintain_aspect_ratio_resize(img, width=self.frame_dim[0], height=self.frame_dim[1])

                if x is None:
                    cropped_raw_frame_q.append(img)
                    print('Bounds not set, not running AI logic.,kenanke')
                    continue

                img_to_process = img[y:y+h, x:x+w]
                og_cropped_dims = img_to_process.shape
                # print('og dims: ', og_cropped_dims)

                # print('img_to_process: ', img_to_process)
                # tmp_img = maintain_aspect_ratio_resize2(img_to_process, .5)
                # tmp_img = maintain_aspect_ratio_resize(img_to_process, width=256)
                img_to_process, dim = maintain_aspect_ratio_resize(img_to_process, width=classifier_resolution)
                # print('shape: ', img_to_process.shape)
                # tmp_img = cv2.resize(img_to_process, (256, 256))
                cropped_raw_frame_q.append(img_to_process)
                # print('len: ', len(cropped_raw_frame_q))

                debug_img = self.frame_logic(img_to_process, img, debug_frame_q)
                # global model_sees_baby
                # global body_found
                # if model_sees_baby is not None:
                # if model_sees_baby is None:
                #     text = 'Pose detected'
                #     text_color = (255,0,0)
                # else:
                # if not body_found:
                #     text = 'Baby detected' if model_sees_baby else 'Baby not detected'
                #     text_color = (255,0,0) if model_sees_baby else (0,140,255)
                #     cv2.putText(debug_img, text, (int(0), int(debug_img.shape[1]) + 10), 1, 1, text_color, 2, 2)
                    # cv2.putText(img, text, (int(img.shape[0]/2) + 250, int(img.shape[1]/2)), 2, 3, text_color, 2, 2)

                # cv2.rectangle(img=img, pt1=(x, y), pt2=(x+w, y+h), color=[153,50,204], thickness=2)
                # tmp = img[y:y+h, x:x+w]
                # img = gamma_correction(img, .4)

                if self.multi_face_landmarks:
                    for face_landmarks in self.multi_face_landmarks:
                            # INDICIES: https://github.com/tensorflow/tfjs-models/blob/838611c02f51159afdd77469ce67f0e26b7bbb23/face-landmarks-detection/src/mediapipe-facemesh/keypoints.ts
                            # https://github.com/google/mediapipe/blob/master/mediapipe/python/solutions/face_mesh_connections.py
                            self.mpDraw.draw_landmarks(
                                image=debug_img,
                                landmark_list=face_landmarks,
                                connections=self.mpFace.FACEMESH_RIGHT_EYE,
                                landmark_drawing_spec=None,
                                connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=1, circle_radius=1))
                                # connection_drawing_spec=self.mpDrawStyles
                                # .get_default_face_mesh_contours_style())
                            self.mpDraw.draw_landmarks(
                                image=debug_img,
                                landmark_list=face_landmarks,
                                connections=self.mpFace.FACEMESH_LEFT_EYE,
                                landmark_drawing_spec=None,
                                connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 255, 0), thickness=1, circle_radius=1))
                                # connection_drawing_spec=self.mpDrawStyles
                                # .get_default_face_mesh_contours_style())

                            self.mpDraw.draw_landmarks(
                                image=debug_img,
                                landmark_list=face_landmarks,
                                connections=self.top_lip,
                                landmark_drawing_spec=None,#self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=2, circle_radius=2),
                                connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 150, 255), thickness=1, circle_radius=1))
                            self.mpDraw.draw_landmarks(
                                image=debug_img,
                                landmark_list=face_landmarks,
                                connections=self.bottom_lip,
                                landmark_drawing_spec=None,
                                connection_drawing_spec=self.mpDraw.DrawingSpec(color=(255, 255, 0), thickness=1, circle_radius=1))


print('Initializing...')
sleepy_baby = SleepyBaby(creepy_baby_model)
print('\nInitialization complete.')

def receive(producer_q):
    print("Start receiving frames.")
    cam_url = 'output_file.mp4'
    print(f"Connecting to camera at: {cam_url}")
    c = cv2.VideoCapture(cam_url)

    next_frame = 0
    fps = 30
    while(c.isOpened()):
        ret, img = c.read()
        if ret:
            producer_q.append(img)
        else:
            break



if __name__ == '__main__':
    sleepy_baby.recorded(debug_frame_q,cropped_raw_frame_q)