## Step1. install protoc
for full guide please visit [official document](https://protobuf.dev/installation/)

### install protoc manually
```bash
VERSION="30.2" # please check the version
PB_REL="https://github.com/protocolbuffers/protobuf/releases"
curl -LO $PB_REL/download/v$VERSION/protoc-$VERSION-osx-aarch_64.zip # consider user 'os' and 'arch'
```

### unzip downloaded zip file
```bash
VERSION="30.2" 
unzip protoc-$VERSION-osx-aarch_64.zip -d protoc-$VERSION -d /.local
```

### make executable 
```bash
export PATH="$PATH:$HOME/.local/bin"
```

## Step2. install required go packages

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
```

## Step3. init go project

```bash
mkdir grpc-gateway
cd grpc-gateway
go mod init example.com/my-grpc-gateway #... make sure your own module
```

```bash
go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
go get github.com/grpc-ecosystem/grpc-gateway/v2
go get google.golang.org/grpc
go get google.golang.org/protobuf
go get github.com/googleapis/googleapis
```