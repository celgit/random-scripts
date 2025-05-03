import os
import subprocess
import json
from datetime import datetime
from tqdm import tqdm
from env import ENV_LINUX_GNOME_DESKTOP

def get_media_files(gopro_path, runtime_env):
    media_files = []
    media_path = os.path.join(gopro_path, 'GoPro MTP Client Disk Volume/DCIM/') if runtime_env == ENV_LINUX_GNOME_DESKTOP else gopro_path

    for root, dirs, files in os.walk(media_path):
        for filename in files:
            if not filename.lower().endswith('.mp4'):
                continue
            file_path = os.path.join(root, filename)
            print(f'adding {filename}')
            media_files.append(file_path)

    return media_files

def get_created_date_from_metadata(file_path):
    cmd = [
        'ffprobe', '-v', 'quiet',
        '-print_format', 'json',
        '-show_format', '-show_streams',
        file_path
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    metadata = json.loads(result.stdout)
    return metadata['format']['tags']['creation_time']

def format_creation_time(creation_time_str):
    formatted_datetime = datetime.fromisoformat(creation_time_str.replace('Z', ''))
    return formatted_datetime.strftime('%Y-%m-%d_%H-%M-%S')

def create_list_to_copy(media_files):
    files_to_copy = []
    for file_path in media_files:
        creation_time = get_created_date_from_metadata(file_path)
        formatted_time = format_creation_time(creation_time)
        new_filename = f'{formatted_time}.mp4'
        files_to_copy.append({'source': file_path, 'new_filename': new_filename})
    return files_to_copy

def print_confirmation_summary(destination_folder, files_to_copy):
    print(f"\nFound {len(files_to_copy)} files to copy:\n")
    for file in files_to_copy:
        destination_path = os.path.join(destination_folder, file['new_filename'])
        print(f"{file['source']} -> {destination_path}")

def copy_files(destination_folder, files_to_copy):
    for file in tqdm(files_to_copy, desc='Copying files', unit='B', unit_scale=True, dynamic_ncols=True):
        source_path = file['source']
        destination_path = os.path.join(destination_folder, file['new_filename'])
        tqdm.write(f'Copying {source_path} -> {destination_path}')
        total_size = os.path.getsize(source_path)
        with tqdm(total=total_size, unit='B', unit_scale=True, dynamic_ncols=True, leave=False) as pbar:
            with open(source_path, 'rb') as src, open(destination_path, 'wb') as dst:
                while True:
                    buf = src.read(1024 * 1024)
                    if not buf:
                        break
                    dst.write(buf)
                    pbar.update(len(buf))