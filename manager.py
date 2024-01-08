import tkinter as tk
from tkinter import ttk
from getpass import getuser
import threading
import random
import time
import subprocess

class WelcomeWindow:
    def __init__(self, master):
        self.master = master
        master.title("Didactinstaller")

        # Set window size and position
        window_width = 500
        window_height = 300
        screen_width = master.winfo_screenwidth()
        screen_height = master.winfo_screenheight()
        x = (screen_width - window_width) // 2
        y = (screen_height - window_height) // 2
        master.geometry(f"{window_width}x{window_height}+{x}+{y}")

        # Set window background color
        master.configure(bg="#2E2E2E")

        # Make the window non-resizable
        master.resizable(False, False)

        # Create and pack widgets
        self.label_didact = tk.Label(
            master, text="Didactinstaller", font=("Arial", 30), fg="#FFA500", bg="#2E2E2E"
        )
        self.label_didact.pack(pady=20)

        current_user = getuser()
        welcome_message = f"Welcome, {current_user}!"
        self.label_welcome_username = tk.Label(
            master,
            text=welcome_message,
            font=("Arial", 20),
            fg="#808080",
            bg="#2E2E2E",
        )
        self.label_welcome_username.pack(pady=10)

        # Add a progress bar
        self.progress_bar = ttk.Progressbar(
            master, orient="horizontal", length=300, mode="determinate"
        )
        self.progress_bar.pack(pady=20)

        # Add a label for displaying the Bash script output
        self.label_output = tk.Label(
            master,
            text="",
            font=("Arial", 10),
            fg="white",
            bg="#2E2E2E",
            justify="left",
            wraplength=450,
        )
        self.label_output.pack(pady=10)

        # Start the background process
        self.background_thread = threading.Thread(target=self.start_background_process)
        self.background_thread.start()

    def start_background_process(self):
        start_time = time.time()
        end_time = start_time + 3  # Set the end time to 3 seconds from the start

        while time.time() < end_time:
            elapsed_time = time.time() - start_time
            progress_value = min(100, (elapsed_time / 3) * 100)
            self.progress_bar["value"] = progress_value
            self.master.update_idletasks()

            # Simulate work being done in the background
            time.sleep(0.1)

        # Ensure the progress bar is filled at the end
        self.progress_bar["value"] = 100
        self.master.update_idletasks()

        # Execute the update.sh bash script
        self.execute_bash_script("update.sh")

        # Schedule window destruction after background tasks are finished
        self.master.after(0, self.master.destroy)

    def execute_bash_script(self, script_name):
        try:
            output = subprocess.check_output(["bash", script_name], text=True)
            self.label_output.config(text=output)
        except subprocess.CalledProcessError as e:
            self.label_output.config(text=f"Error: {e.output}")

if __name__ == "__main__":
    root = tk.Tk()
    welcome_window = WelcomeWindow(root)
    root.mainloop()
