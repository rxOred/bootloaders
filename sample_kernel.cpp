#include <stdlib.h>
#include <stdio.h>

float calculate(double x, double y){

    return x + y;
}

int calculate(int x, int y){

    return x + y;
}

int main(void){

    printf("%d\n", calculate(1, 2));
    printf("%f\n",static_cast<float>(calculate(1, 2)));
}