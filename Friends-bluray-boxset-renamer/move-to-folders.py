import os
import shutil
import re

# Use the current directory
base_dir = os.getcwd()

# List all .mkv files in the folder
for filename in os.listdir(base_dir):
    if filename.endswith(".mkv"):
        # Try to find the season code like s10e04 in the filename
        match = re.search(r's(\d+)e\d+', filename, re.IGNORECASE)
        if match:
            season = f"s{match.group(1).zfill(2)}"  # keep as s01, s10 etc.
            # Make season folder if it doesn't exist
            season_folder = os.path.join(base_dir, season)
            os.makedirs(season_folder, exist_ok=True)

            # Move the file
            src_file = os.path.join(base_dir, filename)
            dst_file = os.path.join(season_folder, filename)
            shutil.move(src_file, dst_file)
            print(f"Moved: {filename} → {season}/")
        else:
            print(f"No season found in: {filename}")
