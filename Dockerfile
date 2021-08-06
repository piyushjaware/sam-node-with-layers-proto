# -------------------------------------------- #
# Only used for Testing!
# -------------------------------------------- #

FROM node:12.18.1
ENV NODE_ENV=test

WORKDIR /app

# Copy all the requirement files to the image first so they can be installed without coping the code.
# This makes the tests super fast as these layers will be cached after the first time.
COPY tests/package.json ./tests/package.json
COPY layers/lib/nodejs/package.json ./layers/lib/nodejs/package.json
COPY lambdas/greeter/package.json ./lambdas/greeter/package.json

# Install all the test+layer+lambdas dependencies at their resp path 
RUN find . ! -path "*/node_modules/*" -name "package.json" -execdir npm install \;

# Put all dependencies at the base path, just as sam makes them avaiable while running lambda
RUN if [ -d ./tests/node_modules ]; then cp -a ./tests/node_modules/. ./node_modules/  ; fi
RUN if [ -d ./layers/lib/nodejs/node_modules ]; then cp -a ./layers/lib/nodejs/node_modules/. ./node_modules/  ; fi
RUN if [ -d ./lambdas/greeter/node_modules ]; then cp -a ./lambdas/greeter/node_modules/. ./node_modules/  ; fi

COPY . .

# Make code layer available as node module, just like sam does 
COPY layers/code/nodejs/node_modules ./node_modules

ENTRYPOINT /bin/bash