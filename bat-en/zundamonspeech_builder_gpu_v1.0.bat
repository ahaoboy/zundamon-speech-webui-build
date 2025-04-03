@echo off

REM UTF-8 with BOM for character encoding
chcp 65001 > NUL
cd /d %~dp0

cd ..

@REM @echo off
@REM echo Have you installed Python 3.9.13, Git, Visual Studio Build Tools, CMake, and CUDA 12.1?
@REM echo Press any key when you are ready to continue
@REM pause > NUL

@REM REM Create virtual environment
@REM echo Creating virtual environment...
@REM if exist zundamon_env (
@REM     echo Virtual environment already exists.
@REM ) else (
@REM     python -m venv zundamon_env
@REM     if %errorlevel% neq 0 (
@REM         echo Failed to create virtual environment. Please check if Python 3.9.13 is installed.
@REM         pause
@REM         exit /b 1
@REM     )
@REM     echo Virtual environment created.
@REM )

@REM echo Activating virtual environment...
@REM call zundamon_env\Scripts\activate
@REM if %errorlevel% neq 0 (
@REM     echo Failed to activate virtual environment.
@REM     pause
@REM     exit /b 1
@REM )

REM Python version check
echo Checking Python version...

:: 1. Check if Python command exists
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Please install Python 3.9.13.
    echo.
    echo Press any key to exit...
    pause > NUL
    exit /b
)

:: 2. Check Python version
python -c "import sys; version='3.9.13'; current='.'.join(map(str, sys.version_info[:3])); print(f'Current Python version: {current}'); sys.exit(0 if current == version else 1)"
if %errorlevel% neq 0 (
    echo.
    echo Warning: Python 3.9.13 is recommended, but a different version was detected.
    echo.
    echo Continuing with a different version may cause unexpected issues.
    goto ASK_CONTINUE
)

:: Continue if version is correct
echo Python version check passed.
goto END

:: -----------------------------------
:: Continuation prompt loop
:ASK_CONTINUE
set /p CONTINUE="Continue with the current Python version? (Y/N): "

if /i "%CONTINUE%" == "N" (
    echo.
    echo Setup has been cancelled. Please install Python 3.9.13.
    echo.
    echo Press any key to exit...
    pause > NUL
    exit /b
) else if /i "%CONTINUE%" == "Y" (
    echo Continuing with current Python version...
) else (
    echo Invalid input. Please enter Y or N.
    echo.
    goto ASK_CONTINUE
)

:: -----------------------------------
:: Final processing
:END
echo.
echo Proceeding with setup...

setlocal enabledelayedexpansion

REM CUDA version check
echo Checking CUDA version...

:: 1. Check if nvcc command exists
where nvcc >nul 2>&1
if %errorlevel% neq 0 (
    echo CUDA not found. Please install CUDA 12.1.
    echo See https://developer.nvidia.com/cuda-downloads for details.
    echo.
    echo Press any key to exit...
    pause > NUL
    exit /b 1
)

:: 2. Get CUDA version
set "CUDA_VERSION="
for /f "tokens=* delims=" %%i in ('nvcc --version ^| findstr /C:"release"') do (
    for /f "tokens=6 delims= " %%j in ("%%i") do (
        set "FULL_VERSION=%%j"
        set "FULL_VERSION=!FULL_VERSION:V=!"
        for /f "tokens=1,2 delims=." %%a in ("!FULL_VERSION!") do (
            set "CUDA_VERSION=%%a.%%b"
        )
    )
)

:: 3. Handle case where version couldn't be detected
if "%CUDA_VERSION%" == "" (
    echo Failed to detect CUDA version. The output format of 'nvcc --version' may have changed.
    echo Please check the output of 'nvcc --version' manually.
    echo.
    echo Press any key to exit...
    pause > NUL
    exit /b 1
)

:: 4. Version check
if not "%CUDA_VERSION%" == "12.1" (
    echo.
    echo Warning: CUDA 12.1 is recommended, but %CUDA_VERSION% was detected.
    echo.
    echo Continuing with a different version may cause unexpected issues.
    call :ASK_CONTINUE
    if errorlevel 1 exit /b 1
) else (
    echo CUDA version is correctly detected.
)

:: Success handling
echo CUDA version check passed.
goto END

:: -----------------------------------
:: Continuation prompt loop
:ASK_CONTINUE
set /p CONTINUE="Continue with the current CUDA version? (Y/N): "

if /i "%CONTINUE%" == "N" (
    echo.
    echo Setup has been cancelled. Please install CUDA 12.1.
    echo See https://developer.nvidia.com/cuda-downloads for details.
    echo.
    echo Press any key to exit...
    pause > NUL
    exit /b 1
) else if /i "%CONTINUE%" == "Y" (
    echo Continuing with current CUDA version...
    exit /b 0
) else (
    echo Invalid input. Please enter Y or N.
    echo.
    goto ASK_CONTINUE
)

:: -----------------------------------
:: Final processing
:END
echo.
echo Proceeding with setup...

REM Clone repository
echo Checking if repository exists...
if exist zundamon-speech-webui (
    echo Repository already cloned. Skipping clone process.
) else (
    echo Cloning repository...
    echo This process may take some time. Progress will be displayed.
    git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
)

cd zundamon-speech-webui

REM Install PyTorch (CPU version)
echo Installing PyTorch (CPU version)...
pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121
if %errorlevel% neq 0 (
    echo Failed to install PyTorch.
    cd ..
    pause
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
pip install -r ../requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install dependencies.
    cd ..
    pause
    exit /b 1
)

echo Installing Git LFS...
git lfs install
if %errorlevel% neq 0 (
    echo Failed to install Git LFS.
    cd ..
    pause
    exit /b 1
)

echo Checking if pre-trained models exist...
pushd GPT-SoVITS\GPT_SoVITS\pretrained_models
if exist gsv-v2final-pretrained (
    echo Pre-trained models already downloaded. Skipping download process.
) else (
    echo Downloading pre-trained models...
    echo This is a large file and may take time to download. Progress will be displayed.
    git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    if %errorlevel% neq 0 (
        echo Failed to download pre-trained models.
        popd
        cd ..\..\..
        pause
        exit /b 1
    )

    echo Moving downloaded files up one level...
    pushd GPT-SoVITS
    for /D %%d in (*) do (
        move "%%d" ..
    )
    for %%f in (*.*) do (
        move "%%f" ..
    )
    popd
)
popd

REM Download and place G2PW model
echo Checking if G2PW model exists...
if exist GPT-SoVITS\GPT_SoVITS\text\G2PWModel (
    echo G2PW model already downloaded and placed. Skipping process.
) else (
    echo Downloading G2PW model...
    echo This download may take some time. You can check the progress with the progress bar.
    curl -L -# https://paddlespeech.bj.bcebos.com/Parakeet/released_models/g2p/G2PWModel_1.1.zip -o G2PWModel.zip
    if %errorlevel% neq 0 (
        echo Failed to download G2PW model.
        cd ..
        pause
        exit /b 1
    )

    echo Extracting G2PW model...
    powershell -command "Expand-Archive -Path G2PWModel.zip -DestinationPath temp_g2pw -Force"
    if %errorlevel% neq 0 (
        echo Failed to extract G2PW model.
        del G2PWModel.zip
        cd ..
        pause
        exit /b 1
    )

    echo Checking extracted folder name...
    if exist temp_g2pw\g2pw (
        echo Renaming extracted folder to "G2PWModel"...
        ren temp_g2pw\g2pw G2PWModel
    )
    if exist temp_g2pw\G2PWModel_1.1 (
        echo Renaming extracted folder to "G2PWModel"...
        ren temp_g2pw\G2PWModel_1.1 G2PWModel
    )

    echo Placing G2PW model...
    move temp_g2pw\G2PWModel GPT-SoVITS\GPT_SoVITS\text\

    rmdir /s /q temp_g2pw
    del G2PWModel.zip
)

REM Download and place Zundamon fine-tuned model
echo Checking if Zundamon fine-tuned model exists...
if exist GPT-SoVITS\GPT_weights_v2 (
    if exist GPT-SoVITS\SoVITS_weights_v2 (
        echo Zundamon fine-tuned model already downloaded and placed. Skipping process.
    ) else (
        echo SoVITS_weights_v2 not found. Downloading model.
        goto download_zundamon_model
    )
) else (
    echo GPT_weights_v2 not found. Downloading model.
    goto download_zundamon_model
)

:download_zundamon_model
echo Downloading Zundamon fine-tuned model...
echo This process may take some time. Progress will be displayed.
git clone --progress https://huggingface.co/zunzunpj/zundamon_GPT-SoVITS
if %errorlevel% neq 0 (
    echo Failed to download Zundamon fine-tuned model.
    cd ..
    pause
    exit /b 1
)

echo Placing Zundamon fine-tuned model...
if exist GPT-SoVITS\GPT_weights_v2 rmdir /s /q GPT-SoVITS\GPT_weights_v2
if exist GPT-SoVITS\SoVITS_weights_v2 rmdir /s /q GPT-SoVITS\SoVITS_weights_v2
move zundamon_GPT-SoVITS\GPT_weights_v2 GPT-SoVITS\
move zundamon_GPT-SoVITS\SoVITS_weights_v2 GPT-SoVITS\
rmdir /s /q zundamon_GPT-SoVITS

REM Check if FFmpeg and FFprobe exist
echo Checking if FFmpeg and FFprobe exist...
if exist GPT-SoVITS\ffmpeg.exe (
    if exist GPT-SoVITS\ffprobe.exe (
        echo FFmpeg and FFprobe already downloaded and placed. Skipping process.
    ) else (
        echo FFprobe not found. Downloading.
        goto download_ffmpeg
    )
) else (
    echo FFmpeg not found. Downloading.
    goto download_ffmpeg
)

:download_ffmpeg
echo Downloading FFmpeg...
echo Download progress will be shown with a progress bar.
curl -L -# https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/ffmpeg.exe -o GPT-SoVITS\ffmpeg.exe
if %errorlevel% neq 0 (
    echo Failed to download FFmpeg.
    cd ..
    pause
    exit /b 1
)

echo Downloading FFprobe...
echo Download progress will be shown with a progress bar.
curl -L -# https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/ffprobe.exe -o GPT-SoVITS\ffprobe.exe
if %errorlevel% neq 0 (
    echo Failed to download FFprobe.
    cd ..
    pause
    exit /b 1
)

@REM REM Download NLTK resources
@REM echo Downloading NLTK resources...
@REM python -c "import nltk; nltk.download('averaged_perceptron_tagger'); nltk.download('averaged_perceptron_tagger_eng')"
@REM if %errorlevel% neq 0 (
@REM     echo Failed to download NLTK resources.
@REM     cd ..
@REM     pause
@REM     exit /b 1
@REM )

REM Create launch batch file
echo Creating launch batch file...
cd ..
echo @echo off > launch_zundamon.bat
echo chcp 65001 ^> NUL >> launch_zundamon.bat
echo cd /d %%~dp0 >> launch_zundamon.bat
@REM echo call zundamon_env\Scripts\activate >> launch_zundamon.bat
echo cd zundamon-speech-webui >> launch_zundamon.bat
echo ./python/python zundamon_speech_run.py >> launch_zundamon.bat
echo pause >> launch_zundamon.bat

echo.
echo ===== Setup completed! =====
echo You can now run launch_zundamon.bat to start Zundamon voice synthesis.
@REM echo Press any key to close this window.
@REM pause > NUL
exit