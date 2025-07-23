# CLAUCIA: Sistema de Classificação de Feridas

## Sobre o Projeto

CLAUCIA é um aplicativo desenvolvido como parte de um Trabalho de Conclusão de Curso (TCC), focado na classificação e monitoramento de feridas em pacientes. O sistema permite aos profissionais de saúde:

- Gerenciar perfis de pacientes
- Registrar e classificar feridas utilizando inteligência artificial
- Acompanhar a evolução de tratamentos
- Coletar e analisar amostras relacionadas às feridas

O aplicativo utiliza um modelo TensorFlow Lite para classificação de imagens de feridas, auxiliando os profissionais na avaliação e tomada de decisões clínicas.

## Tecnologias Utilizadas

- Flutter (Interface multiplataforma)
- Dart (Linguagem de programação)
- TensorFlow Lite (Modelo de classificação)
- API RESTful para backend

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.0.0 ou superior)
- [Android Studio](https://developer.android.com/studio) ou [XCode](https://developer.apple.com/xcode/) para desenvolvimento mobile
- [Git](https://git-scm.com/) para controle de versão

## Configuração do Ambiente

1. Clone este repositório:

```bash
git clone https://github.com/Eduardo-RFarias/CLAUCIA-app
cd tcc-app
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Gere os arquivos de localização:

```bash
flutter gen-l10n
```

## Executando o Projeto

### Para desenvolvimento

```bash
flutter run
```

### Para compilar APK (Android)

```bash
flutter build apk
```

### Para compilar IPA (iOS)

```bash
flutter build ios
```

## Estrutura do Projeto

- `lib/controllers/`: Controladores da aplicação
- `lib/models/`: Modelos de dados
- `lib/screens/`: Interfaces de usuário
- `lib/services/`: Serviços e integrações
- `lib/utils/`: Utilitários e funções auxiliares
- `assets/models/`: Modelo TensorFlow Lite para classificação

## Contribuição

1. Faça o fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Faça commit das alterações (`git commit -m 'Adiciona nova funcionalidade'`)
4. Envie para o branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para mais detalhes.
