#!/bin/bash

# A very simple todo list manager

# Make the tasks directory
TASKDIR=~/.cache/tasks
mkdir -p $TASKDIR

# Find out the Taskfile and create default one if it doesn't exist
make_task_file() {
    printf "main\n" > $TASKDIR/taskfile
    TASKFILE=$TASKDIR/main
}
TASKFILE=$TASKDIR/$(cat $TASKDIR/taskfile) || make_task_file

# The function to enter a new task
# Argument: task_text
new_task() {
    # Print text to taskfile
    task_text="$1"
    printf "%s" "$task_text" >> "$TASKFILE"

    # Check for due date and print it to taskfile
    read -n1 -r -p "Enter a due date? [y/N] " enter_date
    printf "\n"

    if [[ $enter_date == "y" || $enter_date == "Y" ]]; then
        printf "Enter day, month and year in two digit format.\n"

        read -n2 -r -p "Day: " day
        read -n2 -r -p "  Month: " month
        read -n2 -r -p "  Year: " year
        printf "\n"

        printf "  (%s.%s.%s)" "$day" "$month" "$year" >> "$TASKFILE"
    fi

    printf "\n" >> "$TASKFILE"
}

# Check if an argument was given
if [[ $@ ]]; then

    case "$1" in

    # Finish the tasks given in sed format
    f)  sed -i "$2 d" "$TASKFILE"
        ;;
    # Sed substitution to edit the task
    s)  sed -i "$2 s/$3/${*:4}/g" "$TASKFILE"
        ;;
    # Change the task completely
    c)  sed -i "$2 s/.*/${*:3} ($(date --iso-8601))/g" "$TASKFILE"
        ;;
    # Open TASKFILE in editor
    e)  "$EDITOR" "$TASKFILE"
        ;;
    # Switch to a different TASKFILE
    t)  if [[ -n $2 ]]; then printf "%s" "$2" > $TASKDIR/taskfile
        else printf "main" > $TASKDIR/taskfile  # Default
        fi
        ;;
    # List taskfiles
    l)  ls $TASKDIR | grep -v taskfile
        ;;
    # Append the task to the task list
    *)  new_task "$*"
        ;;
    esac

# If there was no argument simply display the tasks with line numbers
else
    printf "Tasks in %s\n" "$(basename "$TASKFILE")"
    perl -E 'say "─" x 80'

    awk '{print NR") "$0}' "$TASKFILE"
fi
