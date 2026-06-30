# Projeto-mobile

Projeto na disciplina de desenvolvimento mobile da faculdade, utilizamos flutter e android studio para simulação/modificações diretas

## 📱 Projeto-mobile: UniGo

O **UniGo** é um aplicativo de mobilidade focado no público universitário, criado para facilitar o trajeto até o campus conectando estudantes e promovendo um transporte mais inteligente e seguro. Este projeto representa o meu marco inicial na disciplina de Desenvolvimento Mobile. Na versão atual, é um aplicativo simples desenvolvido em Flutter, focado em entender a anatomia de um Widget e o ciclo de vida básico de uma aplicação.

## 🎯 Objetivo do Projeto

O foco aqui não é a complexidade, mas a base sólida. O app foi construído para exercitar:
* A renderização de layouts com Scaffold.
* O uso de Widgets de texto, botões e imagens.
* A lógica inicial de alteração de estado (setState).

## ✨ Funcionalidades

* **Interface Intuitiva:** Layout limpo e focado na usabilidade.
* **Interatividade:** Botões que reagem ao toque do usuário.
* **Feedback Visual:** Atualização de dados na tela em tempo real.

## 🛠️ Tecnologias Utilizadas

| Ferramenta | Descrição |
| :--- | :--- |
| **Flutter** | Framework UI para desenvolvimento multiplataforma. |
| **Dart** | Linguagem de programação utilizada. |
| **VS Code** | Editor de código com extensões Flutter/Dart. |

## 📦 Dependências do Projeto

Os seguintes pacotes e plugins do Flutter são necessários para o funcionamento do aplicativo e estão definidos no `pubspec.yaml`:

* **[flutter_map](https://pub.dev/packages/flutter_map)**: Renderização e controle de mapas.
* **[latlong2](https://pub.dev/packages/latlong2)**: Operações e cálculos com coordenadas geográficas (latitude e longitude).
* **[geolocator](https://pub.dev/packages/geolocator)**: Acesso aos serviços de localização (GPS).
* **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)**: Exibição de notificações locais.
* **[file_picker](https://pub.dev/packages/file_picker)**: Seleção de arquivos do dispositivo.
* **[firebase_core](https://pub.dev/packages/firebase_core)**, **[firebase_auth](https://pub.dev/packages/firebase_auth)**, **[cloud_firestore](https://pub.dev/packages/cloud_firestore)**: Integração com os serviços do Firebase (Core, Autenticação e Banco de dados).
* **[http](https://pub.dev/packages/http)**: Requisições de rede e consumo de APIs.
* **[local_auth](https://pub.dev/packages/local_auth)**: Autenticação biométrica nativa (impressão digital, Face ID).
* **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)**: Armazenamento seguro de dados sensíveis.
* **[cupertino_icons](https://pub.dev/packages/cupertino_icons)**: Conjunto de ícones baseados no iOS.
* **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)** (dev): Ferramenta para geração dos ícones do app.

*(O comando `flutter pub get` na seção abaixo se encarregará de baixar todas essas dependências automaticamente).*

## 🚀 Como Executar o App

Para rodar este projeto localmente, você precisa ter o Flutter instalado e configurado em sua máquina.

1. **Clone este repositório:**
   ```bash
   git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)
2. **Acessar a pasta do projeto:**
   ```bash
   cd nome-do-projeto
3. **Baixar as dependências do Pub:**
   ```bash 
   flutter pub get
4. **Executar o app:**
   ```bash
   flutter run
