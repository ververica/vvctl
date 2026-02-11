# Ververica CLI: vvctl

This is a summary from a more extended documentation that can be found at [https://docs.ververica.com/api/cli](https://docs.ververica.com/api/cli).

`vvctl` is the official Ververica command-line interface. It mirrors the public REST API and works both interactively and in automation.

- kubectl-like commands to manage workspaces, deployments, artifacts, drafts, agents, etc.
- Full-screen TUI for quick browsing (run `vvctl` with no args).
- Fits CI/CD pipelines, supports JSON/YAML output.

## Installation

We ship pre-built binaries for Apple Silicon, Linux x86_64, and Windows x86_64.

### Script (macOS/Linux)

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ververica/vvctl/main/install.sh)"
```

Variants:

- Latest preview: `...install.sh)" -- --preview`
- Pin a version: `...install.sh)" -- v2025.7.9`
- Custom install dir: `INSTALL_DIR=$HOME/bin ...install.sh)"`

### Script (Windows)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (irm 'https://raw.githubusercontent.com/ververica/vvctl/main/install.ps1')
```

Variants:

- Preview: add `-Preview`
- Pin: add `-Version v2025.7.9`
  The script installs to the first writable folder in `PATH`, otherwise `$HOME\bin`.

### Homebrew (macOS, stable only)

```sh
brew tap ververica/vvctl && brew install vvctl
```

### Nix (stable only)

```sh
nix profile install github:ververica/vvctl
```

### Manual

1. Download from the [latest release](https://github.com/ververica/vvctl/releases/latest).
2. Extract the archive.
3. Move `vvctl` into your `PATH` (e.g., `/usr/local/bin`), `chmod +x vvctl` on macOS/Linux.
4. Verify: `vvctl --version`.

## Usage

### Interactive mode (TUI)

Running `vvctl` with no arguments opens the TUI. Navigation: arrows or `hjkl`; select with `space`/`enter`; quit with `q`. The footer shows available shortcuts.

### Command mode

`vvctl [COMMAND]` for non-interactive use. Common groups: `login/logout`, `get/create/delete/start/stop`, `run`, `validate`, `logs`, `install/uninstall`, `config`. Use `--help` on any subcommand for exact flags and options.

### Output formats

Most `get` commands support `table` (default), `json`, or `yaml` via `--output|-o`. Example filter:

```sh
vvctl get deployments --workspace <ws> -o yaml | yq '.deployments[] | select(.latestJob.status == "RUNNING")'
```

### Creating a deployment (JAR example)

```sh
vvctl create deployment jar \
  --name wordcount \
  --jar-uri s3i://bucket/artifacts/FlinkQuickStart.jar \
  --entry-class org.example.WordCountStreaming \
  --main-arguments "--input /flink/usrlib/Shakespeare.txt"
```

## Configuration

- Config dir: `XDG_CONFIG_HOME/vvctl` (fallback `~/.config/vvctl`) or `%APPDATA%\vvctl` on Windows. Override file with `VV_CONFIG=/path/to/config.yml`.
- Data dir: `XDG_DATA_HOME/vvctl` (fallback `~/.local/share/vvctl`) or `%LOCALAPPDATA%\vvctl`; session cache stored here.
- Config file: `config.yml` is auto-created on first run. Server name `vvc` is reserved; built-in context `vvc (built-in)` points to `https://app.ververica.cloud`.
- BYOC agent defaults: `agent_version: 1.9.2-1`, `agent_charts: oci://registry.ververica.cloud/agent-charts/vv-agent`, `agent_name: vv-agent`.
- TUI settings: `tui.config.json|toml|yaml` auto-created in the config dir for keybindings/colors.

### Environment variables

| Variable                 | Purpose                                         |
| ------------------------ | ----------------------------------------------- |
| `VV_API_TOKEN`           | Bearer token (skips interactive login)          |
| `VV_EMAIL`/`VV_PASSWORD` | Credentials for login when prompts not possible |
| `VV_WORKSPACE`           | Default workspace ID                            |
| `VV_NAMESPACE`           | Default namespace (fallback `default`)          |
| `VV_CONFIG`              | Path to `config.yml`                            |
| `VV_API_HOST`            | Override API base URL (staging/self-hosted)     |
| `VVCTL_LOG_LEVEL`        | Logging level (`debug`, `info`, …)              |

## Authentication

Authenticate with `vvctl login` (email/password) or set `VV_API_TOKEN`. Tokens are cached in the data directory (`session` file). If a cached token expires, vvctl will prompt again or reuse env vars.

## Output formats (quick reference)

- `--output table|json|yaml` (default `table`).

## Support

Open issues at <https://github.com/ververica/vvctl/issues> or contact <help@ververica.com>.
