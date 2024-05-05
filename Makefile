# simple makefile
@:
	@echo "no commands chosen.";
	@echo "try 'make help' to see available commands.";

## install: Setup repository
install:
	@bundle
	@yarn
	@echo ""
	@echo "Repo setup finished. Start site by running: make watch"

## watch: Start development mode with watcher
watch:
	@jekyll serve

## build: Build production version
build:
	@jekyll build

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command run with parameter options: "
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
