#include "../gencon.hpp"
#include <GenericContainer.hh>

using namespace GC_namespace;

int main() {
  GenCon gc;
  std::cout << gc.dump() << std::endl;

  return 0;
}