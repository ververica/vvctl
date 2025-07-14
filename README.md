# Ververica CLI: vvctl

For a more streamlined experience, you can use `vvctl`, the official Ververica command-line interface. It is built on top of the REST API and is ideal for both interactive use and automated scripting. You can:

- Manage resources with a command structure similar to `kubectl` (e.g., `vvctl get deployments`).
- Browse and manage your workspaces and deployments with a full-screen, text-based user interface (TUI).
- Easily integrate platform operations into your continuous integration and deployment pipelines.

## Installation

Currently we distribute `vvctl` compiled and tested for these systems: Apple Silicon, Linux x86_64
and Windows x86_64.

### Installation via script

You can use a script to download the latest release or to update
your current installation.

On **macOS** and **Linux**, copy and paste in your terminal:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ververica/vvctl/main/install.sh)"
```

On **Windows**, copy and paste the next code in your PowerShell terminal:

```sh
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (irm 'https://raw.githubusercontent.com/ververica/vvctl/main/install.ps1')
```

### Installation via Homebrew

If you are on macOS, you can use [Homebrew](https://brew.sh/)

```sh
brew tap ververica/vvctl && brew install vvctl
```

### Installation via Nix

On Linux you can use [Nix pacakge manager](https://nixos.org/download/#download-nix).
It's required to have [`flakes` and `nix-command` enabled](https://nixos.wiki/wiki/Flakes).

```sh
nix profile install github:ververica/vvctl
```

### Manual installation

You can install `vvctl` by downloading the binary.

1. Go to the [Latest Release Page](https://github.com/ververica/vvctl/releases/latest).
1. Download the binary for your system
1. Extract the archive.
1. Move the `vvctl` binary to a directory in your system's `PATH`. For Linux and macOS, ensure it is executable (`chmod +x vvctl`).

Once installed run

```sh
vvctl --version
```

to check you have the expected version.

### Interactive mode

When running the tool without commands `vvctl`, you will enter in the interative mode where you can manage your workspaces and deployments
in a more visual way. In this mode, you can use the `arrows` or `hjkl` to move around and `space` or `enter` to select.
Usage:
vvctl [COMMAND]

Commands:
login Log in Ververica Cloud
logout Log out of Ververica Cloud
get Display one or more resources
create Create a new resource
delete Delete a resource
start Start a resource
stop Stop a resource
install Install a resource
uninstall Uninstall a resource
default-config Print the default configuration
interactive Run interactive mode
help Print this message or the help of the given subcommand(s)

````

To have a more information about each command we recommend to use the option `--help` to know more about an specific
command and its subcommands and options.

```sh
❯ vvctl get --help
Display one or more resources

Usage: vvctl get <COMMAND>

Commands:
  workspaces    List all workspaces
  agent         List a single agent
  agents        List all agents from a workspace
  agent-values  Download the helm values file of an agent
  deployments   List all deployments from a workspace
  deployment    List a single deployment
  artifacts     List all artifacts from a workspace
  artifact      Download an artifact
  jobs          List all jobs from a deployment
  job           List a single job
  profile       Show logged user profile
  help          Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help

❯ vvctl get workspaces --help
List all workspaces

Usage: vvctl get workspaces [OPTIONS]

Options:
  -i, --instance-id <INSTANCE_ID>
          The ID of the workspace to filter by
  -s, --status-category <STATUS_CATEGORY>
          The status category to filter by
      --with-runtime-info <WITH_RUNTIME_INFO>
          Whether to include runtime information in the response [possible values:
          true, false]
  -p, --permission <PERMISSION>
          The permission to filter by
  -o, --output <OUTPUT>
          Output format [default: table] [possible values: table, json, yaml, yml]
  -h, --help
          Print help
````

### Configuration

The tool uses the next folders by default

| OS            | config folder                 | data folder                 |
| ------------- | ----------------------------- | --------------------------- |
| Linux / macOS | `~/.config/vvctl`             | `~/.local/share/vvctl`      |
| Windows       | `$HOME\AppData\Roaming\vvctl` | `$HOME\AppData\Local\vvctl` |

The configuration file can be found in the file `settings.json` in your config folder.
You would only need to edit this file in case you have an special requirement,
otherwise the default values should just work fine.

This is the default configuration

```json
{
  "session_path": "~/.local/share/vvctl/session",
  "api_host": "https://app.ververica.cloud",
  "default_flink_engine_version": "vera-1.0.6-flink-1.17",
  "agent_version": "1.9.2-1",
  "agent_charts": "oci://registry.ververica.cloud/agent-charts-stage/vv-agent",
  "agent_name": "vv-agent"
}
```

where

| Property       | Description                                                                    |
| -------------- | :----------------------------------------------------------------------------- |
| `session_path` | File path to store the authentication session. You can leave the default value |
| `api_host`     | URl of you of the Ververica API. By default `https://app.ververica.cloud`.     |
| `agent_*`      | Parameters for the BYOC agent installation. Leave the default values           |

#### Using Environment variables

You can also set some environment variables which will be used as the default value for some options
if they are required

| ENV Variable                 | Description                                                    |
| ---------------------------- | :------------------------------------------------------------- |
| `VV_API_HOST`                | URL of the Ververica API to use                                |
| `VV_API_TOKEN`               | API token to be used for authentication                        |
| `VV_EMAIL` and `VV_PASSWORD` | Credentials, email and password, to be used for authentication |
| `VV_WORKSPACE_ID`            | Workspace Id to be used as selected workspace                  |
| `VV_NAMESPACE_ID`            | Namespace Id to be used as selected namespace                  |
| `VV_CONFIG_DIR`              | Path for the folder containing the configuration files         |

### Authentication

The tool supports two methods of authentication.

1. Using credentials, email and password,
1. Using authentication tokens

The authentication tokens will be stored in the file defined in the authentication file. Make sure only
your user has access to this file.

If the authentication stored is not valid, the tool will ask for the credentials when executing any command
if they are not setup in as environment variables.

You can always authenticate directly using the command `vvctl login` with your credentials or API token.

### Output formats

All the commands support these three output formats: `json`, `yaml` and Table, where last one is a visual
representation of the data on a grid. The output format can always be defined using the option `--output` or `-o` with
the values `json`, `yaml` or `table`, which the latter is the default value.

You can then pipe the output with your favorite parsers to create filters. For example to get the running deployments from
a workspace:

```sh
vvctl get deployments --workspace migpc9aex9vi1v --o yaml | yq eval '.deployments[] | select(.latestJob.status == "RUNNING")'
```

### Creating a deployment

You can create a deployment by using the command `vvctl create deployment`. Currently only JAR and PYTHON deployments are supported.

Before creating a deployment, you need to create an artifact `vvctl create artifact` and use the URI of the artifact in your
deployment.

You can just pass the parameters as options to the command,

```sh
$ vvctl create deployment jar \
  --name vvctl-jar-deployment \
  --jar-uri s3i://vvc-tenant-migpc9aex9vi1v-west-1/artifacts/namespaces/default/FlinkQuickStart-1.0-SNAPSHOT-6ba7d69116ac0be045dc7f413346815e.jar \
  --main-arguments "--input /flink/usrlib/Shakespeare.txt" \
  --entry-class org.example.WordCountStreaming \
  --additional-dependencies s3i://vvc-tenant-migpc9aex9vi1v-eu-west-1/artifacts/namespaces/default/Shakespeare.txt
```

You can get more information using `--help` to see what other options you can use.

You can also use a file with all the values. For example, given a file called `jar-deployment.yml`

```sh
$ cat jar-deployment.yml
---
artifact:
  kind: JAR
  jarArtifact:
    additionalDependencies:
      - s3i://vvc-tenant-migpc9aex9vi1v-eu-west-1/artifacts/namespaces/default/Shakespeare.txt
    entryClass: org.example.WordCountStreaming
    jarUri: s3i://vvc-tenant-migpc9aex9vi1v-west-1/artifacts/namespaces/default/FlinkQuickStart-1.0-SNAPSHOT-6ba7d69116ac0be045dc7f413346815e.jar
    mainArgs: '--input /flink/usrlib/Shakespeare.txt'
name: vvctl-jar-deployment

$ vvctl create deployment jar -f jar-deployment.yml
```

The yaml file is the same schema as the output from the command `vvctl get deployment`, so you can use it as a template.

## CI/CD Integration

We also provide some mechanisms to support the usage of the CLI in your pipelines.

## GitHub Action

You can use this action to easily have the cli available in your github runner.

### Usage

To use it, just add this step to your job in your workflow:

```yaml
- name: Setup vvctl
  uses: ververica/vvctl@main
```

By default, this step will install the latest stable version available in the path
`/usr/local/bin`.

### Options

Sometimes you might need a different version or a different installation directory.
If this is your case, we provide these parameters you can use as inputs in your step.

| Input         | Description                               | Default          |
| ------------- | ----------------------------------------- | ---------------- |
| `version`     | Specific version to install (e.g. v1.2.3) | latest stable    |
| `prerelease`  | Install latest prerelease                 | `false`          |
| `install-dir` | Installation directory                    | `/usr/local/bin` |

### Examples

Here we show different uses:

```yaml
# Latest stable
- uses: ververica/vvctl@main

# Specific version and custom installation folder
- uses: ververica/vvctl@main
  with:
    version: "v1.2.3"
    install-dir: ~/bin

# Latest prerelease
- uses: ververica/vvctl@main
  with:
    prerelease: true
```

## Reporting an issue

If you find a bug or you have a request to improve you can use
our [issue tracker](https://github.com/ververica/vvctl/issues) at GitHub.

Feel free to open a new bug issue or feature request if you want to improve or add a
new functionality.

[Open an issue](https://github.com/ververica/vvctl/issues)
