powershell Compress-Archive -Path .\* ld44.zip
move ld44.zip pkg\ld44.love
copy /b pkg\win32\love.exe+pkg\ld44.love pkg\win32\ld44.exe
copy /b pkg\win64\love.exe+pkg\ld44.love pkg\win64\ld44.exe
.\pkg\win64\ld44.exe