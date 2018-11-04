#Multi-stage build First build go with go docker image
FROM golang:1.11.1 as build
#Use the official go image which is multi-arch for s390x, x86, and other architectures .... whichever machine you use to build the image it will pull the correct arch for s390x/x86

WORKDIR /go/src/outyet

# Copy outyet files to container
COPY main.go main_test.go /go/src/outyet/

#Build outyet in container
RUN CGO_ENABLED=0 go build -o outyet .

#Second stage run go with just alpine base image 
FROM alpine:3.8
RUN addgroup -g 1000 outyet && adduser -u 1000 -G outyet -s /bin/sh -D outyet && \
    apk add --no-cache ca-certificates
USER outyet
COPY --from=build /go/src/outyet /home/outyet

WORKDIR /home/outyet
#Make container start by running outyet 
CMD ["./outyet"] 

#Use 8080 as container port for service 
EXPOSE 8080
