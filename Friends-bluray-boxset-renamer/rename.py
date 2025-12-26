from os import rename, listdir
import sys

mydict = {}

# Read dictionary file
with open('dictionary.txt', 'r') as dict_file:
    for line in dict_file:
        line = line.strip()
        left, right = line.split('|')
        mydict[right] = left

# Check that all files in the dictionary exist
existing_files = set(listdir('.'))
missing_files = [fname for fname in mydict if fname not in existing_files]

if missing_files:
    print("Missing files detected. No files were renamed:")
    for fname in missing_files:
        print("  -", fname)
    sys.exit(1)

# Rename files (only runs if everything exists)
for fname in existing_files:
    if fname in mydict:
        rename(fname, 'Friends - ' + mydict[fname] + '.mkv')
