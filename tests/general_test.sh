#!/bin/bash

TASKDIR=~/.local/share/tasks

# Leave with an error message and cleaning up
exit_tests() {
    printf "%s.\n" "$1" 1>&2
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
    ../t t new_task_list

    # The new task list must be in the tasks directory
    find "$TASKDIR" -name "new_task_list" || exit_tests "Task list not created"

    # Add some tasks
    printf "N" | ../t fancy new task
    printf "N" | ../t fancy second task
    printf "N" | ../t fancy third task
    # All there?
    if [[ $(../t | wc -l) != 5 ]]; then
        exit_tests "3 tasks not created correctly."
    fi

    # Remove third task
    ../t f 3
    if [[ $(../t | wc -l) != 4 ]]; then
        exit_tests "Task 3 not removed.\n" 
    fi

    # t must be able to list the taskfile
    ../t l | grep "new_task_list" || exit_tests "New taskfile not listed."

    # Change the second task
    ../t c 2 different second task
    ../t | grep "2) different second task" || \
        exit_tests "Second task not changed."

    # Substitute in the first task
    ../t s 1 new first
    ../t | grep "1) fancy first task" || \
        exit_tests "First task text not substituted."

    # Finally remove the file with t
    printf "y" | ../t r new_task_list
    find "$TASKDIR" | grep "new_task_list" && \
        exit_tests "Task list was not removed."

    # And check if we are back to default
    t | grep "main" || exit_tests "Switch to main failed."
}

printf "Running tests.\n...\n"
run_tests 1>/dev/null
printf "Tests finished succesfully.\n"
