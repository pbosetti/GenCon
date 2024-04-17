%module GenCon
%include "std_string.i"

%rename(GenericContainer) GC_namespace::GenericContainer;

%{
#include "../gencon.hpp"
#include <GenericContainer.hh>
using namespace std;
using namespace GC_namespace;

int dict_into_gc(PyObject *obj, GenericContainer *gc) {
  PyObject *key, *value;
  char const *kstr = NULL;
  Py_ssize_t pos = 0;

  while (PyDict_Next(obj, &pos, &key, &value)) {
    kstr = PyUnicode_AsUTF8(key);
    if (PyInt_Check(value)) {
      (*gc)[kstr] = (long_type)PyInt_AsLong(value);
    } else if (PyFloat_Check(value)) {
      (*gc)[kstr] = PyFloat_AsDouble(value);
    } else if (PyUnicode_Check(value)) {
      (*gc)[kstr] = PyUnicode_AsUTF8(value);
    } else if (PyString_Check(value)) {
      (*gc)[kstr] = PyString_AsString(value);
    } else if (PyBool_Check(value)) {
      (*gc)[kstr] = value == Py_True ? true : false;
    } else {
      PyErr_SetString(PyExc_TypeError, (string("unsupported type in dictionary ") + kstr).c_str());
      return 1;
    }
  }
  return 0;
}

int gc_into_dict(GenericContainer *gc, PyObject *obj) { return 0; }
/*
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
*/
%}

%typemap(in) GenericContainer &gc {
  if (PyDict_Check($input)) {
    $1 = new GenericContainer();
    if (dict_into_gc($input, $1))
      SWIG_fail;
  }
  // complain and fail 
  else {
    PyErr_SetString(PyExc_TypeError, "not a dictionary");
    SWIG_fail;
  }
}
%typemap(freearg) GenericContainer &gc {
  if ($1) {
    cout << "Freeing GenericContainer" << endl;
    delete $1;
  }
}


%typemap(out) string {
  $result = PyString_FromString($1.c_str());
}

%typemap(out) GenericContainer {
  // Dictionary typemap
  $result = PyDict_New();
  if (gc_into_dict(&$1, $result)) 
    SWIG_fail;
}


class GenCon {

public:
  GenCon();

  ~GenCon();

  void deal_with(GenericContainer &gc);

  string dump();

  GenericContainer produce();

};
