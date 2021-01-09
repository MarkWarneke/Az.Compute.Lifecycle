DOCKER_NAME='azurepilotmigration-livecycle-pwsh'

define find.functions
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
endef

help:
	@echo 'The following commands can be used.'
	@echo ''
	$(call find.functions)


build: ## Build docker image
build:
	docker build -f Dockerfile -t $(DOCKER_NAME) .

start.vm: ## Start a given VM using the docker image
start.vm:
	docker run --name $(DOCKER_NAME) --volume="$(current_dir):/app" --env-file .env  $(DOCKER_NAME)

stop.vm: ## Start a given VM using the docker image
stop.vm:
	docker run --name $(DOCKER_NAME) --volume="$(current_dir):/app" --env-file .env  $(DOCKER_NAME) pwsh -file ./run.ps1 -stop

exec: ## Executes into the contianer
exec:
	docker run -it  --env-file .env --entrypoint pwsh  $(DOCKER_NAME)

stop: ## stop docker container
stop:
	docker stop $(DOCKER_NAME)

remove: ## remove docker container
remove: stop
	docker rm -f $(DOCKER_NAME)