
find_package(Python3 COMPONENTS Interpreter Development)

message(STATUS "Python version: ${Python3_VERSION}")
message(STATUS "Python include dirs: ${Python3_INCLUDE_DIRS}") 
message(STATUS "Python libraries: ${Python3_LIBRARY_DIRS}")

add_custom_target(
  jplay_swig ALL
  COMMAND swig -c++ -python -o jplay.cpp jplay.swg
  WORKING_DIRECTORY ${SOURCE_DIR}/wrap
  BYPRODUCTS ${SOURCE_DIR}/wrap/jplay.cpp
  SOURCES ${SOURCE_DIR}/wrap/jplay.swg
)

add_library(jplay SHARED ${SOURCE_DIR}/wrap/jplay.cpp)
target_include_directories(jplay PUBLIC ${Python3_INCLUDE_DIRS})
target_link_directories(jplay PUBLIC ${Python3_LIBRARY_DIRS})
set_target_properties (jplay PROPERTIES PREFIX "")
set_target_properties (jplay PROPERTIES OUTPUT_NAME "_jplay")
if (WIN32)
  set_target_properties (jplay PROPERTIES SUFFIX ".pyd")
else()
  set_target_properties (jplay PROPERTIES SUFFIX ".so")
endif()
target_link_libraries(jplay ${LIB_LIST} ${Python3_LIBRARIES})


install(TARGETS jplay DESTINATION bin)
install(PROGRAMS ${SOURCE_DIR}/wrap/jplay.py TYPE BIN)
