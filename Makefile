.PHONY: build up down

IMAGE_NAME := isu-gateway-service
CONTAINER_NAME := isu-gateway
NETWORK_NAME := isu-project
PORT := 8080
ENV_FILE := .env

build:
	@echo Building Docker image...
	docker build -t $(IMAGE_NAME) .
	@echo Done!

up:
	@echo Starting container...
	@if not exist $(ENV_FILE) ( \
		echo No .env file found. Creating from .env.docker-network... && \
		copy .env.docker-network $(ENV_FILE) \
	)
	@echo Creating network if not exists...
	-docker network create $(NETWORK_NAME) 2>nul
	docker run -d \
		--name $(CONTAINER_NAME) \
		--network $(NETWORK_NAME) \
		-p $(PORT):8080 \
		--env-file $(ENV_FILE) \
		--add-host=host.docker.internal:host-gateway \
		--restart unless-stopped \
		$(IMAGE_NAME)
	@echo Container started successfully!
	@echo Access at: http://localhost:$(PORT)

down:
	@echo Stopping container...
	-docker stop $(CONTAINER_NAME) 2>nul
	-docker rm $(CONTAINER_NAME) 2>nul
	@echo Container stopped!

