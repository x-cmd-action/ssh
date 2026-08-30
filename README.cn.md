# x-cmd-action/ssh

> 纯 shell 的 **ssh-agent setup** + **known_hosts** + **key add**。不依赖 Node.js，不依赖 x-cmd。

[English](./README.md)

## 做什么

把 `x-cmd/action` 的 ssh init 步骤抽出来，独立成 action：

1. 启动 `ssh-agent`
2. 建 `~/.ssh`（权限 700）
3. 从 `x-cmd/knownhost` 拉 `known_hosts`（可通过 `known-hosts-url` 覆盖）
4. 把用户传的 `key` 加到 agent（只在给了 key 的时候）

## 用法

```yaml
steps:
  - uses: x-cmd-action/ssh@v1
    with:
      key: ${{ secrets.SSH_PRIVATE_KEY }}
```

任意 input 都可以省：

| 给了哪些 | 行为 |
| --- | --- |
| 只给 `key` | agent 起来 + known_hosts + key 加载 |
| 都不给 | agent 起来 + known_hosts（不加载 key）|
| `known-hosts-url: '...'` | 覆盖默认 `x-cmd/knownhost` URL |

## 命名约定

这个 action 用**无前缀**的 input 名（`key`、`username`、`password`、`strict`），不是 `ssh_key`、`ssh_strict`。原因：

- 范围窄：这个 action 只管 ssh。`key` 没歧义，因为作用域里没别的东西。
- action 名字本身就是用户的"作用域前缀"。
- 无前缀读起来自然：`with: key: ${{ secrets.X }}` vs `with: ssh_key: ...`。

`x-cmd/action` 用前缀（`ssh_key`），是因为它 17 个 input 跨 ssh/git/docker/artifact —— 那里前缀是消歧用的。本 org 的独立 action 走无前缀约定。

## 接线方式

```yaml
# action.yml（节选）
runs:
  using: composite
  steps:
    - shell: bash
      env:
        INPUT_KEY: ${{ inputs.key }}
        INPUT_KNOWN_HOSTS_URL: ${{ inputs.known-hosts-url }}
        INPUT_STRICT: ${{ inputs.strict }}
      run: bash ${{ github.action_path }}/lib/ssh.sh
```

```bash
# lib/ssh.sh（节选）
eval "$(ssh-agent)"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl -fsSL "$INPUT_KNOWN_HOSTS_URL" >> ~/.ssh/known_hosts 2>/dev/null
[ -z "$INPUT_SSH_KEY" ] || {
    printf '%s\n' "$INPUT_SSH_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa
}
```

## 许可证

Apache 2.0 —— 见 [`LICENSE`](LICENSE)。

## 相关链接

- [x-cmd/action](https://github.com/x-cmd/action) —— 本 action 的来源
- [x-cmd-action/docker](https://github.com/x-cmd-action/docker) —— 同级 Layer 1 action
- [x-cmd-action/checkout](https://github.com/x-cmd-action/checkout) —— 同级 Layer 1 action
- [x-cmd-action/x-cmd](https://github.com/x-cmd-action/x-cmd) —— 装 x-cmd
- [x-cmd-action/.github](https://github.com/x-cmd-action/.github) —— org 主页 + 路线图