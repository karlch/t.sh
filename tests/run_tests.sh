#!/bin/bash

printf "Starting testsuite.\n"
cd "$(dirname "$0")"/.. || exit 1

shell_files="$(find . -name "*.sh")"
test_files="t.sh t_notify.sh"

# Run test for file $1
run_tests() {
    case "$1" in
        "t.sh") tests/t_test.sh || exit 1
            ;;
        "t_notify.sh") tests/t_notify_test.sh || exit 1
            ;;
    esac
}

# Run shellcheck for file $1
run_shellcheck() {
    shellcheck "$1" || exit 1
    printf 'Shellcheck for "%s" ran successfully.\n' "$1"
}

for file in $shell_files; do
    run_shellcheck "$file"
done

for file in $test_files; do
    run_tests "$file"
done

printf "Everything finished successfully.\n"
