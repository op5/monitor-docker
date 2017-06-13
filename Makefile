# Append the git sha unless we are doing a release
ifdef IS_RELEASE
APP_VERSION := $(shell cat version.txt)
else
APP_VERSION ?= $(shell cat version.txt)-$(shell git rev-parse --short HEAD)
endif

IMAGE_NAME:=registry.gitlab.com/truepath/op5_docker/image
IMAGE:=${IMAGE_NAME}:${APP_VERSION}
IMAGE_LATEST:= ${IMAGE_NAME}:latest
# Test properties
VERSION ?= ${APP_VERSION}

build:
	docker build -t ${IMAGE} .
	docker tag ${IMAGE} ${IMAGE_LATEST}

push: build
	docker push ${IMAGE}
# Only push latest if we are doing a release
ifdef IS_RELEASE
	docker push ${IMAGE_LATEST}
endif
	@echo "Pushed version ${APP_VERSION} to registry"

run:
	IMAGE=${IMAGE} docker-compose up -d

stop:
	IMAGE=${IMAGE} docker-compose stop

pull:
	docker rmi ${IMAGE_NAME}:${APP_VERSION} || true
	docker pull ${IMAGE_NAME}:${APP_VERSION}

save:
	docker save ${IMAGE_NAME}:${APP_VERSION} > registry.gitlab.com_truepath_op5_docker-${APP_VERSION}.tar
	gzip registry.gitlab.com_truepath_op5_docker-${APP_VERSION}.tar

clean:
	-@docker rmi $$(docker images | grep ntp | awk '{ print $$3 }')

