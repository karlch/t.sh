### t, a simple command line tasklist manager

## Version 0.1 (unreleased)

t comes with two scripts:

* t.sh: the actual task manager
* t\_notify.sh: sends notifications if a task is due soon

It is recommended to set up an alias `alias t='t.sh'` in your .shellrc.

t saves tasks with optional due dates in taskfiles. It is possible to manipulate
and remove those tasks and to check for tasks which are due soon. Per default t
saves files in TASKDIR=~/.local/share/tasks.

Tasks can be grouped into different taskfiles. The default taskfile is main. The
taskfile to currently operate on is stored in $TASKDIR/taskfile.

Obviously everything is stored as plain text into simple text files. This makes
manipulation and reading with other tools nice and easy.

## Installation

**Requirements**

For t:

* bash (other shells might work)
* standard unix tools like sed, awk or find

For t\_notify additionally:

* libnotify
* a notification daemon

If all requirements are installed both scripts should run just fine. Move them
to somewhere in your $PATH environment like ~/bin to be able to access them
globally.

To install t globally, use the Makefile included.

## Usage

**Show a list of your tasks**

To list your tasks simply run `t`. The list is numbered, the reason therefore
will become clear soon.

    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to earth  (2042-04-02)
    $

**Add new tasks**

To add new tasks run `t the new task`. t will prompt for a due date which
t\_notify can parse.

    $ t Keep calm and drink a beer
    Enter a due date? [y/N] n
    $ t Prepare talk
    Enter a due date? [y/N] y
    Enter a valid date (yy-mm-dd): 17-07-14
    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to earth  (2042-04-02)
    3) Keep calm and drink a beer
    4) Prepare talk  (2017-07-14)
    $

**Finish tasks**

To finish a task run `t f $tasknum`. This is where the line numbers displayed by
`t` come in.

    $ t f 3
    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to earth  (2042-04-02)
    3) Prepare talk  (2017-07-14)
    $

**List all taskfiles**

As it is possible to have multiple taskfiles, there is a way to list all of
them: `t l`. The date appended shows the date when the file was last modified.

    $ t l
    vimiv (01-07-16)
    demolist (04-07-16)
    main (04-07-16)
    $

**Switch taskfile**

To switch to the newly found taskfiles or to create new taskfiles use `t t
$filename`. If no filename is provided, the default main is used.

    $ t t demolist2
    $ t
    Tasks in demolist2
    ────────────────────────────────────────────────────────────────────────────────
    $ t t demolist
    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to earth  (2042-04-02)
    3) Prepare talk  (2017-07-14)
    $

**Remove taskfile**

To remove a taskfile run `t r $filename`.

    $ t l
    vimiv (01-07-16)
    demolist (04-07-16)
    main (04-07-16)
    demolist2 (04-07-16)
    $ t r demolist2
    $ t r demolist
    Taskfile is not empty, delete anyway? [yN] n
    $ t l
    vimiv (01-07-16)
    demolist (04-07-16)
    main (04-07-16)
    $

If the taskfile is not empty t will prompt for confirmation.

**Edit multiple tasks**

As everything is saved in plain text and you probably have your favourite tool
to edit text, `t e` opens the current taskfile in $EDITOR. Note that the
corresponding environment variable must be set. If not set it will default to
nano.


**Change task text**

To completely change the text of one task run `t c $tasknum the new text`.

    $ t c 3 Learn how to use latex beamer
    Keep current date? [Yn] y
    $ t c 2 Come back to earth early!
    Keep current date? [Yn] n
    Enter a valid date (yy-mm-dd): 18-04-02
    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to earth early!  (2018-04-02)
    3) Learn how to use latex beamer  (2017-07-14)
    $

As you can see the entered date can be preserved or changed.

**Substitute string in task**

If a simple sed substitution is enough run `t s $tasknum before after`.
    
    $ t s 2 earth mars
    $ t
    Tasks in demolist
    ────────────────────────────────────────────────────────────────────────────────
    1) Visit the restaurant at the end of the universe
    2) Come back to mars early!  (2018-04-02)
    3) Learn how to use latex beamer  (2017-07-14)
    $

**Receive notifications**

Run `t_notify`. It checks all taskfiles for tasks which are due in the next two
days and notifies about those which are. The notifications are sent via
notify-send. Therefore libnotify and a corresponding notification-daemon must be
installed. If you don't have your favourite, I recommend dunst. It is useful
to run t\_notify periodically, e.g. using systemd timers or a cron job. For
convenience a systemd timer set is included in the repo.

**Extras**

`sed` is used for finishing of, changing and substituting in tasks. It is
therefore possible to work on multiple tasks. For example `t f 3,5` will finish
tasks 3, 4 and 5.


## Thanks to
Steve Losh, author of t https://github.com/sjl/t which inspired me to write this
tool.

Alad Wenter, Wiki Admin of the ArchWiki who helped me in the very beginning and
pointed me towards shellcheck.

## License
GPL3
