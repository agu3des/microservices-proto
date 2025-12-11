#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
# Ajustado para bater com o go_package do seu arquivo .proto
GITHUB_USERNAME=agu3des
SERVICE_NAME=payment
# ---------------------

echo "--- Iniciando geração para o serviço: $SERVICE_NAME ---"

echo "1. Verificando/Instalando plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Pega o caminho da pasta bin do Go
GOBIN=$(go env GOPATH)/bin

# Converte para o formato Windows (C:\Users\...) para o protoc.exe entender (Git Bash/Windows)
PLUGIN_GO_PATH=$(cygpath -w "$GOBIN/protoc-gen-go.exe")
PLUGIN_GRPC_PATH=$(cygpath -w "$GOBIN/protoc-gen-go-grpc.exe")

echo "   > Plugin Go: $PLUGIN_GO_PATH"
echo "   > Plugin GRPC: $PLUGIN_GRPC_PATH"

echo "2. Criando diretório de saída..."
mkdir -p golang/${SERVICE_NAME}

echo "3. Executando protoc..."
# O comando assume que o arquivo .proto está na pasta ./payment/
protoc \
  --plugin=protoc-gen-go="$PLUGIN_GO_PATH" \
  --plugin=protoc-gen-go-grpc="$PLUGIN_GRPC_PATH" \
  --go_out=./golang \
  --go_opt=paths=source_relative \
  --go-grpc_out=./golang \
  --go-grpc_opt=paths=source_relative \
  ./$SERVICE_NAME/*.proto

echo "4. Arquivos gerados:"
ls -al ./golang/$SERVICE_NAME

# Entra na pasta para iniciar o módulo
cd golang/$SERVICE_NAME

echo "5. Configurando Go Modules..."
rm -f go.mod go.sum

# O nome do módulo deve bater com o go_package do .proto
MODULE_PATH="github.com/$GITHUB_USERNAME/microservices-proto/golang/$SERVICE_NAME"
go mod init $MODULE_PATH
go mod tidy

echo "--- Sucesso! Código gerado em ./golang/$SERVICE_NAME ---"