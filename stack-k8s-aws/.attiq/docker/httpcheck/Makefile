.DEFAULT_GOAL := compile

DIRNAME := $(notdir $(abspath .))
IMAGE ?= agilestacks/httpcheck
CONTAINER ?= httpcheck
HTTPCHECK_VERSION ?= v0.0.2
DOCKER_BUILD_OTPS := --no-cache  --force-rm "

deploy: compile build push

build:
	docker build $(DOCKER_BUILD_OPTS) \
		-t $(IMAGE):$(HTTPCHECK_VERSION) \
		-t $(IMAGE):latest .
.PHONY: build

compile:
	GOOS=linux go build \
  	-a --ldflags '-extldflags "-static"' \
  	-o httpcheck .

run:
	docker run --name=$(CONTAINER) $(IMAGE)
.PHONY: run

attach:
	docker exec -i -t $(CONTAINER) bash
.PHONY: run

push:
	docker tag  $(IMAGE):$(HTTPCHECK_VERSION) $(IMAGE):latest
	docker push $(IMAGE):$(HTTPCHECK_VERSION)
	docker push $(IMAGE):latest
.PHONY: push
