# VS Code（dotfiles）

**目标版本：`1.85.2`**（参见 `target-version.txt` —— 离线机器上请选 [1.85.2](https://code.visualstudio.com/updates) 这个 build）。
Linux 上配置软链到 **`~/.config/Code/User/`**。

| 路径                  | 说明                                                       |
|-----------------------|------------------------------------------------------------|
| `settings.json`       | 用户设置（JSONC）                                          |
| `keybindings.json`    | 键位绑定（JSON 数组）                                      |
| `extensions.txt`      | 锁定的 `publisher.extension@version`（按行决定安装顺序）   |
| **`vsix/*.vsix`**     | 入库的扩展安装包（**必须有** —— 详见 `EXTENSIONS.md`）     |

## 离线安装

仓库里 **`vscode/vsix/*.vsix`** 与 **`extensions.txt`** 一一对应。`./install` 会调用 **`scripts/install-vscode-extensions.sh`**，**只**从这些 VSIX 装（不走 Marketplace）。

脚本会先 `code --list-extensions --show-versions` 跟 `extensions.txt` 对账：
- 已经装到目标版本的扩展直接 skip
- 没装或版本不一致的才真正调用 `code --install-extension`
- 末尾打印 `N installed/updated, M already up-to-date` 摘要

刷新版本锁或新增 VSIX 必须**离开**本仓库的脚本来做（去 [Open VSX](https://open-vsx.org) 或 Visual Studio Marketplace 下载新版 `.vsix`），并把出处补到 `EXTENSIONS.md`。

## 环境变量

| 变量                       | 作用                       |
|----------------------------|----------------------------|
| `SKIP_VSCODE_EXTENSIONS=1` | 跳过整个扩展安装步骤       |
| `VSCODE_CLI=/path/to/code` | 手动指定 VS Code CLI       |

## Windows / macOS 路径

本仓库的链接表只覆盖 **`~/.config/Code/User/`**（Linux）。原生 Windows 用 `%APPDATA%\Code\User\`；**WSL** + Linux 版 VS Code 仍然走上面的 Linux 路径。

## Cursor

Cursor 的用户配置目录是 **`~/.config/Cursor/User`**。如果你想让 Cursor 也用同一份 settings/keybindings，自行把这两个 JSON 拷过去或者再做一次软链（本仓库没有自动化这个）。
