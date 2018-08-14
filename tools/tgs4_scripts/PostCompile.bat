@echo off

powershell -NoProfile -ExecutionPolicy Bypass -File PostCompile.ps1 -game_path %1
