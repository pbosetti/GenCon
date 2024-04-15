/*
   ____             ____            
  / ___| ___ _ __  / ___|___  _ __  
 | |  _ / _ \ '_ \| |   / _ \| '_ \ 
 | |_| |  __/ | | | |__| (_) | | | |
  \____|\___|_| |_|\____\___/|_| |_|
                                    
* Generic-Container PoC
* Author: Paolo Bosetti
*/

#ifndef GENCON_HPP
#define GENCON_HPP

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <any>

#define NONAME "-"

using namespace std;

enum class GenConType {
  INT,
  DOUBLE,
  STRING,
  GENCON
};

class GenCon {
public:
  GenCon() {
    // if constexpr (is_same<T, int>::value) {
    //   _type = GenConType::INT;
    // } else if constexpr (is_same<T, string>::value) {
    //   _type = GenConType::STRING;
    // } else if constexpr (is_same<T, double>::value) {
    //   _type = GenConType::DOUBLE;
    // } else if constexpr (is_same<T, GenCon*>::value) {
    //   _type = GenConType::GENCON;
    // } else {
    //   throw runtime_error("Unsupported type");
    // }
  }

  void add(string name, any element) {
    _elements[name].push_back(element);
  }

  any *get(string name, size_t idx = 0) {
    return &(_elements[name][idx]);
  }

  void print(size_t level = 0) {
    for (auto& [name, elements] : _elements) {
      cout << string(level, ' ') << name << ": ";
      for (auto &e : elements) {
        if (e.type() == typeid(int))
          cout << any_cast<int>(e) << " ";
        else if (e.type() == typeid(double))
          cout << any_cast<double>(e) << " ";
        else if (e.type() == typeid(string))
          cout << any_cast<string>(e) << " ";
        else if (e.type() == typeid(char const *))
          cout << any_cast<char const *>(e) << " ";
        else if (e.type() == typeid(char *))
          cout << any_cast<char *>(e) << " ";
        else if (e.type() == typeid(GenCon)) {
          cout << "{" << endl;
          any_cast<GenCon>(e).print(level + 2);
          cout << "}" << endl;
        }
        else
          cout << "Unsupported type " << e.type().name() << endl;
      }
      cout << endl;
    }
  }

private:
  map<string, vector<any>> _elements;
};




#endif // GENCON_HPP