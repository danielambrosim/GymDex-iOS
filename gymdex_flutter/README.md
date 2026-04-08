# GymDex Flutter

Base multiplataforma do GymDex para:

- Android
- Windows
- Linux

## Requisitos

- Flutter SDK instalado
- Android Studio ou SDK Android para mobile
- Visual Studio com Desktop development with C++ para Windows
- Toolchain Linux para build desktop no Linux

## Como gerar os runners nativos

Entre na pasta `gymdex_flutter` e rode:

```bash
flutter create .
```

Esse comando gera ou atualiza as pastas nativas como:

- `android/`
- `windows/`
- `linux/`

## Como rodar

```bash
flutter pub get
flutter run -d android
flutter run -d windows
flutter run -d linux
```

## O que esta implementado

- Ficha de treino
- Cadastro de exercicios
- Contador de calorias
- Analisador textual de comida
- Biblioteca de videos
- Contador de passos
- Motivacao com inicial evoluindo por treino
- Captura de pokemons por frequencia de treino

## Observacao

Como o Flutter nao estava instalado neste ambiente, o codigo e a estrutura Dart foram criados manualmente. Depois de instalar o Flutter, gere os runners com `flutter create .`.
