# x-cmd-action/ssh

> Pure-shell **ssh-agent setup** + **known_hosts** + **key add**. No Node.js, no x-cmd needed.

[中文文档](./README.cn.md)

## What it does

Mirrors the ssh init step from `x-cmd/action`, factored out as a standalone action:

1. Starts `ssh-agent`
2. Creates `~/.ssh` (mode 700)
3. Fetches `known_hosts` from `x-cmd/knownhost` (override via `known-hosts-url`)
4. Adds the user-supplied `ssh-key` to the agent (only when provided)

## Usage

```yaml
steps:
  - uses: x-cmd-action/ssh@v1
    with:
      ssh-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

Any input can be omitted:

| Input set | Behavior |
| --- | --- |
| `ssh-key` only | agent starts + known_hosts + key loaded |
| Nothing | agent starts + known_hosts (no key added) |
| `known-hosts-url: '...'` | override the default `x-cmd/knownhost` URL |

## How it's wired

```yaml
# action.yml (excerpt)
runs:
  using: composite
  steps:
    - shell: bash
      env:
        INPUT_SSH_KEY: ${{ inputs.ssh-key }}
        INPUT_KNOWN_HOSTS_URL: ${{ inputs.known-hosts-url }}
        INPUT_STRICT: ${{ inputs.strict }}
      run: bash ${{ github.action_path }}/lib/ssh.sh
```

```bash
# lib/ssh.sh (excerpt)
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

## License

Apache 2.0 — see [`LICENSE`](LICENSE).

## Related

- [x-cmd/action](https://github.com/x-cmd/action) — the parent this was extracted from.
- [x-cmd-action/docker](https://github.com/x-cmd-action/docker) — sibling Layer 1 action.
- [x-cmd-action/checkout](https://github.com/x-cmd-action/checkout) — sibling Layer 1 action.
- [x-cmd-action/x-cmd](https://github.com/x-cmd-action/x-cmd) — install x-cmd.
- [x-cmd-action/.github](https://github.com/x-cmd-action/.github) — org profile + roadmap.