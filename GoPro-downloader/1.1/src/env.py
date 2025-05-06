import os
from errors import DeviceNotFoundError, UnsupportedRuntimeEnvironmentError

ENV_LINUX_GNOME_DESKTOP = 'gvfs'
ENV_WINDOWS = 'windows'
ENV_OTHER = 'other'

def get_gvfs_mount_path():
    user_id = os.getuid()
    
    return f"/run/user/{user_id}/gvfs"

def get_runtime_env():
    if os.name == 'nt':
        return ENV_WINDOWS
    if os.path.isdir(get_gvfs_mount_path()):
        return ENV_LINUX_GNOME_DESKTOP
    
    raise UnsupportedRuntimeEnvironmentError('Unsupported runtime environment')

def find_gopro(environment):
    if environment == ENV_WINDOWS:
        print('⚠️ Windows cannot access GoPro via path directly (MTP mode).')
        print('Please copy the files manually to a local folder.')
        return input("Enter full path to that folder: ").strip()
    if environment == 'macos':
        print('MacOs, not finished yet!')
    if environment == 'other':
        print('Other environment, not supported yet!')
    if environment == ENV_LINUX_GNOME_DESKTOP:
        path = get_gvfs_mount_path()
        for dir_name in os.listdir(path):
            if 'GoPro' in dir_name:
                print('Woohoo, if works, here it is:')
                return os.path.join(path, dir_name)
            
    raise DeviceNotFoundError('No GoPro found!')