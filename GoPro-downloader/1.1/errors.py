class DeviceNotFoundError(Exception):
    """Raised when no GoPro or other expected device is found"""
    pass

class FailedToCreateTargetFolderError(Exception):
    """Raised when script fails to create target folder"""
    pass

class UnsupportedRuntimeEnvironmentError(Exception):
    """Raised when the runtime environment isn't supported"""
    pass

class FfmpegNotFoundError(Exception):
    """Raised when ffmpeg is missing"""
    pass