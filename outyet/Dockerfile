FROM golang:1.11.1 
#Use the official go image which is multi-arch for s390x, x86, and other architectures .... whichever machine you use to build the image it will pull the correct arch for s390x/x86

# Copy outyet files to container
ADD . /go/src/github.com/golang/example/outyet

#Build outyet in container
RUN go install github.com/golang/example/outyet 

#Make container start by running outyet 
ENTRYPOINT /go/bin/outyet 

#Use 8080 as container port for service 
EXPOSE 8080
