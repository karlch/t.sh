VERSION   := 0.1

PREFIX    := usr/
DESTDIR   := /
SYSTEMD   := lib/systemd/user/

default:
	@printf "There is nothing to do.\n"
	@printf "Run sudo make install to install t.\n"
	@printf "Run sudo make install_timers to install the systemd timer.\n"
	@printf "Run make options for a list of all options.\n"

options: help
	@printf "\nOptions:\n"
	@printf "PREFIX = $(PREFIX)\n"
	@printf "DESTDIR = $(DESTDIR)\n"

help:
	@printf "make help:             Print help.\n"
	@printf "make options:          Print help and list all options.\n"
	@printf "make install:          Install t.\n"
	@printf "make install_timers:   Install systemd timer.\n"
	@printf "make install_all:      Install both.\n"
	@printf "make uninstall:        Uninstall t.\n"
	@printf "make uninstall_timers: Uninstall systemd timer.\n"
	@printf "make uninstall_all:    Uninstall both.\n"

install:
	mkdir -p $(DESTDIR)$(PREFIX)bin
	cp t.sh $(DESTDIR)$(PREFIX)bin/
	cp t_notify.sh $(DESTDIR)$(PREFIX)bin/
	chmod 755 $(DESTDIR)$(PREFIX)bin/t.sh
	chmod 755 $(DESTDIR)$(PREFIX)bin/t_notify.sh
	@printf "It is recommended to setup an alias t=t.sh in your .shellrc.\n"

install_timers:
	mkdir -p $(DESTDIR)$(PREFIX)$(SYSTEMD)
	cp timers/t_notify.timer $(DESTDIR)$(PREFIX)$(SYSTEMD)
	cp timers/t_notify.service $(DESTDIR)$(PREFIX)$(SYSTEMD)
	chmod 644 $(DESTDIR)$(PREFIX)$(SYSTEMD)t_notify.timer
	chmod 644 $(DESTDIR)$(PREFIX)$(SYSTEMD)t_notify.service
	@printf "To run the timer use systemctl --user to enable it.\n"

install_all: install install_timers

uninstall:
	rm -f $(DESTDIR)$(PREFIX)bin/t.sh
	rm -f $(DESTDIR)$(PREFIX)bin/t_notify.sh

uninstall_timers:
	rm -f $(DESTDIR)$(PREFIX)$(SYSTEMD)t_notify.timer
	rm -f $(DESTDIR)$(PREFIX)$(SYSTEMD)t_notify.service

uninstall_all: uninstall uninstall_timers
