#pragma once
#include <iostream>
#include <mutex>
#include <vector>
#include "fwd.h"
#include "department.h"

class Shop {
private:
	std::vector<Department*> departments;
	std::vector<std::thread> threads;
public:
	Shop(int num_departments, std::mutex *print_lock, std::mt19937* generator);
	void start();
	void close();
	void add_customer(Customer *customer);
	int items_num();
};