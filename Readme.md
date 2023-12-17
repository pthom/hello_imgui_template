# hello_imgui_template: get started with HelloImGui in 5 minutes 

This template demonstrates how to easily integrate HelloImGui to your own project. 

You can use it as a starting point for your own project.

Template repository: https://github.com/pthom/hello_imgui_template

## Explanations

### CMake

The [CMakeLists.txt](CMakeLists.txt) file will download and build hello_imgui at configure time, and make the "hello_imgui_add_app" cmake function available. 

By default, you do not need to add HelloImGui as a dependency to your project, it will be downloaded and built automatically during CMake configure time.
If you wish to use a local copy of HelloImGui, edit CMakeLists.txt and uncomment the `add_subdirectory` line.

*Note: `hello_imgui_add_app` will automatically link your app to hello_imgui, embed the assets folder (for desktop, mobile, and emscripten apps), and the application icon.*

### Assets
 

Anything in the assets/ folder located beside the app's CMakeLists will be bundled together with the app (for macOS, iOS, Android, Emscripten).
The files in assets/app_settings/ will be used to generate the app icon, and the app settings.

```
assets/
├── world.jpg                   # A custom asset
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
│
├── fonts/
│    ├── DroidSans.ttf           # Default fonts
│    └── fontawesome-webfont.ttf #   used by HelloImGui
```

### Standard usage

```bash
mkdir build
cd build
cmake ..
make -j 4
./hello_world
```

### Usage with emscripten

#### Install emscripten
You can either install emsdk following [the instruction on the emscripten website](https://emscripten.org/docs/getting_started/downloads.html) or you can use the script [../tools/emscripten/install_emscripten.sh](../tools/emscripten/install_emscripten.sh).

#### Compile with emscripten

```bash
# Add emscripten tools to your path
source ~/emsdk/emsdk_env.sh

# cmake and build
mkdir build_emscripten
cd build_emscripten
emcmake cmake ..
make -j 4

# launch a webserver
python3 -m http.server
```

Open a browser, and navigate to [http://localhost:8000](http://localhost:8000).
