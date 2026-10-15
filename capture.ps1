$env:Path = "C:\Users\Anupom\AppData\Local\Android\Sdk\platform-tools;" + $env:Path

# Try: save on device first, then pull as raw bytes
adb -s emulator-5554 shell screencap -p /sdcard/launch.png
adb -s emulator-5554 pull /sdcard/launch.png "D:\Ostad\New folder (3)\ecommerce_app\screenshot_app.png"
adb -s emulator-5554 shell rm /sdcard/launch.png

# Verify
if (Test-Path "D:\Ostad\New folder (3)\ecommerce_app\screenshot_app.png") {
    $bytes = [System.IO.File]::ReadAllBytes("D:\Ostad\New folder (3)\ecommerce_app\screenshot_app.png")
    Write-Host "Magic bytes:" $bytes[0] $bytes[1] $bytes[2] $bytes[3]
    Write-Host "Total size:" $bytes.Length "bytes"
}