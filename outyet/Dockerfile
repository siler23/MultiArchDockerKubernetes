FROM golang:1.11.1
#Use the official go image which is multi-arch for
#s390x, x86, and other architectures ....
# whichever machine you use to build the image it will pull the
# correct arch for s390x/x86, etc. This image uses a large base os.

# Create new outyet directory for my files
WORKDIR /go/src/outyet

# Copy outyet files to container
COPY main.go main_test.go /go/src/outyet/

#Build outyet in container
RUN go build -o outyet

#Make container start by running outyet
CMD ["./outyet"]

#Use 8080 as container port for service
EXPOSE 8080
