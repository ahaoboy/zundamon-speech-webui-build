$PYTHON_VERSION = "3.9.13"
$DOWNLOAD_URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
$ZIP_NAME = "python-$PYTHON_VERSION-embed-amd64.zip"
$TARGET_DIR = "python"
$GET_PIP_URL = "https://bootstrap.pypa.io/get-pip.py"
$GET_PIP_NAME = "get-pip.py"

# $PIP_PATH = (Resolve-Path "./$TARGET_DIR/Scripts/pip").Path
# $PYTHON_PATH = (Resolve-Path "./$TARGET_DIR/python").Path

if (-Not (Test-Path -Path $TARGET_DIR)) {
    Write-Output "Creating directory: $TARGET_DIR"
    New-Item -ItemType Directory -Path $TARGET_DIR | Out-Null
}

if (Test-Path $ZIP_NAME) {
    Write-Output "Python zip file already exists: $ZIP_NAME"
} else {
    Write-Output "Downloading Python $PYTHON_VERSION embeddable zip for Windows x86-64..."
    try {
        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_NAME -UseBasicParsing
        Write-Output "Download completed: $ZIP_NAME"
    }
    catch {
        Write-Error "Failed to download Python $PYTHON_VERSION. Please check your internet connection."
        exit 1
    }
}

Write-Output "Extracting $ZIP_NAME to $TARGET_DIR..."
try {
    Expand-Archive -Path $ZIP_NAME -DestinationPath $TARGET_DIR -Force
}
catch {
    Write-Error "Failed to extract $ZIP_NAME. Please ensure that the Expand-Archive cmdlet is available."
    exit 1
}

Remove-Item $ZIP_NAME

if (Test-Path $GET_PIP_NAME) {
    Write-Output "get-pip.py already exists: $GET_PIP_NAME"
} else {
    Write-Output "Downloading get-pip.py..."
    try {
        Invoke-WebRequest -Uri $GET_PIP_URL -OutFile $GET_PIP_NAME -UseBasicParsing
        Write-Output "Download completed: $GET_PIP_NAME"
    }
    catch {
        Write-Error "Failed to download get-pip.py. Please check your internet connection."
        exit 1
    }
}

Write-Output "Configuring python39._pth to enable site-packages..."
$PTH_FILE = Join-Path -Path $TARGET_DIR -ChildPath "python39._pth"
if (Test-Path $PTH_FILE) {
    try {
        (Get-Content $PTH_FILE) | ForEach-Object {
            $_ -replace "#import site", "import site"
        } | Set-Content $PTH_FILE
    }
    catch {
        Add-Content -Path $PTH_FILE -Value "import site"
    }
} else {
    Set-Content -Path $PTH_FILE -Value "import site"
}

./python/python "./$GET_PIP_NAME"

Write-Output "Checking if repository exists..."
if (Test-Path "zundamon-speech-webui") {
    Write-Output "Repository already cloned. Skipping clone process."
} else {
    Write-Output "Cloning repository..."
    Write-Output "This process may take some time. Progress will be displayed."
    try {
        git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
    }
    catch {
        Write-Error "Failed to clone repository."
        exit 1
    }
}

Set-Location "zundamon-speech-webui"

Write-Output "Installing PyTorch (CPU version)..."
../python/Scripts/pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cpu
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install PyTorch."
    Set-Location ..
    exit 1
}

Write-Output "Installing dependencies..."
../python/Scripts/pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install dependencies."
    Set-Location ..
    exit 1
}

Write-Output "Installing Git LFS..."
git lfs install
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Git LFS."
    Set-Location ..
    exit 1
}

Write-Output "Checking if pre-trained models exist..."
if (Test-Path "GPT-SoVITS\GPT_SoVITS\pretrained_models\gsv-v2final-pretrained") {
    Write-Output "Pre-trained models already downloaded. Skipping download process."
} else {
    Write-Output "Downloading pre-trained models..."
    Write-Output "This is a large file and may take time to download. Progress will be displayed."
    Push-Location "GPT-SoVITS\GPT_SoVITS\pretrained_models"
    try {
        git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    }
    catch {
        Write-Error "Failed to download pre-trained models."
        Pop-Location
        Set-Location ..
        exit 1
    }
    Get-ChildItem "GPT-SoVITS" | ForEach-Object {
        Move-Item $_.FullName -Destination "."
    }
    Remove-Item -Recurse -Force "GPT-SoVITS"
    Pop-Location
}

Write-Output "Checking if G2PW model exists..."
if (Test-Path "GPT-SoVITS\GPT_SoVITS\text\G2PWModel") {
    Write-Output "G2PW model already downloaded and placed. Skipping process."
} else {
    Write-Output "Downloading G2PW model..."
    Write-Output "This download may take some time. You can check the progress with the progress bar."
    try {
        Invoke-WebRequest -Uri "https://paddlespeech.bj.bcebos.com/Parakeet/released_models/g2p/G2PWModel_1.1.zip" -OutFile "G2PWModel.zip" -UseBasicParsing
    }
    catch {
        Write-Error "Failed to download G2PW model."
        Set-Location ..
        exit 1
    }

    Write-Output "Extracting G2PW model..."
    try {
        Expand-Archive -Path "G2PWModel.zip" -DestinationPath "temp_g2pw" -Force
    }
    catch {
        Write-Error "Failed to extract G2PW model."
        Remove-Item "G2PWModel.zip" -Force
        Set-Location ..
        exit 1
    }

    Write-Output "Placing G2PW model..."
    Move-Item -Path "temp_g2pw\G2PWModel_1.1" -Destination "GPT-SoVITS\GPT_SoVITS\text\G2PWModel"
    Remove-Item -Recurse -Force "temp_g2pw"
    Remove-Item "G2PWModel.zip" -Force
}

Write-Output "Checking if Zundamon fine-tuned model exists..."
if ((Test-Path "GPT-SoVITS\GPT_weights_v2") -and (Test-Path "GPT-SoVITS\SoVITS_weights_v2")) {
    Write-Output "Zundamon fine-tuned model already downloaded and placed. Skipping process."
} else {
    Write-Output "Downloading Zundamon fine-tuned model..."
    Write-Output "This process may take some time. Progress will be displayed."
    try {
        git clone --progress https://huggingface.co/zunzunpj/zundamon_GPT-SoVITS
    }
    catch {
        Write-Error "Failed to download Zundamon fine-tuned model."
        Set-Location ..
        exit 1
    }

    Write-Output "Placing Zundamon fine-tuned model..."
    Remove-Item -Recurse -Force "GPT-SoVITS\GPT_weights_v2" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "GPT-SoVITS\SoVITS_weights_v2" -ErrorAction SilentlyContinue
    Move-Item -Path "zundamon_GPT-SoVITS\GPT_weights_v2" -Destination "GPT-SoVITS\"
    Move-Item -Path "zundamon_GPT-SoVITS\SoVITS_weights_v2" -Destination "GPT-SoVITS\"
    Remove-Item -Recurse -Force "zundamon_GPT-SoVITS"
}

Write-Output "Checking if FFmpeg and FFprobe are installed..."
$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
$ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue
if (-Not $ffmpeg -or -Not $ffprobe) {
    Write-Error "FFmpeg and/or FFprobe not found. Please install them using your package manager.
For example, on Ubuntu: sudo apt-get install ffmpeg"
    Set-Location ..
    exit 1
}

Write-Output "Downloading NLTK resources..."
../python/Scripts -c "import nltk; nltk.download('averaged_perceptron_tagger'); nltk.download('averaged_perceptron_tagger_eng')"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download NLTK resources."
    Set-Location ..
    exit 1
}

Write-Output "Creating launch script..."
Set-Location ..
$launchScriptContent = @'
#!/bin/bash
cd "$(dirname "$0")"
source zundamon_env/bin/activate
cd zundamon-speech-webui
./python/python.exe zundamon_speech_run.py
'@
Set-Content -Path "launch_zundamon.sh" -Value $launchScriptContent

Write-Output ""
Write-Output "===== Setup completed! ====="
Write-Output "You can now run ./launch_zundamon.sh to start Zundamon voice synthesis."
Write-Output ""
Write-Host "Press Enter to close this window."
Read-Host
