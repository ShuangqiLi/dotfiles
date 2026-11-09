# Personal dotfiles

一份个人 dotfiles，覆盖：

- **Zsh**：oh-my-zsh（联网拉取）+ autosuggestions + 语法高亮，**starship** 提示符（brew 安装，`config/starship.toml` 配置）。
- **Tmux**：`C-q` 前缀、vi 键位、顶部 onedark 状态栏（tmux2k）、扩展键上报（适配 pi agent）。
- **Vim**：完整配置，插件本体随仓库带一份（`vim/plugins-vendor/`，离线可用）。
- **Git**：`git/gitconfig`（include `gitconfig.local`）+ 全局 gitignore。
- **字体**：Maple Mono Nerd Font CN（`fonts/` 随仓，install 安装到用户字体目录）。

约定：

* 机器本地的差异放在 `local/` 下（`local/zshrc.local`、`local/gitconfig.local`），**不入库**；仓库只发 `.example` 模板。
* 安装期**部分联网**：brew 包、pip 包、zsh 插件（codeload 拉取缓存）、Homebrew 本身（全新 macOS）。vim 插件离线随仓。
* 幂等：重跑不产生副作用，干净机器全量安装、已有机器秒退。

## 仓库布局

```
dotfiles/
├── install                  # 主入口：装依赖 → 软链 → 装字体 → 收尾（幂等）
├── zsh/
│   ├── zshrc                # 主 rc；zsh_plugin_fetch 按需拉取插件到 $ZSH_PLUGINS_DIR
│   └── aliases              # 共享 alias（zsh/bash 都 source）
├── bash/
│   └── bashrc               # 优先 exec 进 zsh；纯 bash 会话时 source 共享 alias
├── config/
│   └── starship.toml        # starship 提示符配置 → ~/.config/starship.toml
├── tmux/
│   └── tmux.conf
├── vim/
│   ├── vimrc
│   └── plugins-vendor/      # vim 插件本体（随仓库带，离线可用）
├── git/
│   ├── gitconfig            # 含 include! 指向 local/gitconfig.local
│   └── gitignore_global
├── agents/
│   └── skills/              # 各 coding agent 共用的 skills
├── fonts/                   # Maple Mono Nerd Font CN（install 拷到用户字体目录）
├── local/                   # 机器本地、不入库（只有 .example 入库）
│   ├── zshrc.local          # → ~/.zshrc.local（代理/PATH/密钥）
│   └── gitconfig.local      # → ~/.gitconfig.local（git 身份）
└── README.md
```

## 前置条件

一台机器只需要：

```
git    # clone 仓库
curl   # Homebrew 安装脚本（无 brew 的 macOS）
```

其余全部由 `./install` 自动补齐：

| 平台 | 安装 |
|---|---|
| macOS | 无 brew 时先自动装 Homebrew（首次需点一下 Xcode CLT 弹窗）；然后 brew 装 `git zsh tmux starship eza ripgrep ctags node python@3.15` + `rapid-mlx`；pip 装 `argcomplete` |
| Linux | `apt` / `dnf` / `yum` 尽力而为装 `git zsh tmux eza ripgrep ctags nodejs npm python3 python3-pip`（无 root 时自动 sudo）；pip 装 `argcomplete`（`--user`） |

另有两类运行时联网拉取（首次开 shell）：

- **zsh 插件**：`zsh/zshrc` 的 `zsh_plugin_fetch` 从 `codeload.github.com` 拉 tarball 缓存到 `$ZSH_PLUGINS_DIR`（oh-my-zsh、zsh-autosuggestions、zsh-syntax-highlighting）。
- **字体**：`fonts/` 随仓自带，install 拷贝 + 刷新字体缓存，离线可用。

## 安装 / 更新

```sh
git clone git@github.com:ShuangqiLi/dotfiles.git
cd dotfiles && ./install
exec zsh
```

`./install` 做的事（幂等）：

1. 缺失的 `local/zshrc.local` / `local/gitconfig.local` 从 `.example` 模板复制；
2. 安装缺失的工具依赖（brew / apt / dnf / yum + pip，见上表）；
3. 清理 `$HOME` 顶层断链；
4. 软链配置（下表）；
5. 安装 `fonts/` 到 `~/Library/Fonts`（macOS）或 `~/.local/share/fonts`（Linux）；
6. 建 vim 缓存目录，打印后续提示（改 git 身份等）。

**链接表**：

| 仓库内 | 目标 |
|---|---|
| `agents` | `~/.agents` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `vim/vimrc` | `~/.vimrc` |
| `vim` | `~/.vim` |
| `zsh/zshrc` | `~/.zshrc` |
| `local/zshrc.local` | `~/.zshrc.local` |
| `bash/bashrc` | `~/.bashrc`（force） |
| `config/starship.toml` | `~/.config/starship.toml` |
| `git/gitconfig` | `~/.gitconfig` |
| `local/gitconfig.local` | `~/.gitconfig.local`（force） |
| `git/gitignore_global` | `~/.gitignore_global` |

目标已存在但不是期望的软链时：带 `force` 的链接直接替换（无自动备份，在意就手动备份），其余链接报错提示手动处理。

**调整安装行为**：

| 环境变量 | 含义 |
|---|---|
| `DRY_RUN=1` | 只打印将执行的动作，不改动文件系统 |
| `DOTFILES_INSTALL_PKGS=0` | 跳过依赖安装（纯链接/字体/收尾） |

**更新**：`git pull && ./install`，然后开新 shell。

## 拉取 zsh 插件（联网）

`zsh/zshrc` 定义 `zsh_plugin_fetch`，**首次缺件时**从 codeload 拉小 tarball 并缓存：

```
zsh_plugin_fetch <name> <owner/repo> <ref> <entry>
```

* 缓存目录 `$ZSH_PLUGINS_DIR`，默认 `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins`。
* 仅当 `$ZSH_PLUGINS_DIR/<name>/<entry>` 不存在才下载；请求的 ref 失败时回退 `master`/`main`；拉取失败不影响 zsh 启动。

首次拉取的插件：

| 插件 | owner/repo | 默认 ref |
|---|---|---|
| oh-my-zsh | `ohmyzsh/ohmyzsh` | `master` |
| zsh-autosuggestions | `zsh-users/zsh-autosuggestions` | `master` |
| zsh-syntax-highlighting | `zsh-users/zsh-syntax-highlighting` | `master` |

**刷新单个插件**：`rm -rf "$ZSH_PLUGINS_DIR/<name>"`，下次启动重拉。
**离线场景**：把对应 tarball 解压进 `$ZSH_PLUGINS_DIR/<name>/`（结构一致）即可跳过下载。

没有插件管理器：不依赖 `omz update` / `antidote` / `zinit`。

## starship 提示符

```
eval "$(starship init zsh)"        # zshrc 中
~/.config/starship.toml            # → dotfiles/config/starship.toml
```

onedark 风格：紫色目录、绿色分支、黄色 git 状态、Nerd Font 图标（Maple Mono）。
同步计算（无 gitstatus 后台进程），`starship --timings` 可查各段耗时。

## 环境变量

| 名 | 默认 | 含义 |
|---|---|---|
| `ZSH_PLUGINS_DIR` | `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins` | zsh 插件缓存目录 |
| `DRY_RUN` | 空 | 非空时 install 只打印不执行 |
| `DOTFILES_INSTALL_PKGS` | `1` | 置 0 跳过 install 的依赖安装步骤 |

## 机器本地配置（`local/`）

`local/` 在 `.gitignore` 里，仓库只发模板：

```sh
# install 会自动从模板复制缺失文件；随后按需编辑
$EDITOR local/gitconfig.local   # git 身份（gitconfig 的 include!）
$EDITOR local/zshrc.local       # 代理、PATH、API 密钥、机器特有 env
```

**千万别提交** `local/zshrc.local` 和 `local/gitconfig.local`（都已在 `.gitignore`）。

## 已知坑

### Vim 8.1 与 Vim 8.2 的 `set runtimepath` 差异

`vim/vimrc` 同时支持 **Vim 8.1** 和 **8.2**。关键在 `~/.vim/autoload/plug.vim` 加载前的 `set rtp=` 重写：

| 版本 | 行为 |
|---|---|
| Vim 8.1 | `set rtp+=...` 不会报错，但顺序不可控 |
| Vim 8.2 | `set rtp-=X` 在 X 不在 rtp 时抛 `E521` 警告，且 `set rtp=` 整条会**清空**当前 rtp |

`vimrc` 顶部按 `v:version` 分支处理，8.1 / 8.2 都能正常加载 `vim/plugins-vendor/`。

### Tmux + pi agent 的扩展键

tmux 默认把 `Shift+Enter` / `Ctrl+Enter` / `Enter` 上报为同一键，pi agent 无法区分"换行"和"提交"。
`tmux/tmux.conf` 已启用 `extended-keys on` + `extended-keys-format csi-u`（需 tmux 3.5+；本机 3.8）。
改完配置需重启 tmux server（`tmux kill-server`）对新会话生效。

### 字体

`fonts/` 内置 **Maple Mono Nerd Font CN**（16 个字重，覆盖 starship / pi / 各种 Nerd Font 图标）。
install 拷贝到 `~/Library/Fonts`（macOS）或 `~/.local/share/fonts` + `fc-cache`（Linux）；在终端设置里选用 `Maple Mono` 即可。

## 卸载

```sh
cd dotfiles
# 1. 解链
for f in .agents .tmux.conf .vimrc .vim .zshrc .zshrc.local .bashrc \
         .gitconfig .gitconfig.local .gitignore_global; do
  [ -L "$HOME/$f" ] && unlink "$HOME/$f"
done
unlink "$HOME/.config/starship.toml"

# 2. 删运行时产物
rm -rf "${ZSH_PLUGINS_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-plugins}"
rm -rf "$HOME/Library/Fonts"/MapleMono-*.ttf     # 字体（macOS）
```

brew 装的依赖（tmux starship eza …）用 `brew uninstall` 自行处理；`local/` 里的真实配置在仓库内，随仓库删除或先备份。

## 维护提示

* **改 `zsh/zshrc` 插件清单**：删对应 `$ZSH_PLUGINS_DIR/<name>` 触发重拉。
* **改 `vim/plugins-vendor/`**：跑一次 `:PlugClean`。
* **改 `install` 链接表**：重跑 `./install`（force 链接自动替换，非 force 需手动）。
* **改 `tmux/tmux.conf`**：`tmux source-file ~/.tmux.conf`（extended-keys 类改动需重启 server）。
