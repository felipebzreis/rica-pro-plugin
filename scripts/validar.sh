#!/usr/bin/env bash
# Confere o plugin Rica Pro para as duas plataformas antes de publicar.
set -euo pipefail
raiz="$(cd "$(dirname "$0")/.." && pwd)"
plugin="$raiz/plugins/rica-pro"

python3 - "$raiz" "$plugin" <<'PY'
import json, pathlib, re, sys
raiz, plugin = map(pathlib.Path, sys.argv[1:])
erros = []
def ler(p):
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        erros.append(f"{p.relative_to(raiz)}: JSON inválido ({e})"); return {}

claude = ler(plugin / ".claude-plugin/plugin.json")
codex = ler(plugin / ".codex-plugin/plugin.json")
openai = ler(raiz / "openai/plugin.json")
mcp_claude = ler(plugin / ".mcp.json")
mcp_openai = ler(raiz / "openai/mcp.json")

# O Codex ignora .codex-plugin quando existe um plugin.json na raiz do plugin,
# e aí não carrega o conector. O manifesto portátil da OpenAI fica em openai/.
for proibido in ("plugin.json", "mcp.json"):
    if (plugin / proibido).exists():
        erros.append(f"plugins/rica-pro/{proibido} impede o Codex de carregar o conector; mantenha em openai/")
if codex.get("mcpServers") != "./.mcp.json":
    erros.append(".codex-plugin/plugin.json precisa de mcpServers = ./.mcp.json")
ler(raiz / ".claude-plugin/marketplace.json")
ler(raiz / ".agents/plugins/marketplace.json")

for campo in ("name", "version", "license", "homepage", "repository"):
    if not (claude.get(campo) == openai.get(campo) == codex.get(campo)):
        erros.append(f"'{campo}' diferente entre os manifestos do Claude, do Codex e da OpenAI")

url_c = mcp_claude.get("mcpServers", {}).get("rica-pro", {}).get("url")
url_o = mcp_openai.get("mcpServers", {}).get("rica-pro", {}).get("url")
if not url_c or url_c != url_o or not url_c.startswith("https://"):
    erros.append(f"URL do conector diferente ou fora de https: {url_c} x {url_o}")

iface = openai.get("extensions", {}).get("com.openai", {}).get("interface", {})
for campo in ("websiteURL", "privacyPolicyURL", "termsOfServiceURL"):
    if not str(iface.get(campo, "")).startswith("https://"):
        erros.append(f"interface.{campo} ausente ou fora de https")
for campo in ("composerIcon", "logo"):
    if not (plugin / iface.get(campo, "x")).is_file():
        erros.append(f"interface.{campo} aponta para arquivo inexistente")
onb = openai.get("extensions", {}).get("com.openai", {}).get("onboardingSkill", "x")
if not (plugin / onb).is_file():
    erros.append("onboardingSkill aponta para arquivo inexistente")

skills = sorted((plugin / "skills").glob("*/SKILL.md"))
if not skills:
    erros.append("nenhuma skill encontrada")
for s in skills:
    texto = s.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n", texto, re.S)
    if not m:
        erros.append(f"{s.parent.name}: sem front matter"); continue
    meta = dict(l.split(":", 1) for l in m.group(1).splitlines() if ":" in l)
    if meta.get("name", "").strip() != s.parent.name:
        erros.append(f"{s.parent.name}: name do front matter diferente da pasta")
    desc = meta.get("description", "").strip()
    if not (20 <= len(desc) <= 1024):
        erros.append(f"{s.parent.name}: description com {len(desc)} caracteres")

readme = (plugin / "README.md").read_text(encoding="utf-8")
sem_codigo = re.sub(r"```.*?```", "", readme, flags=re.S)
if len(sem_codigo.split()) < 40:
    erros.append("README do plugin com menos de 40 palavras")
if not (plugin / "LICENSE").is_file():
    erros.append("LICENSE ausente no plugin")
for p in plugin.rglob("*"):
    if p.name in (".DS_Store", "Thumbs.db", "desktop.ini") or p.name.startswith("._"):
        erros.append(f"arquivo de sistema: {p.relative_to(raiz)}")
    if p.is_file() and p.suffix not in (".png", ".svg") and p.stat().st_size > 256 * 1024:
        erros.append(f"arquivo acima de 256 KiB: {p.relative_to(raiz)}")

if erros:
    print("\n".join("✗ " + e for e in erros)); sys.exit(1)
print(f"✔ manifestos, conector e {len(skills)} skills conferidos")
PY

# A validação usa a versão atual do Claude Code, que conhece os campos mais
# novos do manifesto (displayName, privacyPolicyUrl) e as checagens do diretório.
if command -v npx >/dev/null 2>&1; then
  npx -y @anthropic-ai/claude-code@latest plugin validate "$plugin"
  npx -y @anthropic-ai/claude-code@latest plugin validate "$raiz"
fi
