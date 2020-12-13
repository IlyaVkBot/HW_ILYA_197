
#include <iostream>
#include <thread>
#include <random>
#include "shop.h"
#include "customer.h"
using namespace std;

int main()
{
	// Инициализация генератора псевдо-случайных чисел
	mt19937 generator((unsigned int)chrono::system_clock::now().time_since_epoch().count());
	// Получение данных
	int customers, max_items;
	mutex print_lock;
    cout << "welcome to the shop simulator" << endl << endl << "Enter number of customers [0; 1000]: ";
	cin >> customers;
	if (customers < 0 || customers > 1000) {
		std::cout << "incorrect value, used default (10)" << endl;
		customers = 10;
	}

	Shop *current_shop = new Shop(2, &print_lock, &generator);
	
	cout << "Enter max number of items in one product list [0; 1000]: ";
	cin >> max_items;
	if (max_items < 0 || max_items > 1000) {
		std::cout << "incorrect value, used default (10)" << endl;
		max_items = 10;
	}

	if (customers > 0) {
		// Запуск магазина
		current_shop->start();
		// запуск клиентов
		vector<thread> threads;
		for (int i = 0; i < customers; ++i) {
			Customer* customer = new Customer(max_items, i + 1, current_shop, &print_lock, &generator);
			threads.push_back(thread(&Customer::go, customer));
		}
		for (auto& t : threads)
			t.join();
		// Закрытие всех магазинов.
		current_shop->close();
	}
	else {
		cout << "nothing to do" << endl;
	}

	cout << "press ENTER to continue" << endl;
	cin.clear();
	cin.sync();
	cin.get();
	cin.get();
	return 0;
}