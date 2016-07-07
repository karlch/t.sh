#!/bin/bash

TASKDIR=~/.local/share/tasks
DEBUGFILE="debug.txt"

# Leave with an error message and cleaning up
exit_tests() {
    printf "%s\n" "$1" 1>&2
    printf "Running tests failed.\n" 1>&2
    # Remove new taskfile manually
    rm $TASKDIR/test_notify 2>/dev/null
    # Remove debugfile
    rm "$DEBUGFILE"
    # And switch to main taskfile manually
    printf "main\n" > $TASKDIR/taskfile
    exit 1
}

# Move into tests directory
cd "$(dirname "$0")" || exit_tests "cd failed."

# Start a new taskfile entering dates that should be checked
# Note: t.sh must work correctly
create_testfile() {
    today=$(date '+%y-%m-%d')
    tomorrow=$(date -d "+1 day" '+%y-%m-%d')
    in_two_days=$(date -d "+2 days" '+%y-%m-%d')
    way_off=$(date -d "+30 days" '+%y-%m-%d')

    ../t.sh t "test_notify"
    printf "y%s" "$today" | ../t.sh fancy new task
    printf "y%s" "$tomorrow" | ../t.sh fancy second task
    printf "y%s" "$in_two_days" | ../t.sh fancy third task
    printf "y%s" "$today" | ../t.sh fancy fourth task
    printf "y%s" "$today" | ../t.sh fancy fifth task
    printf "y%s" "$in_two_days" | ../t.sh fancy sixth task
    printf "y%s" "$tomorrow" | ../t.sh fancy seventh task
    printf "y%s" "$way_off" | ../t.sh useless task

}

run_tests() {
    create_testfile

    # Source t_notify to access the functions
    # shellcheck disable=SC1091
    source ../t_notify.sh
    # Close all notifications thanks to the source
    xdotool key "Control+Shift+space"

    # Run the main notification function on the new taskfile saving output to
    # $DEBUGFILE instead of showing notifications
    main "test_notify" "$DEBUGFILE"

    # All notifications there?
    if [[ $(wc -l "$DEBUGFILE" | awk '{print $1}') != 7 ]]; then
        exit_tests "Not all notifications received."
    fi

    # Get the line numbers for the dates (sorted correctly?)
    todays=$(awk '/today/{print NR}' "$DEBUGFILE" | tr "\n" " ")
    tomorrows=$(awk '/tomorrow/{print NR}' "$DEBUGFILE" | tr "\n" " ")
    in_two_dayss=$(awk '/in two days/{print NR}' "$DEBUGFILE" | tr "\n" " ")
    if [[ $todays != "1 2 3 " || \
          $tomorrows != "4 5 " || \
          $in_two_dayss != "6 7 " ]]; then
        exit_tests "Sorting did not work."
    fi

    # Cleanup
    printf "y" | ../t.sh r "test_notify"
    rm "$DEBUGFILE"
}

printf "Running tests for t_notify.sh.\n...\n"
run_tests 1>/dev/null
printf "Tests finished succesfully.\n"
