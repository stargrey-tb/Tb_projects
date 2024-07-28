#include <iostream>
#include <math.h>

template <int N>
class Matrix
{
private:
    double data[N][N];
    bool check_boundary_conditions(int row, int col) const;

public:
    int const SIZE = N;
    Matrix();
    void set_element(int row, int col, double val);
    double get_element(int row, int col) const;
    void fill(int x);
    void print();
};

template <int N>
Matrix<N>::Matrix()
{ // matrix consturctor
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            if (i == j)
                data[i][j] = 1.0;
            // identity matrix is assigned
            else
                data[i][j] = 0.0;
            // other entires are assigned to 0
        }
    }
}
template <int N>
void Matrix<N>::print()
{ // print function for test
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            std::cout << data[i][j] << " ";
        }
        std::cout << std::endl;
    }
}

template <int N>
bool Matrix<N>::check_boundary_conditions(int row, int col) const
{
    // checks whether entered inputs are in the range
    if (row >= N || row < 0)
    {
        std::cout << "Row invalid" << std::endl;
        return true;
    }
    if (col >= N || col < 0)
    {
        std::cout << "Col invalid" << std::endl;
        return true;
    }
    // row and column must be smaller than N, larger than 0
    return false;
}

template <int N>
void Matrix<N>::set_element(int row, int col, double val)
{
    if (check_boundary_conditions(row, col))
        // check whether row and col are valid
    {
        return;
    }
    data[row][col] = val;
    // if they are valid, assign to data matrix
}

template <int N>
double Matrix<N>::get_element(int row, int col) const
{
    if (check_boundary_conditions(row, col))
        // check whether row and col are valid
    {

        return -99999.;
    }
    return data[row][col];
}

template <int N>
void Matrix<N>::fill(int x)
{
    // fills the matrix with x
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            data[i][j] = x;
        }
    }
}

template <int N>
Matrix<N> multiplication(Matrix<N> mat1, Matrix<N> mat2)
{ // multiplication
    Matrix<N> result;
    result.fill(0);
    for (int i = 0; i < N; ++i)
    {
        // for row of result matrix
        for (int j = 0; j < N; ++j) {
            // for column of result matrix
            for (int k = 0; k < N; ++k)
            {
                result.set_element(i, j, mat1.get_element(i, k) * mat2.get_element(k, j) + result.get_element(i, j));
            }
        }
    }
    return result;
}
template <int N>
Matrix<N> addition(Matrix<N> mat1, Matrix<N> mat2)
{ // addition
    Matrix<N> result;
    result.fill(0);
    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)

        {
            // add same indice elements
            result.set_element(i, j, mat1.get_element(i, j) + mat2.get_element(i, j));
        }
    }
    return result;
}
template <int N>
Matrix<N> subtraction(Matrix<N> mat1, Matrix<N> mat2)
{ // subtraction
    Matrix<N> result;
    result.fill(0);

    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)

        {
            // subtract same indice elements
            result.set_element(i, j, mat1.get_element(i, j) - mat2.get_element(i, j));
        }
    }
    return result;
}
template <int N>
int determ(Matrix<N> a, int n)
{
    int det = 0, p, h, k, i, j;
    Matrix<N> temp;

    if (n == 1)
    {
        return a.get_element(0, 0);
        // dterminant of 1x1 matrix
    }
    else if (n == 2)
    {
        det = (a.get_element(0, 0) * a.get_element(1, 1) - a.get_element(0, 1) * a.get_element(1, 0));
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
                    temp.set_element(h, k, a.get_element(i, j));
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
            det = det + a.get_element(0, p) * pow(-1, p) * determ(temp, n - 1);
            // add all (0, p) elements and multplied by their submatrix determinants together
        }
        return det;
    }
}



