import os
import hashlib
import time
import logging


def calculate_hash(file_path):
    """Calculate the SHA-512 hash of a file."""
    try:
        hash_function = hashlib.sha512()
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                hash_function.update(chunk)
        return hash_function.hexdigest()
    except FileNotFoundError:
        logging.error(f"File not found: {file_path}")
        return None
    except Exception as e:
        logging.error(f"Error calculating hash for {file_path}: {e}")
        return None

def log_change(file_path):
    """Log a change to the specified file."""
    logging.info(f'ALERT: {file_path} has changed!')

def get_all_files(directory):
    """Retrieve all files in the specified directory."""
    files = []
    try:
        for root, dirs, filenames in os.walk(directory):
            for filename in filenames:
                files.append(os.path.join(root, filename))
    except Exception as e:
        logging.error(f"Error accessing directory {directory}: {e}")
    return files

def monitor_directory(directory, interval=10):
    """Monitor the specified directory for file changes."""
    hashes = {}
    
    # Get all files in the directory
    files_to_monitor = get_all_files(directory)
    
    for file_path in files_to_monitor:
        if os.path.exists(file_path):
            hashes[file_path] = calculate_hash(file_path)

    try:
        while True:
            time.sleep(interval)
            for file_path in files_to_monitor:
                if os.path.exists(file_path):
                    current_hash = calculate_hash(file_path)
                    if current_hash and current_hash != hashes.get(file_path):
                        print(f'ALERT: {file_path} has changed!')
                        log_change(file_path)
                        hashes[file_path] = current_hash
                else:
                    print(f'ALERT: {file_path} has been deleted!')
                    logging.warning(f'File deleted: {file_path}')
                    hashes.pop(file_path, None)
    except KeyboardInterrupt:
        print("\nMonitoring stopped by user.")
        logging.info("Monitoring stopped by user.")
    except Exception as e:
        logging.error(f"An error occurred during monitoring: {e}")

# Example usage
if __name__ == "__main__":
    directory_to_monitor = r"D:\Programacion Clase"
    monitor_directory(directory_to_monitor)
