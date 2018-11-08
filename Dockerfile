FROM alpine:latest

ENV BUILD_PACKAGES curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

COPY app.rb config.ru Gemfile ./

RUN apk update && apk upgrade && \
    apk add bash ${BUILD_PACKAGES} && \
    apk add ${RUBY_PACKAGES} && \
    bundle install

EXPOSE 8080

CMD ["bundle", "exec", "rackup", "config.ru", "-p", "8080", "-s", "thin", "-o", "0.0.0.0"]
