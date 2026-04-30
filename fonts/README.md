# 字体 —— MesloLGS NF

本目录的 TTF 来自 [romkatv/powerlevel10k-media](https://github.com/romkatv/powerlevel10k-media)，是 Powerlevel10k 官方推荐的 Powerline / 图标字形字体。

## 入库的内容

- **`MesloLGS NF *.ttf`** （4 个字形：Regular / Bold / Italic / Bold Italic）—— **入库**，确保任何机器克隆后立刻可用，不需要联网。
- **`MesloLGS NF License.txt`** —— Apache 2.0；分发字体时一起带上。

`fonts/.uuid` 是 fontconfig 运行时自己生成的，已经在 `.gitignore` 里。

## 仓库里没有 TTF？

如果是从干净的 `git clone`，4 个 TTF 应该都已经在仓库里。如果不在（比如老的 sparse checkout 排除了），从一台已经下载过的机器复制过来再提交：

```bash
git add fonts/MesloLGS\ NF\ *.ttf fonts/MesloLGS\ NF\ License.txt
git commit -m "Add MesloLGS NF fonts"
```

## `./install` 行为

`scripts/install-meslo-fonts.sh` **完全不联网**，只校验 `fonts/` 下 4 个 TTF 都存在且体积合理。
如果你想从机器上别处的目录把字体拷进来：`MESLO_FONT_SOURCE_DIR=/path/to/fonts bash scripts/install-meslo-fonts.sh`。
完全跳过这一步：`SKIP_MESLO_FONTS=1 ./install`。

## 服务器 vs IDE

| 哪里                               | 作用                                                                       |
|------------------------------------|----------------------------------------------------------------------------|
| **`fonts/`** + `~/.fonts` + `fc-cache` | 服务器本地 GUI 终端用（fontconfig）                                       |
| **Cursor / VS Code（你 PC）**      | IDE 集成终端仍然要在那台机器上**安装** MesloLGS NF，并在 `terminal.integrated.fontFamily` 里指定 —— 见根 README.md |
