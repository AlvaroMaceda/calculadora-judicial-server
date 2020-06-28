# https://github.com/phusion/passenger-docker
# This image ships with ruby-2.6.6
FROM phusion/passenger-ruby26:1.0.10 as builder

# Set correct environment variables.
ENV HOME /root

# For debugging
# COPY ./tmp/ping /usr/bin/ping
# COPY ./tmp/traceroute.db /usr/bin/traceroute

# Install node
RUN apt-get update -y \
    && apt-get install curl gnupg -y \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get install gcc g++ make nodejs -y

# Install yarn
RUN   curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
   && apt-get update && apt-get install yarn

# Install tzdata
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime \
 && apt-get update && apt-get install -y tzdata \
 && dpkg-reconfigure --frontend noninteractive tzdata

# Copy app
RUN mkdir /home/app/webapp && chown app:app /home/app/webapp
COPY --chown=app:app . /home/app/webapp

USER app
WORKDIR /home/app/webapp
ENV HOME=/home/app
# RUN whoami

RUN gem install bundler:2.1.4
# RUN bundle install --without development:test:assets -j4 --retry 3 --path=vendor/bundle
RUN bundle install --without test:assets -j4 --retry 3 --path=vendor/bundle
RUN yarn install --check-files
RUN bundle exec rails webpacker:compile

USER root

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#----------------------------------------------------------------
# Prod stage
#----------------------------------------------------------------
FROM phusion/passenger-ruby26:1.0.10

# Install tzdata
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime \
 && apt-get update && apt-get install -y tzdata \
 && dpkg-reconfigure --frontend noninteractive tzdata

# Enable nginx
RUN rm -f /etc/service/nginx/down

# Configure nginx
RUN rm /etc/nginx/sites-enabled/default
ADD ./docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

# Copy app files. Bundler files are here, under vendor/bundle
ENV RAILS_ROOT=/home/app/webapp
COPY --from=builder $RAILS_ROOT $RAILS_ROOT

# Change user 
USER app
WORKDIR /home/app/webapp
ENV HOME=/home/app

RUN gem install bundler:2.1.4

# FALTAN LAS VARIABLES DE ENTORNO DE RAILS
ENV RAILS_ENV=production
ENV DATABASE_ADAPTER=sqlite3
ENV DATABASE_DATABASE_PRODUCTION=db/production.sqlite3
ENV RAILS_LOG_TO_STDOUT=true

# For debugging
ENV RAILS_ALL_REQUESTS_LOCAL=true 

# Initialize database
RUN bundle exec rails db:create db:migrate db:seed

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]