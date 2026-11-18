# Rica Pro para Claude, ChatGPT e Codex

Este repositório traz o plugin **Rica Pro**, para planejadores financeiros que usam a [Rica Pro](https://rica.com.br). O mesmo plugin funciona no Claude Code, no Codex, no Claude e no ChatGPT: o conector e as skills são os mesmos, e só os manifestos mudam.

O plugin está em [`plugins/rica-pro`](plugins/rica-pro). Lá estão a descrição completa, o que ele acessa e os links de documentação, suporte, privacidade e termos.

## Instalar no Claude Code

```text
/plugin marketplace add https://github.com/felipebzreis/rica-pro-plugin.git
```

Depois, num segundo comando:

```text
/plugin install rica-pro@rica
```

Na primeira consulta, o Claude Code abre o login da Rica no navegador.

## Instalar no Codex

```bash
codex plugin marketplace add https://github.com/felipebzreis/rica-pro-plugin.git
```

Depois, instale o plugin:

```bash
codex plugin add rica-pro@rica
```

O plugin usa o app **Rica Pro** aprovado no diretório do ChatGPT. Na instalação, o Codex pede para conectar o app e abre o login da Rica; se a Rica Pro já estiver conectada no seu ChatGPT (https://chatgpt.com/apps/rica-pro/asdk_app_6aea64fc0da08191b3a4c094c41ddf2d), não há passo extra. Feito o login, abra uma sessão nova do Codex.

## Estrutura

| Arquivo | Para quê |
| --- | --- |
| `plugins/rica-pro/skills/` | Skills compartilhadas pelas duas plataformas |
| `plugins/rica-pro/.claude-plugin/plugin.json` e `.mcp.json` | Manifesto e conector do Claude |
| `plugins/rica-pro/.codex-plugin/plugin.json` | Manifesto do Codex (usa o mesmo `.mcp.json`) |
| `openai/plugin.json` e `openai/mcp.json` | Manifesto portátil da OpenAI, usado só no ZIP do diretório do ChatGPT |
| `.claude-plugin/marketplace.json` | Marketplace do Claude Code |
| `.agents/plugins/marketplace.json` | Marketplace do Codex |
| `scripts/validar.sh` | Confere os manifestos e as skills |
| `scripts/empacotar-openai.sh` | Gera o ZIP para o painel de plugins da OpenAI |

## Licença

MIT. O serviço Rica Pro e a marca Rica não estão cobertos por ela.
