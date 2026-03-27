# 🗡️ Librarium - App de Hábitos Gamificado

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.1+-blue.svg)](https://dart.dev/)

> **Librarium App** – Torne sua rotina épica! Gerencie hábitos, conquiste XP, desafie amigos e suba no ranking – tudo com visual e clima dark fantasy.

---

## 📱 Visão Geral

Librarium é um aplicativo mobile/web Flutter para gerenciamento de hábitos gamificado: registre hábitos, evolua no ranking conforme acumula XP, personalize seu perfil, envie mensagens e desafie outros usuários!

**Funcionalidades principais:**
- ✅ Cadastro e login (email, Google Login, senha)
- 📷 Foto de perfil customizável
- 📒 Criação e gestão de hábitos diários/semanais/mensais
- 🌱 XP, níveis e recompensas automáticas a cada hábito concluído
- 🏆 Ranking global e entre amigos
- 💬 Mensagens para amigos/usuários (chat simples)
- ⚔️ Desafios entre usuários: crie e aceite desafios de hábitos

---

## 🚀 Instalação

### Pré-requisitos

- Flutter 3.19+
- Dart 3.1+

### Instalação Local

```bash
git clone https://github.com/seu-usuario/librarium-front.git
cd librarium-front
flutter pub get
flutter run
```
Abra em um emulador Android/iOS ou acesse em [web] usando `flutter run -d chrome`.

### Configuração Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
2. Ative Authentication (Email/Senha e Google).
3. Ative Firestore e Storage.
4. Baixe o arquivo `google-services.json` (Android) e/ou `GoogleService-Info.plist` (iOS) e coloque nas respectivas pastas.
5. No web, configure o `.env` com suas credenciais.

---

## 🎮 Funcionalidades

### Hábitos
- Criar hábito: título, descrição, frequência, cor/ícone
- Editar/excluir hábitos
- Marcar hábito como concluído (ganhe XP!)
- Visualize progresso diário/semanal/mensal

### Perfil e Foto
- Avatar customizável
- Upload de foto de perfil (Firebase Storage)
- Editar nickname, senha, bio

### Ranking
- Ranking global de XP
- Ranking entre amigos

### XP & Níveis
- Cada hábito concluído gera XP

### Desafios
- Crie desafio entre amigos
- Aceite/recuse desafios
- Veja histórico de desafios ativos/finalizados

### Mensagens
- Chat amigável e privado entre usuários
- Notificação de novas mensagens
- Mensagens simples (texto/imagem)

---

## 📦 Estrutura dos dados (Firestore)

### Usuário
```json
{
  "uid": "string",
  "nickname": "string",
  "email": "string",
  "photoUrl": "string",
  "xp": 0,
  "nivel": 1,
  "rank": 999,
  "amigos": ["uid1", "uid2"],
  "mensagensNoChat": 0,
  "criadoEm": "timestamp"
}
```

### Hábito
```json
{
  "id": "string",
  "uid": "string",
  "titulo": "string",
  "descricao": "string",
  "frequencia": "diario/semanal/mensal",
  "icone": "svg/ref",
  "cor": "#HEX",
  "ativo": true,
  "sequenciaAtual": 0,
  "maiorSequencia": 0,
  "conclusoes": 0,
  "xpTotal": 0,
  "criadoEm": "timestamp"
}
```

### Desafio
```json
{
  "id": "string",
  "criadorUid": "string",
  "desafiadoUid": "string",
  "titulo": "string",
  "descricao": "string",
  "status": "pendente/aceito/recusado/finalizado",
  "xp": 50,
  "criadoEm": "timestamp",
  "finalizadoEm": "timestamp"
}
```

### Mensagem
```json
{
  "id": "string",
  "chatId": "string",
  "autorUid": "string",
  "texto": "string",
  "enviadaEm": "timestamp",
  "tipo": "texto/imagem"
}
```

---

## 🗺️ Telas principais

- Login/Cadastro
- Mural de hábitos
- Progresso e histórico
- Tela de ranking
- Perfil
- Amizades e chat/mensagens
- Desafios

---

## 📊 Sistema de XP, Níveis & Ranking

- Fácil: 10 XP
- Médio: 20 XP
- Difícil: 35 XP
- Desafios especiais: até 100 XP

- XP acumulado define seu nível
- Top 10 usuários ganham medalha especial no ranking da semana

---

## 🔒 Segurança

- Autenticação via Firebase Auth (Google/Email-Senha)
- Regras Firestore para proteção de dados
- Upload de avatars apenas para usuários autenticados

---

## 🛠️ Como contribuir
1. Faça um fork deste repositório.
2. Crie uma branch nova: `git checkout -b feature/minha-feature`
3. Faça seus commits!
4. Abra um Pull Request e explique sua contribuição :)

---

## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo [LICENSE](LICENSE).

---

**Desenvolvido por Pedro Zucchi  
Que sua rotina seja lendária!** 🏰

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black.svg)](https://github.com/pedro-zucchi90)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue.svg)](https://www.linkedin.com/in/pedro-zucchi-52b50132b/)
