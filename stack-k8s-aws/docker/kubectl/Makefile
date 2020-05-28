.DEFAULT_GOAL := deploy

DIRNAME := $(notdir $(abspath .))
IMAGE ?= agilestacks/kubectl
CONTAINER ?= kubectl
KCTL_VERSION ?= v1.13.5
DOCKER_BUILD_OTPS := --no-cache  --force-rm "

deploy: build push

build:
	docker build $(DOCKER_BUILD_OPTS) \
		-t $(IMAGE):$(KCTL_VERSION) \
		-t $(IMAGE):latest .
.PHONY: build

run:
	docker run --name=$(CONTAINER) $(IMAGE)
.PHONY: run

attach:
	docker exec -i -t $(CONTAINER) bash
.PHONY: run

push:
	docker tag  $(IMAGE):$(KCTL_VERSION) $(IMAGE):latest
	docker push $(IMAGE):$(KCTL_VERSION)
	docker push $(IMAGE):latest
.PHONY: push
