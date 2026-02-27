# Chatwoot Unlock (Compose + GitHub, sem arquivos locais)

Objetivo: aplicar patches no container do Chatwoot direto do GitHub, com configuração mínima no `docker-compose`.

## Repositório fonte

- `https://github.com/vithorcoelho/chatwoot-unlock`
- Script remoto: `unlock.sh`

## Como funciona

No startup do container:

1. `entrypoint` baixa o `unlock.sh` do GitHub.
2. O script baixa e aplica:
   - `app/views/super_admin/settings/show.html.erb`
   - `db/seeds.rb`
3. O script executa `bundle exec rails db:seed`.
4. Em seguida, o container executa o comando normal (`rails` ou `sidekiq`).

O `unlock.sh` detecta automaticamente `curl` ou `wget` dentro do container. Isso é importante porque imagens Alpine do Chatwoot normalmente têm `wget`, mas podem não ter `curl`.
Ele também aplica os arquivos e roda o seed imediatamente, sem depender de comando manual adicional.

## EntryPoint mínimo (Rails)

```yaml
entrypoint:
  - sh
  - -lc
  - |
    set -e
    wget -qO- "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0
```

## EntryPoint mínimo (Sidekiq)

```yaml
entrypoint:
  - sh
  - -lc
  - |
    set -e
    wget -qO- "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec bundle exec sidekiq -C config/sidekiq.yml
```

## Execução manual no container

Para imagens que já tenham `curl`:

```bash
docker exec chatwoot-plus-prod-rails-1 sh -lc 'curl -fsSL "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh'
```

Para imagens Alpine que só tenham `wget`:

```bash
docker exec chatwoot-plus-prod-rails-1 sh -lc 'wget -qO- "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh'
```

## Usar tag fixa (recomendado em produção)

Troque `main` por uma tag ou commit:

```text
https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/v1.0.0/unlock.sh
https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/<commit>/unlock.sh
```

## Parâmetros opcionais

O `unlock.sh` aceita via env:

- `UNLOCK_REPO` (default: `vithorcoelho/chatwoot-unlock`)
- `UNLOCK_REF` (default: `main`)

Exemplo:

```yaml
entrypoint:
  - sh
  - -lc
  - |
    set -e
    export UNLOCK_REPO=vithorcoelho/chatwoot-unlock
    export UNLOCK_REF=v1.0.0
    wget -qO- "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0
```

## Observações

- Não precisa manter `.sh` local no servidor.
- Requer internet no container para acessar `raw.githubusercontent.com`.
- Se o GitHub estiver indisponível, o startup pode falhar.
- O comando recomendado para Alpine é com `wget -qO-`, não com `curl`.
- O container precisa ter `bundle exec rails` funcional para que o seed seja executado com sucesso.
