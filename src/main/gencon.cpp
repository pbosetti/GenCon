#include "../gencon.hpp"

int main() {
  char str[10] = "ciao";
  GenCon gc;
  gc.add("a", 42);
  gc.add("a", 43);
  gc.add("b", 44);
  gc.add("b", 45.3);
  gc.add("b", string("hello"));
  gc.add("b", "hello");
  gc.add("c", str);

  gc.add("d", GenCon());

  any_cast<GenCon>(gc.get("d"))->add("A", 42);
  any_cast<GenCon>(gc.get("d"))->add("B", 43);

  gc.print();
  return 0;
}