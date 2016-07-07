#!/bin/bash

# Notification tool for the simple todo list manager

# Tasks directory
TASKDIR=~/.local/share/tasks
# Need at least two files in the directory for this to make sense
# one is the file containing the current taskfiles name
# one is the current taskfile
if [[ $(find $TASKDIR | wc -l) -lt 2 ]]; then
    printf "No tasks to check for available.\n"
    exit 1
fi

# Dates that are close
today=$(date '+%F')
tomorrow=$(date -d "+1 day" '+%F')
in_two_days=$(date -d "+2 days" '+%F')
close_dates="$today $tomorrow $in_two_days"

# Checks for dates that are close and returns the corresponding tasks
# Argument: TASKFILE
get_tasks() {
    TASKFILE=$TASKDIR/$1

    # Get the due_dates and only once
    due_dates=$(grep -o '20[0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]' "$TASKFILE" | \
                sort | uniq)

    # Check for matches
    close_tasks=""
    for due_date in $due_dates; do
        for close_date in $close_dates; do
            if [[ $due_date == "$close_date" ]]; then
                # If dates match remember the corresponding task formatted
                # neatly including the taskfile name
                close_task=$(grep "$due_date" "$TASKFILE" | \
                             sed "s/^/$1: /")

                close_tasks=$close_tasks$close_task$'\n'
            fi
        done
    done

    printf "%s" "$close_tasks"
}

# Formats and sorts the tasks sending notifications at the end
# Arguments: close_tasks, debugfile
notify() {
    # Order tasks by date and format neatly with sed
    close_tasks=$(printf "%s" "$1" | awk '{print $NF, $0}' | \
                  sort -nk1 | cut -d " " -f2- | \
                  sed "s/$today/today/" | \
                  sed "s/$tomorrow/tomorrow/" | \
                  sed "s/$in_two_days/in two days/")

    # Send a notification for all tasks due soon
    while read -r task; do
        # The debug option is necessary for testing
        if [[ -n $2 ]]; then
            printf "%s\n" "$task" >> "$2"
        else
            notify-send -u critical "$task"
        fi
    done <<< "$close_tasks"
}

# Main function which runs the other two
# Argument: files, debugfile
main() {
    # Get tasks which are due soon
    all_close_tasks=""
    while read -r taskfile; do
        all_close_tasks=$all_close_tasks$(get_tasks "$taskfile")$'\n'
    done <<< \
        "$1"

    # Remove blanks
    all_close_tasks=$(printf "%s" "$all_close_tasks" | grep '[^[:blank:]]')

    # Send notifications
    notify "$all_close_tasks" "$2"
}

# Run main on all files
main "$(find $TASKDIR -mindepth 1 -name "taskfile" -prune -o -printf "%f\n")"
