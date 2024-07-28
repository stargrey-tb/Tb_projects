import numpy as np
import matplotlib.pyplot as plt
from utils import plot_value_function, plot_policy  # Importing utility functions

class MazeEnvironment:
    def __init__(self):
        # Define the maze layout, rewards, action space (up, down, left, right)
        self.maze = np.array([
        [0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1],
        [0, 0, 0, 0, 1, 1, 0, 2, 0, 0, 1],
        [0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0],
        [0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 3],
        [0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0],
        [1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0],
        [1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0],
        [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
        ])
        self.start_pos = (0, 0)  # Start position of the agent
        self.current_pos = self.start_pos
        self.state_penalty = -1
        self.trap_penalty = -100
        self.goal_reward = 100
        self.actions = {0: (-1, 0), 1: (1, 0), 2: (0, -1), 3: (0, 1)}
        
        # Rewards matrix
        self.rewards = np.full(self.maze.shape, self.state_penalty, dtype=np.float32)
        self.rewards[5, 10] = self.goal_reward  # Goal
        self.rewards[1, 7] = self.trap_penalty  # Traps
        self.rewards[6, 5] = self.trap_penalty
        self.goal_pos = (5, 10)  # Define the goal position

    def reset(self):
        self.current_pos = self.start_pos
        return self.current_pos
    
    def step(self, action):
        move = self.actions[action]
        new_pos = (self.current_pos[0] + move[0], self.current_pos[1] + move[1])
        
        if new_pos[0] < 0 or new_pos[0] >= self.maze.shape[0] or new_pos[1] < 0 or new_pos[1] >= self.maze.shape[1] or self.maze[new_pos] == 1:
            # If hit the wall or move out of bounds, stay in the current position
            new_pos = self.current_pos
        
        self.current_pos = new_pos
        reward = self.rewards[new_pos]
        done = new_pos == self.goal_pos
        
        return new_pos, reward, done

class MazeTD0(MazeEnvironment):  # Inherited from MazeEnvironment
    def __init__(self, alpha=0.1, gamma=0.95, epsilon=0.2, episodes=10000):
        super().__init__()
        self.alpha = alpha  # Learning Rate
        self.gamma = gamma  # Discount factor
        self.epsilon = epsilon  # Exploration Rate
        self.episodes = episodes
        self.utility = np.zeros_like(self.maze, dtype=np.float32)  # Initialize utility values with zeros

    def choose_action(self, state):
        if np.random.rand() < self.epsilon:
            # Exploration: Choose a random action
            return np.random.choice(list(self.actions.keys()))
        else:
            # Exploitation: Choose the best action based on current utility values
            possible_actions = list(self.actions.keys())
            action_values = []
            for move in self.actions.values():
                new_pos = (state[0] + move[0], state[1] + move[1])
                if 0 <= new_pos[0] < self.maze.shape[0] and 0 <= new_pos[1] < self.maze.shape[1]:
                    action_values.append(self.utility[new_pos])
                else:
                    action_values.append(-np.inf)  # Set a very low value for invalid moves
            best_action = possible_actions[np.argmax(action_values)]
            return best_action

    def update_utility_value(self, current_state, reward, new_state):
        current_value = self.utility[current_state]
        
        # Calculate next_value only for valid moves
        next_value = max(
            [self.utility[(new_state[0] + move[0], new_state[1] + move[1])] 
             for move in self.actions.values() 
             if 0 <= new_state[0] + move[0] < self.maze.shape[0] and 0 <= new_state[1] + move[1] < self.maze.shape[1]], 
            default=0
        )
        
        new_value = current_value + self.alpha * (reward + self.gamma * next_value - current_value)
        self.utility[current_state] = new_value

    def run_episodes(self):
        convergence_data = []
        for episode in range(self.episodes):
            self.epsilon = max(0.1, self.epsilon * 0.99)  # Decay epsilon over time
            state = self.reset()
            done = False
            previous_utility = self.utility.copy()
            while not done:
                action = self.choose_action(state)
                next_state, reward, done = self.step(action)
                self.update_utility_value(state, reward, next_state)
                state = next_state
            # Calculate the sum of absolute differences between the utility values of successive iterations
            convergence_data.append(np.sum(np.abs(self.utility - previous_utility)))
        return self.utility, convergence_data

class MazeQLearning(MazeEnvironment):  # Inherited from MazeEnvironment
    def __init__(self, alpha=0.1, gamma=0.95, epsilon=0.2, episodes=2, max_steps_per_episode=1000):
        super().__init__()
        self.alpha = alpha  # Learning Rate
        self.gamma = gamma  # Discount factor
        self.epsilon = epsilon  # Exploration Rate
        self.episodes = episodes
        self.max_steps_per_episode = max_steps_per_episode  # Max steps per episode to prevent infinite loops
        self.q_table = np.zeros((*self.maze.shape, len(self.actions)), dtype=np.float32)  # Initialize Q-table with zeros

    def choose_action(self, state):
        if np.random.rand() < self.epsilon:
            # Exploration: Choose a random action
            return np.random.choice(list(self.actions.keys()))
        else:
            # Exploitation: Choose the best action based on current Q values
            state_q_values = self.q_table[state[0], state[1]]
            return np.argmax(state_q_values)

    def update_q_table(self, current_state, action, reward, new_state):
        current_q = self.q_table[current_state[0], current_state[1], action]
        max_future_q = np.max(self.q_table[new_state[0], new_state[1]])
        new_q = current_q + self.alpha * (reward + self.gamma * max_future_q - current_q)
        self.q_table[current_state[0], current_state[1], action] = new_q

    def run_episodes(self):
        for episode in range(self.episodes):
            self.epsilon = max(0.1, self.epsilon * 0.99)  # Decay epsilon over time
            state = self.reset()  # Reset the agent's position at each episode start
            done = False
            steps = 0
            while not done and steps < self.max_steps_per_episode:
                action = self.choose_action(state)
                next_state, reward, done = self.step(action)
                self.update_q_table(state, action, reward, next_state)
                state = next_state
                steps += 1
            # Debug: Print Q values at specific intervals
            if episode % 1000 == 0:
                print(f"Episode {episode}, Q-Table:\n", self.q_table)
        return self.q_table
      
env = MazeEnvironment()


maze_td0 = MazeTD0(alpha=0.1, gamma=0.95, epsilon=0.2, episodes=1000)
final_values, convergence_data = maze_td0.run_episodes()


#maze_q_learning = MazeQLearning(alpha=0.1, gamma=0.95, epsilon=0.2, episodes=2, max_steps_per_episode=10000)
#final_q_table = maze_q_learning.run_episodes()
#final_values = np.max(final_q_table, axis=2)

print("Final Utility Values:\n", final_values)

plot_value_function(final_values, env.maze)
plot_policy(final_values, env.maze)

# Plot convergence
plt.plot(convergence_data)
plt.xlabel('Episodes')
plt.ylabel('Sum of Absolute Differences')
plt.title('TD(0) Learning Convergence')
plt.show()