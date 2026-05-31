# Using 1Password for API Keys and Secrets

This document covers secure approaches for accessing secrets from 1Password without triggering biometric prompts on every shell startup.

## Why Not Load Keys in Shell Init?

Loading secrets in `.zshrc` or shell initialization causes:
- Biometric prompt on every new terminal window/tab
- Secrets persist in memory for all shell processes
- Added latency to shell startup

## Recommended Approaches

### 1. Tool-Specific Key Storage

Many tools have their own secure key storage. Use these instead of environment variables.

**llm (Python LLM CLI)**
```bash
# Store keys once, used automatically
llm keys set openai
llm keys set anthropic
```

**GitHub CLI**
```bash
gh auth login
```

**AWS CLI**
```bash
aws configure
# Or use 1Password's AWS shell plugin
```

### 2. On-Demand Helper Functions

Add functions to your shell config that you call explicitly when needed:

```bash
# Add to zsh initContent in home-manager.nix
load-ai-keys() {
  export OPENAI_API_KEY=$(op read "op://Private/OpenAI API key/credential")
  export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API Key/credential")
  echo "API keys loaded for this session"
}
```

Usage:
```bash
$ load-ai-keys  # Prompts for biometric once
$ python my_script.py  # Uses the exported keys
```

### 3. Per-Project with direnv

Load secrets only when entering specific project directories.

**Setup:**
```bash
# Install direnv (already in packages.nix)
# Add to shell: eval "$(direnv hook zsh)"
```

**Create `.envrc` in your project:**
```bash
# .envrc
export OPENAI_API_KEY=$(op read "op://Private/OpenAI API key/credential")
export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API Key/credential")
```

```bash
$ cd my-ai-project
direnv: loading .envrc
# Biometric prompt once when entering directory
```

### 4. 1Password Shell Plugins

1Password has official integrations for AWS, GitHub, and other CLIs.

```bash
# Install the plugin
op plugin init aws

# Now `aws` commands use 1Password automatically
```

See: https://developer.1password.com/docs/cli/shell-plugins/

### 5. Secret References in Config Files

Some tools support 1Password references directly in config files:

```yaml
# config.yaml
api_key: op://Private/OpenAI API key/credential
```

Then run with:
```bash
op run -- mycommand
```

### 6. SSH Agent Integration

For SSH keys, 1Password can act as an SSH agent:

1. Enable SSH Agent in 1Password Settings > Developer
2. Add to `~/.ssh/config`:
   ```
   Host *
     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
   ```

## Quick Reference

| Use Case | Recommended Approach |
|----------|---------------------|
| LLM/AI tools | `llm keys set` |
| One-off scripts | `load-ai-keys` function |
| Project-specific | direnv with `.envrc` |
| AWS/GitHub CLI | 1Password shell plugins |
| SSH keys | 1Password SSH agent |
| CI/CD | `op run` with secret refs |

## Resources

- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
- [1Password Shell Plugins](https://developer.1password.com/docs/cli/shell-plugins/)
- [direnv](https://direnv.net/)
