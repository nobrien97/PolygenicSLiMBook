cmake_minimum_required(VERSION 3.1)
project(SLiMRunGen)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(generators src/generators.cpp)
add_executable(slimrungen src/main.cpp)
target_link_libraries(slimrungen generators)