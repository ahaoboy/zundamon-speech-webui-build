﻿
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

@REM REM Install PyTorch (CPU version)
@REM echo Installing PyTorch (CPU version)...
@REM echo PyTorch (CPU版) をインストールしています...
@REM pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cpu
@REM if %errorlevel% neq 0 (
@REM     echo Failed to install PyTorch.
@REM     echo PyTorchのインストールに失敗しました。
@REM     cd ..
@REM     pause
@REM     exit /b 1
@REM )

@REM REM Install dependencies
@REM echo Installing dependencies...
@REM echo 依存関係をインストールしています...
@REM pip install -r ../requirements.txt
@REM if %errorlevel% neq 0 (
@REM     echo Failed to install dependencies.
@REM     echo 依存関係のインストールに失敗しました。
@REM     cd ..
@REM     pause
@REM     exit /b 1
@REM )

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

@REM REM Download NLTK resources
@REM echo Downloading NLTK resources...
@REM echo NLTKリソースをダウンロードしています...
@REM python -c "import nltk; nltk.download('averaged_perceptron_tagger'); nltk.download('averaged_perceptron_tagger_eng')"
@REM if %errorlevel% neq 0 (
@REM     echo Failed to download NLTK resources.
@REM     echo NLTKリソースのダウンロードに失敗しました。
@REM     cd ..
@REM     pause
@REM     exit /b 1
@REM )

@REM REM Create launch batch file
@REM echo Creating launch batch file...
@REM echo 起動用バッチファイルを作成しています...
@REM cd ..
@REM echo @echo off > launch_zundamon.bat
@REM echo chcp 65001 ^> NUL >> launch_zundamon.bat
@REM echo cd /d %%~dp0 >> launch_zundamon.bat
@REM echo call zundamon_env\Scripts\activate >> launch_zundamon.bat
@REM echo cd zundamon-speech-webui >> launch_zundamon.bat
@REM echo python zundamon_speech_run.py >> launch_zundamon.bat
@REM echo pause >> launch_zundamon.bat

echo.
echo ===== Setup completed! =====
echo ===== セットアップが完了しました！ =====
echo You can now run launch_zundamon.bat to start Zundamon voice synthesis.
echo 今後はlaunch_zundamon.batを実行することでZundamon Speechを起動できます。
echo Press any key to close this window.
echo 何かキーを押して画面を閉じてください
pause > NUL
exit