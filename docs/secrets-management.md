# Secrets Management

Overview of how secrets are handled in this repository.

SOPS + age

- Secrets live in `secrets/` and are encrypted with SOPS using age keys.
- To edit secrets:

```bash
sops secrets/secrets.yaml
```

- To generate an age key:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

SSH keys

- SSH keys are defined in modules and deployed to `~/.ssh/authorized_keys` via the module system.
- Multiple keys and key roles are supported.

If secrets are missing

- Flake evaluation or machine rebuilds may fail if required secrets are not available. Ensure age keys are present and accessible to SOPS.
