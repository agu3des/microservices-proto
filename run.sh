#!/bin/bash
set -e

GITHUB_USERNAME=agu3des
GITHUB_EMAIL=anandaguedesdoo@gmail.com
SERVICE_NAME=order
RELEASE_VERSION=v1.2.3

echo "Instalando plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# 1. Pega o caminho da pasta bin do Go
GOBIN=$(go env GOPATH)/bin

# 2. Converte para o formato Windows (C:\Users\...) para o protoc.exe entender
# Isso é crucial porque o protoc é um binário Windows
PLUGIN_GO_PATH=$(cygpath -w "$GOBIN/protoc-gen-go.exe")
PLUGIN_GRPC_PATH=$(cygpath -w "$GOBIN/protoc-gen-go-grpc.exe")

echo "Usando plugins em:"
echo "Go: $PLUGIN_GO_PATH"
echo "GRPC: $PLUGIN_GRPC_PATH"

echo "Generating Go source code for service: $SERVICE_NAME"
mkdir -p golang/${SERVICE_NAME}

# 3. Executa o protoc apontando explicitamente onde estão os plugins
protoc \
  --plugin=protoc-gen-go="$PLUGIN_GO_PATH" \
  --plugin=protoc-gen-go-grpc="$PLUGIN_GRPC_PATH" \
  --go_out=./golang \
  --go_opt=paths=source_relative \
  --go-grpc_out=./golang \
  --go-grpc_opt=paths=source_relative \
  ./$SERVICE_NAME/*.proto

echo "Generated Go source code files:"
ls -al ./golang/$SERVICE_NAME

cd golang/$SERVICE_NAME

echo "Iniciando módulo Go..."
rm -f go.mod go.sum
go mod init github.com/$GITHUB_USERNAME/microservices-proto/golang/$SERVICE_NAME
go mod tidy

echo "Sucesso!"