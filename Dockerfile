# ==============================================================================
# Stage 1: Runtime =============================================================
# The minimal package dependencies required to run the app in the release image:

# Use the official Ruby 3.0.3 Slim Bullseye image as base:
FROM ruby:3.0.3-slim-bullseye AS runtime

# We'll set MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# We'll install curl for later dependency package installation steps
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libpq5 \
    openssl \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Stage 2: development-base ====================================================
# This stage will contain the minimal dependencies for the rest of the images
# used to build the project:

# Use the "runtime" stage as base:
FROM runtime AS development-base

# Install the app build system dependency packages:
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev

# Receive the developer user's UID and USER:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_USERNAME=you

# Replicate the developer user in the development image:
RUN addgroup --gid ${DEVELOPER_UID} ${DEVELOPER_USERNAME} \
 ;  useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_UID} \
    --shell /bin/bash -c "Developer User,,," ${DEVELOPER_USERNAME}

# Ensure the developer user's home directory and app path are owned by him/her:
# (A workaround to a side effect of setting WORKDIR before creating the user)
RUN userhome=$(eval echo ~${DEVELOPER_USERNAME}) \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} $userhome \
 && mkdir -p /workspaces/rails-google-cloud-identity-demo/node_modules \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} /workspaces/rails-google-cloud-identity-demo

# Add the app's "bin/" directory to PATH:
ENV PATH=/workspaces/rails-google-cloud-identity-demo/bin:$PATH

# Set the app path as the working directory:
WORKDIR /workspaces/rails-google-cloud-identity-demo

# Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Configure bundler to retry downloads 3 times:
RUN bundle config set --local retry 3

# Configure bundler to use 4 threads to download, build and install:
RUN bundle config set --local jobs 4

# ==============================================================================
# Stage 3: Bundler Testing Dependencies ========================================
FROM development-base AS bundler-testing-dependencies

# Copy the project's Gemfile and Gemfile.lock files:
COPY --chown=${DEVELOPER_USERNAME} Gemfile* /workspaces/rails-google-cloud-identity-demo/

# Configure bundler to exclude the gems from the "development" group when
# installing, so we get the leanest Docker image possible to run tests:
RUN bundle config set --local without development

# Install the project gems, excluding the "development" group:
RUN bundle install

# ==============================================================================
# Stage 4: Testing =============================================================
# In this stage we'll complete an image with the minimal dependencies required
# to run the tests in a continuous integration environment.

# Use the "development-base" stage as base:
FROM development-base AS testing

# Copy the gems installed in the "bundler-testing-dependencies" stage:
COPY --from=bundler-testing-dependencies /workspaces/rails-google-cloud-identity-demo/ /workspaces/rails-google-cloud-identity-demo/
COPY --from=bundler-testing-dependencies /usr/local/bundle /usr/local/bundle

# ==============================================================================
# Stage 5: Development =========================================================
# In this stage we'll add the packages, libraries and tools required in our
# day-to-day development process.

# Use the "development-base" stage as base:
FROM development-base AS development

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Change to root user to install the development packages:
USER root

# Install sudo, along with any other tool required at development phase:
RUN apt-get install -y --no-install-recommends \
  # Adding bash autocompletion as git without autocomplete is a pain...
  bash-completion \
  # gpg & gpgconf is used to get Git Commit GPG Signatures working inside the
  # VSCode devcontainer:
  gpg \
  openssh-client \
  # Para esperar a que el servicio de minio (u otros) esté disponible:
  netcat \
  # /proc file system utilities: (watch, ps):
  procps \
  # Vim will be used to edit files when inside the container (git, etc):
  vim \
  # Sudo will be used to install/configure system stuff if needed during dev:
  sudo

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Persist the bash history between runs
# - See https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/command-history/.bash_history" \
 && mkdir /command-history \
 && touch /command-history/.bash_history \
 && chown -R ${DEVELOPER_USERNAME} /command-history \
 && echo $SNIPPET >> "/home/${DEVELOPER_USERNAME}/.bashrc"

# Create the extensions directories:
RUN mkdir -p \
  /home/${DEVELOPER_USERNAME}/.vscode-server/extensions \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders/extensions \
 && chown -R ${DEVELOPER_USERNAME} \
  /home/${DEVELOPER_USERNAME}/.vscode-server \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders

# Change back to the developer user:
USER ${DEVELOPER_USERNAME}

# Copy the gems installed in the "bundler-testing-dependencies" stage:
COPY --from=bundler-testing-dependencies /usr/local/bundle /usr/local/bundle
COPY --from=bundler-testing-dependencies /workspaces/rails-google-cloud-identity-demo/ /workspaces/rails-google-cloud-identity-demo/

# Configure bundler to not exclude any gem group, so we now get all the gems
# specified in the Gemfile:
RUN bundle config unset --local without

# Install the full gem list:
RUN bundle install

# Stage 7: Asset Precompilation ================================================
# We'll copy the minimal set of files required by rails to precompile the app
# assets:
FROM testing AS asset-precompilation

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

COPY --chown=${DEVELOPER_USERNAME} vendor /workspaces/rails-google-cloud-identity-demo/vendor
COPY --chown=${DEVELOPER_USERNAME} app/assets /workspaces/rails-google-cloud-identity-demo/app/assets
COPY --chown=${DEVELOPER_USERNAME} app/javascript /workspaces/rails-google-cloud-identity-demo/app/javascript
COPY --chown=${DEVELOPER_USERNAME} bin/rails /workspaces/rails-google-cloud-identity-demo/bin/
COPY --chown=${DEVELOPER_USERNAME} Rakefile /workspaces/rails-google-cloud-identity-demo/
COPY --chown=${DEVELOPER_USERNAME} config/initializers/assets.rb /workspaces/rails-google-cloud-identity-demo/config/initializers/assets.rb
COPY --chown=${DEVELOPER_USERNAME} config/environments/production.rb /workspaces/rails-google-cloud-identity-demo/config/environments/production.rb
COPY --chown=${DEVELOPER_USERNAME} config/application.rb config/boot.rb config/environment.rb /workspaces/rails-google-cloud-identity-demo/config/

RUN RAILS_ENV=production SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece rails assets:precompile

# Stage 8: Builder =============================================================
# In this stage we'll add the rest of the code, compile assets, and perform a
# cleanup for the releasable image.

# Use the "testing" stage as base:
FROM testing AS builder

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Copy the full contents of the project:
COPY --chown=${DEVELOPER_USERNAME} . /workspaces/rails-google-cloud-identity-demo/

# Copy the precompiled assets:
COPY --from=asset-precompilation --chown=${DEVELOPER_USERNAME} /workspaces/rails-google-cloud-identity-demo/public /workspaces/rails-google-cloud-identity-demo/public

# Test if the rails app loads:
RUN SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece RAILS_ENV=production rails secret > /dev/null

# Configure bundler to exclude the gems from the "development" and "test" groups
# from the installed gemset, which should set them out to remove on cleanup:
RUN bundle config set --local without development test

# Cleanup the gems excluded from the current configuration. We'll copy the
# remaining gemset into the deployable image on the next stage:
RUN bundle clean --force

# Test if the rails app loads:
RUN SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece RAILS_ENV=production rails secret > /dev/null

# Change to root, before performing the final cleanup:
USER root

# Remove unneeded gem cache files (cached *.gem, *.o, *.c):
RUN rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove project files not used on release image:
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/dev-entrypoint \
    tmp/cache/*

# Stage 9: Release =============================================================
# In this stage, we build the final, releasable, deployable Docker image, which
# should be smaller than the images generated on previous stages:

# Use the "runtime" stage as base:
FROM runtime AS release

# Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy the app code and compiled assets from the "builder" stage to the
# final destination at /srv/rails-google-cloud-identity-demo:
COPY --from=builder --chown=nobody:nogroup /workspaces/rails-google-cloud-identity-demo /srv/rails-google-cloud-identity-demo

# Set the container user to 'nobody':
USER nobody

# Set the RAILS and PORT default values:
ENV HOME=/srv/rails-google-cloud-identity-demo \
    RAILS_ENV=production \
    RAILS_FORCE_SSL=yes \
    RAILS_LOG_TO_STDOUT=yes \
    RAILS_SERVE_STATIC_FILES=yes \
    PORT=3000

# Set the installed app directory as the working directory:
WORKDIR /srv/rails-google-cloud-identity-demo

# Set the default command:
CMD [ "puma" ]
