# Dotfiles

自包含、**离线优先**的 dotfiles。无插件管理器、无子模块、安装时不依赖任何外部工具——`./install` 只是一个小 bash 脚本，把文件软链到 `$HOME` 并跑几个安装后钩子。

**入库的内容都是通用配置**；每台机器自己的密钥和环境变量放在 [本地（不入库）](#本地不入库) 那一节列出的 gitignored 文件里。

## 仓库布局

根目录只有 `install` 和 `README.md`，其余全部是文件夹：

```
.
├── install               # bash 入口 -> scripts/install.sh
├── README.md
├── bash/                 # bashrc（如果系统装了 zsh 就 exec 过去）
├── git/                  # gitconfig, gitignore_global
├── zsh/                  # zshrc, p10k.zsh, p9k.zsh, vendor/* (oh-my-zsh, p10k, p9k, …)
├── vim/                  # vimrc, autoload/plug.vim, plugins-vendor/*
├── vscode/               # settings.json, keybindings.json, extensions.txt, vsix/
├── fonts/                # MesloLGS NF + License
├── local/                # 仅本机用的 env.zsh / gitconfig.local（gitignore），以及 *.example 模板
└── scripts/              # install.sh, package-for-offline.sh, update-vendor.sh, …
```

`./install` 只负责把这些文件软链到 `$HOME`（链接表见 `scripts/install.sh`）。`zsh/vendor/` 与 `vim/plugins-vendor/` 下面的所有内容都已经作为普通文件入库——没有 git 子模块，也没有 upstream 的提交历史。

## 前置依赖

- **Git**、**Bash 4.2+**（RHEL 7 自带的就够）、**coreutils**。
- **Zsh** 作登录 shell（可选，但本套配置默认按这个写）。
- **安装期不需要联网**：
  - **Zsh 插件** 在 `zsh/vendor/<name>/` 下，纯文件。
  - **Vim 插件** 在 `vim/plugins-vendor/<name>/` 下，纯文件。
  - **MesloLGS NF 字体** 在 `fonts/` 下入库。
  - **VS Code 1.85.2 扩展** 在 `vscode/vsix/*.vsix` 下入库；`code` CLI 必须能在 `PATH` 里找到（或者用 `VSCODE_CLI` 显式指定）。`SKIP_VSCODE_EXTENSIONS=1` 可以跳过这一步。

## 安装

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install        # 幂等；已经装好的机器再跑 ~3s
```

`./install` 直接 exec 到 `scripts/install.sh`（一个~110 行的 bash 脚本，dotbot 替身），执行顺序：

1. 如果 `local/gitconfig.local` 不存在，从 `local/gitconfig.local.example` 复制一份（参考 [本地（不入库）](#本地不入库)）。
2. 清掉 `$HOME` 顶层那些断掉的符号链接。
3. 把仓库里的文件软链到 `$HOME`：
   - `~/.vimrc` → `vim/vimrc`，`~/.vim` → `vim/`
   - `~/.zshrc` → `zsh/zshrc`，`~/.p10k.zsh` → `zsh/p10k.zsh`，`~/.p9k.zsh` → `zsh/p9k.zsh`
   - `~/.bashrc` → `bash/bashrc`（带 force：原地的非软链文件会被直接覆盖，介意的话先备份）
   - `~/.gitconfig` → `git/gitconfig`，`~/.gitconfig.local` → `local/gitconfig.local`，`~/.gitignore_global` → `git/gitignore_global`
   - `~/.fonts` → `fonts/`
   - `~/.config/Code/User/settings.json` → `vscode/settings.json`，`keybindings.json` 同理
4. 校验 `fonts/` 下的 Meslo TTF 是否齐全，刷一次 `fc-cache`（默认无 `-f`，没改字体就跳过）。
5. 用 `code --list-extensions --show-versions` 跟 `vscode/extensions.txt` 对账，只对**未装**或**版本不匹配**的扩展真正调用 `code --install-extension`，已经是目标版本的直接 skip。

可调环境变量：

| 变量                       | 作用                                            |
|----------------------------|-------------------------------------------------|
| `DRY_RUN=1`                | 只打印动作，不修改文件系统                      |
| `SKIP_MESLO_FONTS=1`       | 跳过字体校验 + `fc-cache`                       |
| `SKIP_VSCODE_EXTENSIONS=1` | 跳过 VS Code 扩展安装                           |
| `VSCODE_CLI=/path/to/code` | 手动指定 `code` 可执行路径（绕开自动检测）      |

`~/.bashrc` 与 `~/.gitconfig.local` 用 force 语义：如果对应位置已经有**非软链**的真实文件，会被无备份直接删除。介意的话请先手动备份。

### 离线机器更新流程（sneakernet）

离线机器没法 `git pull`。整个仓库现在是纯文件（无子模块），打包就是一条 `tar`：

**有网那台：**

```bash
cd ~/dotfiles
git pull
scripts/package-for-offline.sh             # 输出 ../dotfiles-<sha>-<时间戳>.tar.gz
# 或者更小（不带 .git，~131 MB 而非 ~420 MB）：
NO_GIT=1 scripts/package-for-offline.sh
```

**离线那台：**

```bash
mv ~/dotfiles ~/dotfiles.bak.$(date +%s)
tar -xzf dotfiles-<sha>-<时间戳>.tar.gz -C ~/
cd ~/dotfiles && ./install
```

整个过程没有任何 `git submodule update` 步骤——vendor 目录就是普通文件。第二次起 `./install` 全部幂等，约 3 秒。

### 更新某个 vendored 插件 / 主题

只能在有网机器上跑：

```bash
scripts/update-vendor.sh <vendor 路径> <git URL> [<ref>]
# 示例：
scripts/update-vendor.sh vim/plugins-vendor/nerdtree https://github.com/preservim/nerdtree.git master
scripts/update-vendor.sh zsh/vendor/powerlevel10k    https://github.com/romkatv/powerlevel10k.git v1.20.0
```

脚本会克隆 upstream，删掉它的 `.git/`，把目标目录整个替换掉，并把改动 stage 起来。用 `git diff --cached <path>` 复核，再提交：

```bash
git commit -m "chore(vendor): update <path> to <ref>"
```

### 本地（不入库）

下面这些文件 **永远不要入库**（已经写在 `.gitignore`）。仓库只提供 `*.example` 模板，第一次 `./install` 会自动从模板复制成真实文件：

| 文件                              | 入库？ | 用途                                                                |
|-----------------------------------|--------|---------------------------------------------------------------------|
| **`local/gitconfig.local.example`** | 是     | Git 身份模板（user.name / user.email）                              |
| **`local/gitconfig.local`**         | **否** | 真实的 git 身份；`./install` 首次跑时从模板复制，链到 `~/.gitconfig.local` |
| **`local/env.zsh.example`**       | 是     | 本机 zsh 环境模板                                                   |
| **`local/env.zsh`**               | **否** | 代理、`PATH`、机器密钥等；`zsh/zshrc` 末尾会 source 它                |
| **`fonts/MesloLGS NF *.ttf`**     | 是     | 入库的 Meslo + `MesloLGS NF License.txt`（Apache 2.0）              |

绝对不要把 **`local/gitconfig.local`** 或 **`local/env.zsh`** 提交。

### Vim 插件

插件以普通目录形式放在 `vim/plugins-vendor/<name>/`，由 **vim-plug** 通过本地路径加载（`vim/vimrc` 里写的）：

```vim
Plug '~/.vim/plugins-vendor/nerdtree'
" ...
```

`plug#end()` 会把每个目录加到 `&runtimepath`，所以**完全不需要跑 `PlugInstall`**。

**Vim 版本与 easycomplete**：`vim-easycomplete` 需要较新的 Vim（含 `v:null`、`v:true`/`v:false`、`job`、`timer` 等，约 **Vim 8.0+**）。`vim/vimrc` 在检测到环境不支持时会**自动不加载**该插件，避免在 RHEL 7 等自带 **Vim 7.4** 的机器上整屏 E121/E15；其余插件仍正常加载。若需要 LSP 补全，请在该机安装新版 Vim 后再用。终端光标序列 `&t_SR` 等在旧版上可能不存在，配置里已用 `exists('&t_SR')` 等形式做了探测，避免 E355。

> **离线注意**：`vim-easycomplete` 在 `vim/plugins-vendor/vim-easycomplete/autoload/easycomplete/installer/*.sh` 里有一堆 LSP 服务器（rust-analyzer、jdtls、omnisharp…）的下载脚本，会用 `curl` 联网。在离线机器上不要执行 `:InstallLspServer`；要么提前在有网机器上准备好 LSP 二进制，要么放弃对应语言的补全功能。

### Prompt 主题：P10k + 老 zsh 自动回退到 P9K

Powerlevel10k 要求 `zsh >= 5.1`。如果 `$ZSH_VERSION` 太老（典型场景：RHEL/CentOS 7 自带 5.0.2，且不允许升级 zsh），`zsh/zshrc` 会自动改用它的前身 **Powerlevel9k**：

- `zsh/vendor/powerlevel10k/` —— `zsh >= 5.1` 时使用，配置文件 `zsh/p10k.zsh`（链到 `~/.p10k.zsh`）。
- `zsh/vendor/powerlevel9k/`  —— `zsh < 5.1` 时使用，配置文件 `zsh/p9k.zsh`（链到 `~/.p9k.zsh`；未链接时 `zshrc` 会从 `$DOTFILES/zsh/p9k.zsh` 直接加载）。右侧 prompt 段仅包含当前 vendor 快照里存在的 segment（本仓库内的 P9K 无 `terraform` 段）。rainbow 风格，整体外观与 p10k preset 接近。

两套主题都假设你装了 MesloLGS NF（仓库的 `fonts/` 已经带）。`zsh/zshrc` 顶部的 P10k instant-prompt 缓存块也加了同样的 zsh 版本守卫，所以 5.0.2 那台不会再看到 "minimum required version is 5.1" 的红字。

## 字体与 Powerlevel10k（不出现乱码方块）

字体细节（具体哪些 TTF 入库、IDE 端怎么配字体）见 **`fonts/README.md`**。

简版：在 Cursor / VS Code 跑 IDE 的那台机器的 **User** settings.json 里加：

```json
{
  "terminal.integrated.fontFamily": "'MesloLGS NF', monospace",
  "terminal.integrated.fontSize": 14
}
```

也可以参考官方的 [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)。

## 参考链接

- [vim-plug](https://github.com/junegunn/vim-plug/wiki)
- [Powerlevel10k fonts](https://github.com/romkatv/powerlevel10k#fonts)
- [Powerlevel9k Stylizing Your Prompt](https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt)
