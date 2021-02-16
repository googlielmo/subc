FROM gcc
COPY . /usr/src/subc
WORKDIR /usr/src/subc
RUN make clean configure
#CMD [""]
