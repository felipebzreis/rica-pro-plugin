#!/usr/bin/env bash
# Gera o ZIP do plugin Rica Pro para o painel de plugins da OpenAI.
# O pacote leva plugin.json, mcp.json, skills, assets, README e LICENSE
# na raiz, sem os arquivos que só o Claude usa.
set -euo pipefail
raiz="$(cd "$(dirname "$0")/.." && pwd)"
plugin="$raiz/plugins/rica-pro"
"$raiz/scripts/validar.sh" >/dev/null
versao="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$plugin/plugin.json")"
mkdir -p "$raiz/dist"
destino="$raiz/dist/rica-pro-openai-$versao.zip"
rm -f "$destino"
(cd "$plugin" && zip -qrX "$destino" plugin.json mcp.json README.md LICENSE skills assets -x '*.DS_Store' -x '__MACOSX/*')
echo "$destino"
unzip -l "$destino" | tail -n +4 | sed '$d' | sed '$d' | awk '{print "  " $4}'
