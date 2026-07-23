# gmtk-gamejam

Projeto Godot 4.7 com VS Code como editor de scripts.

Este README cobre **apenas o setup do ambiente**. Documentação do jogo em si virá depois.

---

## Requisitos

| Ferramenta                      | Versão | Observação                                                       |
| ------------------------------- | ------ | ---------------------------------------------------------------- |
| Godot Engine                    | 4.7.x  | Build **standard** para GDScript; **.NET** apenas se for usar C# |
| Visual Studio Code              | atual  | —                                                                |
| Extensão `geequlim.godot-tools` | 2.7+   | Instalar pelo Marketplace                                        |

> **Ponto crítico:** o autocomplete e o "go to definition" vêm de um Language Server que roda **dentro do editor do Godot**, na porta `6005`. Com o Godot fechado, o VS Code entrega só realce de sintaxe. Por isso o comando `godev` abre os dois na ordem certa.

---

## Setup — macOS

### 1. Instalar o Godot

Baixe o build **universal** em [godotengine.org/download/macos](https://godotengine.org/download/macos), descompacte e mova para `/Applications`:

```bash
mv ~/Downloads/Godot.app /Applications/
xattr -dr com.apple.quarantine /Applications/Godot.app
```

O `xattr` remove a quarentena do Gatekeeper — sem isso o macOS bloqueia o primeiro launch.

Valide:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --version
```

### 2. Instalar a extensão

Procurar e instalar a extensão `Godot-Tools` (geequlim)

ou

```bash
code --install-extension geequlim.godot-tools
```

### 3. Apontar o executável no VS Code

`Cmd+Shift+P` → **Preferences: Open User Settings (JSON)**:

```json
{
  "godotTools.editorPath.godot4": "/Applications/Godot.app/Contents/MacOS/Godot"
}
```

Precisa ser caminho **absoluto** e apontar para o binário dentro do bundle — não para o `.app`.

### 4. Definir o VS Code como editor externo do Godot

Instale o comando `code` no PATH: `Cmd+Shift+P` → **Shell Command: Install 'code' command in PATH**.

No Godot: menu **Godot → Editor Settings** (menu da aplicação, não "Editor"):

`Text Editor > External`

- ✅ **Use External Editor**
- **Exec Path**: `/usr/local/bin/code` _(confirme com `which code`)_
- **Exec Flags**: `{project} --goto {file}:{line}:{col}`

`Text Editor > Behavior`

- ✅ **Auto Reload Scripts on External Change**

### 5. Comando `godev`

Adicione ao final do `~/.zshrc`:

```bash
# --- Godot ---
godev() {
  local p="${1:-$PWD}"
  p="${p:A}"
  if [[ ! -f "$p/project.godot" ]]; then
    echo "godev: sem project.godot em $p"
    return 1
  fi
  open -na /Applications/Godot.app --args --path "$p" -e
  sleep 2
  code "$p"
}
```

Recarregue:

```bash
source ~/.zshrc
```

> Se o Oh My Zsh estiver instalado, **não** use o nome `gd` — já é alias de `git diff`. Confira qualquer nome novo com `type <nome>` antes de definir.

---

## Setup — Windows

### 1. Instalar o Godot

Baixe o build **win64** em [godotengine.org/download/windows](https://godotengine.org/download/windows) e extraia para um caminho estável, ex.: `C:\Tools\Godot\`.

Anote o caminho completo do `.exe` — o nome inclui a versão:

```
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe
```

### 2. Instalar a extensão

Procurar e instalar a extensão `Godot-Tools` (geequlim)

ou

```powershell
code --install-extension geequlim.godot-tools
```

### 3. Apontar o executável no VS Code

`Ctrl+Shift+P` → **Preferences: Open User Settings (JSON)**:

```json
{
  "godotTools.editorPath.godot4": "C:\\Tools\\Godot\\Godot_v4.7.1-stable_win64.exe"
}
```

Barras invertidas precisam ser escapadas (`\\`) no JSON. Alternativamente, use barras normais: `C:/Tools/Godot/...`.

### 4. Definir o VS Code como editor externo do Godot

No Godot: **Editor → Editor Settings**

`Text Editor > External`

- ✅ **Use External Editor**
- **Exec Path**: `C:\Users\<usuario>\AppData\Local\Programs\Microsoft VS Code\Code.exe`
- **Exec Flags**: `{project} --goto {file}:{line}:{col}`

Se o Godot recusar o `Code.exe`, aponte para `bin\code.cmd` no mesmo diretório de instalação.

`Text Editor > Behavior`

- ✅ **Auto Reload Scripts on External Change**

### 5. Comando `godev`

Abra o profile do PowerShell:

```powershell
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
code $PROFILE
```

Adicione:

```powershell
# --- Godot ---
function godev {
    param([string]$ProjectPath = (Get-Location).Path)

    $ProjectPath = (Resolve-Path $ProjectPath).Path

    if (-not (Test-Path (Join-Path $ProjectPath "project.godot"))) {
        Write-Host "godev: sem project.godot em $ProjectPath" -ForegroundColor Red
        return
    }

    Start-Process "C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe" `
        -ArgumentList "--path", "`"$ProjectPath`"", "-e"

    Start-Sleep -Seconds 2
    code $ProjectPath
}
```

Ajuste o caminho do `.exe` conforme sua instalação. Recarregue:

```powershell
. $PROFILE
```

Se o PowerShell bloquear a execução do profile:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

---

## Uso no dia a dia

```bash
godev ~/P/godot-projects/gmtk-gamejam
```

Ou, já dentro da pasta do projeto:

```bash
godev
```

O comando abre o editor do Godot direto no projeto e, dois segundos depois, o VS Code na mesma raiz — com o Language Server já disponível.

### Divisão de trabalho

| Godot                       | VS Code                 |
| --------------------------- | ----------------------- |
| Cenas, nodes, Inspector     | Escrever código         |
| Conectar sinais             | Refactor e busca global |
| Importar assets             | Git                     |
| Project Settings, Input Map | Debug com `F5`          |

**Criar um script novo:** faça o attach pelo node no Godot (assim ele já nasce vinculado ao `.tscn`). O duplo clique abre o arquivo no VS Code na linha certa.

**Salvar:** `Cmd+S` / `Ctrl+S` no VS Code — o Godot recarrega sozinho graças ao _Auto Reload_.

**Rodar:** `F5` em qualquer um dos dois. Pelo VS Code, os breakpoints ficam ativos.

---

## Problemas comuns

| Sintoma                                     | Causa                          | Solução                                                                                                     |
| ------------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| Sem autocomplete, só cores                  | Godot fechado                  | Abra o Godot; ou `Godot Tools: Reconnect to Language Server` na palette                                     |
| "The specified Godot executable is invalid" | Caminho errado ou relativo     | Revise `godotTools.editorPath.godot4` — precisa ser absoluto                                                |
| Godot abre no gerenciador de projetos       | Faltam os args `--path ... -e` | Use a função `godev` acima, não `open -a` puro                                                              |
| LSP não conecta mesmo com Godot aberto      | Porta divergente               | Compare Godot `Editor Settings > Network > Language Server` com `godotTools.lsp.serverPort` (padrão `6005`) |
| Erros fantasma no arquivo inteiro           | Linha incompleta acima         | GDScript cascateia erro de parse; corrija a primeira linha marcada                                          |
| VS Code sem IntelliSense na raiz certa      | Pasta errada aberta            | Abra a raiz que contém `project.godot`, não uma subpasta                                                    |

Após alterar o `settings.json`: `Cmd+Shift+P` / `Ctrl+Shift+P` → **Developer: Reload Window**.
