import time
import random
import sys

def generate_z_data(filepath, count=1000):
    now = int(time.time())
    with open(filepath, 'w') as f:
        for i in range(count):
            path = f"/home/user/project_{i}/src/component_{random.randint(0, 100)}"
            rank = float(random.randint(1, 100))
            timestamp = now - random.randint(0, 3600 * 24 * 30) # Last 30 days
            f.write(f"{path}|{rank}|{timestamp}\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python gen_data.py <filepath> [count]")
        sys.exit(1)
    
    filepath = sys.argv[1]
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 1000
    generate_z_data(filepath, count)
