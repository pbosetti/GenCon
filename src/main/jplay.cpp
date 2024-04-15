
#include "../jplay.hpp"

using namespace std;
using namespace nlohmann;

int main(int argc, char const *argv[]) {
  jplay j;
  json jd = j.produce();
  j.deal_with(jd);
  return 0;
}