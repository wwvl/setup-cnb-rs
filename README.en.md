# setup-cnb-rs

[简体中文](./README.md) | **English**

[![CNB Repo](https://img.shields.io/badge/CNB-wwvo%2Fcnb--rs%2Fsetup--cnb--rs-2F80ED?style=flat-square)](https://cnb.cool/wwvo/cnb-rs/setup-cnb-rs)
[![License](https://img.shields.io/badge/license-MIT-2F80ED?style=flat-square)](LICENSE)

Install the [cnb-rs](https://cnb.cool/wwvo/cnb-rs/cnb-rs) CLI tool in GitHub Actions with a single step.

## Quick Start

```yaml
steps:
  - uses: wwvo/setup-cnb-rs@v1
  - run: cnb-rs --version
```

## Usage

### Specify a version

```yaml
steps:
  - uses: wwvo/setup-cnb-rs@v1
    with:
      version: v1.0.0-alpha.1
```

### Full workflow example

```yaml
name: CNB Automation
on:
  push:
    branches: [main]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: wwvo/setup-cnb-rs@v1
        with:
          version: v1.0.0-alpha.1

      - name: Comment on an issue
        run: cnb-rs issue comment 1 -b "CI build completed"
        env:
          CNB_TOKEN: ${{ secrets.CNB_TOKEN }}
```

## Inputs

| Name | Description | Required | Default |
|---|---|---|---|
| `version` | cnb-rs version to install | No | `v1.0.0-alpha.1` |
| `source` | Download source (`cnb` or `github`) | No | `cnb` |

## Outputs

| Name | Description |
|---|---|
| `version` | The installed cnb-rs version string |
| `bin-path` | Directory containing the cnb-rs binary |

## Supported Platforms

| Runner | Architecture | Status |
|---|---|---|
| `ubuntu-latest` | x86_64, arm64 | ✅ |
| `macos-latest` | x86_64, arm64 | ✅ |
| `windows-latest` | x86_64, arm64 | ✅ |

## License

[MIT License](LICENSE)
