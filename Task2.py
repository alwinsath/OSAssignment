#!/usr/bin/env python3
import os
import json
from datetime import datetime

# File names for persistent storage
REQUESTS_FILE = "book_requests.txt"
LOG_FILE = "library_log.txt"

# Predefined list of available books in the library
available_books = [
    "Introduction to Algorithms",
    "Design Patterns",
    "The Pragmatic Programmer",
    "Clean Code",
    "Artificial Intelligence: A Modern Approach"
]

# In-memory list of book requests.
# Each request is stored as a dictionary:
# { "student": str, "book": str, "priority": int, "timestamp": str }
requests_list = []

# --- Helper Functions ---

def log_operation(message):
    """Append a log entry with a timestamp to the log file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = f"[{timestamp}] {message}\n"
    with open(LOG_FILE, "a") as log_file:
        log_file.write(entry)
    print("LOG:", message)

def load_requests():
    """Load existing book requests from the requests file."""
    global requests_list
    if os.path.exists(REQUESTS_FILE):
        try:
            with open(REQUESTS_FILE, "r") as f:
                requests_list = json.load(f)
        except Exception as e:
            print("Error loading requests:", e)
            requests_list = []
    else:
        requests_list = []

def save_requests():
    """Save the current book requests to the requests file."""
    try:
        with open(REQUESTS_FILE, "w") as f:
            json.dump(requests_list, f, indent=4)
    except Exception as e:
        print("Error saving requests:", e)

def view_available_books():
    """Display the list of available books."""
    print("\n--- Available Books in the Library ---")
    for idx, book in enumerate(available_books, 1):
        print(f"{idx}. {book}")
    print("----------------------------------------\n")

def request_book():
    """Allow a student to request a book and add the request to the queue."""
    student = input("Enter your name or ID: ").strip()
    view_available_books()
    book = input("Enter the book title you want to request: ").strip()
    
    if book not in available_books:
        print(f"Sorry, the book '{book}' is not available in the library.")
        log_operation(f"Request failed: '{book}' not available (Student: {student})")
        return

    priority_input = input("Enter priority (1-10) [press Enter for default (10)]: ").strip()
    if priority_input:
        try:
            priority = int(priority_input)
            if priority < 1 or priority > 10:
                raise ValueError
        except ValueError:
            print("Invalid priority. Using default priority 10.")
            priority = 10
    else:
        priority = 10

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    request_entry = {
        "student": student,
        "book": book,
        "priority": priority,
        "timestamp": timestamp
    }
    requests_list.append(request_entry)
    save_requests()
    log_operation(f"Book requested: '{book}' by {student} with priority {priority}")
    print("Your request has been added.\n")

def process_requests():
    """Process book requests using either FIFO or Priority Scheduling."""
    if not requests_list:
        print("No pending book requests.")
        return

    print("\nSelect processing mode:")
    print("1. FIFO (First Come, First Served)")
    print("2. Priority Scheduling (Highest priority served first)")
    mode_choice = input("Enter 1 or 2: ").strip()

    if mode_choice == "1":
        # FIFO: Process the first request added
        request = requests_list.pop(0)
        mode = "FIFO"
    elif mode_choice == "2":
        # Priority Scheduling: Process the request with lowest 'priority' value.
        # If two requests have the same priority, process the older one (based on timestamp).
        # We'll sort by (priority, timestamp)
        sorted_requests = sorted(requests_list, key=lambda r: (r["priority"], r["timestamp"]))
        request = sorted_requests[0]
        # Remove the processed request from requests_list
        requests_list.remove(request)
        mode = "Priority"
    else:
        print("Invalid choice. Returning to main menu.")
        return

    # Log and display processing of the request.
    student = request["student"]
    book = request["book"]
    priority = request["priority"]
    print(f"\nProcessing request using {mode} scheduling:")
    print(f"Student: {student}")
    print(f"Book: {book}")
    print(f"Priority: {priority}")
    log_operation(f"Book lent: '{book}' to {student} (Processed via {mode})")
    save_requests()
    print("Request processed.\n")

def exit_system():
    """Exit the system after confirmation."""
    confirm = input("Are you sure you want to exit? (Y/N): ").strip().lower()
    if confirm == "y":
        log_operation("Library system exited.")
        print("Exiting system. Goodbye!")
        exit(0)
    else:
        print("Exit cancelled.")

def display_menu():
    """Display the main menu."""
    print("\n===== CHRIST CHURCH UNIVERSITY LIBRARY SYSTEM =====")
    print("1. View available books")
    print("2. Request a book")
    print("3. Process book requests")
    print("4. Exit system")
    print("=====================================================")

def main():
    load_requests()
    log_operation("Library system started.")
    while True:
        display_menu()
        choice = input("Select an option (1-4): ").strip()
        if choice == "1":
            view_available_books()
        elif choice == "2":
            request_book()
        elif choice == "3":
            process_requests()
        elif choice == "4":
            exit_system()
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
