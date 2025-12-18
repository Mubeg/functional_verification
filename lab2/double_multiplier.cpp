#include <iostream>

int main()
{
	double f = 1.0;
    long unsigned int a = 0, b = 0, i = 0;

	while(1){
		std::cin >> a;
		std::cin >> b;
        f = reinterpret_cast<double&>(a) * reinterpret_cast<double&>(b);
        i = reinterpret_cast<long unsigned int&>(f);
        std::cout << i << std::endl;
	}

	return 0;
}
