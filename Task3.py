#!/usr/bin/env python3
import os
import hashlib
import shutil
from datetime import datetime

SUBMISSIONS_DIR = "submissions"
LOG_FILE = "submission_log.txt"
MAX_SIZE = 5 * 1024 * 1024  # 5MB in bytes

# Create submissions directory if it doesn't exist
os.makedirs(SUBMISSIONS_DIR, exist_ok=True)

def log_submission(message):
    """Append a log entry with a timestamp to the log file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] {message}\n")
    print("LOG:", message)

def compute_hash(filepath):
    """Compute the SHA256 hash of the given file."""
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()

def submit_assignment():
    student = input("Enter student name: ").strip()
    filepath = input("Enter path to assignment file: ").strip()

    if not os.path.isfile(filepath):
        print("File does not exist.")
        return

    filename = os.path.basename(filepath)
    extension = filename.split('.')[-1].lower()
    if extension not in ["pdf", "docx"]:
        print("Invalid file type. Only .pdf and .docx files are accepted.")
        return

    filesize = os.path.getsize(filepath)
    if filesize > MAX_SIZE:
        print("File is too large. Maximum size is 5MB.")
        return

    filehash = compute_hash(filepath)
    destination = os.path.join(SUBMISSIONS_DIR, filename)

    if os.path.exists(destination):
        existing_hash = compute_hash(destination)
        if filehash == existing_hash:
            print("Duplicate submission detected! File with the same name and content already submitted.")
            log_submission(f"Duplicate submission attempt by {student} for file {filename}")
            return

    shutil.copy2(filepath, destination)
    print("Assignment submitted successfully.")
    log_submission(f"Assignment submitted by {student}: {filename}, hash: {filehash}")

def check_submission():
    fname = input("Enter the file name to check: ").strip()
    path = os.path.join(SUBMISSIONS_DIR, fname)
    if os.path.exists(path):
        print(f"File '{fname}' has already been submitted.")
        filehash = compute_hash(path)
        print("Hash:", filehash)
    else:
        print(f"File '{fname}' has not been submitted.")

def list_submissions():
    submissions = os.listdir(SUBMISSIONS_DIR)
    if not submissions:
        print("No submissions yet.")
    else:
        print("Submitted Assignments:")
        for file in submissions:
            path = os.path.join(SUBMISSIONS_DIR, file)
            size = os.path.getsize(path)
            print(f"{file} - Size: {size} bytes")

def main():
    while True:
        print("\nExamination Submission System")
        print("1. Submit an assignment")
        print("2. Check if a file has already been submitted")
        print("3. List all submitted assignments")
        print("4. Exit")
        choice = input("Choose an option: ").strip()
        if choice == "1":
            submit_assignment()
        elif choice == "2":
            check_submission()
        elif choice == "3":
            list_submissions()
        elif choice == "4":
            confirm = input("Are you sure you want to exit? (Y/N): ").strip().lower()
            if confirm == "y":
                log_submission("Submission system exited.")
                print("Exiting system.")
                break
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
