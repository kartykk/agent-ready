---
name: no-secrets
description: Never write API keys, passwords, or .env values into the repo, chat, or inbox.
---

# no-secrets

Never put in git, markdown, or `.agents/room/inbox/`:

- `.env` contents
- API keys, tokens, PEM, `AKIA…`
- production passwords

Use env vars or a secrets manager the project already uses. If you found a secret in a file, **do not repeat it** in the chat. Tell the human the **path** only.
