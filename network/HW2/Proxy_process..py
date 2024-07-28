import json
import socket
import threading
import time

class SimpleProxyServer:
    def __init__(self, host, port, size_of_cache):
        self.host = host
        self.port = port
        self.size_of_cache = size_of_cache
        self.cache_data = {
            "Entry0": "Datadirectory0",
            "Entry1": "Datadirectory1",
            "Entry2": "Datadirectory2",
            "Entry3": "Datadirectory3",
            "Entry4": "Datadirectory4"
        }
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        print(f"Proxy server is running on {self.host}:{self.port}")
        self.server_socket.listen(5)                

    def request_response(self, conn) :
        while 1:
            try:
                dataReceived = conn.recv(1024)
            except OSError:
                print (clientAddress, 'disconnected')
                self.server_socket.listen(5)
                conn, clientAddress = self.server_socket.accept()
                time.sleep(0.4)
                print ('Connected by',clientAddress)
                
            print("Data Initial: ")
            print(dataReceived)
            dataReceived = dataReceived.decode('utf-8')
            print("Data decoded:")                                  
            print(dataReceived)
            response = self.process_request(dataReceived)
            if response:
                conn.sendall(response.encode('utf-8'))
        conn.close()

    def start (self) :
        while 1:
            client_socket, client_address = self.server_socket.accept()
            print("Client address is:", client_address)
            client_thread = threading.Thread(target=self.request_response, args=(client_socket, ))
            save_thread = client_thread
            save_thread.start()

    def process_request(self, data_requested):
        parts = data_requested.split()
        op_code = parts[0].rstrip(";") 

        print("OPCODE:", op_code, "REQUEST:", data_requested)
        directory, input = None, None

        for part in parts[1:]:
            if part.startswith("INDEX="):
                 directory= part.split("=")[1].rstrip(";").strip()
            elif part.startswith("DATA="):
                input= part.split("=")[1].strip(";")

        if op_code == "GET":
            return self.get_function(directory)
        elif op_code == "SET":
            return self.set_function(directory, input)
        elif op_code == "RESET":
            return self.reset_function(input)
        elif op_code == "EVICT":
            return self.evict_function(directory)
        else:
            return "opcode not recognized"

    def set_function(self, directory, data):
        self.cache_data[directory] = data
        if len(self.cache_data) > self.size_of_cache:
            self.cache_data.popitem(last=False)

        print(f"SET requested in the directory={directory} and Data correspond to: {data}")
        return "OK;"

    def get_function(self, directory):
        if directory in self.cache_data:
            print(f"GET requested in the directory={directory} and found in cache. Data correspond to: {self.cache_data[directory]}")
            return f"OK directory={directory} DATA={self.cache_data[directory]};"
        else:
            print(f"GET requested in the directory={directory} and not found in cache.")
            return None  

    def evict_function(self, directory=None):
        if directory:
            if directory in self.cache_data:
                del self.cache_data[directory]
                print(f"EVICT requested in the directory={directory} data evicted from cache.")
        else:
            self.cache_data.clear()
            print(f"EVICT requested and cache will cleared.")
        return "OK;"

    def reset_function(self, data):
        if data:
            self.cache_data.clear()
            print(f"RESET requested and cache will be cleared.")
            return "OK;"
        else:
            self.cache_data = {}
            print(f"RESET requested and cache will be reset.")
            return "OK;"

HOST_IP= '127.0.0.1'
PROXY_PORT= 2845
CACHE_SIZE= 5

proxy_server = SimpleProxyServer(HOST_IP, PROXY_PORT, CACHE_SIZE )
proxy_server.start()
