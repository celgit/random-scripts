import os
import subprocess
from errors import FailedToCreateTargetFolderError, FfmpegNotFoundError

def check_ffprobe_available():
    try:
        subprocess.run(['ffprobe', '-version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        raise FfmpegNotFoundError("\u274c 'ffprobe' not found in PATH. Please install ffmpeg to continue.")

def create_target_folder_if_not_exists(destination_folder):
    try:
        if not os.path.exists(destination_folder):
            os.makedirs(destination_folder, exist_ok=True)
    except OSError as e:
        raise FailedToCreateTargetFolderError(f"Failed to create/access destination folder: {e}")
