@echo off
setlocal

chcp 65001

set "script_dir=%~dp0"
set "pip_path=%script_dir%python_gpu\Scripts\pip.exe"
set "get_pip_path=%script_dir%python_gpu\get-pip.py"
set "streamlit_path=%script_dir%python_gpu\Scripts\streamlit.exe"
set "python_path=%script_dir%python_gpu\python.exe"

if exist "%pip_path%" (
    @REM echo pip ok
) else (
    @REM echo install pip
    "%python_path%" "%get_pip_path%"
)

if exist "%streamlit_path%" (
    @REM echo streamlit ok
) else (
    @REM echo install streamlit
    "%python_path%" -m pip install streamlit
)


cd zundamon-speech-webui\GPT-SoVITS

"%streamlit_path%" run zundamon_webui.py

pause