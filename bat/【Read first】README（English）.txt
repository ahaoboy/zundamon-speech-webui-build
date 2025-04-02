# Zundamon Speech Builder
=======================================================

When you place this folder anywhere and run the batch file, it will automatically set up the environment needed to run "Zundamon Speech" and output a batch file for launching the application.

It builds a virtual environment before execution to prevent affecting other Python projects (dependencies will be installed and configured within the virtual environment).

Please read the following instructions carefully as preparation is required before running the batch file.

## Instructions

### Common Steps

If you're unsure about installing the various tools, please refer to this video tutorial:
https://youtu.be/cWBAWCUg9s4

### CPU Version (No NVIDIA GPU required)

1. Place this folder anywhere you like

   * Folder names and paths should contain only alphanumeric characters [Example: C:\Users\Documents\zundamonspeech]

2. Install Python 3.9.13 (version 3.9.13 has been confirmed to work)
   https://www.python.org/downloads/release/python-3913/

   * When installing, be sure to check "ADD Python 3.9 to PATH"
   * Python has fragile compatibility, so installing other versions may cause the application to fail

3. Install Git
   https://git-scm.com/

4. Install Visual Studio Build Tools
   https://visualstudio.microsoft.com/visual-cpp-build-tools/

   * Be sure to check "Desktop development with C++" during installation

5. Install CMake
   https://cmake.org/download/

6. Run "zundamonspeech_builder_cpu_v[version].bat" (be careful not to mix it up with the "gpu" version!)

7. A confirmation message will appear first; press any key when you're ready

8. The environment setup will start, please wait for a while.

   * When warning messages appear, check the content and enter "Y" or "N" to proceed with execution.

9. Upon completion, "launch_zundamon.bat" will be automatically created in the folder; run this file

10. The operation screen should appear in your browser

    * The first launch may take some time to start

### GPU Version

1-5. Same as CPU version

6. Install CUDA 12.1
   https://developer.nvidia.com/cuda-12-1-0-download-archive

   * While it has better compatibility than Python, different versions may cause the application to fail

7. Run "zundamonspeech_builder_gpu_v[version].bat" (be careful not to mix it up with the "cpu" version!)

8. A confirmation message will appear first; press any key when you're ready

9. The environment setup will start, please wait for a while.

   * When warning messages appear, enter "Y" or "N" to proceed with execution.

10. Upon completion, "launch_zundamon.bat" will be automatically created in the folder; run this file

11. The operation screen should appear in your browser

    * The first launch may take some time to start

## How to Use Zundamon Speech

If you don't understand the following explanation, please refer to the video:
https://youtu.be/cWBAWCUg9s4

* Step 1: Reference Audio File
  Upload an audio file for the AI to reference. Audio files are in the [Zundamon-Speech-WebUI]-[reference] folder; you can drag and drop them.

* Step 2: Reference Text
  Enter the text corresponding to the audio file. Text files are available in the above folder for copying and pasting.

* Step 3: Target Text
  Enter the lines you want Zundamon to speak. Input should be in the language you want to convert to (e.g., "Japanese if you want to convert to Japanese").

* Step 4: Language Selection
  Select the language of the uploaded audio in Step 1 and the language you want to convert to. If your script contains multiple languages, select "~Mixed."

After that, click "Generate Speech" to start the generation process.

* Note: If using the CPU version, generation speed will be slow, so please be patient.

Once the audio is complete, you can save it as a WAV file by clicking the "Download Generated Audio" button.

## Test Environment

### CPU Version (Laptop)

* CPU: AMD Ryzen7 Mobile 2700U
* Memory: 16GB (DDR4)
* GPU: AMD Radeon RX Vega 10 Graphics

Note: This is a 6-year-old laptop, but it worked without issues.

### GPU Version (Desktop PC)

* CPU: Intel Core i9-14900F
* Memory: 64GB (DDR5)
* GPU: NVIDIA GeForce RTX4090

## Links

* [zundamon-speech-webui]
  https://github.com/zunzun999/zundamon-speech-webui?tab=readme-ov-file

* [Sound Source Terms of Use (Zunzun Project)]
  https://zunko.jp/con_ongen_kiyaku.html

Released 2025/3/7 Ver1.0

---

Created by: YuuPro
https://www.youtube.com/c/yuupro
https://x.com/YuuPro_2022