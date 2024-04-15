# Minimal settings
cmake_minimum_required(VERSION 3.15)
set(VERSION "0.1.1")
project(C-CNC VERSION ${VERSION} LANGUAGES CXX)

# Build mode
if(CMAKE_BUILD_TYPE MATCHES "Debug")
  message(NOTICE "Debug build, enabling all warnings")
  add_compile_options(-Wall)
elseif(CMAKE_BUILD_TYPE MATCHES "Release")
  message(STATUS "Release build")
else()
  message(FATAL_ERROR "Please set CMAKE_BUILD_TYPE to either Debug or Release!")
endif()


# 3rd party external libraries
include(FetchContent)
FetchContent_Declare(nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG        v3.11.3
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(nlohmann_json)

include_directories(
  ${nlohmann_json_SOURCE_DIR}/include
)


# Build settings
set(CMAKE_CXX_STANDARD 17)
set(SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src)
add_compile_definitions(_GNU_SOURCE)

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/src/wrap)


add_executable(gencon_test ${SOURCE_DIR}/main/gencon.cpp)

add_executable(jplay_test ${SOURCE_DIR}/main/jplay.cpp)


set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_LIST_DIR}/usr)
install(TARGETS jplay_test
  BUNDLE DESTINATION bin
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
)