FROM ruby:2.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y -qq \
      libpq-dev

# Create app directory
ENV APP_HOME /usr/src/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install bundler
RUN gem install bundler

# Increase Bundler workers
ENV BUNDLE_JOBS=2

# Copy working directory
COPY . $APP_HOME

# Install newer version of Bundler and gems
RUN bundle install

# Add bin/ folder to PATH
ENV PATH $APP_HOME/bin:$PATH

# Create tmp directory
RUN mkdir $APP_HOME/tmp && \
    mkdir $APP_HOME/tmp/pids \
    mkdir $APP_HOME/log
