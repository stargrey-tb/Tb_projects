#include <string>
#include <cstdlib>
#include <iostream>
#include <math.h>
#include <chrono>
#include <fstream>
using namespace std;

class Matrix {
public:
    int data[20][20];
    int N;              // NxN matrix
    Matrix();
    Matrix(int x1, int x2); // for reading matrix from file 
    Matrix(int);
    void setter(int row, int col, int val);
    int getter(int row, int col);
    void print();

    bool operator==(const Matrix& A) {      // == operator overload for matrix comparison
        if (N == A.N) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {
                    if (A.data[i][j] != data[i][j])     // check each element
                        return false;
                }
            }
            return true;           // if all elements are equal return true
        }
        else
            return false;       // else return false

    }
    bool operator<(const Matrix& A) {       // < operator overload for matrix comparison
        bool x = false;
        if (N < A.N)            // first check matrix size
            return true;
        else if (N == A.N) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {           // then check elements' magnitude
                    if (data[i][j] > A.data[i][j])
                        return false;
                    else if (data[i][j] != A.data[i][j])
                        x = true;
                }
            }
            if (x == true)
                return true;
        }
        else
            return false;
    }
    void operator= (const Matrix& other)        // to transfer one matrix to another overload operator=
    {
        
        for (int i = 0; i < other.N; i++) {
            for (int j = 0; j < other.N; j++) {
                this->data[i][j] = other.data[i][j];        // transfer each element 
            }
        }
        N = other.N;
    }
};

Matrix::Matrix() {                      //constructor with no input
    for (int i = 0; i < 20; i++)
        for (int j = 0; j < 20; j++)
            data[i][j] = 0;
    N = 0;
}

Matrix::Matrix(int x1, int x2) {      // constructor for read from file
    // you need to enter two random integer to read from file

    ifstream input_file; /* input file stream */
    input_file.open("0.txt");
    if (!input_file.is_open()) {
        cout << "file could not be opened" << endl;
        exit(1);
    }
    for (int i = 0; i < 11; ++i) {
        for (int j = 0; j < 11; ++j) {
            input_file >> data[i][j];
        }
    }
    input_file.close();
    N = 11;     // change in every folder

}

Matrix::Matrix(int a) {     // another constructor with one integer input
    N = a;
    for (int i = 0; i < a; i++)
    {
        for (int j = 0; j < a; j++) {   // size is equal to input
            if (i == j)
                data[i][j] = 1;         // identity matrix
            else
                data[i][j] = 0;
        }
    }


}

void Matrix::setter(int row, int col, int val) {    // set data[row][col] with given value

    data[row][col] = val;
}

int Matrix::getter(int row, int col) {      // get data[row][col]

    return data[row][col];
}

void Matrix::print()        // print function for test
{
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            std::cout << data[i][j] << " ";
        }
        std::cout << std::endl;
    }
}
long determ(Matrix a, int n) {
    int det = 0, p, h, k, i, j;
    Matrix temp;

    if (n == 1)
    {
        return a.data[0][0];
        // determinant of 1x1 matrix
    }
    else if (n == 2)
    {
        det = (a.data[0][0] * a.data[1][1] - a.data[0][1] * a.data[1][0]);
        // determinant of 2x2 matrix
        return det;
    }
    else
    {
        for (p = 0; p < n; p++)
        {
            h = 0;
            k = 0;
            for (i = 1; i < n; i++)
                // examine all elements of each row
            {
                for (j = 0; j < n; j++)
                {
                    if (j == p)
                    {
                        continue;
                    }
                    // divide the matrix into submatrices
                    temp.setter(h, k, a.data[i][j]);
                    k++;
                    // then increase the column
                    if (k == n - 1)
                    {
                        h++;
                        k = 0;
                        // at the end column, reset k
                    }
                }
            }
            det = det + a.data[0][p] * pow(-1, p) * determ(temp, n - 1);
            // add all (0, p) elements and multplied by their submatrix determinants together
        }
        return det;
    }
}

class BST_Node
{
public:
    BST_Node* left;
    BST_Node* right;
    BST_Node();
    BST_Node(Matrix a, long b);
    // Determinant of key matrix is value
    Matrix key;
    long value;
    bool key_exists(BST_Node* x, Matrix A);
    long search(BST_Node* x, Matrix A);
    long det_funct(BST_Node* x, Matrix M);
    bool operator<(const BST_Node A) {          // overload operator< for BST_Node class
        if (key < A.key)                        // comparison matrix of each node
            return true;
        else
            return false;
    }

};

BST_Node::BST_Node() {          // constructor assignss null values
    left = NULL;
    right = NULL;
    value = 0;
    key = NULL;
}

BST_Node::BST_Node(Matrix a, long b) {      // constructor assigns for given values
    left = NULL;
    right = NULL;
    key = a;
    value = b;

}

bool BST_Node::key_exists(BST_Node* x, Matrix A) {
    if (x->key == A)                                    // check given matrix is equal to current node
        return true;
    else if (right == NULL && x->key < A)                // if right is NULL and input matrix is greater than current matrix, search fail
        return false;
    else if (left == NULL && A < x->key)               // if left is NULL and input matrix is smaller than current matrix, search fail
        return false;
    else if (x->key < A)                                // input matrix is greater than current matrix, go right
        key_exists(x->right, A);
    else if (A < x->key)                                // input matrix is smaller than current matrix, go left
        key_exists(x->left, A);
}

long BST_Node::search(BST_Node* x, Matrix A) {
    if (x->key == A)                                    // same principle with key_exists
        return x->value;
    else if (right == NULL && x->key < A)
        return 0;
    else if (left == NULL && A < x->key)
        return 0;
    else if (x->key < A)
        search(x->right, A);
    else if (A < x->key)
        search(x->left, A);
}

void insert(BST_Node* x, Matrix A, long detA) {
    BST_Node* new_node_p = new BST_Node (A, detA);

    if (x->key == A) {
        x->value = detA;
        return;
    }
    else if (x->left == NULL && A < x->key) {
        x->left = new_node_p;
        return;
    }

    else if (x->right == NULL && x->key < A) {
        x->right = new_node_p;
        return;
    }

    else if (x->key < A)
        insert(x->right, A, detA);

    else if (A < x->key)
        insert(x->left, A, detA);

}

long BST_Node::det_funct(BST_Node* x, Matrix M) {           
    if (key_exists(x, M))
        return search(x, M);
    else {
        long a = determ(M, M.N);            // by using cofactor methode (determ function) given above 
        insert(x, M, a);
        return a;                           // return determinant
    }

}
void print(BST_Node* x) {                   // print binary search tree to control the code
    if (x == NULL)
        return;
    if (x->left != NULL)
    print(x->left);
    cout << x->value << endl;
    if (x->right != NULL)
    print(x->right);
}
int main()
{
    //Matrix a(4);
    //a.setter(0, 2, 7);
    //a.setter(1, 3, 4);
    //a.setter(2, 0, 3);
    //Matrix b(3);
    //Matrix c(2);
    //Matrix d(4);
    //Matrix e(3);
    //b.setter(0, 2, 7);
    //b.setter(0, 0, 4);
    //c.setter(1, 0, 3);
    //c.setter(0, 0, 6);                                      // to check functions run correctly
    //BST_Node x(a, determ(a, a.N));
    //BST_Node y(b, determ(b, b.N));
    //BST_Node z(c, determ(c, c.N));
    //BST_Node w(d, determ(d, d.N));

    //BST_Node* p1 = &x;
    //BST_Node* p2 = &y;
    //BST_Node* p3 = &z;
    //BST_Node* p4 = &w;

    //cout << determ(a, a.N) << endl;
    //cout << determ(b, b.N) << endl;
    //cout << determ(c, c.N) << endl;

    //insert(p1, a, determ(a, a.N));
    //insert(p1, b, determ(b, b.N));
    //insert(p1, c, determ(c, c.N));
    //insert(p1, d, determ(d, d.N));
    //insert(p1, e, determ(e, e.N));
    //
    //cout << "Size of one BST_Node : " << sizeof(x) / 1024 << " kb" << endl;



   

}

