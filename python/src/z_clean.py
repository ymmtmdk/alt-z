import sys
import os
import argparse
from common import read_data, write_data

def main():
    parser = argparse.ArgumentParser(description='z cleanup tool')
    parser.add_argument('-x', action='store_true', help='remove the current directory from the datafile')
    args = parser.parse_args()
    
    entries = read_data()
    new_entries = []
    
    cwd = os.getcwd()
    
    for entry in entries:
        if args.x and entry.path == cwd:
            continue
            
        if os.path.exists(entry.path):
            new_entries.append(entry)
            
    write_data(new_entries)

if __name__ == "__main__":
    main()
