# GymDex iOS

Aplicativo iOS em SwiftUI para academia com:

- criacao de ficha de treino
- contador de calorias consumidas e gastas
- analisador textual de comida com estimativa de calorias
- biblioteca de videos por exercicio
- contador de passos
- area de motivacao com inicial que evolui por batalhas
- captura de novos pokemons por treino diario

## Estrutura

- `GymDex.xcodeproj`: projeto para abrir no Xcode
- `GymDex/`: codigo-fonte SwiftUI

## Como abrir

1. Copie a pasta para um Mac com Xcode 16 ou superior.
2. Abra `GymDex.xcodeproj`.
3. Defina seu `Development Team` em Signing & Capabilities.
4. Rode em simulador iPhone ou em um aparelho real.

## Funcionalidades entregues

- Treino: cria fichas, adiciona exercicios e registra treino do dia.
- Nutricao: registra refeicoes, analisa texto e calcula saldo calorico.
- Videos: abre links para execucao dos exercicios.
- Passos: atualizacao manual, pronta para HealthKit.
- Motivacao: inicial evolui por treino; capturas liberadas a cada 3 dias.

## Proximos passos recomendados

1. Integrar HealthKit para passos reais e calorias.
2. Trocar o analisador textual por visao computacional ou API de alimentos.
3. Adicionar banco local com SwiftData.
4. Criar tela dedicada para detalhes do exercicio e player embutido.
5. Revisar a parte tematica de Pokemon se o app for publicado comercialmente.
