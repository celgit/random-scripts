from os import rename, listdir

for fname in listdir('.'):
    if ' ' in fname:
        new_name = fname.replace(' ', '_')
        rename(fname, new_name)
        print(f"{fname} -> {new_name}")