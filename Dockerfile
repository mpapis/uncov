FROM ruby:3.4-slim

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential git && rm -rf /var/lib/apt/lists/*
RUN git config --global --add safe.directory /app

ENTRYPOINT ["/bin/bash"]
