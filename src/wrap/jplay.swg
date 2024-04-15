%module jplay
%include "std_string.i"

%{
#include "../jplay.hpp"
#include "nlohmann/json.hpp"
using namespace std;
using namespace nlohmann;

void dict_into_json(PyObject *obj, json *out, ssize_t level = 1) {
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
      (*out)[kstr] = json::array();
      cout << "[";
      for (size_t i = 0; i < PyList_Size(value); i++) {
        PyObject *item = PyList_GET_ITEM(value, i);
        if (PyInt_Check(item)) {
          (*out)[kstr].push_back(PyInt_AsLong(item));
          cout << PyInt_AsLong(item);
        } else if (PyFloat_Check(item)) {
          (*out)[kstr].push_back(PyFloat_AsDouble(item));
          cout << PyFloat_AsDouble(item);
        } else if (PyUnicode_Check(item)) {
          (*out)[kstr].push_back(PyUnicode_AsUTF8(item));
          cout << "\"" << PyUnicode_AsUTF8(item) << "\"";
        } else if (PyString_Check(item)) {
          (*out)[kstr].push_back(PyString_AsString(item));
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
      json sub = json();
      dict_into_json(value, &sub, level + 1);
      (*out)[kstr] = sub;
    } else {
      cout  << "Unsupported (" << Py_TYPE(value)->tp_name << ")" << endl;
    }
  }
  cout << string(level-1, ' ') << string(level-1, ' ') << "}" << endl;
}
%}

%typemap(in) nlohmann::json &j {
  // JSON typemap
  // we get a PyObject* and we need to convert it to a nlohmann::json
  if (Py_TYPE($input) == SwigPyObject_type()) {
    if (!SWIG_IsOK(SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 0))) {
      SWIG_exception_fail(SWIG_TypeError, "in method '$symname', expecting pointer to type nlohmann::json");
    }
  } 
  // we get a dictionary: convert it to a nlohmann::json object
  else if (PyDict_Check($input)) {
    $1 = new json();
    dict_into_json($input, $1);
  }
  // complain and fail 
  else {
    PyErr_SetString(PyExc_TypeError, "not a dictionary nor a nlohmann::json pointer");
    SWIG_fail;
  }
}

%typemap(out) string {
  $result = PyString_FromString($1.c_str());
}

%typecheck(SWIG_TYPECHECK_STRING) string {
  $1 = PyString_Check($input) || PyUnicode_Check($input);
}
%typemap(in) string {
  if (PyString_Check($input)) {
    $1 = PyString_AsString($input);
  } if (PyUnicode_Check($input)) {
    $1 = PyUnicode_AsUTF8($input);
  }
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
  jplay(string str = "");

  static void test(int i);

  void deal_with(nlohmann::json &j);

  string dump();

  // void deal_with();

  nlohmann::json produce();

};
