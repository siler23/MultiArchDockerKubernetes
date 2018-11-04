# Stage 1 build go application
FROM golang:1.11.1 as build

WORKDIR /go/src/go-server

#Copy necessary files to container
COPY main.go .

# Get all go dependencies
RUN go get -d ./...

#Build webserver in container
#Build with debug information removed with -ldflags '-w -s' for even smaller binary
RUN CGO_ENABLED=0 go build -ldflags '-w -s' -o go-server .

# Stage 2 run go application in smallest possible scratch image
FROM scratch
COPY --from=build /go/src/go-server /home/server
WORKDIR /home/server
CMD ["./go-server"]

# Document 5000 as listening port
EXPOSE 5000

