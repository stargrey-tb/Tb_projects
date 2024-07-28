#include <string>
#include <cstdlib>
#include <iostream>
#include <math.h>
#include <chrono>
#include <fstream>
using namespace std;


class Matrix {
public:
    long long hash_value;
    int data[20][20];           // NxN matrix
    int N;
    Matrix();
    Matrix(int x1, int x2);     // for reading matrix from file
    Matrix(int);
    void setter(int row, int col, int val);
    int getter(int row, int col);
    void print();
    int hash_funct();

    bool operator==(const Matrix& A) {              // == operator overload for matrix comparison
        if (A.N==N) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {
                    if (A.data[i][j] != data[i][j])
                        return false;
                }
            }
            return true;
        }
        else
            return false;

    }
    bool operator<(const Matrix& A) {               // < operator overload for matrix comparison
        bool x = false;
        if (N < A.N)
            return true;
        else if (N == A.N) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {
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

    void operator= (const Matrix& other)            // to transfer one matrix to another overload operator=
    {

        for (int i = 0; i < other.N; i++) {
            for (int j = 0; j < other.N; j++) {
                this->data[i][j] = other.data[i][j];
            }
        }
        N = other.N;
        hash_value = other.hash_value;
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
        for (int j = 0; j < a; j++) {
            if (i == j)
                data[i][j] = 1;
            else
                data[i][j] = 0;
        }
    }


}

void Matrix::setter(int row, int col, int val) {        // set data[row][col] with given value

    data[row][col] = val;
}

int Matrix::getter(int row, int col) {       // get data[row][col]

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
   
    long long det = 0, p, h, k, i, j;
    Matrix temp;

    if (n == 1)
    {
        return a.data[0][0];
        // dterminant of 1x1 matrix
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

int Matrix::hash_funct() {          // hash  function to calculate hash value 
    hash_value = N;
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N;j++ ) {
            hash_value = ((61 * hash_value) + data[i][j])% 65536;       // hash value formula
        }
    }
    return hash_value% 65536;
}

class HT_Item
{
public:
    Matrix key;
    long value;
    HT_Item();
    HT_Item(Matrix a, long b);
};

HT_Item::HT_Item() {        // constructor
    key = NULL;
    value = NULL;
}

HT_Item::HT_Item(Matrix a, long b) {    // constructor for assigning given values
    key = a;
    value = b;
}

class hash_table {              // identify new class for hash table
public:
    HT_Item* table[65536];      // size 65536
    bool key_exists(Matrix A);
    long search(Matrix A);
    void insert(Matrix A, long detA);
    hash_table();
    void print();

};

hash_table::hash_table() {          // constructor assigns NULL to array firstly 
    for (int i = 0; i < 65536; i++)
        table[i] = NULL;
}

bool hash_table::key_exists(Matrix A) {
    int i = A.hash_funct();
    if (table[i] == NULL)   
        return false;
    if (table[i]->key == A)          // chech first hash value
        return true;
    else if (table[i] == NULL)
        return false;
    for (int j = i + 1; j % 65536 != i; j++) {      // if there is collision check linearly
        if (table[j] == NULL)                       // if empty is found search fails 
            return false;
        else if (table[j]->key == A)                // input matrix is found, then search is successful
            return true;
         
    }
    return false;
}

long hash_table::search(Matrix A) {     // same principle with key_exists function
     if (key_exists(A)) {
        int i = A.hash_funct();
        if (table[i] == NULL)
            return -1;
        if (table[i]->key == A)
            return table[i]->value;

        for (int j = i + 1; j % 65536 != i; j++) {
            if (table[j]->key == A)
                return table[j]->value;
        }
        return -1;
    }
    else
        return -1;

}

void hash_table::insert( Matrix A, const long detA) {
    int count = 0;
    HT_Item* temp = new HT_Item(A, detA);       // insert HT_Item pointer to hash table array
                                    
    int i = A.hash_funct();         
    if (count != 65536) {
        if (table[i] == NULL) {
            table[i] = temp;
            count++;
        }

        else {
            while (table[i] != NULL) {
                i++;
            }
            table[i] = temp;
            count++;
        }
            
    }
    else
        cout << "Table is full" << endl;
}

void hash_table::print() {
    for (int i = 11245; i < 65536; i++) {
        if (table[i] != NULL)
        {
            cout <<"At "<< i << " : "<<table[i]->value << endl;
            
        }
    }

    
}

int main()
{
  /*  hash_table x;
    Matrix a(4);                                
    a.setter(0, 2, 7);                      
    a.setter(1, 3, 4);
    a.setter(2, 0, 3);
    Matrix b(3);
    Matrix c(2);
    Matrix d(4);
    b.setter(0, 2, 7);
    b.setter(0, 0, 4);
    c.setter(1, 0, 3);
    c.setter(0, 0, 6);
    cout << determ(a, a.N) << endl;
    cout << determ(b, b.N) << endl;
    cout << determ(c, c.N) << endl;
    cout << "Print table" << endl;
    long boom = determ(a, a.N);
    x.insert(a, boom);
    long k = determ(b, b.N);                                                                     // to test functions run correctly
    x.insert(b, k);
    long l = determ(c, c.N);
    x.insert(c, l);                                                                          
    x.print();*/                                            
    


    

     /*Matrix a(5,3);
     HT_Item y(a, determ(a, a.N));                                                              // to test average memory usage
     cout << "Size of one HT_Item : " << sizeof(y) / 1024 << " kb" << endl;*/




    /* Matrix a(5, 3);
    cout << "Matrix:" << endl;
    a.print();                                                                                           // to test average time 
    std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
    cout <<"Determinant : " << determ(a, a.N) << endl;
    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
    std::cout << "execution time = " << std::chrono::duration_cast<std::chrono::seconds>(end - begin).count() << "[sec]" << std::endl;*/

    
    


    // Run time gets too long if 3 test are not run separately


}