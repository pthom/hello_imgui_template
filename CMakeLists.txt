cmake_minimum_required(VERSION 3.12)
project(helloworld_with_helloimgui)
set(CMAKE_CXX_STANDARD 17)

# Build hello_imgui
# =================
# 1/  Option 1: if you added hello_imgui as a subfolder, you can add it to your project with:
if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/external/hello_imgui)
    add_subdirectory(external/hello_imgui)
endif()

# 2/  Option 2: simply fetch hello_imgui during the build
if (NOT TARGET hello_imgui)
    message(STATUS "Fetching hello_imgui")
    include(FetchContent)
    FetchContent_Declare(hello_imgui GIT_REPOSITORY https://github.com/pthom/hello_imgui.git GIT_TAG master)
    FetchContent_MakeAvailable(hello_imgui)
endif()

# 3/  Option 3: via vcpkg
# i/ You can install hello_imgui via vcpkg with:
#     vcpkg install "hello-imgui[opengl3-binding,glfw-binding]"
# ii/ Then you can use it inside CMake with:
#     find_package(hello-imgui CONFIG REQUIRED)


# Build your app
# ==============
# hello_imgui_add_app is a helper function, similar to cmake's "add_executable"
# Usage:
# hello_imgui_add_app(app_name file1.cpp file2.cpp ...)
#
# Features:
# * It will automatically link the target to the required libraries (hello_imgui, OpenGl, glad, etc)
# * It will embed the assets (for desktop, mobile, and emscripten apps)
# * It will perform additional customization (app icon and name on mobile platforms, etc)

# Now you can build your app with
#     mkdir build && cd build && cmake .. && cmake --build .

# By default, we install in a portable way (i.e. assets and executable are in the same folder)
option(EXAMPLE_INTEGRATION_PORTABLE_INSTALL "Install in a portable way" ON)


if (EXAMPLE_INTEGRATION_PORTABLE_INSTALL)
    # portable installation is the easiest way to install the app
    hello_imgui_add_app(hello_world_ hello_world.main.cpp)
else()
    # Disable HelloImGui default install behavior
    set(HELLOIMGUI_ADD_APP_WITH_INSTALL OFF CACHE BOOL "" FORCE)

    imgui_bundle_add_app(hello_world_ hello_world.main.cpp)

    # If not portable, we have to
    # - install the app manually
    # - install the assets manually
    # - pass the assets location to the app, and set this assets location in main() via the compile definition ASSETS_LOCATION:
    #     #ifdef ASSETS_LOCATION \n HelloImGui::SetAssetsFolder(ASSETS_LOCATION); \n #endif
    if (NOT EXAMPLE_INTEGRATION_PORTABLE_INSTALL)
        include(GNUInstallDirs)
        install(TARGETS hello_world_ DESTINATION ${CMAKE_INSTALL_BINDIR})
        set(assets_install_dir ${CMAKE_INSTALL_DATADIR}/hello_world_)
        if (NOT IS_ABSOLUTE ${assets_install_dir})
            set(assets_install_dir ${CMAKE_INSTALL_PREFIX}/${assets_install_dir})
        endif()
        install(DIRECTORY assets DESTINATION ${assets_install_dir})
        target_compile_definitions(imgui_bundle_example_integration PRIVATE ASSETS_LOCATION="${assets_install_dir}/assets")
    endif()
endif()
