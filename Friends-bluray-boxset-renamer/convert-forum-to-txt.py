with open("forum_list.txt", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    line = line.strip()
    if not line:
        continue
    # Split at the first '-' occurrence
    first_part, rest = line.split('-', 1)
    first_part = first_part.lower()

    # Keep only up to and including '.mkv'
    if ".mkv" in rest:
        rest = rest.split(".mkv", 1)[0] + ".mkv"

    new_line = f"{first_part}|{rest}"
    new_lines.append(new_line)

with open("file_processed.txt", "w") as f:
    f.write("\n".join(new_lines))

print("Processing complete. Check 'file_processed.txt'.")
