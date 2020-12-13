#pragma once
#include "customer.h"
#include <queue>
#include <mutex>
#include <condition_variable>
#include <iostream>

class Department {
private:
	int counter = 0;
	int max_iterations = 20;
	int items;
	int id;
	bool open = false;
	std::queue<Customer*> customers;
	std::mutex *print_lock;
	std::mutex queue_lock;
	std::mutex work_lock;
	std::condition_variable queue_check;
	std::mt19937 *generator;
public:
	Department(int dep_id, int items, std::mutex *print_lock, std::mt19937 *generator);
	void start();
	void close();
	void add_customer(Customer *customer);
	void start_service();
	void closed();
	void end_service();
	void print_queue(std::queue<Customer*> customers);
	int items_num();
};