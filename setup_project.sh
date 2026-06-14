#!/usr/bin/env bash 

PROJECT_NAME=""

cleanup(){
  echo "[Interrupted] Signal trigger. Bundling current state..."

  if [ -n "$PROJECT_NAME" ] ; then 
    tar -czf "${PROJECT_NAME}_archive.tar.gz" "$PROJECT_NAME/"
    rm -rf "$PROJECT_NAME/"
    echo "[Status] Archive created. Folders cleared" 
  
  else 
    echo "[Status] Deploying process halted. Clean slate" 
  
  fi 

}

trap cleanup SIGINT

# Stage 1: Welcome and Project ID Creation Block

echo "+++++++++++++++++++++++++++++++++++++"
echo " Student Tracker Deployment Setup"
echo "+++++++++++++++++++++++++++++++++++++"

echo "[Greetings] Welcome to your student tracker deployement setup !"

read -p "[Project ID] Please, Enter a project indentifier: " SUFFIX

if [ -z "$SUFFIX" ] ; then
    echo "[ERROR] No identifier inserted. Exiting"

exit 1

fi

PROJECT_NAME="attendance_tracker_${SUFFIX}"
echo "[Info] Creating project:  $PROJECT_NAME"

# Directory Structure 

mkdir -p "$PROJECT_NAME/Helpers"
mkdir -p "$PROJECT_NAME/reports"

# Inserting the content of the subjected files attendance_checker.py/ assets.csv config.json and reports. log using Heredocs

# 1.Attendance Checker

cat > "$PROJECT_NAME/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()

EOF

# 2. Config.Json 

cat > "$PROJECT_NAME/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

# 3. Assets.csv

cat > "$PROJECT_NAME/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0

EOF

# 4.reports.log

cat > "$PROJECT_NAME/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.

EOF

echo "[Info] Files created successfully."

# Threshold Configuration

read -p "[Update] Would you like to edit the threshold(s)? (y/n): " UPDATE_THRESHOLDS

if [[ "$UPDATE_THRESHOLDS" == "y" || "$UPDATE_THRESHOLDS" == "Y" ]]; then

    read -p "[Edit] Insert the new warning: " NEW_WARNING
    read -p "[Edit] Insert the new failure: " NEW_FAILURE

    sed -i "s/\"warning\": [0-9]*/\"warning\": $NEW_WARNING/" "$PROJECT_NAME/Helpers/config.json"
    echo "[CONFIG] Warning threshold set to $NEW_WARNING%"

    sed -i "s/\"failure\": [0-9]*/\"failure\": $NEW_FAILURE/" "$PROJECT_NAME/Helpers/config.json"
    echo "[CONFIG] Failure threshold set to $NEW_FAILURE%"

else
    echo "[Update] Thresholds remain unchanged!"

fi

# Healt Check 

echo "[HEALTH CHECK] Running environment validation..."

if python3 --version &>/dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "[OK] Python3 found: $PYTHON_VERSION"
else
    echo "[WARNING] Python3 not found. Issue detected"
fi

echo "[HEALTH CHECK] Verifying directory structure..."
if [ -e "$PROJECT_NAME/attendance_checker.py" ] ; then 
    echo "[Check] '$PROJECT_NAME/attendance_checker.py' exists" 
else 
    echo "[Error] '$PROJECT_NAME/attendance_checker.py' not found" 

fi

if [ -e "$PROJECT_NAME/Helpers/assets.csv" ] ; then 
    echo "[Check] '$PROJECT_NAME/Helpers/assets.csv' exists" 
else 
    echo "[Error] '$PROJECT_NAME/Helpers/assets.csv' not found" 

fi 

if [ -e "$PROJECT_NAME/Helpers/config.json" ] ; then 
     echo "[Check] '$PROJECT_NAME/Helpers/config.json' exists" 
else 
     echo "[Error] '$PROJECT_NAME/Helpers/config.json' not found" 

fi 

if [ -e "$PROJECT_NAME/reports/reports.log" ] ; then 
    echo "[Check] '$PROJECT_NAME/reports/reports.log' exists" 
else 
    echo "[Error] '$PROJECT_NAME/reports/reports.log' not found" 
fi

echo "++++++++++++++++++++++++++++++++++++++++"
echo "  Setup Complete: $PROJECT_NAME"
echo "+++++++++++++++++++++++++++++++++++++++++"

echo "[Thanks] Designed by David-Harold E. Koffi-Essiben"
echo "@builtbykoffi"

