@echo off

REM UTF-8 with BOM for Japanese characters
chcp 65001 > NUL
cd /d %~dp0

@REM HACK
cd ..

@REM @ echo off
@REM echo Have you installed Python3.9.13, Git, Visual Studio Build Tools, and CMake?
@REM echo Press any key when you are ready to continue
@REM pause > NUL

REM Create virtual environment
echo Creating virtual environment...
if exist zundamon_env (
    echo Virtual environment already exists.
) else (
    python -m venv zundamon_env
    if %errorlevel% neq 0 (
        echo Failed to create virtual environment. Please check if Python 3.9.13 is installed.
        pause
        exit /b 1
    )
    echo Virtual environment created.
)

echo Activating virtual environment...
call zundamon_env\Scripts\activate
if %errorlevel% neq 0 (
    echo Failed to activate virtual environment.
    pause
    exit /b 1
)

echo Checking Python version...

:: 1. Check if Python command exists
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Please install Python 3.9.13.
    pause > NUL
    exit /b
)

:: 2. Check Python version
python -c "import sys; version='3.9.13'; current='.'.join(map(str, sys.version_info[:3])); print(f'Current Python version: {current}'); sys.exit(0 if current == version else 1)"
if %errorlevel% neq 0 (
    echo Warning: Python 3.9.13 is recommended, but a different version was detected.
    goto ASK_CONTINUE
)

echo Python version check passed.
goto END

:ASK_CONTINUE
set /p CONTINUE="Do you want to continue with the current Python version? (Y/N): "
if /i "%CONTINUE%" == "N" (
    echo Setup has been cancelled. Please install Python 3.9.13.
    pause > NUL
    exit /b
) else if /i "%CONTINUE%" == "Y" (
    echo Continuing with current Python version...
) else (
    echo Invalid input. Please enter Y or N.
    goto ASK_CONTINUE
)

:END
echo Proceeding with setup...

REM Clone repository
echo Checking if repository exists...
if exist zundamon-speech-webui (
    echo Repository already cloned. Skipping clone process.
) else (
    echo Cloning repository...
    git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
)

cd zundamon-speech-webui

REM Install PyTorch (CPU version)
echo Installing PyTorch (CPU version)...
pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cpu
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

REM Install Git LFS
echo Installing Git LFS...
git lfs install
if %errorlevel% neq 0 (
    echo Failed to install Git LFS.
    cd ..
    pause
    exit /b 1
)

REM Check if pre-trained models exist
echo Checking if pre-trained models exist...
pushd GPT-SoVITS\GPT_SoVITS\pretrained_models
if exist gsv-v2final-pretrained (
    echo Pre-trained models already downloaded. Skipping download process.
) else (
    echo Downloading pre-trained models...
    git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    if %errorlevel% neq 0 (
        echo Failed to download pre-trained models.
        popd
        cd ..\..\..
        pause
        exit /b 1
    )
)
popd

REM Download and place G2PW model
echo Checking if G2PW model exists...
if exist GPT-SoVITS\GPT_SoVITS\text\G2PWModel (
    echo G2PW model already downloaded and placed. Skipping process.
) else (
    echo Downloading G2PW model...
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
    move temp_g2pw\G2PWModel GPT-SoVITS\GPT_SoVITS\text\
    rmdir /s /q temp_g2pw
    del G2PWModel.zip
)

REM Create launch batch file
echo Creating launch batch file...
cd ..
echo @echo off > launch_zundamon.bat
echo chcp 65001 ^> NUL >> launch_zundamon.bat
echo cd /d %%~dp0 >> launch_zundamon.bat
echo call zundamon_env\Scripts\activate >> launch_zundamon.bat
echo cd zundamon-speech-webui >> launch_zundamon.bat
echo ./python/python zundamon_speech_run.py >> launch_zundamon.bat
echo pause >> launch_zundamon.bat

echo.
echo ===== Setup completed! =====
echo You can now run launch_zundamon.bat to start Zundamon voice synthesis.
@REM echo Press any key to close this window.
@REM pause > NUL
exit
