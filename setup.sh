#!/bin/bash

# KipuBankV2 Setup Script
echo "🏦 Configurando KipuBankV2..."

# Verificar si Foundry está instalado
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry no está instalado. Instalando..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
else
    echo "✅ Foundry está instalado"
fi

# Instalar dependencias
echo "📦 Instalando dependencias de OpenZeppelin..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit

echo "📦 Instalando dependencias de Chainlink..."
forge install smartcontractkit/chainlink --no-commit

# Compilar contratos
echo "🔨 Compilando contratos..."
forge build

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Copia .env.example a .env"
    echo "2. Completa las variables de entorno en .env"
    echo "3. Ejecuta: forge script script/Deploy.s.sol:DeployKipuBankV2 --rpc-url \$SEPOLIA_RPC_URL --private-key \$PRIVATE_KEY --broadcast --verify --etherscan-api-key \$ETHERSCAN_API_KEY"
else
    echo "❌ Error en la compilación"
    exit 1
fi