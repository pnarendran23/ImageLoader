
# Running the Xcode Project (Image Loader)

## Description
This project is to assess based on the below task.
- In online, pagination is enabled to load images from Unsplash API.
- Cache is enabled to avoid multiple times loading. But it will be cleared when app is killed.
- In offline, top banner will be shown as "Device in offline".
- If initial load is performed during offline, Center screen shows offline view with an image(No network image) and a text "Device in Offline. It will be loaded when device is back online".

## Prerequisites
- Xcode installed on your macOS device.
- Knowledge of Swift and iOS development.

## Installation
Follow these steps to run the Xcode project:

1. **Clone the Repository**: 
    - Open Terminal.
    - Navigate to the directory where you want to clone the repository.
    - Run the following command:
    ```bash
    https://github.com/pnarendran23/ImageLoader.git
    ```

2. **Open the Xcode Project**: 
    - Open Xcode.
    - Click on "File" > "Open" and navigate to the directory where you cloned the repository.
    - Select the `.xcodeproj` file and click "Open".

## Build and Run
Follow these steps to build and run the project:

1. **Select Target Device**:
    - Choose a target device (iPhone, iPad, or simulator) to run the app on. You can select the target device from the dropdown menu located in the Xcode toolbar.

2. **Build the Project**: 
    - Click on the "Build" button (hammer icon) in the Xcode toolbar, or use the shortcut `⌘ + B`. This compiles the project and checks for any errors.

3. **Run the Project**: 
    - Click on the "Run" button (play icon) in the Xcode toolbar, or use the shortcut `⌘ + R`. This builds and runs the project on the selected target device or simulator.

## Usage
After clicking "Run" (play icon) in the toolbar of the Xcode, image starts loading and you can also launch the application in Offline. 

## Troubleshooting
If you encounter any issues while running the project, refer to the following troubleshooting steps:
- Check for any error messages in the Xcode console.
- Make sure you have selected the correct target device or simulator.
- Ensure all required dependencies are installed and configured correctly.
