cmake_minimum_required(VERSION 3.12)

project(helloworld_with_helloimgui)
set(CMAKE_CXX_STANDARD 17)

# Fetch hello_imgui (and its dependencies) from GitHub
set(HELLOIMGUI_DOWNLOAD_FREETYPE_IF_NEEDED ON CACHE BOOL "" FORCE)
include(FetchContent)
FetchContent_Declare(hello_imgui GIT_REPOSITORY https://github.com/pthom/hello_imgui.git GIT_TAG master)
FetchContent_MakeAvailable(hello_imgui)

# output to bin/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Create the hello world application
hello_imgui_add_app(hello_world hello_world.main.cpp)
