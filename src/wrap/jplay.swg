%module jplay
%include "std_string.i"

%{
#include "../jplay.hpp"
#include "nlohmann/json.hpp"
using namespace std;
using namespace nlohmann;

void test_function(PyObject *obj, json *out, ssize_t level = 1) {
  PyObject *key, *value;
  char const *kstr = NULL;
  Py_ssize_t pos = 0;

  cout << "{" << endl;
  while (PyDict_Next(obj, &pos, &key, &value)) {
    kstr = PyUnicode_AsUTF8(key);
    cout << string(level, ' ') << string(level, ' ') << kstr << ": ";
    if (PyInt_Check(value)) {
      (*out)[kstr] = PyInt_AsLong(value);
      cout << PyInt_AsLong(value) << endl;
    } else if (PyFloat_Check(value)) {
      (*out)[kstr] = PyFloat_AsDouble(value);
      cout << PyFloat_AsDouble(value) << endl;
    } else if (PyUnicode_Check(value)) {
      (*out)[kstr] = PyUnicode_AsUTF8(value);
      cout << "\"" << PyUnicode_AsUTF8(value) << "\"" << endl;
    } else if (PyString_Check(value)) {
      (*out)[kstr] = PyString_AsString(value);
      cout << "\"" << PyString_AsString(value) << "\"" << endl;
    } else if (PyList_Check(value)) {
      cout << "[";
      for (size_t i = 0; i < PyList_Size(value); i++) {
        PyObject *item = PyList_GET_ITEM(value, i);
        if (PyInt_Check(item)) {
          cout << PyInt_AsLong(item);
        } else if (PyFloat_Check(item)) {
          cout << PyFloat_AsDouble(item);
        } else if (PyUnicode_Check(item)) {
          cout << "\"" << PyUnicode_AsUTF8(item) << "\"";
        } else if (PyString_Check(item)) {
          cout << "\"" << PyString_AsString(item) << "\"";
        } else {
          cout << "Unsupported (" << Py_TYPE(item)->tp_name << ")";
        }
        if (i < PyList_Size(value) - 1) {
          cout << ", ";
        }
      }
      cout << "]" << endl;
    } else if (PyDict_Check(value)) {
      test_function(value, out, level + 1);
    } else {
      cout  << "Unsupported (" << Py_TYPE(value)->tp_name << ")" << endl;
    }
  }
  cout << string(level-1, ' ') << string(level-1, ' ') << "}" << endl;
}
%}

%typemap(in) nlohmann::json &j {
  // JSON typemap
  $1 = new json();
  test_function($input, $1);
}

%typemap(out) string {
  $result = PyString_FromString($1.c_str());
}


// %typemap(in) int i {
//   // TYPEMAP!
//   if (!PyDict_Check($input)) {
//     PyErr_SetString(PyExc_TypeError, "not a dictionary");
//     SWIG_fail;
//   }
//   json j = json();
//   test_function($input, &j);
//   $1 = 42;
// }


class jplay {

public:
  jplay();

  static void test(int i);

  void deal_with(nlohmann::json &j);

  string dump();

  // void deal_with();

  nlohmann::json produce();

};
