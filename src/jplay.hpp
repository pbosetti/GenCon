#ifndef JPLAY_HPP
#define JPLAY_HPP

#include <iostream>
#include <nlohmann/json.hpp>

using namespace std;
using namespace nlohmann;

class jplay {
private:
  json _data;

public:
  jplay(string str = "") : _data(produce()) {
    if (!str.empty()) {
      _data = json::parse(str);
    }
  }

  void deal_with(json &j) {
    _data = j;
  }

  string dump() {
    return _data.dump();
  }

  json produce_ptr() {
    json j;
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

  json produce() {
    return produce_ptr();
  }

  static void test(int i = 0) {
    cout << "Test: " << i << endl;
  }

  json get_data() {
    return _data;
  }

};




#endif // JPLAY_HPP