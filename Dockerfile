# bcrypt in a container
#
# echo -m mysecret | docker run --rm -i bitnami/bcrypt
#
FROM ryotakatsuki/godev as build

WORKDIR /go/src/app
COPY . .

RUN rm -rf out

RUN make

RUN upx --ultra-brute out/bcrypt

FROM alpine:latest

COPY --from=build /go/src/app/out/bcrypt /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/bcrypt"]
