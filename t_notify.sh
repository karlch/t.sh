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

# The actual function
# Checks for dates that are close and sends a notification containing the task
# due and the date
# Arguments: TASKFILE
notify() {
    TASKFILE=$TASKDIR/$1

    # Get the due_dates
    due_dates=$(grep -o '20[0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]' "$TASKFILE")

    # Dates that are close
    today=$(date '+%F')
    tomorrow=$(date -d "+1 day" '+%F')
    in_two_days=$(date -d "+2 days" '+%F')
    close_dates="$today $tomorrow $in_two_days"

    # Check for matches
    close_tasks=""
    for due_date in $due_dates; do
        for close_date in $close_dates; do
            if [[ $due_date == "$close_date" ]]; then
                # If dates match remember the corresponding task formatted
                # neatly
                close_task=$(grep "$due_date" "$TASKFILE")

                case "$due_date" in
                    $today)         due_format="(today)" ;;
                    $tomorrow)      due_format="(tomorrow)" ;;
                    $in_two_days)   due_format="(in 2 days)" ;;
                esac

                # Use $1 here because this is the short name
                close_task=$(printf "%s: %s" "$1" "$close_task" | \
                             sed "s/($due_date)/$due_format/")

                close_tasks=$close_tasks$close_task$'\n'
            fi
        done
    done
    # Only unique tasks (multiples happen if multiple tasks have the same due
    # date)
    close_tasks=$(printf "%s" "$close_tasks" | sort | uniq)

    # Send a notification for all tasks due soon
    if [[ -n "$close_tasks" ]]; then
        while read -r task; do
            notify-send -u critical -h string:iconname:"$TASKFILE" "$task"
        done <<< "$close_tasks"
    fi
}

# Notify for each taskfile
while read -r taskfile; do
    notify "$taskfile"
done <<< \
    "$(find $TASKDIR -mindepth 1 -name "taskfile" -prune -o -printf "%f\n")"
