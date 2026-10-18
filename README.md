# Personal dotfiles

一份个人 dotfiles，覆盖：
- **Zsh**：oh-my-zsh + autosuggestions + 语法高亮，powerlevel10k / powerlevel9k 二选一，外加 mo 项目自带的 prompt 状态。
- **Tmux**：`C-q` 前缀、vi 键位、顶部状态栏（含 mo 的 CPU/内存/磁盘）。
- **Vim**：完整配置 + vim-plug 插件，**插件本体随仓库带一份**（`vim/plugins-vendor/`，离线可用）。
- **Git / GitHub CLI**：`gitconfig` / `gitconfig.local` / `github-cli`。

约定：

* 仓库里的所有文件用占位符 `{{USER}}` / `{{HOST}}` 表示因人而异的内容；机器本地的差异放在 `local/` 下（`local/env.zsh`、`local/gitconfig.local`）。
* 安装期**需要联网**：zsh 插件在首次加载时通过 codeload 拉取并缓存，不随仓库分发。仅 `vim/plugins-vendor/` 是离线随仓自带的。

## 仓库布局

```
dotfiles/
├── install                    # 主入口：实际链接/复制/软链逻辑
├── zsh/
│   ├── zshrc                  # 主 rc；用 zsh_plugin_fetch 按需拉取插件到 $ZSH_PLUGINS_DIR
│   ├── mo-prompt.zsh          # 调 ~/.mo/config/prompts.zsh
│   ├── p10k.zsh               # powerlevel10k 配置（默认）
│   └── p9k.zsh                # powerlevel9k 配置（用 DOTFILES_USE_P9K=1 启用）
├── tmux/
│   ├── tmux.conf
│   └── mo-status.sh           # 状态栏右侧：CPU / 内存 / 磁盘（mo status --json）
├── vim/
│   ├── vimrc
│   └── plugins-vendor/        # vim 插件本体（随仓库带，离线可用）
├── gitconfig                  # 含 include! 指向 local/ 的 gitconfig.local
├── github-cli                 # gh 配置
├── local/                     # 机器本地、不入库的内容
│   ├── env.zsh
│   └── gitconfig.local
│   （示例：env.zsh.example / gitconfig.local.example）
└── README.md
```

`./install` 只负责把这些文件软链到 `$HOME`（链接表见 `install`）。`vim/plugins-vendor/` 下面是普通文件——没有 git 子模块，也没有 upstream 的提交历史。

## 前置条件

```
zsh tmux vim gh curl
```

* **tmux ≥ 1.9**：用了 `source-file` / `refresh-client`。
* **zsh ≥ 5.1** 才会用 `powerlevel10k`；低于该版本自动退化到 `powerlevel9k`。
* 在 **zsh 5.0.x + 非 UTF-8 locale** 上（典型如某些 macOS 15+ 容器化 zsh）P10K 加载会失败，脚本会捕获 `zerr` 回退到 P9K 纯文本配置。
* **联网**：zsh 插件在首次加载时按 `codeload.github.com` 拉取（离线场景可先把 tarball 放进 `$ZSH_PLUGINS_DIR`，见下文）。仅 zsh 插件需要联网，vim 插件离线。

## 安装 / 更新

```sh
./install
```

会做的事（幂等）：
1. 把顶层文件软链到 `$HOME`（`zsh/zshrc` → `~/.zshrc`、`vim/vimrc` → `~/.vimrc`、`gitconfig` → `~/.gitconfig`、`github-cli` → `~/.github-cli`、`tmux/tmux.conf` → `~/.tmux/tmux.conf`）。
2. 软链 `tmux/mo-status.sh` → `~/.config/mo-status.sh`（tmux 状态栏右侧读取）。
3. 把 `local/env.zsh` 复制到 `~/.config/local/env.zsh`（不存在时）。
4. 把 `local/gitconfig.local` 复制到 `~/.config/gitconfig.local`（不存在时）。

如果某处的目标文件已存在但不是软链，脚本会先备份到 `.<name>.bak.<timestamp>` 再覆盖。

**重新链接**（改了 `install` 的链接表之后）：
```sh
yes | ./install
```
脚本默认 `read -r -p` 交互询问覆盖；管道/非交互调用时 `read` 在 EOF 直接退出，不会回退确认。

## 拉取 zsh 插件（联网）

`zsh/zshrc` 顶部定义了 `zsh_plugin_fetch`，**首次缺件时**才去 codeload 拉一份小 tarball 并解压：

```
zsh_plugin_fetch <name> <owner/repo> <ref> <entry>
```

* 缓存目录为 `$ZSH_PLUGINS_DIR`，默认 `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins`。
* 仅当 `$ZSH_PLUGINS_DIR/<name>/<entry>` 不存在时才下载——已缓存则直接复用。
* 拉取失败时回退到 `master`/`main` 分支，并打印警告；插件缺失时 zsh 仍能启动。

首次拉取的插件：

| 插件 | owner/repo | 默认 ref |
|---|---|---|
| oh-my-zsh | `ohmyzsh/ohmyzsh` | `master` |
| zsh-autosuggestions | `zsh-users/zsh-autosuggestions` | `master` |
| powerlevel10k (+ gitstatus) | `romkatv/powerlevel10k` | `master` |
| powerlevel9k | `bhilburn/powerlevel9k` | `master` |
| zsh-syntax-highlighting | `zsh-users/zsh-syntax-highlighting` | `master` |

**离线场景**：把对应 tarball 手动放进 `$ZSH_PLUGINS_DIR/<name>/`（与解压结果结构一致），`zsh_plugin_fetch` 发现已存在就跳过下载。

没有插件管理器：不依赖 `omz update` / `antidote` / `zinit` 之类。每个插件就是一份小 tarball，刷新方式见下。

## 刷新单个 zsh 插件

```sh
# 删掉缓存，下次启动 zsh 就会重新拉取
rm -rf "$ZSH_PLUGINS_DIR/powerlevel10k"
```

## 软链表（`install`）

| 仓库内 | 目标 |
|---|---|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/mo-prompt.zsh`   | `~/.mo-prompt.zsh` |
| `zsh/p10k.zsh`       | `~/.p10k.zsh` |
| `zsh/p9k.zsh`        | `~/.p9k.zsh` |
| `tmux/tmux.conf`     | `~/.tmux/tmux.conf` |
| `tmux/mo-status.sh`  | `~/.config/mo-status.sh` |
| `vim/vimrc`          | `~/.vimrc` |
| `gitconfig`          | `~/.gitconfig` |
| `github-cli`         | `~/.github-cli` |

（`local/env.zsh` 与 `local/gitconfig.local` 是 **copy 而非 symlink**，让每台机器各自维护。）

## 环境变量

| 名 | 默认 | 含义 |
|---|---|---|
| `ZSH_PLUGINS_DIR` | `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins` | zsh 插件缓存目录 |
| `TMUX_NO_ATTACH` | 空 | 非空时登录 shell 不自动 attach 已存在 tmux session |
| `DOTFILES_USE_P9K` | 空 | 非空则 zsh 加载 `~/.p9k.zsh`（默认用 `~/.p10k.zsh`） |
| `MO_PROMPT` / `MO_PROMPT_MODE` | 见 `~/.mo/config/prompts.zsh` | mo 项目侧的 prompt 配置 |

zsh prompt 顺序：mo 状态 → `powerlevel10k` / `powerlevel9k`（二选一）→ autosuggestions + 语法高亮。
`powerlevel10k` / `powerlevel9k` 在仓库里都带一份缓存，二选一加载；`zsh/p9k.zsh` 只 `autoload powerlevel9k`（不加载 powerlevel10k），并带一层 `zerr` 回退：在 zsh 5.0.x + 非 UTF-8 locale 上 P9K 的 `icons.zsh` 会因为 `$'\uXXXX'` 被截断，本文件会 catch 住并退化到纯文本 prompt。

## 已知坑

### Vim 8.1 与 Vim 8.2 的 `set runtimepath` 差异

本仓 `vimrc` 同时支持 **Vim 8.1** 和 **Vim 8.2**。关键区别在 `~/.vim/autoload/plug.vim` 加载前的 `set rtp=` 重写：

| 版本 | 行为 |
|---|---|
| Vim 8.1 | `set rtp+=...; set rtp-=/usr/share/vim/...` 不会报错，但顺序不可控 |
| Vim 8.2 | `set rtp-=X` 在 X 不在 runtimepath 时抛 `E521: ...` 警告，且 `set rtp=` 整条会**清空**当前 rtp |

`vim/vimrc` 顶部按 `v:version` 分支：8.2 用 `set rtp=...` 直接重写；8.1 走 `set rtp+=` 增量。这样 8.1 / 8.2 都能正常加载 `vim/plugins/` 与 `vim/plugins-vendor/`。

### 在 Vim 8.1 上 `Plug#...#Update!` 行为

`plug.vim` 老版本对 `g:plug_update=1` 的处理与新版不一致：
- 8.1：`Plug ... | Update!` 会触发 `git pull --ff-only`，需要联网且 `--ff-only` 在某些仓库上失败。
- 8.2：`Update!` 走 `--force-rebase`，更宽容。

本仓 `vim/plugins-vendor/` 是**纯文件**（git 不跟踪 upstream history），所以不依赖 `Plug ... | Update!` 在线拉取；离线/在线都能用。

### Tmux + powerlevel10k 的 `git` 段

`tmux/tmux.conf` 默认 prefix 为 `C-q`（避开 `C-b`，与 Vim `i` 模式下的 `C-o` 不冲突；避开 `C-c`/C-v，macOS 终端常用）。
状态栏右侧由 `~/.config/mo-status.sh` 提供（`CPU / 内存 / 磁盘`），来自 `mo status --json`。
P10K 的 git 段在 tmux 内会读 `TMUX_PANE_WORKING_DIR`；若 `gitstatus` 已加载（zsh 拉取时附带），git 段实时更新。

### 字体

P10K / P9K 的 `nerdfont-complete` 段需要 **Meslo LGS NF**（nerd-font），否则图标位置显示为方块。
本仓不再内置字体，请自行安装 Meslo LGS NF 并在你的终端中选用。

## 卸载

```sh
# 1. 解链 dotfiles
for f in .zshrc .p10k.zsh .p9k.zsh .mo-prompt.zsh .vimrc .gitconfig .github-cli; do
  [ -L "$HOME/$f" ] && unlink "$HOME/$f"
done
rm -f "$HOME/.tmux/tmux.conf" "$HOME/.config/mo-status.sh"

# 2. 删缓存（zsh 插件缓存 + 备份）
rm -rf "${ZSH_PLUGINS_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins}"
find "$HOME" -maxdepth 1 -name '.*.bak.*' -print -delete
```

`vim/plugins-vendor/` 是纯文件，随仓库一起删；如想保留已 vendor 的插件备份，先 `cp -a vim/plugins-vendor /tmp/` 再删仓库。

## 维护提示

* **改 `zsh/zshrc` 的插件清单后**：删掉对应缓存目录即可触发重拉，无需动仓库。
* **改 `vim/plugins-vendor/` 后**：跑一次 `:PlugClean`。
* **改 `install` 链接表后**：`yes | ./install` 重链一次。
