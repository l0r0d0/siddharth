Siddharth
Siddharth is a Bash-based tool that recursively scans websites for directories and files using gobuster. It enhances gobuster by providing colorized output, clean result formatting, and a queue-based recursive scanning mechanism. The tool is designed for security researchers and penetration testers to discover hidden paths on web servers.
Features

Recursively scans a target URL using gobuster.
Colorized output for better readability (red for errors, green for results, cyan for status, yellow for queue).
Filters results to show only relevant HTTP status codes (200, 301, 302, 303, 400, 401, 403).
Summarizes all findings at the end of the scan.
Temporary file management for clean operation.

Prerequisites

gobuster: Required for directory brute-forcing.
bash: The script runs in a Bash environment.
A wordlist (e.g., /usr/share/wordlists/dirb/common.txt from Kali Linux).

Install gobuster on Kali Linux or other Debian-based systems:
sudo apt update
sudo apt install gobuster

Installation

Clone the Repository:
git clone https://github.com/l0r0d0/siddharth.git
cd siddharth


Make the Script Executable:
chmod +x siddharth.sh


(Optional) Move to a System Path:To run siddharth from anywhere, move it to /usr/local/bin/:
sudo mv siddharth.sh /usr/local/bin/siddharth


Verify Installation:Run the script to ensure it works:
siddharth --help



Usage
Run the tool with a target URL, a wordlist, and optional gobuster parameters:
siddharth <target_url> <wordlist> [gobuster_options]

Example
Scan https://example.com with a wordlist and 50 threads:
siddharth https://example.com /usr/share/wordlists/dirb/common.txt -t 50

Output

The tool displays discovered paths in real-time with their HTTP status codes.
A queue of URLs to be scanned is shown (in yellow).
A final summary lists all findings grouped by URL.

Notes

Ensure the target URL does not end with a trailing slash (e.g., use https://example.com, not https://example.com/).
The wordlist should be a text file with one path per line.
Additional gobuster options (e.g., -t for threads, -x for file extensions) can be passed directly.

Example Output
[*] Scanning: https://example.com
[*] Discovered paths for https://example.com:
Path                Status
----                ------
admin               Status: 200
login               Status: 301
uploads             Status: 403

[*] Current queue:
  https://example.com/admin
  https://example.com/login
  https://example.com/uploads

[*] Final Summary of All Findings:
Results for https://example.com:
Path                Status
----                ------
admin               Status: 200
login               Status: 301
uploads             Status: 403

[*] Scanning complete.

Contributing
Contributions are welcome! Please read the CONTRIBUTING.md file for guidelines on how to contribute to this project.
License
This project is licensed under the MIT License. See the LICENSE file for details.
Contact
For issues, suggestions, or questions, open an issue on the GitHub repository or contact [your.email@example.com].
Disclaimer
This tool is intended for authorized security testing only. Unauthorized use against systems you do not own or have permission to test is illegal. The author is not responsible for misuse of this tool.
