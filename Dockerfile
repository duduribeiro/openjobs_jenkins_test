FROM ruby:2.4.1
MAINTAINER mail@carlosribeiro.me

RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& curl -sL http://deb.nodesource.com/setup_6.x | bash - \
&& echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
&& apt-get update \
&& apt-get install -y \
  build-essential \
  imagemagick \
  nodejs \
  yarn

RUN mkdir -p /var/app
COPY . /var/app
WORKDIR /var/app

RUN bundle install && yarn
RUN bundle exec rake assets:precompile
CMD rails s -b 0.0.0.0
