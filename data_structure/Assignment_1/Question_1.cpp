#include <iostream>
#include "matrix.cpp"


int main() {
    Matrix<3> m1{};
    Matrix<3> m2{};
    m1.set_element(2, 2, 5);
    m1.set_element(1, 1, 3);
    m1.set_element(1, 0, 2);
    m1.set_element(0, 1, 4);
    std::cout << " First Matrix : "<<std::endl;
    m1.print();
    std::cout << std::endl;

    m2.set_element(2, 2, 3);
    m2.set_element(1, 1, 1);
    m2.set_element(1, 0, 4);
    m2.set_element(0, 1, 6);
    Matrix<3> m3{ addition(m1,m2) };
    std::cout << " Second Matrix : " << std::endl;
    m2.print();
    std::cout << std::endl;
    std::cout << " Addition : "<<std::endl;
    m3.print();

}