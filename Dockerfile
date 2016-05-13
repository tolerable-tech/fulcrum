FROM asaaki/elixir-phoenix-dev:0.1.1
MAINTAINER Jake Wilkins <me@jsw.io>

ADD . /app
WORKDIR /app

EXPOSE 4000

ENV MIX_ENV dev

#RUN yes | mix do deps.get, deps.compile

