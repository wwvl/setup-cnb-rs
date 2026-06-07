# setup-cnb-rs

[简体中文](./README.md) | **English**

[![Release][badge-release]][cnb-releases]
[![Marketplace][badge-marketplace]][marketplace]
[![GitHub][badge-github]][github-repo]
[![CNB Repo][badge-cnb]][cnb-repo]
[![License][badge-license]][license]

Install the [cnb-rs][cnb-rs-repo] CLI tool in GitHub Actions with a single step.

## Quick Start

```yaml
steps:
  - uses: wwvl/setup-cnb-rs@main
  - run: cnb-rs --version
```

## Usage

### Specify a version

```yaml
steps:
  - uses: wwvl/setup-cnb-rs@main
    with:
      version: v1.0.0-alpha.13
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
      - uses: wwvl/setup-cnb-rs@main

      - name: Comment on an issue
        run: cnb-rs issue comment 1 -b "CI build completed"
        env:
          CNB_TOKEN: ${{ secrets.CNB_TOKEN }}
```

## Inputs

| Name      | Description                         | Required | Default           |
| --------- | ----------------------------------- | -------- | ----------------- |
| `version` | cnb-rs version to install           | No       | `v1.0.0-alpha.13` |
| `source`  | Download source (`cnb` or `github`) | No       | `cnb`             |

## Outputs

| Name       | Description                            |
| ---------- | -------------------------------------- |
| `version`  | The installed cnb-rs version string    |
| `bin-path` | Directory containing the cnb-rs binary |

## Supported Platforms

| Runner           | Architecture  | Status |
| ---------------- | ------------- | ------ |
| `ubuntu-latest`  | x86_64, arm64 | ✅     |
| `macos-latest`   | x86_64, arm64 | ✅     |
| `windows-latest` | x86_64, arm64 | ✅     |

## License

[MIT License][license]

<!-- badges -->

[badge-release]: https://cnb.cool/wwvo/cnb-rs/cnb-rs/-/badge/release
[badge-marketplace]: https://img.shields.io/badge/Marketplace-setup--cnb--rs-2088FF?style=flat-square&logo=githubactions&logoColor=white
[badge-github]: https://img.shields.io/badge/GitHub-wwvl%2Fsetup--cnb--rs-181717?style=flat-square&logo=github&logoColor=white
[badge-cnb]: https://img.shields.io/badge/CNB-wwvo%2Fcnb--rs%2Fsetup--cnb--rs-2F80ED?style=flat-square
[badge-license]: https://img.shields.io/badge/license-MIT-2F80ED?style=flat-square

<!-- links -->

[cnb-releases]: https://cnb.cool/wwvo/cnb-rs/cnb-rs/-/releases
[marketplace]: https://github.com/marketplace/actions/setup-cnb-rs
[github-repo]: https://github.com/wwvl/setup-cnb-rs
[cnb-repo]: https://cnb.cool/wwvo/cnb-rs/setup-cnb-rs
[cnb-rs-repo]: https://cnb.cool/wwvo/cnb-rs/cnb-rs
[license]: LICENSE
