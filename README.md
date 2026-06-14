# deploy_agent_David-Harold

A shell script that automates the creation and configuration of a Student Attendance Tracker workspace.

## How to Run

1. Clone the repository
2. Give the script execution permission:
   chmod +x setup_project.sh
3. Run the script:
   ./setup_project.sh
4. Follow the prompts:
   - Enter a project identifier
   - Choose whether to update attendance thresholds

## How to Trigger the Archive Feature

The archive feature activates automatically if you interrupt the script mid-execution using Ctrl+C.

If the project directory has already been created, the script will:
- Bundle the current state into a .tar.gz archive named attendance_tracker_{input}_archive.tar.gz
- Delete the incomplete project directory
- Exit cleanly

If interrupted before a project name is entered, the script exits with no archive needed.

## Author

David-Harold E. Koffi-Essiben
@builtbykoffi
