#!/bin/bash

# Clone repository
echo "Checking if repository exists..."
if [ -d "zundamon-speech-webui" ]; then
    echo "Repository already cloned. Skipping clone process."
else
    echo "Cloning repository..."
    echo "This process may take some time. Progress will be displayed."
    git clone --progress --recursive https://github.com/zunzun999/zundamon-speech-webui.git
fi

cd zundamon-speech-webui

# Install Git LFS
echo "Installing Git LFS..."
git lfs install
if [ $? -ne 0 ]; then
    echo "Failed to install Git LFS."
    cd ..
    exit 1
fi

# Check if pre-trained models exist
echo "Checking if pre-trained models exist..."
pushd GPT-SoVITS/GPT_SoVITS/pretrained_models
if [ -d "gsv-v2final-pretrained" ]; then
    echo "Pre-trained models already downloaded. Skipping download process."
else
    echo "Downloading pre-trained models..."
    echo "This is a large file and may take time to download. Progress will be displayed."
    git clone --progress https://huggingface.co/lj1995/GPT-SoVITS
    if [ $? -ne 0 ]; then
        echo "Failed to download pre-trained models."
        popd
        cd ../../..
        exit 1
    fi
    echo "Moving downloaded files up one level..."
    pushd GPT-SoVITS
    for d in */; do
        mv "$d" ..
    done
    for f in *; do
        if [ -f "$f" ]; then
            mv "$f" ..
        fi
    done
    popd
fi
popd

# Download and place G2PW model
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
    echo "Checking extracted folder name..."
    if [ -d "temp_g2pw/g2pw" ]; then
        echo "Renaming extracted folder to 'G2PWModel'..."
        mv temp_g2pw/g2pw temp_g2pw/G2PWModel
    fi
    if [ -d "temp_g2pw/G2PWModel_1.1" ]; then
        echo "Renaming extracted folder to 'G2PWModel'..."
        mv temp_g2pw/G2PWModel_1.1 temp_g2pw/G2PWModel
    fi
    echo "Placing G2PW model..."
    mv temp_g2pw/G2PWModel GPT-SoVITS/GPT_SoVITS/text/
    rm -rf temp_g2pw
    rm G2PWModel.zip
fi

# Download and place Zundamon fine-tuned model
echo "Checking if Zundamon fine-tuned model exists..."
if [ -d "GPT-SoVITS/GPT_weights_v2" ] && [ -d "GPT-SoVITS/SoVITS_weights_v2" ]; then
    echo "Zundamon fine-tuned model already downloaded and placed. Skipping process."
else
    echo "Downloading Zundamon fine-tuned model..."
    echo "This process may take some time. Progress will be displayed."
    git clone --progress https://huggingface.co/zunzunpj/zundamon_GPT-SoVITS\

    ls -lh zundamon_GPT-SoVITS

    if [ $? -ne 0 ]; then
        echo "Failed to download Zundamon fine-tuned model."
        cd ..
        exit 1
    fi
    echo "Placing Zundamon fine-tuned model..."
    if [ -d "GPT-SoVITS/GPT_weights_v2" ]; then
        ls -lh GPT-SoVITS/GPT_weights_v2
        rm -rf GPT-SoVITS/GPT_weights_v2
    fi
    if [ -d "GPT-SoVITS/SoVITS_weights_v2" ]; then
        ls -lh GPT-SoVITS/SoVITS_weights_v2
        rm -rf GPT-SoVITS/SoVITS_weights_v2
    fi
    mv zundamon_GPT-SoVITS/GPT_weights_v2 GPT-SoVITS/
    mv zundamon_GPT-SoVITS/SoVITS_weights_v2 GPT-SoVITS/
    rm -rf zundamon_GPT-SoVITS
fi

# Check if FFmpeg and FFprobe exist
echo "Checking if FFmpeg and FFprobe exist..."
if [ -f "GPT-SoVITS/ffmpeg" ] && [ -f "GPT-SoVITS/ffprobe" ]; then
    echo "FFmpeg and FFprobe already downloaded and placed. Skipping process."
else
    echo "Downloading FFmpeg..."
    echo "Download progress will be shown with a progress bar."
    curl -L -# https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz -o ffmpeg.tar.xz
    if [ $? -ne 0 ]; then
        echo "Failed to download FFmpeg."
        cd ..
        exit 1
    fi
    echo "Extracting FFmpeg..."
    tar -xf ffmpeg.tar.xz
    mv ffmpeg-git-*-amd64-static/ffmpeg GPT-SoVITS/
    mv ffmpeg-git-*-amd64-static/ffprobe GPT-SoVITS/
    rm -rf ffmpeg-git-*-amd64-static
    rm ffmpeg.tar.xz
    chmod +x GPT-SoVITS/ffmpeg GPT-SoVITS/ffprobe
fi

echo
echo "===== Setup completed! ====="