#include <iostream>
#include <math.h>
class Disc {
public:
    int diameter;
    Disc() { diameter = 0; }
    Disc(int d) { diameter = d; }
    // disc constructor assigns the input to diameter
};

class Hanoi {
public:
    Disc left[20], mid[20], right[20];

    Hanoi(int);
    void move(int from, int to);
    Disc* decode_rod_id(int);
    int get_top_disc_id(Disc*);
    void print() const;
    // these functions of the class are initialized
};

Hanoi::Hanoi(int n_discs) {
    for (int i = 0, j = n_discs; i < n_discs; i++, j--)
        left[i] = Disc(j);
    // Takes number of discs and transfer them to the default left array
}

int Hanoi::get_top_disc_id(Disc* rod) {
    int disc_id = 0;
    for (; disc_id < 20 && rod[disc_id].diameter > 0; disc_id++)
        ;  //checks until arrive to 0 daimeter disc
    // if no disc return -1
    return disc_id - 1;
}

Disc* Hanoi::decode_rod_id(int rod_id)
{
    Disc* rod;
    switch (rod_id)
    {
    case 0:
        rod = left;
        break;
    case 1:
        rod = mid;
        break;
    case 2:
        rod = right;
        break;
    default:
        rod = left;
    }
    // left -> 0, mid -> 1, right -> 2
    return rod;
}

void Hanoi::move(int from, int to)
{
    
    if (from > 2 || from < 0 || to > 2 || to < 0)
    {
        std::cout << "Illegal Move" << std::endl;
        return;
    }

    Disc* from_rod = decode_rod_id(from);
    Disc* to_rod = decode_rod_id(to);

    int from_top_disc_id = get_top_disc_id(from_rod);
    int to_top_disc_id = get_top_disc_id(to_rod);
    // get top disc indices of both rods
    bool from_disc_exists = from_top_disc_id != -1;
    bool to_disc_exists = to_top_disc_id != -1;

    bool illegal_move = false;
    Disc from_top_disc, to_top_disc;
    // illegal move check
    if (from_disc_exists)
        from_top_disc = from_rod[from_top_disc_id];
    // check existence of from_disc
    if (to_disc_exists)
        to_top_disc = to_rod[to_top_disc_id];

    if (from_disc_exists && to_disc_exists)
    {
        if (from_top_disc.diameter >= to_top_disc.diameter)
            illegal_move = true;
        // from_disc diamter >= to_disc daimeter condition
    }
    else if (!from_disc_exists)
        illegal_move = true;

    if (illegal_move) {
        std::cout << "Illegal Move" << std::endl;
        return;
    }
    

    // safe to move
    from_rod[from_top_disc_id] = Disc();
    to_rod[to_top_disc_id + 1] = from_top_disc;
    std::cout << " Disk " << from_top_disc_id+1 << " is moved from Rod " << from << " to Rod " << to << std::endl;
    // print move
}

void Hanoi::print() const
{
    for (int i = 19; i >= 0; i--)
    {
        std::cout
            << left[i].diameter
            << " " << mid[i].diameter
            << " " << right[i].diameter
            << std::endl;
    }
    // print Hanoi Tower for test
}




void solve_hanoi(Hanoi& game) {
    int num_disc = game.get_top_disc_id(game.left)+1;
    int count=0;
    
    
        if (num_disc % 2 == 0) {
            while (count < pow(2, num_disc) - 1) {
                if (game.left[game.get_top_disc_id(game.left)].diameter < game.right[game.get_top_disc_id(game.right)].diameter && (game.left[game.get_top_disc_id(game.left)].diameter > 0) || game.right[game.get_top_disc_id(game.right)].diameter == 0)
                  game.move(0, 2);
              else
                  game.move(2, 0);
            count++;
            if ((game.left[game.get_top_disc_id(game.left)].diameter < game.mid[game.get_top_disc_id(game.mid)].diameter && game.left[game.get_top_disc_id(game.left)].diameter > 0) || game.mid[game.get_top_disc_id(game.mid)].diameter == 0)
                game.move(0, 1);
            else
                game.move(1, 0);
            count++;
            if ((game.right[game.get_top_disc_id(game.right)].diameter < game.mid[game.get_top_disc_id(game.mid)].diameter && game.right[game.get_top_disc_id(game.right)].diameter > 0) || game.mid[game.get_top_disc_id(game.mid)].diameter == 0)
                game.move(2, 1);
            else
                game.move(1, 2);
            count++;
        } 
        }

        else {
            while (count < pow(2, num_disc) - 1) {
                if ((game.mid[game.get_top_disc_id(game.mid)].diameter < game.left[game.get_top_disc_id(game.left)].diameter && game.mid[game.get_top_disc_id(game.mid)].diameter > 0) || game.left[game.get_top_disc_id(game.left)].diameter==0)
                    game.move(1, 0);
                else
                    game.move(0, 1);
                count++;
                if ((game.left[game.get_top_disc_id(game.left)].diameter < game.right[game.get_top_disc_id(game.right)].diameter && (game.left[game.get_top_disc_id(game.left)].diameter > 0) || game.right[game.get_top_disc_id(game.right)].diameter == 0))
                    game.move(0, 2);
                else
                    game.move(2, 0);
                count++;
                if ((game.mid[game.get_top_disc_id(game.mid)].diameter < game.right[game.get_top_disc_id(game.right)].diameter && (game.mid[game.get_top_disc_id(game.mid)].diameter > 0) || game.right[game.get_top_disc_id(game.right)].diameter == 0))
                    game.move(1, 2);
                else
                    game.move(2, 1);
                count++;
            } 
        }
        
    
}


void print_backwards(char const* string)
{
    if (*string == '\0')
        return;
    // it goes up to null identity
    else {
        print_backwards(string + 1);
        std::cout << *string;
        //prints backward
    }
}


bool is_prime(int a)
{  // checks whether input is prime 
    if (a > 1)
    {
        for (int i = 2; i < a; i++)
        {
            if (a % i == 0)
            {
                // divide by numbers excluding itself must be different from 0
                return false;
            }
        }
        return true;
    }
    else
        return false;
}

int nth_prime(int n)
{
    
    int *prime_numbers= new int[n * n + 2]{};
    for (int i = 0, j = 0; i < (n * n) + 2; i++)
    {
        //  n * n + 2 -> mathematical theory
        if (is_prime(i))
        {
             //  checks prime numbers until the n * n + 2 
            prime_numbers[j] = i;
            j++;
        }
    }
    return prime_numbers[n - 1];
}






int main() {

    
    Hanoi h(5);
    
    solve_hanoi(h);
    


    
}