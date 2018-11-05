#Multi-stage build First build go with go docker image
# build = name of build referred to in later copy step
FROM golang:1.11.1 as build
#Use the official go image which is multi-arch for
#s390x, x86, and other architectures .... whichever machine
#you use to build the image it will pull the correct arch for s390x/x86

#Creates /go/src/outyet directory and makes this our current directory
WORKDIR /go/src/outyet

# Copy outyet files to container
COPY main.go main_test.go /go/src/outyet/

#Build outyet in container
#Build with debug information removed with -ldflags '-w -s' for even smaller binary
RUN CGO_ENABLED=0 go build -ldflags '-w -s' -o outyet .

#Second stage run go with the smallest image possible scratch
# (an empty image see https://hub.docker.com/_/scratch/)
FROM scratch

#Add outyet binary file to our scratch image, feels like home-cooking
# --from=build references to first stage name
COPY --from=build /go/src/outyet /home/outyet

#Add root ssl certs [necessary for web connection for go outyet check in app]
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# move to executable's directory
WORKDIR /home/outyet
#Make container start by running outyet
CMD ["./outyet"]

#Use 8080 as container port for service
EXPOSE 8080
