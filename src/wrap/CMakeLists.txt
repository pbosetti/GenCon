
find_package(Python3 COMPONENTS Interpreter Development)

message(STATUS "Python version: ${Python3_VERSION}")
message(STATUS "Python include dirs: ${Python3_INCLUDE_DIRS}") 
message(STATUS "Python libraries: ${Python3_LIBRARY_DIRS}")


macro(add_wrapper name)
  add_custom_target(
    ${name}_swig ALL
    COMMAND swig -c++ -python -o ${name}.cpp ${name}.swg
    WORKING_DIRECTORY ${SOURCE_DIR}/wrap
    BYPRODUCTS ${SOURCE_DIR}/wrap/${name}.cpp
    SOURCES ${SOURCE_DIR}/wrap/${name}.swg
  )

  add_library(${name} SHARED ${SOURCE_DIR}/wrap/${name}.cpp)
  target_include_directories(${name} PUBLIC ${Python3_INCLUDE_DIRS})
  target_link_directories(${name} PUBLIC ${Python3_LIBRARY_DIRS})
  set_target_properties (${name} PROPERTIES PREFIX "")
  set_target_properties (${name} PROPERTIES OUTPUT_NAME "_${name}")
  if (WIN32)
    set_target_properties (${name} PROPERTIES SUFFIX ".pyd")
  else()
    set_target_properties (${name} PROPERTIES SUFFIX ".so")
  endif()
  target_link_libraries(${name} ${LIB_LIST} ${Python3_LIBRARIES})
  install(PROGRAMS ${SOURCE_DIR}/wrap/${name}.py TYPE BIN)
endmacro()

add_wrapper(jplay)

add_wrapper(GenCon)
target_link_libraries(GenCon GenericContainer_osx_static_debug)

install(TARGETS 
  jplay GenCon
  DESTINATION bin
)
