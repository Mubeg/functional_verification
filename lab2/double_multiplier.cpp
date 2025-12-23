

#ifdef _WIN32

    #define LIBRARY_API __declspec(dllexport)
#else
  #define LIBRARY_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef USING_VPI
    #define vpi_printf printf
    #include <stdio.h>
#else
    #include <vpi_user.h>
#endif


LIBRARY_API long unsigned int c_etalon(long unsigned int a, long unsigned int b){
    double f = 1.0;

    f = reinterpret_cast<double&>(a) * reinterpret_cast<double&>(b);
    long unsigned res = reinterpret_cast<long unsigned int&>(f);
    vpi_printf("%.2e (%x) * %.2e (%x) = %.2e (%x)\n", a, a, b, b, res, res);
    return res;
}

#ifdef __cplusplus
}
#endif


