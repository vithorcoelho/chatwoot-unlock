# Chatwoot Unlock (Compose + GitHub, sem arquivos locais)

Objetivo: aplicar patches no container do Chatwoot direto do GitHub, com configuração mínima no `docker-compose`.

## Repositório fonte

- `https://github.com/vithorcoelho/chatwoot-unlock`
- Script remoto: `unlock.sh`

## Como funciona

No startup do container:

1. `entrypoint` faz `curl` do `unlock.sh` do GitHub.
2. O script baixa e aplica:
   - `app/views/super_admin/settings/show.html.erb`
   - `db/seeds.rb`
3. Em seguida, o container executa o comando normal (`rails` ou `sidekiq`).

## EntryPoint mínimo (Rails)

```yaml
entrypoint:
  - sh
  - -lc
  - |
    set -e
    curl -fsSL "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0
```

## EntryPoint mínimo (Sidekiq)

```yaml
entrypoint:
  - sh
  - -lc
  - |
    set -e
    curl -fsSL "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec bundle exec sidekiq -C config/sidekiq.yml
```

## Usar tag fixa (recomendado em produção)

Troque `main` por uma tag:

```text
https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/v1.0.0/unlock.sh
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
    curl -fsSL "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh
    exec docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0
```

## Bash manual (opcional)

Se quiser rodar manualmente no host:

```bash
docker exec chatwoot-rails-1 sh -lc 'curl -fsSL "https://raw.githubusercontent.com/vithorcoelho/chatwoot-unlock/main/unlock.sh" | sh'
```

## Observações

- Não precisa manter `.sh` local no servidor.
- Requer internet no container para acessar `raw.githubusercontent.com`.
- Se o GitHub estiver indisponível, o startup pode falhar.
