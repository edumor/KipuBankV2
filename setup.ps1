# KipuBankV2 Setup Script para Windows
Write-Host "🏦 Configurando KipuBankV2..." -ForegroundColor Cyan

# Verificar si Foundry está instalado
try {
    forge --version | Out-Null
    Write-Host "✅ Foundry está instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Foundry no está instalado. Por favor instálalo desde: https://getfoundry.sh/" -ForegroundColor Red
    exit 1
}

# Instalar dependencias
Write-Host "📦 Instalando dependencias de OpenZeppelin..." -ForegroundColor Yellow
forge install OpenZeppelin/openzeppelin-contracts --no-commit

Write-Host "📦 Instalando dependencias de Chainlink..." -ForegroundColor Yellow
forge install smartcontractkit/chainlink --no-commit

# Compilar contratos
Write-Host "🔨 Compilando contratos..." -ForegroundColor Yellow
forge build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación exitosa!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "1. Copia .env.example a .env"
    Write-Host "2. Completa las variables de entorno en .env"
    Write-Host "3. Ejecuta el comando de deploy desde el README.md"
} else {
    Write-Host "❌ Error en la compilación" -ForegroundColor Red
    exit 1
}