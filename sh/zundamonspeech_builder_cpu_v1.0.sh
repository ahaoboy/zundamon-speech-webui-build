
PYTHON_VERSION="3.9.13"
DOWNLOAD_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-embed-amd64.zip"
ZIP_NAME="python-${PYTHON_VERSION}-embed-amd64.zip"
TARGET_DIR="python"
GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py"
GET_PIP_NAME="get-pip.py"
PIP_PATH=$(realpath "./python/Scripts/pip")
PYTHON_PATH=$(realpath "./python/python")

echo $PIP_PATH
echo $PYTHON_PATH

# Create the target directory if it doesn’t exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Download the embeddable Python zip if not already present
if [ -f "$ZIP_NAME" ]; then
    echo "Python zip file already exists: $ZIP_NAME"
else
    echo "Downloading Python ${PYTHON_VERSION} embeddable zip for Windows x86-64..."
    curl -L -# "$DOWNLOAD_URL" -o "$ZIP_NAME"
    if [ $? -ne 0 ]; then
        echo "Failed to download Python ${PYTHON_VERSION}. Please check your internet connection."
        exit 1
    fi
    echo "Download completed: $ZIP_NAME"
fi

# Extract the zip file to the target directory
echo "Extracting $ZIP_NAME to $TARGET_DIR..."
unzip -o "$ZIP_NAME" -d "$TARGET_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to extract $ZIP_NAME. Please ensure 'unzip' is installed."
    exit 1
fi

# Clean up the downloaded zip file
# rm "$ZIP_NAME"

# Download get-pip.py if not already present
if [ -f "$GET_PIP_NAME" ]; then
    echo "get-pip.py already exists: $GET_PIP_NAME"
else
    echo "Downloading get-pip.py..."
    curl -L -# "$GET_PIP_URL" -o "$GET_PIP_NAME"
    if [ $? -ne 0 ]; then
        echo "Failed to download get-pip.py. Please check your internet connection."
        exit 1
    fi
    echo "Download completed: $GET_PIP_NAME"
fi

# Modify python39._pth to enable site-packages (required for pip)
echo "Configuring python39._pth to enable site-packages..."
PTH_FILE="$TARGET_DIR/python39._pth"
if [ -f "$PTH_FILE" ]; then
    # Uncomment or add the site-packages line
    sed -i 's/#import site/import site/' "$PTH_FILE" || echo "import site" >> "$PTH_FILE"
else
    echo "import site" > "$PTH_FILE"
fi

# Since we're on a Unix-like system, we can't run the Windows python.exe directly.
# We'll provide instructions for the user to complete the pip installation on Windows.
# echo ""
# echo "Python ${PYTHON_VERSION} embeddable package has been extracted to $TARGET_DIR"
# echo "To install pip, follow these steps on a Windows x86-64 system:"
# echo "1. Transfer the '$TARGET_DIR' directory and '$GET_PIP_NAME' to a Windows machine."
# echo "2. Open a command prompt in the directory containing '$GET_PIP_NAME' and '$TARGET_DIR'."
# echo "3. Run the following command:"
# echo "   $TARGET_DIR\\python.exe $GET_PIP_NAME"
# echo "4. After this, pip will be installed in $TARGET_DIR\\Scripts\\pip.exe."
# echo "5. You can then use pip with: $TARGET_DIR\\Scripts\\pip.exe install <package>"
# echo ""
# echo "Note: If you need to use this on a Unix-like system, consider installing a native Python version."


$PYTHON_PATH "./${GET_PIP_NAME}"




# Prompt the user to confirm prerequisites are installed
# echo "Have you installed Python 3.9.13, Git, and the necessary build tools?"
# echo "Press Enter when you are ready to continue"
# read -r

# # Create virtual environment
# echo "Creating virtual environment..."
# if [ -d "zundamon_env" ]; then
#     echo "Virtual environment already exists."
# else
#     python3 -m venv zundamon_env
#     if [ $? -ne 0 ]; then
#         echo "Failed to create virtual environment. Please check if Python 3 is installed."
#         exit 1
#     fi
#     echo "Virtual environment created."
# fi

# Activate virtual environment
# echo "Activating virtual environment..."
# source zundamon_env/bin/activate

# Check Python version
# echo "Checking Python version..."
# if ! command -v python &> /dev/null; then
#     echo "Python not found. Please install Python 3.9.13."
#     exit 1
# fi

# current_version=$(python -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
# expected_version="3.9.13"
# echo "Current Python version: $current_version"
# if [ "$current_version" != "$expected_version" ]; then
#     echo "Warning: Python 3.9.13 is recommended, but a different version was detected."
#     echo "Continuing with a different version may cause unexpected issues."
#     while true; do
#         read -p "Do you want to continue with the current Python version? (Y/N): " continue_choice
#         case $continue_choice in
#             [Yy]*)
#                 echo "Continuing with current Python version..."
#                 break
#                 ;;
#             [Nn]*)
#                 echo "Setup has been cancelled. Please install Python 3.9.13."
#                 exit 1
#                 ;;
#             *)
#                 echo "Invalid input. Please enter Y or N."
#                 ;;
#         esac
#     done
# else
#     echo "Python version check passed."
# fi

# echo "Proceeding with setup..."

# Clone repository
echo "Checking if repository exists..."
if [ -d "zundamon-speech-webui" ]; then
    echo "Repository already cloned. Skipping clone process."
else
    echo "Cloning repository..."
    echo "This process may take some time. Progress will be displayed."
    git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository."
        exit 1
    fi
fi

# Change to the repository directory
cd zundamon-speech-webui || exit 1

# Install PyTorch (CPU version)
echo "Installing PyTorch (CPU version)..."
../python/Scripts/pip  install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cpu
# $PIP_PATH  install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2
if [ $? -ne 0 ]; then
    echo "Failed to install PyTorch."
    cd ..
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
$PIP_PATH install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies."
    cd ..
    exit 1
fi

# Install Git LFS
echo "Installing Git LFS..."
git lfs install
if [ $? -ne 0 ]; then
    echo "Failed to install Git LFS."
    cd ..
    exit 1
fi

# Check and download pre-trained models
echo "Checking if pre-trained models exist..."
if [ -d "GPT-SoVITS/GPT_SoVITS/pretrained_models/gsv-v2final-pretrained" ]; then
    echo "Pre-trained models already downloaded. Skipping download process."
else
    echo "Downloading pre-trained models..."
    echo "This is a large file and may take time to download. Progress will be displayed."
    pushd GPT-SoVITS/GPT_SoVITS/pretrained_models
    git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    if [ $? -ne 0 ]; then
        echo "Failed to download pre-trained models."
        popd
        cd ../..
        exit 1
    fi
    mv GPT-SoVITS/* .
    rm -rf GPT-SoVITS
    popd
fi

# Check and download G2PW model
echo "Checking if G2PW model exists..."
if [ -d "GPT-SoVITS/GPT_SoVITS/text/G2PWModel" ]; then
    echo "G2PW model already downloaded and placed. Skipping process."
else
    echo "Downloading G2PW model..."
    echo "This download may take some time. You can check the progress with the progress bar."
    curl -L -# https://paddlespeech.bj.bcebos.com/Parakeet/released_models/g2p/G2PWModel_1.1.zip -o G2PWModel.zip
    if [ $? -ne 0 ]; then
        echo "Failed to download G2PW model."
        cd ..
        exit 1
    fi

    echo "Extracting G2PW model..."
    unzip -o G2PWModel.zip -d temp_g2pw
    if [ $? -ne 0 ]; then
        echo "Failed to extract G2PW model."
        rm G2PWModel.zip
        cd ..
        exit 1
    fi

    echo "Placing G2PW model..."
    mv temp_g2pw/G2PWModel_1.1 GPT-SoVITS/GPT_SoVITS/text/G2PWModel
    rm -rf temp_g2pw
    rm G2PWModel.zip
fi

# Check and download Zundamon fine-tuned model
echo "Checking if Zundamon fine-tuned model exists..."
if [ -d "GPT-SoVITS/GPT_weights_v2" ] && [ -d "GPT-SoVITS/SoVITS_weights_v2" ]; then
    echo "Zundamon fine-tuned model already downloaded and placed. Skipping process."
else
    echo "Downloading Zundamon fine-tuned model..."
    echo "This process may take some time. Progress will be displayed."
    git clone --progress https://huggingface.co/zunzunpj/zundamon_GPT-SoVITS
    if [ $? -ne 0 ]; then
        echo "Failed to download Zundamon fine-tuned model."
        cd ..
        exit 1
    fi

    echo "Placing Zundamon fine-tuned model..."
    rm -rf GPT-SoVITS/GPT_weights_v2
    rm -rf GPT-SoVITS/SoVITS_weights_v2
    mv zundamon_GPT-SoVITS/GPT_weights_v2 GPT-SoVITS/
    mv zundamon_GPT-SoVITS/SoVITS_weights_v2 GPT-SoVITS/
    rm -rf zundamon_GPT-SoVITS
fi

# Check for FFmpeg and FFprobe
echo "Checking if FFmpeg and FFprobe are installed..."
if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
    echo "FFmpeg and/or FFprobe not found. Please install them using your package manager."
    echo "For example, on Ubuntu: sudo apt-get install ffmpeg"
    cd ..
    exit 1
fi

# Download NLTK resources
echo "Downloading NLTK resources..."
$PYTHON_PATH  -c "import nltk; nltk.download('averaged_perceptron_tagger'); nltk.download('averaged_perceptron_tagger_eng')"
if [ $? -ne 0 ]; then
    echo "Failed to download NLTK resources."
    cd ..
    exit 1
fi

# Create launch script
echo "Creating launch script..."
cd ..
cat << EOF > launch_zundamon.sh
#!/bin/bash
cd "\$(dirname "\$0")"
source zundamon_env/bin/activate
cd zundamon-speech-webui
./python/python.exe zundamon_speech_run.py
EOF
chmod +x launch_zundamon.sh

# Final message
echo ""
echo "===== Setup completed! ====="
echo "You can now run ./launch_zundamon.sh to start Zundamon voice synthesis."
echo ""
echo "Press Enter to close this window."
read -r