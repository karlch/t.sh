#!/bin/bash

shell_files="t.sh t_notify.sh tests/general_test.sh tests/run_tests.sh"
test_files="t.sh"

# Run test for file $1
run_tests() {
    case "$1" in
        "t") tests/general_test.sh || exit 1
            ;;
    esac
}

# Run shellcheck for file $1
run_shellcheck() {
    shellcheck "$1" || exit 1
    printf 'Shellcheck for "%s" ran successfully.\n' "$1"
}

printf "Starting testsuite.\n"
cd .. || exit 1

for file in $shell_files; do
    run_shellcheck "$file"
done

for file in $test_files; do
    run_tests "$file"
done

printf "Everything finished successfully.\n"
