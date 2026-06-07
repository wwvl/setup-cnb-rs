# setup-cnb-rs

**简体中文** | [English](./README.en.md)

[![Release][badge-release]][cnb-releases]
[![Marketplace][badge-marketplace]][marketplace]
[![GitHub][badge-github]][github-repo]
[![CNB Repo][badge-cnb]][cnb-repo]
[![License][badge-license]][license]

在 GitHub Actions 中一键安装 [cnb-rs][cnb-rs-repo] CLI 工具。

## 快速开始

```yaml
steps:
  - uses: wwvl/setup-cnb-rs@main
  - run: cnb-rs --version
```

## 使用示例

### 指定版本

```yaml
steps:
  - uses: wwvl/setup-cnb-rs@main
    with:
      version: v1.0.0-alpha.15
```

### 完整工作流

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

      - name: 给 Issue 添加评论
        run: cnb-rs issue comment 1 -b "CI 构建完成"
        env:
          CNB_TOKEN: ${{ secrets.CNB_TOKEN }}
```

## Inputs

| 名称      | 描述                        | 必填 | 默认值            |
| --------- | --------------------------- | ---- | ----------------- |
| `version` | cnb-rs 版本号               | 否   | `v1.0.0-alpha.15` |
| `source`  | 下载源（`cnb` 或 `github`） | 否   | `cnb`             |

## Outputs

| 名称       | 描述                      |
| ---------- | ------------------------- |
| `version`  | 实际安装的版本号          |
| `bin-path` | cnb-rs 二进制文件所在目录 |

## 支持平台

| Runner           | 架构          | 状态 |
| ---------------- | ------------- | ---- |
| `ubuntu-latest`  | x86_64, arm64 | ✅   |
| `macos-latest`   | x86_64, arm64 | ✅   |
| `windows-latest` | x86_64, arm64 | ✅   |

## 许可证

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
