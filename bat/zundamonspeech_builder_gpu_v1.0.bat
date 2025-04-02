@echo off

REM UTF-8 with BOM for Japanese characters
chcp 65001 > NUL
cd /d %~dp0
@ echo off
echo Python3.9.13、Git、Visual Studio Build Tools、CMake、CUDA12.1のインストールはできましたか？
echo Have you installed Python3.9.13, Git, Visual Studio Build Tools, CMake, and CUDA12.1?
echo 準備ができたら何かキーを押してください
echo Press any key when you are ready to continue
pause > NUL

REM Create virtual environment
echo Creating virtual environment...
echo 仮想環境を作成しています...
if exist zundamon_env (
    echo Virtual environment already exists.
    echo 仮想環境は既に存在します。
) else (
    python -m venv zundamon_env
    if %errorlevel% neq 0 (
        echo Failed to create virtual environment. Please check if Python 3.9.13 is installed.
        echo 仮想環境の作成に失敗しました。Python 3.9.13がインストールされているか確認してください。
        pause
        exit /b 1
    )
    echo Virtual environment created.
    echo 仮想環境を作成しました。
)

echo Activating virtual environment...
echo 仮想環境を有効化しています...
call zundamon_env\Scripts\activate
if %errorlevel% neq 0 (
    echo Failed to activate virtual environment.
    echo 仮想環境の有効化に失敗しました。
    pause
    exit /b 1
)

REM Pythonのバージョンチェック
echo Pythonバージョンを確認しています...
echo Checking Python version...

:: 1. Pythonコマンドが存在するかチェック
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Pythonが見つかりません。Python 3.9.13をインストールしてください。
    echo.
    echo 何かキーを押して終了してください...
    pause > NUL
    exit /b
)

:: 2. Pythonバージョンをチェック
python -c "import sys; version='3.9.13'; current='.'.join(map(str, sys.version_info[:3])); print(f'Current Python version: {current}'); sys.exit(0 if current == version else 1)"
if %errorlevel% neq 0 (
    echo.
    echo 警告: Python 3.9.13が推奨されていますが、異なるバージョンが検出されました。
    echo Warning: Python 3.9.13 is recommended, but a different version was detected.
    echo.
    echo 異なるバージョンで続行すると予期しない問題が発生する可能性があります。
    echo Continuing with a different version may cause unexpected issues.

    goto ASK_CONTINUE  :: 続行確認のループへ移動
)

:: バージョンが正常の場合は処理を継続
echo Pythonバージョンチェックが完了しました。
echo Python version check passed.
goto END

:: -----------------------------------
:: 続行確認のループ
:ASK_CONTINUE
set /p CONTINUE="現在のPythonバージョンで続行しますか？ (Y/N): "

if /i "%CONTINUE%" == "N" (
    echo.
    echo セットアップがキャンセルされました。Python 3.9.13をインストールしてください。
    echo Setup has been cancelled. Please install Python 3.9.13.
    echo.
    echo 何かキーを押して終了してください...
    pause > NUL
    exit /b
) else if /i "%CONTINUE%" == "Y" (
    echo 現在のPythonバージョンで続行します...
    echo Continuing with current Python version...
) else (
    echo 無効な入力です。YまたはNを入力してください。
    echo Invalid input. Please enter Y or N.
    echo.
    goto ASK_CONTINUE  :: 無効な入力時は再度質問
)

:: -----------------------------------
:: 最終処理
:END
echo.
echo セットアップを続行中...
echo Proceeding with setup...

setlocal enabledelayedexpansion

REM CUDAのバージョンチェック
echo CUDAバージョンを確認しています...
echo Checking CUDA version...

:: 1. nvccコマンドが存在するかチェック
where nvcc >nul 2>&1
if %errorlevel% neq 0 (
    echo CUDAが見つかりません。CUDA 12.1をインストールしてください。
    echo 詳細は https://developer.nvidia.com/cuda-downloads を確認してください。
    echo.
    echo 何かキーを押して終了してください...
    pause > NUL
    exit /b 1
)

:: 2. CUDAバージョンを取得
set "CUDA_VERSION="
for /f "tokens=* delims=" %%i in ('nvcc --version ^| findstr /C:"release"') do (
    for /f "tokens=6 delims= " %%j in ("%%i") do (
        set "FULL_VERSION=%%j"
        :: 先頭のVがある場合は削除
        set "FULL_VERSION=!FULL_VERSION:V=!"
        :: メジャー.マイナーバージョンのみ抽出（最初の2つの数字部分）
        for /f "tokens=1,2 delims=." %%a in ("!FULL_VERSION!") do (
            set "CUDA_VERSION=%%a.%%b"
        )
    )
)

:: 3. バージョンが取得できなかった場合の処理
if "%CUDA_VERSION%" == "" (
    echo CUDAバージョンの検出に失敗しました。nvcc --versionの出力形式が変更されている可能性があります。
    echo Please check the output of 'nvcc --version' manually.
    echo.
    echo 何かキーを押して終了してください...
    pause > NUL
    exit /b 1
)

:: 4. バージョンチェック
if not "%CUDA_VERSION%" == "12.1" (
    echo.
    echo 警告: CUDA 12.1が推奨されていますが、%CUDA_VERSION%が検出されました。
    echo Warning: CUDA 12.1 is recommended, but %CUDA_VERSION% was detected.
    echo.
    echo 違うバージョンで続行すると予期しない問題が発生する可能性があります。
    echo Continuing with a different version may cause unexpected issues.
    
    call :ASK_CONTINUE
    if errorlevel 1 exit /b 1
) else (
    echo CUDAバージョンが正しく検出されました。
    echo CUDA version is correctly detected.
)

:: 成功時処理
echo CUDAバージョンチェックが完了しました。
echo CUDA version check passed.
goto END

:: -----------------------------------
:: 続行確認ループ
:ASK_CONTINUE
set /p CONTINUE="現在のCUDAバージョンで続行しますか？ (Y/N): "

if /i "%CONTINUE%" == "N" (
    echo.
    echo セットアップがキャンセルされました。CUDA 12.1をインストールしてください。
    echo Setup has been cancelled. Please install CUDA 12.1.
    echo 詳細は https://developer.nvidia.com/cuda-downloads を確認してください。
    echo.
    echo 何かキーを押して終了してください...
    pause > NUL
    exit /b 1
) else if /i "%CONTINUE%" == "Y" (
    echo 現在のCUDAバージョンで続行します...
    echo Continuing with current CUDA version...
    exit /b 0
) else (
    echo 無効な入力です。YまたはNを入力してください。
    echo Invalid input. Please enter Y or N.
    echo.
    goto ASK_CONTINUE
)

:: -----------------------------------
:: 最終処理
:END
echo.
echo セットアップを続行中...
echo Proceeding with setup...

REM Clone repository
echo Checking if repository exists...
echo リポジトリの存在を確認しています...
if exist zundamon-speech-webui (
    echo Repository already cloned. Skipping clone process.
    echo リポジトリは既にクローンされています。クローン処理をスキップします。
) else (
    echo Cloning repository...
    echo リポジトリをクローンしています...
    echo このプロセスには時間がかかる場合があります。進捗状況が表示されます。
    echo This process may take some time. Progress will be displayed.
    git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
)

cd zundamon-speech-webui

REM Install PyTorch (CPU version)
echo Installing PyTorch (CPU version)...
echo PyTorch (GPU版) をインストールしています...
pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121
if %errorlevel% neq 0 (
    echo Failed to install PyTorch.
    echo PyTorchのインストールに失敗しました。
    cd ..
    pause
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
echo 依存関係をインストールしています...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install dependencies.
    echo 依存関係のインストールに失敗しました。
    cd ..
    pause
    exit /b 1
)

echo Installing Git LFS...
echo Git LFSをインストールしています...
git lfs install
if %errorlevel% neq 0 (
    echo Failed to install Git LFS.
    echo Git LFSのインストールに失敗しました。
    cd ..
    pause
    exit /b 1
)

echo Checking if pre-trained models exist...
echo 事前学習済みモデルの存在を確認しています...
pushd GPT-SoVITS\GPT_SoVITS\pretrained_models
if exist gsv-v2final-pretrained (
    echo Pre-trained models already downloaded. Skipping download process.
    echo 事前学習済みモデルは既にダウンロードされています。ダウンロード処理をスキップします。
) else (
    echo Downloading pre-trained models...
    echo 事前学習済みモデルをダウンロードしています...
    echo 大きなファイルのため、ダウンロードには時間がかかります。進捗状況が表示されます。
    echo This is a large file and may take time to download. Progress will be displayed.
    git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    if %errorlevel% neq 0 (
        echo Failed to download pre-trained models.
        echo 事前学習済みモデルのダウンロードに失敗しました。
        popd
        cd ..\..\..
        pause
        exit /b 1
    )
    
    echo Moving downloaded files up one level...
    echo ダウンロードしたファイルを1つ上の階層に移動しています...
    REM Current directory is GPT-SoVITS\GPT_SoVITS\pretrained_models
    pushd GPT-SoVITS
    REM Move all files and folders in GPT-SoVITS directory one level up
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
echo G2PWモデルの存在を確認しています...
if exist GPT-SoVITS\GPT_SoVITS\text\G2PWModel (
    echo G2PW model already downloaded and placed. Skipping process.
    echo G2PWモデルは既にダウンロード・配置されています。処理をスキップします。
) else (
    echo Downloading G2PW model...
    echo G2PWモデルをダウンロードしています...
    echo このダウンロードには時間がかかる場合があります。プログレスバーで進捗状況を確認できます。
    echo This download may take some time. You can check the progress with the progress bar.
    curl -L -# https://paddlespeech.bj.bcebos.com/Parakeet/released_models/g2p/G2PWModel_1.1.zip -o G2PWModel.zip
    if %errorlevel% neq 0 (
        echo Failed to download G2PW model.
        echo G2PWモデルのダウンロードに失敗しました。
        cd ..
        pause
        exit /b 1
    )

    echo Extracting G2PW model...
    echo G2PWモデルを解凍しています...
    powershell -command "Expand-Archive -Path G2PWModel.zip -DestinationPath temp_g2pw -Force"
    if %errorlevel% neq 0 (
        echo Failed to extract G2PW model.
        echo G2PWモデルの解凍に失敗しました。
        del G2PWModel.zip
        cd ..
        pause
        exit /b 1
    )

    echo Checking extracted folder name...
    echo 解凍したフォルダ名を確認しています...
    REM If the extracted folder is named "g2pw", rename it to "G2PWModel"
    if exist temp_g2pw\g2pw (
        echo Renaming extracted folder to "G2PWModel"...
        echo 解凍したフォルダを「G2PWModel」に名前変更しています...
        ren temp_g2pw\g2pw G2PWModel
    )
    REM If the extracted folder is named "G2PWModel_1.1" etc., also rename it to "G2PWModel"
    if exist temp_g2pw\G2PWModel_1.1 (
        echo Renaming extracted folder to "G2PWModel"...
        echo 解凍したフォルダを「G2PWModel」に名前変更しています...
        ren temp_g2pw\G2PWModel_1.1 G2PWModel
    )

    echo Placing G2PW model...
    echo G2PWモデルを配置しています...
    move temp_g2pw\G2PWModel GPT-SoVITS\GPT_SoVITS\text\
    
    rmdir /s /q temp_g2pw
    del G2PWModel.zip
)

REM Download and place Zundamon fine-tuned model
echo Checking if Zundamon fine-tuned model exists...
echo ずんだもん用微調整モデルの存在を確認しています...
if exist GPT-SoVITS\GPT_weights_v2 (
    if exist GPT-SoVITS\SoVITS_weights_v2 (
        echo Zundamon fine-tuned model already downloaded and placed. Skipping process.
        echo ずんだもん用微調整モデルは既にダウンロード・配置されています。処理をスキップします。
    ) else (
        echo SoVITS_weights_v2 not found. Downloading model.
        echo SoVITS_weights_v2が見つかりません。モデルをダウンロードします。
        goto download_zundamon_model
    )
) else (
    echo GPT_weights_v2 not found. Downloading model.
    echo GPT_weights_v2が見つかりません。モデルをダウンロードします。
    goto download_zundamon_model
)

:download_zundamon_model
echo Downloading Zundamon fine-tuned model...
echo ずんだもん用微調整モデルをダウンロードしています...
echo このプロセスには時間がかかる場合があります。進捗状況が表示されます。
echo This process may take some time. Progress will be displayed.
git clone --progress https://huggingface.co/zunzunpj/zundamon_GPT-SoVITS
if %errorlevel% neq 0 (
    echo Failed to download Zundamon fine-tuned model.
    echo ずんだもん用微調整モデルのダウンロードに失敗しました。
    cd ..
    pause
    exit /b 1
)

echo Placing Zundamon fine-tuned model...
echo ずんだもん用微調整モデルを配置しています...
if exist GPT-SoVITS\GPT_weights_v2 rmdir /s /q GPT-SoVITS\GPT_weights_v2
if exist GPT-SoVITS\SoVITS_weights_v2 rmdir /s /q GPT-SoVITS\SoVITS_weights_v2
move zundamon_GPT-SoVITS\GPT_weights_v2 GPT-SoVITS\
move zundamon_GPT-SoVITS\SoVITS_weights_v2 GPT-SoVITS\
rmdir /s /q zundamon_GPT-SoVITS

REM Check if FFmpeg and FFprobe exist
echo Checking if FFmpeg and FFprobe exist...
echo FFmpegとFFprobeの存在を確認しています...
if exist GPT-SoVITS\ffmpeg.exe (
    if exist GPT-SoVITS\ffprobe.exe (
        echo FFmpeg and FFprobe already downloaded and placed. Skipping process.
        echo FFmpegとFFprobeは既にダウンロード・配置されています。処理をスキップします。
    ) else (
        echo FFprobe not found. Downloading.
        echo FFprobeが見つかりません。ダウンロードします。
        goto download_ffmpeg
    )
) else (
    echo FFmpeg not found. Downloading.
    echo FFmpegが見つかりません。ダウンロードします。
    goto download_ffmpeg
)

:download_ffmpeg
echo Downloading FFmpeg...
echo FFmpegをダウンロードしています...
echo ダウンロードの進捗状況がプログレスバーで表示されます。
echo Download progress will be shown with a progress bar.
curl -L -# https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/ffmpeg.exe -o GPT-SoVITS\ffmpeg.exe
if %errorlevel% neq 0 (
    echo Failed to download FFmpeg.
    echo FFmpegのダウンロードに失敗しました。
    cd ..
    pause
    exit /b 1
)

echo Downloading FFprobe...
echo FFprobeをダウンロードしています...
echo ダウンロードの進捗状況がプログレスバーで表示されます。
echo Download progress will be shown with a progress bar.
curl -L -# https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/ffprobe.exe -o GPT-SoVITS\ffprobe.exe
if %errorlevel% neq 0 (
    echo Failed to download FFprobe.
    echo FFprobeのダウンロードに失敗しました。
    cd ..
    pause
    exit /b 1
)

REM Download NLTK resources
echo Downloading NLTK resources...
echo NLTKリソースをダウンロードしています...
python -c "import nltk; nltk.download('averaged_perceptron_tagger'); nltk.download('averaged_perceptron_tagger_eng')"
if %errorlevel% neq 0 (
    echo Failed to download NLTK resources.
    echo NLTKリソースのダウンロードに失敗しました。
    cd ..
    pause
    exit /b 1
)

REM Create launch batch file
echo Creating launch batch file...
echo 起動用バッチファイルを作成しています...
cd ..
echo @echo off > launch_zundamon.bat
echo chcp 65001 ^> NUL >> launch_zundamon.bat
echo cd /d %%~dp0 >> launch_zundamon.bat
echo call zundamon_env\Scripts\activate >> launch_zundamon.bat
echo cd zundamon-speech-webui >> launch_zundamon.bat
echo python zundamon_speech_run.py >> launch_zundamon.bat
echo pause >> launch_zundamon.bat

echo.
echo ===== Setup completed! =====
echo ===== セットアップが完了しました！ =====
echo You can now run launch_zundamon.bat to start Zundamon voice synthesis.
echo 今後はlaunch_zundamon.batを実行することでZundamon Speechを起動できます。
echo Press any key to close this window.
echo 何かキーを押して画面を閉じてください
pause > NUL
exit