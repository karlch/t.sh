#!/bin/bash

# A very simple todo list manager

# Make the tasks directory
TASKDIR=~/.local/share/tasks
mkdir -p $TASKDIR

# Find out the Taskfile and create default one if it doesn't exist
make_task_file() {
    printf "main\n" > $TASKDIR/taskfile
    TASKFILE=$TASKDIR/main
    if [[ ! -s $TASKDIR/main ]]; then
        touch $TASKDIR/main
    fi
}
TASKFILE=$TASKDIR/$(cat $TASKDIR/taskfile 2>/dev/null) || make_task_file

# Read a date from the user making sure it is a real date
read_date() {
    # Read until a user date is correct
    while true; do
        read -r -p "Enter a valid date (yy-mm-dd): " user_date
        user_date=$(printf "20%s" "$user_date" | sed 's/[^0-9a-zA-Z]/-/g' | \
                    grep "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]") || continue
        # Timestamps to compare
        yesterday=$(date -d "yesterday" +%s)
        user_date_num=$(date -d "$user_date" +%s) || continue
        if [[ $user_date_num -gt "$yesterday" ]]; then
            printf "(%s)" "$user_date"
            break
        fi
    done
}

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
        entered_date=$(read_date)

        printf "  %s" "$entered_date" >> "$TASKFILE"
    fi

    printf "\n" >> "$TASKFILE"
}

# Switch to a taskfile
# Argument: filename
switch_taskfile() {
    if [[ -n $1 ]]; then
        printf "%s" "$1" > $TASKDIR/taskfile
    else
        printf "main" > $TASKDIR/taskfile  # Default
    fi
    # Create taskfile if it doesn't exist
    if [[ ! -s "$TASKDIR/$1" ]]; then
        touch "$TASKDIR/$1"
    fi
}

# Opens taskfile in editor setting a default
edit_taskfile() {
    if [[ -z "$EDITOR" ]]; then
        printf "\$EDITOR not set, defaulting to nano.\n"
        sleep 2
        EDITOR="nano"
    fi
    "$EDITOR" "$TASKFILE"
}

# Removes a taskfile
# Argument: filename
remove_taskfile() {
    local taskfile=$TASKDIR/$1
    if [[ -s $taskfile ]]; then
        read -n1 -r -p "Taskfile is not empty, delete anyway? [yN] " delete
        printf "\n"
        if [[ $delete != "y" && $delete != "Y" ]]; then exit 1; fi
    fi
    rm "$taskfile"
    # Switch to main taskfile if the removed one is the current taskfile
    if [[ $taskfile == "$TASKFILE" ]]; then
        switch_taskfile
    fi
}

# A function to change the task preserving the due_date if whished
# Arguments: tasknum, new_text
change_task() {
    tasknum="$1"
    new_text="$2"
    old_text=$(sed "${tasknum}q;d" "$TASKFILE")

    # Has a date?
    if printf "%s\n" "$old_text" | grep -E "([0-9]{4}-[0-9]{2}-[0-9]{2})"
    then
        # Substitute everything up to date
        sed -i "$tasknum s/.*\(  (\)/$new_text\1/g" "$TASKFILE"
        # Should it be preserved?
        read -n1 -r -p "Keep current date? [Yn] " keep_date
        printf "\n" >&2

        if [[ $keep_date == "n" || $keep_date == "N" ]]; then
            new_date=$(read_date)
            sed -i "$tasknum s/(20[0-9][0-9]-[0-9][0-9]-[0-9][0-9])/$new_date/" "$TASKFILE"
        fi
    else
        sed -i "$tasknum s/.*/$new_text/g" "$TASKFILE"
    fi
}

# Check if an argument was given
if [[ $@ ]]; then

    case "$1" in

    # Finish the tasks given in sed format
    f)  sed -i "$2 d" "$TASKFILE"
        ;;
    # List taskfiles
    l)  find "$TASKDIR" -mindepth 1 -name "taskfile" -prune \
            -o -printf "%f (%Td-%Tm-%Ty)\n"
        ;;
    # Switch to a different TASKFILE
    t)  switch_taskfile "$2"
        ;;
    # Open TASKFILE in editor
    e)  edit_taskfile
        ;;
    # Remove a taskfile
    r)  remove_taskfile "$2"
        ;;
    # Change the task completely
    c)  change_task "$2" "${*:3}" > /dev/null
        ;;
    # Sed substitution to edit the task
    s)  sed -i "$2 s/$3/${*:4}/g" "$TASKFILE"
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
