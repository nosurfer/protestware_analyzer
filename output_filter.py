import sys
import subprocess

def filtering():
    logfile = sys.argv[1]
    filterfile = sys.argv[2]


    with open(f"{logfile}/logfile.log", "r") as read_file:
        data = read_file.readlines()

    counter = 0
    with open(f"{filterfile}/filterlog.log", "w+") as write_file:
        write_file.write(data[0])
        for row in data[1:]:
            row = row.split()
            if not row:
                continue
            if row[-1] == "newfstatat":
                continue

            row = f"{counter} {row[1]} {row[5]} {row[7]} {' '.join(row[8:])}"
            write_file.write("".join(row) + "\n")
            counter += 1