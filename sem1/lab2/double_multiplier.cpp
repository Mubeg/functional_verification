

#ifdef _WIN32

    #define LIBRARY_API __declspec(dllexport)
#else
  #define LIBRARY_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef NOT_USING_VPI
    #define vpi_printf printf
    #include <stdio.h>
#else
    #include <vpi_user.h>
#endif


LIBRARY_API long unsigned int c_etalon(long unsigned int a, long unsigned int b){
	double a_f = reinterpret_cast<double&>(a);
	double b_f = reinterpret_cast<double&>(b);

    double res_f = a_f * b_f;
    long unsigned res = reinterpret_cast<long unsigned int&>(res_f);
    vpi_printf("%.2e (%lx) * %.2e (%lx) = %.2e (%lx)\n", a_f, a, b_f, b, res_f, res);
    return res;
}

#ifdef __cplusplus
}
#endif


