//T compiles:yes
//T retval:24
//? desc:Tests recursion

uint factorial(uint arg) {
  if (arg <= 1) 
    return 1;
  else
    return arg * factorial(arg-1);
} // factorial() function

int main()
{
    return factorial(4);
}
