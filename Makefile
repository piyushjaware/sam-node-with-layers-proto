.PHONY: test invoke


NODE=node:12
STACK := --stack-name sam-node-proto
BUCKET_PREFIX := --s3-prefix sam-test
PKG_TPL_OPTS := --template-file template.yml --output-template-file template-export.yml
DEPLOY_CAPS := --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
IMAGE:= sam-node-proto

REGION := --region us-west-2 # secret
ENG_PROFILE := --profile eng # secret
ENG_S3_BUCKET := --s3-bucket bunchball-code-qa # secret
DEV_TAGS := --tags Environment=dev Project=sam-node-proto


validate:
	sam validate --template template.yml

install-deps: install-lib-layer-deps install-greeter-function-deps

install-lib-layer-deps:
	docker run -i --rm --name install -v `pwd`/layers/lib/nodejs:/usr/src/app -w /usr/src/app $(NODE) npm install

install-greeter-function-deps:
	docker run -i --rm --name install -v `pwd`/lambdas/greeter:/usr/src/app -w /usr/src/app $(NODE) npm install

build: install-deps
	sam build

run-greeter: build
	sam local invoke -e tests/resources/event-payloads/event.json GreeterFunction

build-tests: # build for pytest
	$(warning This might take a bit longer the first time as all dependencies need to be installed. Later runs will be quicker as they use cached dependency data.) 
	docker build --tag=${IMAGE}:latest .

# inspect the files in the test image.
inspect-files: build-tests
	docker run -it -v ~/.aws:/root/.aws --entrypoint="bash" ${IMAGE}:latest

test: build-tests
	docker run --rm \
	-v ~/.aws:/root/.aws \
	--entrypoint="node" ${IMAGE}:latest node_modules/.bin/nyc node_modules/.bin/_mocha tests/unit/**/*.js --colors
	
deploy-dev: validate install-deps test
	sam package ${PKG_TPL_OPTS} ${ENG_S3_BUCKET} ${BUCKET_PREFIX} $(ENG_PROFILE) $(REGION)
	sam deploy --template-file template-export.yml --parameter-overrides $(shell cat deploy/parameters.dev.properties) ${STACK}-dev $(DEPLOY_CAPS) $(ENG_PROFILE) $(REGION) ${DEV_TAGS}