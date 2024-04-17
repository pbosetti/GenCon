%module GenCon
%include "std_string.i"

%rename(GenericContainer) GC_namespace::GenericContainer;

%{
#include "../gencon.hpp"
#include <GenericContainer.hh>
#include <complex>
using namespace std;
using namespace GC_namespace;

static int dict_into_gc(PyObject *obj, GenericContainer *gc);

static int array_into_dict(PyObject *obj, GenericContainer *gc, string key) {
  if (PyList_Check(obj)) {
    for (size_t i = 0; i < PyList_Size(obj); i++) {
      PyObject *item = PyList_GET_ITEM(obj, i);
      if (PyInt_Check(item)) {
        (*gc)[i] = (long_type)PyInt_AsLong(item);
      } else if (PyFloat_Check(item)) {
        (*gc)[i] = PyFloat_AsDouble(item);
      } else if (PyComplex_Check(item)) {
        Py_complex pc = PyComplex_AsCComplex(item);
        complex<double> c = complex<double>(pc.real, pc.imag);
        (*gc)[i] = c;
      } else if (PyUnicode_Check(item)) {
        (*gc)[i] = PyUnicode_AsUTF8(item);
      } else if (PyString_Check(item)) {
        (*gc)[i] = PyString_AsString(item);
      } else if (PyBool_Check(item)) {
        (*gc)[i] = (bool)(item == Py_True);
      } else if (PyList_Check(item)) {
        (*gc)[i].set_vector(PyList_Size(item));
        if (array_into_dict(item, &(*gc)[i], key))
          return 1;
      } else if (PyDict_Check(item)) {
        GenericContainer sub = GenericContainer();
        dict_into_gc(item, &sub);
        (*gc)[i] = sub;
      } else {
        PyErr_SetString(PyExc_TypeError, "unsupported type in list");
        return 1;
      }
    }
  } else {
    PyErr_SetString(PyExc_TypeError, (string("not a list ") + key).c_str());
    return 1;
  }
  return 0;
}

static int dict_into_gc(PyObject *obj, GenericContainer *gc) {
  PyObject *key, *value;
  char const *kstr = NULL;
  Py_ssize_t pos = 0;

  while (PyDict_Next(obj, &pos, &key, &value)) {
    kstr = PyUnicode_AsUTF8(key);
    if (PyInt_Check(value)) {
      (*gc)[kstr] = (long_type)PyInt_AsLong(value);
    } else if (PyFloat_Check(value)) {
      (*gc)[kstr] = PyFloat_AsDouble(value);
    } else if (PyComplex_Check(value)) {
      Py_complex pc = PyComplex_AsCComplex(value);
      complex<double> c = complex<double>(pc.real, pc.imag);
      (*gc)[kstr] = c;
    } else if (PyUnicode_Check(value)) {
      (*gc)[kstr] = PyUnicode_AsUTF8(value);
    } else if (PyString_Check(value)) {
      (*gc)[kstr] = PyString_AsString(value);
    } else if (PyBool_Check(value)) {
      (*gc)[kstr] = (bool)(value == Py_True);
    } else if (PyList_Check(value)) {
      (*gc)[kstr].set_vector(PyList_Size(value));
      if (array_into_dict(value, &(*gc)[kstr], kstr))
        return 1;
    } else if (PyDict_Check(value)) {
      GenericContainer sub = GenericContainer();
      dict_into_gc(value, &sub);
      (*gc)[kstr] = sub;
    } else {
      PyErr_SetString(PyExc_TypeError, (string("unsupported type in dictionary at key \"") + kstr + "\"").c_str());
      return 1;
    }
  }
  return 0;
}

static int gc_into_dict(GenericContainer *gc, PyObject *obj) {
  
  return 0;
}
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

  string json_string();

  void dump();

  GenericContainer produce();

};
