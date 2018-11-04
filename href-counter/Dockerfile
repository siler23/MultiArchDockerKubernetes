FROM golang:1.11.1

WORKDIR /go/src/href

COPY app.go .

# Get all go dependencies
RUN go get -d ./...

#Build with debug information removed with -ldflags '-w -s' for even smaller binary
RUN CGO_ENABLED=0 go build -ldflags '-w -s' -o app .

FROM scratch

WORKDIR /home/href
# Since no build name i.e. as name, use default of 0 since first build is by default 0 => --from=0
COPY --from=0 /go/src/href/app /home/href

#Add root ssl certs [necessary for connecting to certain sites when looking up their hrefs for example yahoo.com]
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

CMD ["./app"]
