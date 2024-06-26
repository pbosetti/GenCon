/*
   ____             ____
  / ___| ___ _ __  / ___|___  _ __
 | |  _ / _ \ '_ \| |   / _ \| '_ \
 | |_| |  __/ | | | |__| (_) | | | |
  \____|\___|_| |_|\____\___/|_| |_|

* Author: Paolo Bosetti
*/

#ifndef GENCON_HPP
#define GENCON_HPP

#include <GenericContainer.hh>
#include <GenericContainer/GenericContainerJson.hh>
#include <iostream>

using namespace GC_namespace;

class GenCon {
public:
  GenCon() {
    _gc["int"] = 42;
  }

  ~GenCon() {}

  string json_string() { return genericContainerToJsonString(_gc); }

  void dump() {
    std::cout << "GenericContainer content:" << std::endl;
    _gc.dump(std::cout);
  }

  void deal_with(GenericContainer &gc) { 
    _gc.clear();
    _gc = gc; 
  }

  GenericContainer produce() {
    return _gc;
  }

private:
  GenericContainer _gc;
};

#endif // GENCON_HPP