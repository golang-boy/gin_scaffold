PREFIX:=golangboy
NAME := gin_scaffold
DEVTAG := dev
PRODTAG := latest
IMAGE := $(PREFIX)/$(NAME)
PACKNAME:= $(PREFIX)_$(NAME)_$(PRODTAG).tar
DEVPACKNAME:= $(PREFIX)_$(NAME)_$(DEVTAG).tar

AUTHBOX := /home/authbox/stor/

bin:
	go build  -o ./bin/gin_scaffold  main.go

build:
#	docker image prune -f
	docker build --network host -f Dockerfile -t $(IMAGE):$(PRODTAG) .
run: 
	docker run --rm --name $(IMAGE) \
	-p 8023:8023 \
	-it $(IMAGE):$(PRODTAG) 

pack: build
	docker save $(IMAGE):$(PRODTAG) > images/$(PACKNAME)

devops: 
	ansible-playbook -i hosts  deploy.yml --extra-vars "image=$(PACKNAME) workspace=$(PWD) authbox=$(AUTHBOX)"

lint:
	docker run --rm --network host -e GOPROXY=https://goproxy.cn,direct  -v $(PWD):/app -w /app golangci/golangci-lint:v1.27.0 golangci-lint run ./... --timeout=10m -v --out-format checkstyle > golangcilint.xml

sonar: lint
	docker run --rm --network host -v $(PWD):/usr/src sonarsource/sonar-scanner-cli  -Dproject.settings=sonar.properties

build-dev:
#	docker image prune -f
	docker build -f Dockerfile.debug -t $(IMAGE):$(DEVTAG) .

run-dev:
	docker run --rm --name $(IMAGE) \
	--security-opt="seccomp=unconfined" --cap-add=SYS_PTRACE \
	-p 2345:2345 \
	-p 8023:8023 \
	-it $(IMAGE):${DEVTAG}

pack-dev: build-dev
	docker save $(IMAGE):$(DEVTAG) > images/$(DEVPACKNAME)
