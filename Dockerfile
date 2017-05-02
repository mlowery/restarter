FROM alpine:3.5

RUN apk add --no-cache bash

ADD test-app /test-app
ADD restarter /restarter

ENTRYPOINT ["/restarter", "/test-app", "george"]
