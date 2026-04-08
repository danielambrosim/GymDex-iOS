# GymDex iOS

GymDex e um prototipo de aplicativo iOS para academia, feito em SwiftUI, com foco em treino, nutricao, acompanhamento diario e gamificacao.

## O que o app faz

- Criacao de ficha de treino
- Cadastro de exercicios por ficha
- Registro de treino concluido no dia
- Contador de calorias consumidas e gastas
- Analisador textual de comida com estimativa calorica
- Biblioteca de videos para execucao dos exercicios
- Contador de passos
- Area de motivacao com inicial que evolui ao vencer batalhas
- Captura de novos pokemons por consistencia nos treinos

## Conceito de gamificacao

O app usa um sistema de motivacao inspirado em evolucao e captura:

- O usuario escolhe um inicial
- O inicial ganha XP quando o treino do dia e registrado
- As batalhas so acontecem quando o usuario realmente treina no dia
- O inicial evolui conforme o progresso
- Novos pokemons sao capturados com base em dias unicos de treino

## Stack

- Swift
- SwiftUI
- `UserDefaults` para persistencia local simples

## Estrutura do projeto

```text
GymDex-iOS/
├── GymDex.xcodeproj/
├── GymDex/
│   ├── GymDexApp.swift
│   ├── ContentView.swift
│   ├── Info.plist
│   ├── Models/
│   │   └── AppModels.swift
│   ├── ViewModels/
│   │   └── AppStore.swift
│   └── Views/
│       ├── DashboardView.swift
│       ├── WorkoutPlansView.swift
│       ├── NutritionView.swift
│       ├── VideoLibraryView.swift
│       └── MotivationView.swift
└── README.md
```

## Principais areas

### Treino

- Cria fichas de treino
- Adiciona exercicios com series, repeticoes, descanso e video
- Marca treinos concluidos

### Nutricao

- Registra refeicoes manualmente
- Faz analise textual de alimentos
- Calcula saldo calorico do dia

### Videos

- Lista links para videos de execucao dos exercicios

### Passos

- Permite atualizacao manual da contagem diaria
- Estrutura pronta para futura integracao com HealthKit

### Motivacao

- Escolha de inicial
- Evolucao por XP
- Log de batalhas
- Captura desbloqueada por frequencia de treino

## Como abrir no Xcode

1. Copie a pasta do projeto para um Mac.
2. Abra `GymDex.xcodeproj`.
3. Configure seu `Development Team` em Signing & Capabilities.
4. Rode no simulador ou em um iPhone.

## Limitacoes atuais

- O contador de passos ainda e manual
- A analise de comida e textual e baseada em estimativa local
- Os videos sao acessados por link externo
- A persistencia ainda usa `UserDefaults`

## Proximos passos recomendados

1. Integrar HealthKit para passos e gasto calorico real.
2. Adicionar camera e analise de comida por imagem.
3. Migrar persistencia para SwiftData ou Core Data.
4. Criar player nativo de videos dentro do app.
5. Refinar design, onboarding e metas personalizadas.
6. Revisar o uso comercial da tematica Pokemon antes de publicacao.

## Licenca

Este projeto esta sob a licenca MIT. Veja `LICENSE`.
