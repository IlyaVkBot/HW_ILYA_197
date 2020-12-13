#include "shop.h"
#include "department.h"

Shop::Shop(int num_departments, std::mutex *print_lock, std::mt19937 *generator) {
	for (int i = 0; i < num_departments; i++) {
		int items_dep;
		std::cout << "Enter number of items in the " << i + 1 << " department [0; 1000000]: ";
		std::cin >> items_dep;
		if (items_dep < 0 || items_dep > 1000000) {
			std::cout << "incorrect value, used default (10)" << std::endl;
			items_dep = 10;
		}
		departments.push_back(new Department(i + 1, items_dep, print_lock, generator));
	}
}

void Shop::add_customer(Customer *customer) {
	int sum = 0;
	for (auto& dep : departments) {
		sum += dep->items_num();
		if (sum > customer->current_item()) {
			dep->add_customer(customer);
			break;
		}
	}
}

void Shop::start() {
	for (auto& dep : departments) {
		threads.push_back(std::thread(&Department::start, dep));
	}
}

void Shop::close() {
	for (auto& dep : departments)
		dep->close();
	for (auto& t : threads)
		t.join();
}

int Shop::items_num() {
	int sum = 0;
	for (auto &dep : departments) {
		sum += dep->items_num();
	}
	return sum;
}