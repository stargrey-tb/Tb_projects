
#include <iostream>

using namespace std;




#include <iostream>
#include <fstream>
#include <stdio.h>
#include <iostream>
using namespace std;

template <class T>
class Node
{
public:
    T data;
    Node(T item);
    Node();

    Node<T>* xnode;
};

template <class T>
Node<T>::Node(T item) {
    xnode = NULL;
    data = item;
}

template <class T>
Node<T>::Node() {

}

template <class T>
Node<T>* Xor(Node<T>* x, Node<T>* y)
{
    return reinterpret_cast<Node<T>*>(
        reinterpret_cast<uintptr_t>(x)
        ^ reinterpret_cast<uintptr_t>(y));
}

template <class T>
void insert(Node<T>*& head_ref, T data)
{
    Node<T>* new_node = new Node<T>();
    new_node->data = data;

    new_node->xnode = head_ref;
    if (head_ref != NULL)
    {

        head_ref->xnode = Xor(new_node, head_ref->xnode);
    }

    head_ref = new_node;
}

template <class T>
void print_elements(Node<T>* head) {
    Node<T>* currPtr = head;
    Node<T>* prevPtr = NULL;
    Node<T>* nextPtr;

    cout << "The nodes of Linked List are: \n";

    while (currPtr != NULL) {
        if(currPtr->data!=0)
        cout << currPtr->data << endl;


        nextPtr = Xor(prevPtr, currPtr->xnode);

        prevPtr = currPtr;
        currPtr = nextPtr;
    }
    cout << endl;
}

template <class T>
void push_rear(Node<T>*& head, T data) {
    Node<T>* currPtr = head;
    Node<T>* prevPtr = NULL;
    Node<T>* nextPtr;
    Node<T>* new_node = new Node<T>();
    new_node->data = data;
    if (head != NULL)
    {
        while (currPtr != NULL) {
            nextPtr = Xor(prevPtr, currPtr->xnode);
            prevPtr = currPtr;
            currPtr = nextPtr;                  // go to the rear of the linked list
        }
        prevPtr->xnode = Xor(prevPtr->xnode, new_node);     // let the penultimate node show the new node
        new_node->xnode = prevPtr;                          // push the data at the end
    }
    else
        head = new_node;

}

template <class T>
void push_front(Node<T>*& head, T data) {
    Node<T>* new_node = new Node<T>();
    new_node->data = data;
    new_node->xnode = head; // new node->xnode= xor(null , head)
    if (head != NULL)
    {
        head->xnode = Xor(new_node, head->xnode);
    }
    head = new_node; // revise head pointer to the new node
}

template <class T>
T pop_front(Node<T>*& head) {
    Node<T>* currPtr = head;
    Node<T>* prevPtr = NULL;
    Node<T>* nextPtr = Xor(prevPtr, currPtr->xnode);
    nextPtr->xnode = Xor(currPtr, nextPtr->xnode);
    currPtr->xnode = NULL; // delete the first node
    head = nextPtr; // new head
    return currPtr->data; // return data of the head node

}

template <class T>
T pop_rear(Node<T>*& head) {
    Node<T>* currPtr = head;
    Node<T>* prevPtr = NULL;
    if (head != NULL)
    {
        while (currPtr != NULL) {

            Node<T>* nextPtr = Xor(prevPtr, currPtr->xnode);
            prevPtr = currPtr;
            currPtr = nextPtr;
            nextPtr = Xor(prevPtr, currPtr->xnode);
            if (nextPtr == NULL) { // when last node become currPtr
                prevPtr->xnode = Xor(prevPtr->xnode, currPtr);
                currPtr->xnode = NULL; // pop the rear element
                return currPtr->data;
            }
        }
    }
}

template <class T>
T peak_front(Node<T>*& head) {
    T x = head->data;
    return x;
}

template <class T>
class LL_wrapper {
public:
    Node<T>* head_node;

public:
    T last_data(Node<T>* head_node);
    void push_front(T data) {
        push_front_node(head_node, data);
    }
    void push_rear(T data) {
        push_rear_node(head_node, data);
    }
    void pop_front() {
        pop_front_node(head_node);
    }
    void pop_rear() {
        pop_rear_node(head_node);
    }


};
template <class T>
T last_data(Node<T>* head_node) { // the function for finding data of the last element
    Node<T>* currPtr = head_node;
    Node<T>* prevPtr = NULL;
    Node<T>* nextPtr;

    while (nextPtr != NULL) {

        nextPtr = Xor(prevPtr, currPtr->xnode);

        prevPtr = currPtr;
        currPtr = nextPtr;
        nextPtr = Xor(prevPtr, currPtr->xnode);
    }
    return currPtr->data;
}


int main()
{

    Node<int>* prev = new Node <int>();
    cout << "Push front 30" << endl;
    push_front(prev, 30);
    cout << "Push rear 50" << endl;
    push_rear(prev, 50);
    cout << "Insert 20" << endl;
    insert(prev, 20);
    print_elements(prev);
    cout << "Pop front" << endl;
    pop_front(prev);
    print_elements(prev);
    cout << "Pop rear" << endl;
    pop_rear(prev);
    print_elements(prev);



    // I cannot run the code in the stackqueue code but all functions run correctly.
}





