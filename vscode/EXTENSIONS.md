# Pinned extension sources (VS Code 1.85.2)

| Extension | Version | Source |
|-----------|---------|--------|
| `MS-CEINTL.vscode-language-pack-zh-hans` | 1.85.0 | [Open VSX](https://open-vsx.org) — `engines.vscode`: `^1.85.0` |
| `ms-python.python` | 2023.20.0 | Open VSX — `^1.82.0` |
| `ms-vscode.cpptools` | 1.18.5 | Microsoft Visual Studio Marketplace (strip gzip wrapper) — `linux-x64` VSIX |
| `eamodio.gitlens` | 14.6.1 | Open VSX — `^1.82.0` |
| `editorconfig.editorconfig` | 0.16.6 | Open VSX |
| `esbenp.prettier-vscode` | 10.4.0 | Open VSX |
| `dbaeumer.vscode-eslint` | 2.4.4 | Open VSX |
| `vscodevim.vim` | 1.27.2 | Open VSX — `^1.74.0` (1.27.3 is not on Open VSX) |
| `twxs.cmake` | 0.0.17 | Open VSX |
| `earshinov.filter-lines` | 1.1.0 | Open VSX |
| `yzhang.markdown-all-in-one` | 3.5.1 | Open VSX |

To replace **cpptools** for another platform, download the matching `vspackage` from the Marketplace, gunzip the payload to a `.vsix` zip, and name it `ms-vscode.cpptools-<version>.vsix` per `extensions.txt`.
