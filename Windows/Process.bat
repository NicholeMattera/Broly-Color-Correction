@echo off
IF [%1] == [] (
    ECHO Destination path missing.
    EXIT /B
)

echo Checking for required apps...

where /q makemkvcon
IF ERRORLEVEL 1 (
    ECHO MakeMKV is missing. Ensure it is installed and placed in your PATH.
    EXIT /B
)

where /q HandBrakeCLI
IF ERRORLEVEL 1 (
    ECHO HandBrake CLI is missing. Ensure it is installed and placed in your PATH.
    EXIT /B
)

where /q ffmpeg
IF ERRORLEVEL 1 (
    ECHO FFmpeg is missing. Ensure it is installed and placed in your PATH.
    EXIT /B
)

echo Ripping title from disc...
makemkvcon mkv disc:0 0 "%1"

echo Re-encoding ripped video...
HandBrakeCLI --input "%1\Dragon Ball Super Broly_t00.mkv" --output "%1\1.mkv" --audio-lang-list "und" --all-audio --all-subtitles --preset "Matroska/H.264 MKV 1080p30"

echo Demuxing video track...
ffmpeg -i "%1\1.mkv" -map 0:v -c copy "%1\2.mp4"

echo Applying video filters to video track...
ffmpeg -i "%1\2.mp4" -vf "curves=psfile=DBSB.acv, eq=gamma=1:saturation=0.91" -c:a copy -c:s copy "%1\3.mp4"

echo Muxing video back together...
ffmpeg -i "%1\3.mp4" -i "%1\1.mkv" -c copy -map 0:v:0 -map 1:a:0 -map 1:a:1 -map 1:a:2 -map 1:a:3 -map 1:s:0 "%1\Dragon Ball Super - Broly.mkv"

echo Cleaning up...
del /f "%1\Dragon Ball Super Broly_t00.mkv"
del /f "%1\1.mkv"
del /f "%1\2.mp4"
del /f "%1\3.mp4"

echo All done!
explorer %1