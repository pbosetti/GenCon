#ifndef JPLAY_HPP
#define JPLAY_HPP

#include <iostream>
#include <nlohmann/json.hpp>

using namespace std;

class jplay {
private:
  nlohmann::json _data;

public:
  jplay(/* args */) : _data(produce()) {}

  void deal_with(nlohmann::json &j) {
    _data = j;
  }

  void deal_with() {
    deal_with(_data);
  }

  string dump() {
    return _data.dump();
  }

  nlohmann::json produce() {
    nlohmann::json j;
    j["name"] = "John";
    j["age"] = 25;
    j["is_student"] = true;
    j["marks"] = {88, 77, 99};
    j["address"] = {
      {"street", "123 Main St"},
      {"city", "New York"}
    };
    return j;
  }

  static void test(int i) {
    cout << "Test: " << i << endl;
  }

};




#endif // JPLAY_HPP