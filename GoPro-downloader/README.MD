# GoPro Downloader

A simple Python script to download and rename `.mp4` videos from a GoPro HERO7 (or compatible device) when connected via USB.

### But why?
Well, gopro won't win any rewards regarding how they name the files the camera create. In my case, a Hero7, it was but impossible to figure out which was first of the files etc. This script somewhat solves this since it names them based on created timestamp. Easy peasy.
(You are welcome)

## Features

- Automatically detects connected GoPro.
- Lists all `.mp4` video files.
- Extracts the original recording date and time from each video.
- Renames files based on creation time (`YYYY-MM-DD_HH-MM-SS.mp4`).
- Copies videos to a user-specified destination folder.
- Displays a clean MB/s progress bar while copying.
- Gracefully handles missing devices or folder creation errors.

## Requirements

- Python 3.8+
- `tqdm`
- `ffprobe` (installed as part of `ffmpeg`)

### Install Python dependencies
pip install -r requirements.txt

## Usage
Connect your GoPro via USB and set it to MTP mode (should happen automatically on HERO7).

### Run the script:
python3 gopro_downloader.py
When prompted, enter the destination folder where you want to copy the videos.

Review the list of files and confirm to start copying.

Example folder input:
~/Videos/FromGoPro

## Note, the script will:
Create the folder if it doesn't exist.
Copy and rename videos based on their recorded timestamp.