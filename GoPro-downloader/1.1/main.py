from src.env import get_runtime_env, find_gopro
from src.media import (
    get_media_files,
    create_list_to_copy,
    print_confirmation_summary,
    copy_files
)
from src.utils import (
    check_ffprobe_available,
    create_target_folder_if_not_exists
)
from src.errors import (
    DeviceNotFoundError,
    FailedToCreateTargetFolderError,
    UnsupportedRuntimeEnvironmentError,
    FfmpegNotFoundError
)
import os
import sys

def main():
    try:
        check_ffprobe_available()
    except FfmpegNotFoundError as e:
        print(e)
        print('☙️ On Windows: choco install ffmpeg -y')
        print('☙️ On Linux:   sudo apt install ffmpeg')
        sys.exit(1)

    destination_folder = input('Enter destination folder: \n').strip()
    destination_folder = os.path.expanduser(destination_folder)

    try:
        runtime_env = get_runtime_env()
        connected_gopro = find_gopro(runtime_env)
    except (UnsupportedRuntimeEnvironmentError, DeviceNotFoundError) as error:
        print(error)
        sys.exit(1)

    media_files = get_media_files(connected_gopro, runtime_env)
    files_to_copy = create_list_to_copy(media_files)

    print_confirmation_summary(destination_folder, files_to_copy)

    proceed = input("\nPress Enter to continue or type 'n' to cancel: ").strip().lower()

    if proceed == 'n':
        print('Cancelled by user. Exiting.')
        exit(0)

    try:
        create_target_folder_if_not_exists(destination_folder)
        print('\nALL DONE!\n')
    except FailedToCreateTargetFolderError as error:
        print(error)
        sys.exit(1)

    copy_files(destination_folder, files_to_copy)

if __name__ == '__main__':
    main()
