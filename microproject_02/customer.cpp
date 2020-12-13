#include "customer.h"
#include "shop.h"
#include "iostream"

Customer::Customer(int max_items, int id, Shop *current_shop, std::mutex *print_lock, std::mt19937 *generator) {
	this->current_shop = current_shop;
	this->print_lock = print_lock;
	this->customer_id = id;
	int items_count = max_items == 0 ? 0 : (*generator)() % max_items;
	items_list = std::queue<int>();
	{
		std::unique_lock<std::mutex> queue_locker((*print_lock));
		std::cout << "customer " << id << " product list: [";
		for (int i = 0; i < items_count; i++) {
			items_list.push((*generator)() % current_shop->items_num());
			std::cout << " " << items_list.back();
		}
		std::cout << " ]" << std::endl;
	}
}

int Customer::id() {
	return customer_id;
}

void Customer::go() {
	while (!items_list.empty()) {
		{
			std::unique_lock<std::mutex> locker(items_lock);
			current_shop->add_customer(this);
			while (waiting) {
				sleep_check.wait(locker);
			}
			items_list.pop();
		}
	}
	end();
}

void Customer::wake_up() {
	waiting = false;
	sleep_check.notify_one();
}

void Customer::sleep() {
	waiting = true;
}

int Customer::current_item() {
	return items_list.front();
}

void Customer::end() {
	std::unique_lock<std::mutex> queue_locker((*print_lock));
	std::cout << "customer " << id() << " went home" << std::endl;
}