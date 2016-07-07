#!/bin/bash

TASKDIR=~/.local/share/tasks

# Leave with an error message and cleaning up
exit_tests() {
    printf "%s\n" "$1" 1>&2
    printf "Running tests failed.\n" 1>&2
    # Remove new taskfile manually
    rm $TASKDIR/new_task_list 2>/dev/null
    # And switch to main taskfile manually
    printf "main\n" > $TASKDIR/taskfile
    exit 1
}

# Move into tests directory
cd "$(dirname "$0")" || exit_tests "cd failed."

# Actual testfunction
run_tests() {
    # Create a new task list to work with
    ../t.sh t new_task_list

    # The new task list must be in the tasks directory
    find "$TASKDIR" -name "new_task_list" || exit_tests "Task list not created"

    # Add some tasks
    printf "y17-07-13" | ../t.sh fancy new task
    printf "N" | ../t.sh fancy second task
    printf "N" | ../t.sh fancy third task
    # All there?
    if [[ $(../t.sh | wc -l) != 5 ]]; then
        exit_tests "3 tasks not created correctly."
    fi

    # Remove third task
    ../t.sh f 3
    if [[ $(../t.sh | wc -l) != 4 ]]; then
        exit_tests "Task 3 not removed.\n" 
    fi

    # t must be able to list the taskfile
    ../t.sh l | grep "new_task_list" || exit_tests "New taskfile not listed."

    # Change the second task preserving date
    printf "y" | ../t.sh c 2 different second task
    ../t.sh | grep "2) different second task" || \
        exit_tests "Second task not changed."
    # Change the first task changing date
    printf "N17-07-14\n" | ../t.sh c 1 different new task 2>&1
    ../t.sh | grep "1) different new task  (2017-07-14)" || \
        exit_tests "First task with date not changed."

    # Substitute in the first task
    ../t.sh s 1 new first
    ../t.sh | grep "1) different first task  (2017-07-14)" || \
        exit_tests "First task text not substituted."

    # Finally remove the file with t
    printf "y" | ../t.sh r new_task_list
    find "$TASKDIR" | grep "new_task_list" && \
        exit_tests "Task list was not removed."

    # And check if we are back to default
    ../t.sh | grep "main" || exit_tests "Switch to main failed."
}

printf "Running tests for t.sh.\n...\n"
run_tests 1>/dev/null
printf "Tests finished succesfully.\n"
