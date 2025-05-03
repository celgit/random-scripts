import os
import subprocess
import json
from datetime import datetime
from tqdm import tqdm

def find_gopro():
    user_id = os.getuid()
    path = f'/run/user/{user_id}/gvfs/'

    gopro_found = False

    for dir_name in os.listdir(path):
        if 'GoPro' in dir_name:
            print('Woohoo, if works, here it is:')

            gopro_found = True
            return os.path.join(path, dir_name)
            
    if not gopro_found:
        print('No GoPro found, please connect it')
        exit(1)

def get_media_files(gopro_path):
    media_files = []

    if gopro_path:
        media_path = os.path.join(gopro_path, 'GoPro MTP Client Disk Volume/DCIM/')

        for root, dirs, files in os.walk(media_path):
            for filename in files:
                if filename.lower().endswith('.mp4'):
                        file_path = os.path.join(root, filename)
                        print(f'adding {filename}')
                        media_files.append(file_path)
                        
    return media_files

def get_created_date_from_metadata(file_path):
    cmd = [
        'ffprobe',
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        file_path
    ]

    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    metadata = json.loads(result.stdout)

    return metadata["format"]["tags"]["creation_time"]

def format_creation_time(creation_time_str):
    formatted_datetime = datetime.fromisoformat(creation_time_str.replace('Z', ''))  # Remove 'Z'

    return formatted_datetime.strftime('%Y-%m-%d_%H-%M-%S')

def create_list_to_copy(media_files):
    files_to_copy = []

    for file_path in media_files:
        creation_time = get_created_date_from_metadata(file_path)
        formatted_time = format_creation_time(creation_time)
        new_filename = f'{formatted_time}.mp4'

        files_to_copy.append({
            'source': file_path,
            'new_filename': new_filename
        })

    return files_to_copy

def destination_folder_validated(destination_folder):
    try:
        if not os.path.exists(destination_folder):
            os.makedirs(destination_folder)

        return True
    except Exception as e:
        print(f"Failed to create/access destination folder: {e}")
        
        return False

def copy_files(destination_folder, files_to_copy):
    for file in tqdm(files_to_copy, desc="Copying files", unit="B", unit_scale=True, dynamic_ncols=True):
        source_path = file['source']
        new_filename = file['new_filename']
        destination_path = os.path.join(destination_folder, new_filename)

        tqdm.write(f'Copying {source_path} -> {destination_path}')

        total_size = os.path.getsize(source_path)
        with tqdm(total=total_size, unit='B', unit_scale=True, dynamic_ncols=True, leave=False) as pbar:
            with open(source_path, 'rb') as src, open(destination_path, 'wb') as dst:
                while True:
                    buf = src.read(1024 * 1024)  # 1 MB buffer
                    if not buf:
                        break
                    dst.write(buf)
                    pbar.update(len(buf))

def print_confirmation_summary(destination_folder, files_to_copy):
    print(f"\nFound {len(files_to_copy)} files to copy:\n")
    for file in files_to_copy:
        destination_path = os.path.join(destination_folder, file['new_filename'])
        print(f"{file['source']} -> {destination_path}")

def main():
    destination_folder = input('Enter destination folder: \n').strip()
    destination_folder = os.path.expanduser(destination_folder)

    media_files = get_media_files(find_gopro())
    files_to_copy = create_list_to_copy(media_files)

    print_confirmation_summary(destination_folder, files_to_copy)

    proceed = input("\nPress Enter to continue or type 'n' to cancel: ").strip().lower()

    if proceed == 'n':
        print("Cancelled by user. Exiting.")
        exit(0)

    if destination_folder_validated(destination_folder):
        copy_files(destination_folder, files_to_copy)
        print('\nALL DONE!\n')
    else:
        print("Aborting copy because destination folder could not be prepared.")

if __name__ == "__main__":
    main()
