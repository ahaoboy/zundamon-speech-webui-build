@echo off
setlocal

chcp 65001

set "script_dir=%~dp0"
set "pip_path=%script_dir%python_cpu\Scripts\pip.exe"
set "get_pip_path=%script_dir%python_cpu\get-pip.py"
set "streamlit_path=%script_dir%python_cpu\Scripts\streamlit.exe"
set "python_path=%script_dir%python_cpu\python.exe"

if exist "%pip_path%" (
    echo pip ok
) else (
    echo install pip
    "%python_path%" "%get_pip_path%"
)

if exist "%streamlit_path%" (
    echo streamlit ok
) else (
    echo install streamlit
    "%python_path%" -m pip install streamlit
)

cd /d %%~dp0

cd zundamon-speech-webui

"%~dp0python_cpu\python.exe" zundamon_speech_run.py

pause