%module jplay
%include "std_string.i"

%{
#include "../jplay.hpp"
#include "nlohmann/json.hpp"
using namespace std;
using namespace nlohmann;

int dict_into_json(PyObject *obj, json *out) {
  PyObject *key, *value;
  char const *kstr = NULL;
  Py_ssize_t pos = 0;

  while (PyDict_Next(obj, &pos, &key, &value)) {
    kstr = PyUnicode_AsUTF8(key);
    if (PyInt_Check(value)) {
      (*out)[kstr] = PyInt_AsLong(value);
    } else if (PyFloat_Check(value)) {
      (*out)[kstr] = PyFloat_AsDouble(value);
    } else if (PyUnicode_Check(value)) {
      (*out)[kstr] = PyUnicode_AsUTF8(value);
    } else if (PyString_Check(value)) {
      (*out)[kstr] = PyString_AsString(value);
    } else if (PyBool_Check(value)) {
      (*out)[kstr] = value == Py_True ? true : false;
    } else if (PyList_Check(value)) {
      (*out)[kstr] = json::array();
      for (size_t i = 0; i < PyList_Size(value); i++) {
        PyObject *item = PyList_GET_ITEM(value, i);
        if (PyInt_Check(item)) {
          (*out)[kstr].push_back(PyInt_AsLong(item));
        } else if (PyFloat_Check(item)) {
          (*out)[kstr].push_back(PyFloat_AsDouble(item));
        } else if (PyUnicode_Check(item)) {
          (*out)[kstr].push_back(PyUnicode_AsUTF8(item));
        } else if (PyString_Check(item)) {
          (*out)[kstr].push_back(PyString_AsString(item));
        } else {
          PyErr_SetString(PyExc_TypeError, (string("unsupported type in list ") + kstr).c_str());
          return 1;
        }
      }
    } else if (PyDict_Check(value)) {
      json sub = json();
      dict_into_json(value, &sub);
      (*out)[kstr] = sub;
    } else {
      PyErr_SetString(PyExc_TypeError, (string("unsupported type in dictionary ") + kstr).c_str());
      return 1;
    }
  }
  return 0;
}


int json_into_dict(nlohmann::json *j, PyObject *obj) {
  for (json::iterator it = j->begin(); it != j->end(); ++it) {
    if (it.value().is_number_integer()) {
      PyDict_SetItemString(obj, it.key().c_str(), PyLong_FromLong(it.value().get<int>()));
    } else if (it.value().is_number_float()) {
      PyDict_SetItemString(obj, it.key().c_str(), PyFloat_FromDouble(it.value().get<double>()));
    } else if (it.value().is_string()) {
      PyDict_SetItemString(obj, it.key().c_str(), PyUnicode_FromString(it.value().get<string>().c_str()));
    } else if (it.value().is_boolean()) {
      PyDict_SetItemString(obj, it.key().c_str(), PyBool_FromLong(it.value().get<bool>()));
    } else if (it.value().is_array()) {
      PyObject *list = PyList_New(it.value().size());
      for (size_t i = 0; i < it.value().size(); i++) {
        if (it.value()[i].is_number_integer()) {
          PyList_SetItem(list, i, PyLong_FromLong(it.value()[i].get<int>()));
        } else if (it.value()[i].is_number_float()) {
          PyList_SetItem(list, i, PyFloat_FromDouble(it.value()[i].get<double>()));
        } else if (it.value()[i].is_string()) {
          PyList_SetItem(list, i, PyUnicode_FromString(it.value()[i].get<string>().c_str()));
        } else {
          PyErr_SetString(PyExc_TypeError, (string("unsupported type in list ") + it.key()).c_str());
          return 1;
        }
      }
      PyDict_SetItemString(obj, it.key().c_str(), list);
    } else if (it.value().is_object()) {
      PyObject *sub = PyDict_New();
      json_into_dict(&it.value(), sub);
      PyDict_SetItemString(obj, it.key().c_str(), sub);
    } else {
      PyErr_SetString(PyExc_TypeError, (string("unsupported type in dictionary ") + it.key()).c_str());
      return 1;
    }
  }
  return 0;
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
    if (dict_into_json($input, $1))
      SWIG_fail;
  }
  // complain and fail 
  else {
    PyErr_SetString(PyExc_TypeError, "not a dictionary nor a nlohmann::json pointer");
    SWIG_fail;
  }
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

%typemap(out) string {
  $result = PyString_FromString($1.c_str());
}

%typemap(out) nlohmann::json {
  // Dictionary typemap
  $result = PyDict_New();
  if (json_into_dict(&$1, $result)) 
    SWIG_fail;
}


class jplay {

public:
  jplay(string str = "");

  static void test(int i);

  void deal_with(nlohmann::json &j);

  string dump();

  nlohmann::json produce();

  nlohmann::json get_data();

  // delete typemap so we can return a pointer
  %typemap(out) nlohmann::json;
  nlohmann::json produce_ptr();

};
