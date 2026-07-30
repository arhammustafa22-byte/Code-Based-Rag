@echo off
setlocal enabledelayedexpansion
title Codebase RAG Launcher
cd /d "%~dp0"

echo ============================================
echo   Codebase RAG - Launcher
echo ============================================
echo.

REM --- 1. Check Python 3.11 is installed via the py launcher ---
py -3.11 --version >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Python 3.11 was not found.
    echo This project needs Python 3.10+ ^(3.11 recommended for best compatibility^).
    echo Install it from https://www.python.org/downloads/release/python-3119/
    pause
    exit /b 1
)

REM --- 2. Check Git is installed (needed to clone GitHub repos) ---
where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git was not found on PATH.
    echo This project clones GitHub repos and requires Git.
    echo Install it from https://git-scm.com/downloads
    pause
    exit /b 1
)

REM --- 3. Create virtual environment if it doesn't exist ---
if not exist "venv\Scripts\activate.bat" (
    echo [1/5] Creating virtual environment with Python 3.11...
    py -3.11 -m venv venv
) else (
    echo [1/5] Virtual environment already exists, skipping creation.
)

REM --- 4. Activate virtual environment ---
echo [2/5] Activating virtual environment...
call venv\Scripts\activate.bat

REM --- 5. Install dependencies (only if marker file missing) ---
if not exist "venv\installed.flag" (
    echo [3/5] Installing dependencies from requirements.txt...
    echo       This may take several minutes on first run ^(torch is large^)...
    pip install --upgrade pip >nul
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Dependency installation failed. See errors above.
        pause
        exit /b 1
    )
    echo done> venv\installed.flag
) else (
    echo [3/5] Dependencies already installed, skipping.
)

REM --- 6. Warn if .env / GROQ key missing ---
if not exist ".env" (
    echo.
    echo [NOTE] No .env file found - create one in this folder with:
    echo        GROQ_API_KEY=your_key_here
    echo        GITHUB_TOKEN=your_token_here   ^(optional, avoids rate limits^)
    echo        The app will not generate answers without GROQ_API_KEY.
    echo.
    pause
)

REM --- 7. Start the app in a new window, then open the browser ---
echo [4/5] Starting Codebase RAG on http://127.0.0.1:7860 ...
start "Codebase RAG - Server" cmd /k "call venv\Scripts\activate.bat && python main.py"

REM Give the app time to load the embedding model and boot Gradio
echo [5/5] Waiting for the app to finish loading the embedding model...
timeout /t 15 /nobreak >nul
start "" "http://127.0.0.1:7860"

echo.
echo Server is running in a separate window titled "Codebase RAG - Server".
echo Close that window (or press Ctrl+C in it) to stop the server.
echo If the browser page does not load yet, just refresh it after a few
echo more seconds - the embedding model can take a bit longer on first run.
echo This launcher window can be closed safely.
echo.
pause
