FROM alpine:latest

ENV BUILD_PACKAGES curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && apk upgrade && \
    addgroup -g 700 service_group && \
    adduser -u 700 -G service_group -D service_user 

WORKDIR /home/service_user
COPY app.rb config.ru Gemfile .semver /home/service_user/

RUN apk add bash ${BUILD_PACKAGES} && \
    apk add ${RUBY_PACKAGES} && \
    bundle install

EXPOSE 8080

USER service_user
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "8080", "-s", "thin", "-o", "0.0.0.0"]
