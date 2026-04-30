# VS Code 1.85.2 扩展锁定清单

| 扩展 ID                                  | 版本     | 来源 / 备注                                                                       |
|------------------------------------------|----------|-----------------------------------------------------------------------------------|
| `MS-CEINTL.vscode-language-pack-zh-hans` | 1.85.0   | [Open VSX](https://open-vsx.org) —— `engines.vscode`：`^1.85.0`                  |
| `ms-python.python`                       | 2023.20.0 | Open VSX —— `^1.82.0`                                                            |
| `ms-vscode.cpptools`                     | 1.18.5   | Microsoft Visual Studio Marketplace（payload 是 gzip 包，需要解开成普通 zip）；`linux-x64` 平台 VSIX |
| `eamodio.gitlens`                        | 14.6.1   | Open VSX —— `^1.82.0`                                                            |
| `editorconfig.editorconfig`              | 0.16.6   | Open VSX                                                                          |
| `esbenp.prettier-vscode`                 | 10.4.0   | Open VSX                                                                          |
| `dbaeumer.vscode-eslint`                 | 2.4.4    | Open VSX                                                                          |
| `vscodevim.vim`                          | 1.27.2   | Open VSX —— `^1.74.0`（1.27.3 在 Open VSX 上没有）                              |
| `twxs.cmake`                             | 0.0.17   | Open VSX                                                                          |
| `earshinov.filter-lines`                 | 1.1.0    | Open VSX                                                                          |
| `yzhang.markdown-all-in-one`             | 3.5.1    | Open VSX                                                                          |

> 想给别的平台换 **cpptools**：去 Marketplace 下载对应平台的 `vspackage`，把 gzip payload 解开成 zip，重命名为 `ms-vscode.cpptools-<version>.vsix`，与 `extensions.txt` 里的版本号对齐即可。
