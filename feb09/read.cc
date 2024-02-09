#include <iostream>
#include <fstream>

using namespace std;
int main() {
  ifstream filein("demo.lst");
  char c;
    
  c = getchar();

  while (filein >> c) {
    cout << c;
  }

  return 0;
}
