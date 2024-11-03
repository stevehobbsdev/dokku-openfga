.PHONY: clean-src build subcommands/% subcommands

SUBCOMMANDS=subcommands/world
TRIGGERS=triggers/report

clean-src:
	@rm -rf src README.md Makefile support .idea .dockerignore

build: commands subcommands triggers

commands: src/commands/commands.go
	go build -a -o commands src/commands/commands.go

subcommands:
	go build -a -o subcommands/subcommands src/subcommands/subcommands.go
	$(MAKE) $(SUBCOMMANDS)

subcommands/%:
	ln -s subcommands $@

triggers:
	go build -a -o triggers src/triggers/triggers.go
	$(MAKE) $(TRIGGERS)

triggers/%:
	ln -s triggers $(shell echo $@ | cut -d '/' -f2)
