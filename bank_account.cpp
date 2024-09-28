#include <iostream>
#include <string>
#include <fstream>


class Account {
protected:
std::string acc_name;
float acc_balance;
__int64 balance_num;

public:
    Account (std::string name, float balance, __int64 number){
        acc_name = name;
        acc_balance = balance;
        balance_num = number;
    }
     void set_account_name( const std::string name) {
        acc_name = name;
    }

    int money_withdraw ( int requested_amount){
        acc_balance = acc_balance-requested_amount;

        return requested_amount;
    }

    int money_deposit ( int requested_amount){
        acc_balance = acc_balance+requested_amount;

        return requested_amount;
    }

    float balance_display ( ){
        std::cout << "Balance Display " << acc_balance <<std::endl;
        return acc_balance;
    }

    virtual float calculate_interest (){
        float interest = 0.0f;
        return interest;

    }
    void display_info() {
        std::cout << "Account Name: " << acc_name 
                  << ", Balance: " << acc_balance 
                  << ", Account Number: " << balance_num << std::endl;
    }

    void save_to_file(){
       std::ofstream outfile("account_info.txt", std::ios::app);
        if(outfile.is_open()){
            outfile << acc_name << " " << acc_balance << " " << balance_num << std::endl;
            outfile.close();

        }
        else {
            std::cout << "Error Opening File" << std:: endl ;
        }
    }



};

class saving_account : public Account {
    public:
         saving_account(float balance, __int64 number) : Account("Saving Account ", balance, number) {
    }

    int sav_account_withdraw ( int requested_amount){
        return money_withdraw(requested_amount);
    }

    int sav_account_deposit ( int requested_amount){
        

        return money_deposit(requested_amount);
    }

    float sav_account_display ( ){
        std::cout << "Saving Account Balance Display" << acc_balance <<std::endl;
        return balance_display();
    }

    float calculate_interest ()  override {
        float interest = 0.5f;
        return acc_balance * interest;
    }

};

Account load_account_from_file() {
    std::ifstream infile("account_info.txt");
    std::string name;
    float balance;
    __int64 number;

    if (infile.is_open()) {
        if (infile >> name >> balance >> number) {
            infile.close();
            return Account(name, balance, number); // Yeni Account nesnesi döndür
        }
        infile.close();
    } else {
        std::cout << "Error opening file!" << std::endl;
    }

    return Account("", 0, 0); // Hata durumunda boş bir Account döndür
}


int main()
{

     // Yeni bir hesap oluştur ve dosyaya kaydet
    Account hesap("telha", 100, 15821690);
    hesap.money_deposit(20);
    hesap.balance_display();
    hesap.money_withdraw(10);
    hesap.balance_display();
    hesap.save_to_file(); // Hesap bilgilerini dosyaya kaydet

    // Dosyadan hesap bilgilerini yükle
    Account loaded_account = load_account_from_file();
    loaded_account.display_info(); // Yüklenen hesabı görüntüle

    saving_account tasarruf(350, 206907317);
    tasarruf.money_deposit(50);
    tasarruf.balance_display();

    float interest = tasarruf.calculate_interest();
    std::cout << "Interest earned on saving account: " << interest << std::endl;
    tasarruf.save_to_file(); // Tasarruf hesabı bilgilerini dosyaya kaydet

    loaded_account = load_account_from_file();
    loaded_account.display_info(); // Yüklenen hesabı görüntüle

    return 0;
    
}
