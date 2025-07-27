cmake_minimum_required(VERSION 3.31)
project(emulator CXX)

set(CMAKE_CXX_STANDARD 23)

file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "main.cpp" "components/*.cpp")

add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
