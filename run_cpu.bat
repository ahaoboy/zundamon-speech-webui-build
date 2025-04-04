@echo off

chcp 65001

cd /d %%~dp0

cd zundamon-speech-webui

"%~dp0python_cpu\python.exe" zundamon_speech_run.py

pause