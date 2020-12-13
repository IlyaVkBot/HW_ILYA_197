#pragma once
#include <queue>
#include <mutex>
#include <random>
#include <condition_variable>
#include "fwd.h"

class Customer {
private:
	bool waiting = false;
	int customer_id;
	Shop *current_shop;
	std::queue<int> items_list;
	std::mutex *print_lock;
	std::mutex items_lock;
	std::condition_variable sleep_check;
public:
	Customer(int max_items, int id, Shop *current_shop, std::mutex * print_lock, std::mt19937 * generator);
	int id();
	int current_item();
	void go();
	void wake_up();
	void sleep();
	void end();
};