# hello_imgui_template: get started with HelloImGui in 5 minutes 

This template demonstrates how to easily integrate HelloImGui to your own project. 

You can use it as a starting point for your own project.

Template repository: https://github.com/pthom/hello_imgui_template

## Explanations

### Get Hello ImGui with CMake

There are 3 ways to get HelloImGui with CMake. They are documented inside the CMakeLists.txt file.
By default, option 2 below is used: HelloImGui is downloaded and built automatically at configure time.

#### Option 1: add hello_imgui as a dependency
If you added hello_imgui as a subfolder, you can add it to your project with:
```cmake
add_subdirectory(external/hello_imgui)
```

#### Option 2: automatic download
The [CMakeLists.txt](CMakeLists.txt) file will download and build hello_imgui at configure time, and make the "hello_imgui_add_app" cmake function available, if hello-imgui is not found;

By default, you do not need to add HelloImGui as a dependency to your project, it will be downloaded and built automatically during CMake configure time.
If you wish to use a local copy of HelloImGui, edit CMakeLists.txt and uncomment the `add_subdirectory` line.

*Note: `hello_imgui_add_app` will automatically link your app to hello_imgui, embed the assets folder (for desktop, mobile, and emscripten apps), and the application icon.*

#### Option 3: via vcpkg
You can install hello_imgui via vcpkg with:
```bash
vcpkg install "hello-imgui[opengl3-binding,glfw-binding]"
```
Then you can use it inside CMake with:
```cmake
find_package(hello-imgui CONFIG REQUIRED)
hello_imgui_add_app(hello_world hello_world.main.cpp)
```

(note: the vcpkg package is named "hello-imgui" with a dash, not "hello_imgui")


### Assets folder structure
 

Anything in the assets/ folder located beside the app's CMakeLists will be bundled 
together with the app (for macOS, iOS, Android, Emscripten).
The files in assets/app_settings/ will be used to generate the app icon, 
and the app settings.

```
assets/
├── world.jpg                   # A custom asset. Any file or folder here will be deployed 
│                               # with the app.
├── fonts/
│    ├── DroidSans.ttf           # Default fonts used by HelloImGui
│    └── fontawesome-webfont.ttf # (if not found, the default ImGui font will be used)
│               
├── app_settings/               # Application settings
│    ├── icon.png               # This will be the app icon, it should be square
│    │                          # and at least 256x256. It will  be converted
│    │                          # to the right format, for each platform (except Android)
│    ├── apple/
│    │    │── Info.plist         # macOS and iOS app settings
│    │    │                      # (or Info.ios.plist + Info.macos.plist)
│    │    └── Resources/
│    │      └── ios/             # iOS specific settings: storyboard
│    │        └── LaunchScreen.storyboard
│    │
│    ├── android/                # Android app settings: any file placed here will be deployed 
│    │   │── AndroidManifest.xml # (Optional manifest, HelloImGui will generate one if missing)
│    │   └── res/                
│    │       └── mipmap-xxxhdpi/ # Optional icons for different resolutions
│    │           └── ...         # Use Android Studio to generate them: 
│    │                           # right click on res/ => New > Image Asset
│    └── emscripten/
│      ├── shell.emscripten.html # Emscripten shell file
│      │                         #   (this file will be cmake "configured"
│      │                         #    to add the name and favicon) 
│      └── custom.js             # Any custom file here will be deployed
│                                #   in the emscripten build folder
```

## Build instructions

### Build for Linux and macOS

#### 1. Optional: clone hello_imgui

_Note: This step is optional, since the CMakeLists.txt file will by default download and build hello_imgui at configure time._

In this example, we clone hello_imgui inside `external/hello_imgui`

Note: `external/` is mentioned in `.gitignore`

```bash
mkdir -p external && cd external
git clone https://github.com/pthom/hello_imgui.git
cd ..
```

Add this line at the top of your CMakeLists.txt

```cmake
add_subdirectory(external/hello_imgui)
```

#### 2. Create the build directory, run cmake and make

```bash
mkdir build && cd build
cmake ..
make -j 4
```

### Build for Windows

#### 1. Optional: clone hello_imgui
Follow step 1 from the Linux/macOS section above.

#### 2. Create the build directory, run cmake

```bash
mkdir build && cd build
cmake ..
```

#### 3. Open the Visual Studio solution
It should be located in build/helloworld_with_helloimgui.sln


### Build for Android

#### 1. Clone hello_imgui:
You will need to clone hello_imgui. In this example, we clone hello_imgui inside hello_imgui_template/external/hello_imgui


```bash
mkdir -p external && cd external
git clone https://github.com/pthom/hello_imgui.git
cd ..
```

Notes: 
* `external/` is mentioned in .gitignore
* the main CMakeList will detect the presence of hello_imgui in `external/hello_imgui`, and will use it instead of downloading it.


#### 2. Create the Android Studio project
```bash
# Set the ANDROID_HOME and ANDROID_NDK_HOME environment variables
# For example:
export ANDROID_HOME=/Users/YourName/Library/Android/sdk
export ANDROID_NDK_HOME=/Users/YourName/Library/Android/sdk/ndk/26.1.10909125

mkdir build_android && cd build_android
../external/hello_imgui/tools/android/cmake_arm-android.sh ../
```

#### 3. Open the project in Android Studio
It should be located in build_android/hello_world_AndroidStudio.


### Build for iOS

#### 1. Clone hello_imgui with its submodules

```bash
mkdir -p external && cd external
git clone --recurse-submodules https://github.com/pthom/hello_imgui.git
cd ..
```


#### 2. Create the Xcode project
```bash
mkdir build_ios && cd build_ios
```

Run CMake with the following command, where you replace XXXXXXXXX with your Apple Developer Team ID,
and com.your_website with your website (e.g. com.mycompany).

```bash
cmake .. \
-GXcode \
-DCMAKE_TOOLCHAIN_FILE=../external/hello_imgui/hello_imgui_cmake/ios-cmake/ios.toolchain.cmake \
-DHELLOIMGUI_USE_SDL2=ON \
-DHELLOIMGUI_HAS_OPENGL3=ON \
-DPLATFORM=OS64COMBINED \
-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=XXXXXXXXX \
-DHELLO_IMGUI_BUNDLE_IDENTIFIER_URL_PART=com.your_website
```

Then, open the XCode project in build_ios/helloworld_with_helloimgui.xcodeproj


### Build for emscripten

#### Install emscripten
You can either install emsdk following [the instruction on the emscripten website](https://emscripten.org/docs/getting_started/downloads.html) or you can use the script [hello_imgui/tools/emscripten/install_emscripten.sh](https://github.com/pthom/hello_imgui/blob/master/tools/emscripten/install_emscripten.sh).

#### Compile with emscripten

```bash
# Add emscripten tools to your path
source ~/emsdk/emsdk_env.sh

# cmake and build
mkdir build_emscripten
cd build_emscripten
emcmake cmake .. -DCMAKE_BUILD_TYPE=Release  # or Debug (Release builds lead to smaller files)
make -j 4

# launch a webserver
python3 -m http.server
```

Open a browser, and navigate to [http://localhost:8000](http://localhost:8000).
