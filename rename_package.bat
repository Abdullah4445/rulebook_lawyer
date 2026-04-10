@echo off
echo ================================================
echo Lawyer App Package Rename Script
echo ================================================
echo.
echo This script will rename all package imports from 'driver' to 'lawyer'
echo.
echo IMPORTANT: This will modify 300+ files
echo Make sure you have a backup before proceeding
echo.
pause

cd /d C:\rulebook\driverJuly2025Goride

echo.
echo Step 1: Running flutter clean...
call flutter clean

echo.
echo Step 2: Updating all Dart files...
echo (This may take a minute...)

:: Use PowerShell to do the replacement
powershell -Command "(Get-ChildItem -Path '.' -Filter '*.dart' -Recurse) | ForEach-Object { (Get-Content $_.FullName -Raw) -replace 'package:driver/', 'package:lawyer/' | Set-Content $_.FullName -NoNewline }"

echo.
echo Step 3: Running flutter pub get...
call flutter pub get

echo.
echo ================================================
echo ✅ Package rename complete!
echo ================================================
echo.
echo Next steps:
echo 1. Review changes in your IDE
echo 2. Check for any compilation errors
echo 3. Run: flutter build apk --debug
echo.
pause

