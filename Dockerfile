FROM vborja/asdf-alpine:latest

ENV ERLANG_VERSION "20.2.4"
ENV ELIXIR_VERSION "1.7.4-otp-20"
ENV NODE_JS_VERSION="8.10.0"
ENV TIMEZONE "Europe/Moscow"

USER root
RUN apk add --update --no-cache autoconf automake bash curl alpine-sdk perl imagemagick openssl openssl-dev ncurses ncurses-dev unixodbc unixodbc-dev git ca-certificates postgresql-client tzdata
RUN cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime

USER asdf
RUN asdf update --head

# Adding Erlang, Elixir and NodeJS plugins
RUN asdf plugin-add erlang && \
    asdf plugin-add elixir && \
    asdf plugin-add nodejs
    
# Adding Erlang installation and dependencies requirements
USER root
RUN apk add openssh-client gawk grep yaml-dev expat-dev libxml2-dev
USER asdf

# Adding Erlang/OTP
RUN asdf install erlang $ERLANG_VERSION

# Adding Elixir with corresponding Erlang
RUN asdf install elixir $ELIXIR_VERSION && \
    asdf global erlang $ERLANG_VERSION && \
    asdf global elixir $ELIXIR_VERSION && \
    yes | mix local.hex --force && \
    yes | mix local.rebar --force

# NodeJS requirements
USER root
RUN apk add curl make gcc g++ python linux-headers binutils-gold gnupg perl-utils libstdc++
USER asdf
RUN gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 77984A986EBC2AA786BC0F66B01FBB92821C587A

# Adding NodeJS LTS
RUN asdf install nodejs $NODE_JS_VERSION

# Setting global versions
RUN asdf global erlang $ERLANG_VERSION && \
    asdf global elixir $ELIXIR_VERSION  && \
    asdf global nodejs $NODE_JS_VERSION

CMD ["/bin/bash"]