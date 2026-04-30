# `local/` —— 仅本机使用

这个目录里的文件 **不入库**（在根 `.gitignore` 里）。仓库只发模板：

- `env.zsh.example`           —— 本机 zsh 环境模板
- `gitconfig.local.example`   —— Git 身份模板

## 使用

第一次跑 `./install` 时，`scripts/install.sh` 会自动把缺失的模板复制成真实文件（即 `local/gitconfig.local`）。`local/env.zsh` 不会自动创建——只有需要时手动从模板拷一份：

```bash
cp local/env.zsh.example local/env.zsh
$EDITOR local/env.zsh   # 改代理、PATH、密钥、DISPLAY 等
```

新开一个 zsh 即可生效——`zsh/zshrc` 在最后通过 `$DOTFILES/local/env.zsh` 来 source 这个文件。

## Git 身份

```bash
$EDITOR local/gitconfig.local   # 把 user.name / user.email 改成你自己的
```

`git/gitconfig` 里有 `[include] path = ~/.gitconfig.local`，而 `~/.gitconfig.local` 是 `./install` 创建的指向 `local/gitconfig.local` 的软链——所以改一次就生效。

## 千万别提交

- `local/gitconfig.local`
- `local/env.zsh`

这两个都已经写在 `.gitignore` 里。
