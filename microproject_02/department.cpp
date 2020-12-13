#include "department.h"

Department::Department(int dep_id, int items, std::mutex* print_lock, std::mt19937 *generator) {
	this->items = items;
	this->id = dep_id;
	this->print_lock = print_lock;
	this->generator = generator;
}

void Department::add_customer(Customer *customer) {
	customer->sleep();
	{
		std::unique_lock<std::mutex> locker(queue_lock);
		if (counter >= max_iterations) {
			if(counter == max_iterations)
				closed();
			counter++;
			customer->wake_up();
			return;
		}
		counter++;
		customers.push(customer);
	}
	queue_check.notify_one();
}

void Department::start() {
	open = true;
	while(open){
		std::unique_lock<std::mutex> locker(work_lock);
		while (customers.empty()) {
			queue_check.wait(locker);
			if (!open)
				return;
		}
		print_queue(customers);
		start_service();
		std::this_thread::sleep_for(std::chrono::seconds(1 + (*generator)() % 5));
		end_service();
		customers.front()->wake_up();
		{
			std::unique_lock<std::mutex> queue_locker(queue_lock);
			customers.pop();
		}
	}
}

void Department::start_service() {
	std::unique_lock<std::mutex> queue_locker((*print_lock));
	std::cout << "department " << id << " started to sell product " << customers.front()->current_item() << " to customer " << customers.front()->id() << std::endl;
}

void Department::closed() {
	std::unique_lock<std::mutex> queue_locker((*print_lock));
	std::cout << "!!!!! department " << id << " selled all products and is now closed for new customers !!!!!" << std::endl;
}

void Department::end_service() {
	std::unique_lock<std::mutex> queue_locker((*print_lock));
	std::cout << "department " << id << " selled product " << customers.front()->current_item() << " to customer " << customers.front()->id() << std::endl;
}

void Department::print_queue(std::queue<Customer*> customers) {
	std::unique_lock<std::mutex> queue_locker((*print_lock));
	std::cout << "department " << id << " current queue: [";
	while (!customers.empty()) {
		std::cout << " " << customers.front()->id() << "<" << customers.front()->current_item() << ">";
		customers.pop();
	}
	std::cout << " ]" << std::endl;
}

void Department::close() {
	open = false;
	queue_check.notify_one();
}

int Department::items_num() {
	return items;
}