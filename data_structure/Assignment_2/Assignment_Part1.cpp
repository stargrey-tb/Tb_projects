
#include <iostream>
#pragma once
#include <fstream>
#include <stdio.h>

using namespace std;

template <class T>
class StackQueue {
public:
	int front, rear;
	T* list = new T[1024 * sizeof(T)]; // at least 1024 size of T

	int  count;
	StackQueue();
	void push_front(T);
	void push_rear(T);
	T pop_front();
	T pop_rear();
	T peek_front();
	void pop_item(StackQueue& sq, int& a);
	friend ostream& operator<<(ostream& os, const StackQueue<T>& a)  // for << operator to print an object of class
	{
		for (int i = 0; i < a.count; i++)
		{
			cout << a.list[i];
		}
		cout << endl;
		return os;
	}

};

template <class T>
StackQueue<T>::StackQueue() :front(0), rear(0), count(0) {

}

template <class T>
void StackQueue<T>::push_front(T item)       // push an item to the front then shift the list one to the right
{
	if (rear < 1023)
	{
		T* shifted_list = new T[1024 * sizeof(T)];
		for (int i = front; i < rear; i++)
		{
			shifted_list[i + 1] = list[i];
		}
		shifted_list[front] = item;
		count++;
		rear++;

		delete[] list;

		list = shifted_list;
	}
	else
		cout << "Maximum size exceeded" << endl;
}
template <class T>
void StackQueue<T>::push_rear(T item) {    // push an item to the rear of the list
	if (rear < 1023) {
		list[rear] = item;
		rear++;
		count++;
	}
	else
		cout << "Maximum size exceeded" << endl;
}

template <class T>
T StackQueue<T>::pop_front() {    // replace front item of the list with null
	T x = list[front];
	list[front] = '\0';
	front++;
	return x;					  // return the popped item
}

template <class T>
T StackQueue<T>::pop_rear() {     // replace rear item of the list with null
	T x = list[rear - 1];
	list[rear - 1] = '\0';
	rear--;
	return x;                    // return the popped item
}

template <class T>
T StackQueue<T>::peek_front() {
	return list[front];
}


template <class T>
void StackQueue<T>::pop_item(StackQueue& sq, int& a) {
	for (int i = sq.front; i < a; i++) {
		sq.list[i + 1] = sq.list[i];
	}
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class Maze {
private:
	char state[20][20]{};
	int curr_row, curr_col, targ_row, targ_col;
	int start_row, start_col;
	char orient, start_orient;
	StackQueue<char> solver;

public:

	Maze();

	bool can_move_left();
	bool can_move_right();
	bool can_move_forward();
	bool can_move_back();
	void move_left();
	void move_right();
	void move_forward();
	void move_back();
	void print_state();
	bool is_solved();
	void maze_solver();


};

Maze::Maze() {
	/* reading the maze from file */
	ifstream input_file; /* input file stream */
	input_file.open("input_maze.txt");

	int nrow, ncol; /* number of rows and columns */
	input_file >> nrow >> ncol; /* read the size from file */

	for (int i = 0; i < nrow; ++i) {
		for (int j = 0; j < ncol; ++j) {
			char x;
			input_file >> x;
			//cout << x << endl;
			state[i][j] = x;
			if (state[i][j] == 'W' || state[i][j] == 'N' || state[i][j] == 'E' || state[i][j] == 'S') {
				orient = state[i][j];
				start_orient = orient;
				curr_row = i;
				start_row = curr_row;           
				curr_col = j;                    // record current location of the robot with curr_row and curr_col
				start_col = curr_col;
			}
			if (state[i][j] == 'T') {
				targ_row = i;
				targ_col = j;					// record current location of the target with tar_row and tar_col
			}
		}
	}
	input_file.close();

}

bool Maze::can_move_left() {                     // if there is '.' or target it can move
	if (orient == 'W') {
		if (state[curr_row + 1][curr_col] == '.' || state[curr_row + 1][curr_col] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'N') {
		if (state[curr_row][curr_col - 1] == '.' || state[curr_row][curr_col - 1] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'E') {
		if (state[curr_row - 1][curr_col] == '.' || state[curr_row - 1][curr_col] == 'T')
			return true;
		else
			return false;
	}
	else if (orient == 'S') {
		if (state[curr_row][curr_col + 1] == '.' || state[curr_row][curr_col + 1] == 'T')
			return true;
		else
			return false;

	}

}
bool Maze::can_move_right() {						// if there is '.' or target it can move
	if (orient == 'W') {
		if (state[curr_row - 1][curr_col] == '.' || state[curr_row - 1][curr_col] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'N') {
		if (state[curr_row][curr_col + 1] == '.' || state[curr_row][curr_col + 1] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'E') {
		if (state[curr_row + 1][curr_col] == '.' || state[curr_row + 1][curr_col] == 'T')
			return true;
		else
			return false;
	}
	else if (orient == 'S') {
		if (state[curr_row][curr_col - 1] == '.' || state[curr_row][curr_col - 1] == 'T')
			return true;
		else
			return false;

	}

}

bool Maze::can_move_forward() {						// if there is '.' or target it can move

	if (orient == 'W') {
		if (state[curr_row][curr_col - 1] == '.' || state[curr_row][curr_col - 1] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'N') {
		if (state[curr_row - 1][curr_col] == '.' || state[curr_row - 1][curr_col] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'E') {
		if (state[curr_row][curr_col + 1] == '.' || state[curr_row][curr_col + 1] == 'T')
			return true;
		else
			return false;
	}
	else if (orient == 'S') {
		if (state[curr_row + 1][curr_col] == '.' || state[curr_row + 1][curr_col] == 'T')
			return true;
		else
			return false;

	}

}

bool Maze::can_move_back() {								// if there is '.' or target it can move
	if (orient == 'W') {	
		if (state[curr_row][curr_col + 1] == '.' || state[curr_row][curr_col + 1] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'N') {
		if (state[curr_row + 1][curr_col] == '.' || state[curr_row + 1][curr_col] == 'T')
			return true;
		else
			return false;
	}

	else if (orient == 'E') {
		if (state[curr_row][curr_col - 1] == '.' || state[curr_row][curr_col - 1] == 'T')
			return true;
		else
			return false;
	}
	else if (orient == 'S') {
		if (state[curr_row - 1][curr_col] == '.' || state[curr_row - 1][curr_col] == 'T')
			return true;
		else
			return false;

	}

}

void Maze::move_left() {						// if robot can turn left, turn left
	if (can_move_left()) {

		if (orient == 'W') {
			orient = 'S';
			state[curr_row][curr_col] = '.';
			state[curr_row + 1][curr_col] = orient;
			curr_row++;
		}

		else if (orient == 'N') {
			orient = 'W';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col - 1] = orient;
			curr_col--;
		}

		else if (orient == 'E') {
			orient = 'N';
			state[curr_row][curr_col] = '.';
			state[curr_row - 1][curr_col] = orient;
			curr_row--;
		}

		else if (orient == 'S') {
			orient = 'E';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col + 1] = orient;
			curr_col++;

		}



	}
	else
		cout << "Invalid move left" << endl;

}
void Maze::move_right() {
	if (can_move_right()) {
		if (orient == 'W') {
			orient = 'N';
			state[curr_row][curr_col] = '.';
			state[curr_row - 1][curr_col] = orient;
			curr_row--;
		}

		else if (orient == 'N') {
			orient = 'E';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col + 1] = orient;
			curr_col++;
		}

		else if (orient == 'E') {
			orient = 'S';
			state[curr_row][curr_col] = '.';
			state[curr_row + 1][curr_col] = orient;
			curr_row++;
		}

		else if (orient == 'S') {
			orient = 'W';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col - 1] = orient;
			curr_col--;
		}



	}
	else
		cout << "Invalid move right" << endl;
}
void Maze::move_forward() {
	if (can_move_forward()) {
		if (orient == 'W') {
			orient = 'W';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col - 1] = orient;
			curr_col--;
		}

		else if (orient == 'N') {
			orient = 'N';
			state[curr_row][curr_col] = '.';
			state[curr_row - 1][curr_col] = orient;
			curr_row--;
		}

		else if (orient == 'E') {
			orient = 'E';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col + 1] = orient;
			curr_col++;
		}

		else if (orient == 'S') {
			orient = 'S';
			state[curr_row][curr_col] = '.';
			state[curr_row + 1][curr_col] = orient;
			curr_row++;
		}


	}
	else
		cout << "Invalid move forward" << endl;
}
void Maze::move_back() {
	if (can_move_back()) {
		if (orient == 'W') {
			orient = 'E';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col + 1] = orient;
			curr_col++;
		}

		else if (orient == 'N') {
			orient = 'S';
			state[curr_row][curr_col] = '.';
			state[curr_row + 1][curr_col] = orient;
			curr_row++;
		}

		else if (orient == 'E') {
			orient = 'W';
			state[curr_row][curr_col] = '.';
			state[curr_row][curr_col - 1] = orient;
			curr_col--;
		}

		else if (orient == 'S') {
			orient = 'N';
			state[curr_row][curr_col] = '.';
			state[curr_row - 1][curr_col] = orient;
			curr_row--;
		}


	}
	else
		cout << "Invalid move back" << endl;
}

void Maze::print_state() {
	for (int i = 0; i < 20; i++) {
		for (int j = 0; j < 20; j++) {
			cout << state[i][j];

		}
		cout << endl;

	}
}

bool Maze::is_solved() {
	if (curr_row == targ_row && curr_col == targ_col) {
		return true;
	}
	else
		return false;
}

void Maze::maze_solver() {
	while (!is_solved())
	{
		if (can_move_left())
		{

			if (can_move_left() && solver.list[solver.rear - 1] == 'B') {			//control the stackqueue according to the regulations

				if (solver.list[solver.rear - 2] == 'L') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('F');
				}
				else if (solver.list[solver.rear - 2] == 'F') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('R');
				}
				else if (solver.list[solver.rear - 2] == 'R') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('B');
				}

			}
			else
				solver.push_rear('L');

			cout << solver;
			move_left();
			print_state();
		}
		else if (can_move_forward())
		{

			if (!can_move_left() && can_move_forward() && solver.list[solver.rear - 1] == 'B') {

				if (solver.list[solver.rear - 2] == 'L') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('R');
				}
				else if (solver.list[solver.rear - 2] == 'F') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('B');
				}

			}
			else
				solver.push_rear('F');

			cout << solver;
			move_forward();
			print_state();
		}
		else if (can_move_right())
		{

			if (!can_move_left() && !can_move_forward() && can_move_right() && solver.list[solver.rear - 1] == 'B') {

				if (solver.list[solver.rear - 2] == 'L') {
					solver.pop_rear();
					solver.pop_rear();
					solver.push_rear('B');
				}

			}
			else
				solver.push_rear('R');

			cout << solver;
			move_right();
			print_state();
		}

		else if (!can_move_left() && !can_move_forward() && !can_move_right()) {
			move_back();
			solver.push_rear('B');
			cout << solver;
			print_state();
		}

	}
	cout << "Second pass:" << endl;									// Second pass by using the stackqueue
	state[curr_row][curr_col] = 'T';
	curr_row = start_row;
	curr_col = start_col;
	state[start_row][start_col] = start_orient;
	cout << solver;
	print_state();

	while (solver.rear != solver.front) {
		if (solver.list[solver.front] == 'L') {
			move_left();
			solver.pop_front();
			cout << solver;
			print_state();
		}
		else if (solver.list[solver.front] == 'R') {
			move_right();
			solver.pop_front();
			cout << solver;
			print_state();
		}
		else if (solver.list[solver.front] == 'F') {
			move_forward();
			solver.pop_front();
			cout << solver;
			print_state();
		}
		else if (solver.list[solver.front] == 'B') {
			move_back();
			solver.pop_front();
			cout << solver;
			print_state();
		}
	}

}




int main(void) {

	Maze B;
	B.maze_solver();


}

