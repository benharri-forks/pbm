FROM ruby:3.1.4-alpine3.17

WORKDIR /pbm

RUN apk update && apk add build-base postgresql-dev nodejs

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD bundle exec rails s
