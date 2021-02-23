FROM gcc
RUN apt-get update -y
RUN apt-get install -y vim man manpages libc6-dev less
WORKDIR /usr/src/subc
