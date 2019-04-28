powershell Compress-Archive . ld44.love
move ld44.love pkg\ld44.love
copy /b pkg\win32\love.exe+pkg\ld44.love pkg\win32\ld44.exe
copy /b pkg\win64\love.exe+pkg\ld44.love pkg\win64\ld44.exe