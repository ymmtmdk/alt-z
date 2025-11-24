import os
import time
import fcntl
import sys

# Default configuration
DATA_FILE = os.environ.get("_Z_DATA", os.path.expanduser("~/.z"))
MAX_SCORE = int(os.environ.get("_Z_MAX_SCORE", 9000))
EXCLUDE_DIRS = os.environ.get("_Z_EXCLUDE_DIRS", "").split(":")
OWNER = os.environ.get("_Z_OWNER")

class Entry:
    def __init__(self, path, rank, timestamp):
        self.path = path
        self.rank = float(rank)
        self.timestamp = int(timestamp)

    def to_line(self):
        return f"{self.path}|{self.rank}|{self.timestamp}\n"

def read_data(filepath=DATA_FILE):
    entries = []
    if not os.path.exists(filepath):
        return entries

    try:
        with open(filepath, "r") as f:
            # Shared lock for reading
            try:
                fcntl.flock(f, fcntl.LOCK_SH)
                for line in f:
                    parts = line.strip().split("|")
                    if len(parts) >= 3:
                        entries.append(Entry(parts[0], parts[1], parts[2]))
            finally:
                fcntl.flock(f, fcntl.LOCK_UN)
    except Exception as e:
        # Fail silently or log to stderr if needed, similar to original z
        pass
    return entries

def write_data(entries, filepath=DATA_FILE):
    try:
        # Open with 'r+' to allow locking before truncation, or 'w' if it doesn't exist
        # However, 'w' truncates immediately. To safely lock, we should open 'a+' or similar,
        # lock, then truncate.
        
        # Strategy: Open for append to get a file descriptor, lock it, then truncate and write.
        with open(filepath, "a+") as f:
            try:
                fcntl.flock(f, fcntl.LOCK_EX)
                f.seek(0)
                f.truncate()
                for entry in entries:
                    f.write(entry.to_line())
            finally:
                fcntl.flock(f, fcntl.LOCK_UN)
                
        # Handle ownership if _Z_OWNER is set (e.g. sudo usage)
        if OWNER:
            try:
                import pwd
                uid = pwd.getpwnam(OWNER).pw_uid
                gid = pwd.getpwnam(OWNER).pw_gid
                os.chown(filepath, uid, gid)
            except:
                pass

    except Exception as e:
        pass

def frecency(rank, timestamp, current_time):
    dx = current_time - timestamp
    # 0.0001 * dx + 1 -> if dx is small, close to 1. if dx is large, large.
    # 3.75 / (...) -> weight decreases as time passes.
    # + 0.25 -> minimum weight?
    
    # Original awk:
    # dx = t - time
    # return int(10000 * rank * (3.75/((0.0001 * dx + 1) + 0.25)))
    
    weight = 3.75 / ((0.0001 * dx + 1) + 0.25)
    return int(10000 * rank * weight)
