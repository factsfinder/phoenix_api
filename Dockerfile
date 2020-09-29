FROM elixir:latest

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

CMD mix deps.get && mix deps.compile && mix ecto.setup && mix start

