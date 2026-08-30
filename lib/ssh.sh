#!/usr/bin/env bash
# x-cmd-action/ssh — pure-shell implementation.
# Extracted from x-cmd/action's ___x_cmd_ghaction_init_ssh_key (lib/index.sh).

set -euo errexit

echo "ssh: loading ssh-agent and creating ~/.ssh + adding known_hosts"

# Start agent.
eval "$(ssh-agent)"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Fetch known_hosts (x-cmd's public list, but overrideable).
# curl may fail on offline runners; don't error out.
curl -fsSL "$INPUT_KNOWN_HOSTS_URL" >> ~/.ssh/known_hosts 2>/dev/null || true
chmod 600 ~/.ssh/known_hosts

# Strict mode (default on).
if [ "$INPUT_STRICT" != "true" ]; then
    cat > ~/.ssh/config <<EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
fi

# Skip key-add when no key provided — agent + known_hosts still useful.
if [ -z "$INPUT_KEY" ]; then
    exit 0
fi

printf '%s\n' "$INPUT_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa >/dev/null