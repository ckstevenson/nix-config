# nix-server Tailscale Services Migration

## Status

Proposed.

## Summary

Move web-service access from Traefik and `*.germerica.us` to private Tailscale Services. Keep Docker Compose as the runtime during the first migration. Use:

- NixOS for host configuration, Tailscale daemon, Serve endpoints, firewall, systemd ordering, and secret file delivery.
- OpenTofu with the Tailscale provider for tailnet control-plane resources: policy, tags, Services, HTTPS, and approvals.
- SOPS + age for Mullvad, Tailscale, and application credentials.

Migrate and validate one service at a time. Do not disable its Traefik route until the Tailscale endpoint has passed acceptance checks.

## Current State

`nix-server` already runs Tailscale, Docker, and the Compose services. Current Tailscale state includes:

- Tailscale IP `100.74.109.93`.
- MagicDNS suffix `tail4e22c.ts.net`.
- Advertised subnet route `10.10.10.0/24`.
- Advertised exit node.
- Tailscale version `1.94.2`.
- `--accept-dns=false` in NixOS configuration.
- No Tailscale Serve configuration.

Migration working assumptions:

- Active Compose definitions copied for inspection live at `/home/cameron/compose` on `nix-server`.
- Docker inspection and Compose commands run as the `cameron` user without `sudo`.
- Existing minute, hourly, and daily ZFS snapshots are the rollback baseline. Do not remove or replace them.
- The first foundation change may be deployed with a NixOS rebuild after reviewing its diff and validation results.

Traefik currently terminates HTTPS on ports `80` and `443`, obtains wildcard certificates for `*.germerica.us`, and routes by hostname. Compose exposes several service ports on all interfaces. NixOS has firewall disabled.

Compose services found:

- Homer/dashboard
- Jellyfin
- Kavita
- Grafana, Prometheus, Alertmanager, speedtest, and blackbox
- MotionEye
- Nextcloud
- Omada
- Pi-hole
- SearXNG
- Transmission, Sonarr, Radarr, Lidarr, and Prowlarr
- Vaultwarden

NixOS also runs Home Assistant, ESPHome, Mosquitto, node exporters, cAdvisor, and ZFS exporters.

## Target Architecture

Create one Tailscale Service per web application. Each Service receives a stable private HTTPS name, for example:

```text
nc.tail4e22c.ts.net
vw.tail4e22c.ts.net
jf.tail4e22c.ts.net
grafana.tail4e22c.ts.net
```

These are Tailscale Service names, not ordinary DNS aliases. Each Service has a TailVIP and is backed by `nix-server` as a tagged Service host. Tailscale terminates HTTPS on port `443` and forwards to a local HTTP backend such as `127.0.0.1:18080`.

Use names without the old domain where possible:

| Existing service | Tailscale Service | Endpoint |
| --- | --- | --- |
| Homer | `svc:dashboard` | `dashboard.tail4e22c.ts.net` |
| Jellyfin | `svc:jf` | `jf.tail4e22c.ts.net` |
| Kavita | `svc:kavita` | `kavita.tail4e22c.ts.net` |
| Grafana | `svc:grafana` | `grafana.tail4e22c.ts.net` |
| Prometheus | `svc:prometheus` | `prometheus.tail4e22c.ts.net` |
| Alertmanager | `svc:alertmanager` | `alertmanager.tail4e22c.ts.net` |
| MotionEye | `svc:motioneye` | `motioneye.tail4e22c.ts.net` |
| Nextcloud | `svc:nc` | `nc.tail4e22c.ts.net` |
| Omada | `svc:omada` | `omada.tail4e22c.ts.net` |
| Pi-hole | `svc:pihole` | `pihole.tail4e22c.ts.net` |
| SearXNG | `svc:searxng` | `searxng.tail4e22c.ts.net` |
| Transmission | `svc:transmission` | `transmission.tail4e22c.ts.net` |
| Sonarr | `svc:sonarr` | `sonarr.tail4e22c.ts.net` |
| Radarr | `svc:radarr` | `radarr.tail4e22c.ts.net` |
| Lidarr | `svc:lidarr` | `lidarr.tail4e22c.ts.net` |
| Prowlarr | `svc:prowlarr` | `prowlarr.tail4e22c.ts.net` |
| Vaultwarden | `svc:vw` | `vw.tail4e22c.ts.net` |

Use Tailscale Services for TCP web traffic only. Keep direct LAN ports for DNS, device discovery, controller adoption, MQTT, and other protocols that cannot be replaced by HTTPS.

## Control-Plane Management

Create `infrastructure/tailscale/` as a standalone OpenTofu root in this repository. Pin the Tailscale provider and OpenTofu version constraints. Keep state local initially on encrypted storage; do not commit `.tfstate`, plans, provider caches, or credentials.

Manage these resources:

- `tailscale_tailnet_settings` with HTTPS enabled.
- `tailscale_acl` containing the complete HuJSON policy.
- `tailscale_device_tags` assigning `tag:server` to `nix-server`.
- `tailscale_service` resources for each migrated web application.

The ACL resource replaces the entire tailnet policy. Import and review existing policy before first managed apply. Add policy tests before enabling external management.

Use grants with least privilege:

- Permit the owner/admin identity and approved personal devices to each migrated Service on TCP `443`.
- Permit `tag:server` to advertise the Services.
- Auto-approve the existing subnet route and exit-node advertisement for `tag:server` if those capabilities are to remain.
- Preserve required Tailscale SSH access.
- Deny access for non-members and shared users unless explicitly required.
- Add policy tests for service access, SSH, route access, and denied access.

One bootstrap action is unavoidable: create a least-privileged Tailscale OAuth client in Trust Credentials. The provider cannot create credentials used to authenticate itself. Store its client ID and secret in SOPS immediately. No subsequent Tailscale console configuration should be required.

Before changing `nix-server` from user-owned to tag-owned, export and verify current node, route, and exit-node state. Re-authenticate only if required, using a tag-scoped credential. Confirm route and exit-node advertisements after the change.

## NixOS Management

Extend `hosts/nix-server/configuration.nix` and use native options:

```nix
services.tailscale = {
  enable = true;
  useRoutingFeatures = "server";
  extraUpFlags = [
    "--advertise-exit-node"
    "--advertise-routes=10.10.10.0/24"
  ];
  serve = {
    enable = true;
    services = {
      # Enabled one service at a time during migration.
      nc = {
        endpoints."tcp:443" = "http://127.0.0.1:18080";
        advertised = false;
      };
    };
  };
};
```

The exact option shape must be confirmed against the pinned nixpkgs revision before implementation. Native NixOS Serve configuration should replace custom systemd scripts.

Set `--accept-dns=true` or remove the explicit false flag after validating the Pi-hole and split-DNS design. MagicDNS must work from MBP and Pixel. Avoid DNS loops if Pi-hole forwards `tail4e22c.ts.net` queries.

Add systemd ordering so Serve starts after Tailscale autoconnect and the corresponding Compose service. A Serve endpoint must not be advertised before its backend is healthy.

Enable the NixOS firewall before removing Traefik. Permit only required traffic:

- SSH from LAN and approved Tailscale sources.
- Tailscale tunnel traffic.
- LAN and Tailscale DNS to Pi-hole.
- Omada controller and discovery/adoption ports on LAN.
- Home Assistant, ESPHome, Mosquitto, and required LAN device traffic.
- Optional Jellyfin discovery ports if those protocols remain needed.
- No public web access after Traefik retirement.

## Secrets

Use SOPS + age, already present in this repository. Do not use Kubernetes Sealed Secrets.

Add encrypted values to a host/service secret file, with paths such as:

```text
mullvad/wireguard_private_key
tailscale/oauth_client_id
tailscale/oauth_client_secret
```

Rotate the plaintext Mullvad key currently present in `compose/servarr/compose.yml` before migration. Remove the old value from Compose and any tracked history where practical.

Expose secrets only at runtime:

- Mullvad key through a root-readable SOPS-rendered file or environment file consumed by the Compose launch process.
- Tailscale OAuth values through environment variables pointing to SOPS-rendered files when OpenTofu runs.
- Application credentials through SOPS-rendered files, never interpolated into Nix derivations or committed Compose `.env` files.

Review OpenTofu provider behavior before first plan. Do not allow sensitive values to enter state. Prefer provider environment variables and OAuth credentials over API keys.

## Repository And Runtime Preparation

1. Copy each active Compose definition into a tracked host-specific location under `hosts/nix-server/compose/`.
2. Preserve current named volumes and bind mounts. Do not recreate or delete data.
3. Define how Compose projects are started and stopped with systemd or an existing host convention.
4. Remove stale comments and invalid indentation while preserving behavior.
5. Replace `latest` images with reviewed versions over time; version pinning is separate from first routing cutover.
6. Remove Traefik labels only after the matching Tailscale Service is accepted.
7. Change web-only host bindings from `0.0.0.0` to unique loopback ports. Keep explicit LAN bindings for services that must remain LAN reachable.

## Migration Sequence

### Foundation

1. Verify existing minute, hourly, and daily ZFS snapshots and record rollback commands. Do not create or remove snapshots for this baseline.
2. Rotate Mullvad key and migrate secrets to SOPS.
3. Add OpenTofu root, provider constraints, and SOPS credential wrapper.
4. Import existing Tailscale policy/settings and inspect the resulting plan.
5. Enable HTTPS in code.
6. Add policy, tags, Services, auto-approvers, and policy tests.
7. Tag/re-authenticate `nix-server` only after validating the plan and preserving route/exit-node behavior.
8. Enable MagicDNS resolution on the server and verify from MBP and Pixel.
9. Enable the NixOS firewall with an explicit LAN/Tailscale allowlist.

### Per-Service Cutover

For every service:

1. Snapshot its data and record current Compose/Traefik configuration.
2. Ensure its Tailscale Service exists in OpenTofu.
3. Assign a unique loopback backend port.
4. Add native Nix Serve configuration with `advertised = false`.
5. Deploy and confirm the local backend is healthy.
6. Advertise the Service and verify Tailscale approval/availability.
7. Test DNS, HTTPS, login, primary workflows, logs, and client behavior from MBP and Pixel.
8. Update application base URL, trusted domains, callback URLs, webhooks, bookmarks, and mobile/desktop clients.
9. Observe for 24-72 hours.
10. Remove only that service's Traefik route and old public binding.
11. Record acceptance evidence and rollback information.

Recommended order:

1. Homer/dashboard as the pilot.
2. Grafana.
3. Prometheus and Alertmanager.
4. SearXNG.
5. Kavita.
6. Jellyfin.
7. Prowlarr, Sonarr, Radarr, Lidarr, and Transmission.
8. MotionEye.
9. Omada.
10. Pi-hole UI while retaining DNS service ports.
11. Nextcloud.
12. Vaultwarden.
13. Home Assistant and ESPHome, if their external/mobile URLs need migration.

## Service-Specific Requirements

- **Homer:** use as the first low-risk Serve and ACL test.
- **Grafana:** set its root URL to the Tailscale hostname; validate links and OAuth/callback settings if present.
- **Prometheus/Alertmanager:** update external URLs and Grafana targets where configured.
- **SearXNG:** set `server.base_url` to its Tailscale hostname.
- **Jellyfin:** validate clients, transcoding, and any DLNA/discovery requirement before removing LAN exposure.
- **Servarr:** preserve `network_mode: service:gluetun`; Tailscale should proxy the host-published backend ports without bypassing Mullvad for application egress. Validate Transmission and indexer connectivity after secret migration.
- **MotionEye:** validate camera streams and LAN camera access.
- **Omada:** retain host networking and all required controller/adoption/discovery ports on LAN. Only its web UI moves behind Tailscale.
- **Pi-hole:** retain `53/tcp` and `53/udp` on LAN and Tailscale as required. Only its web UI moves behind Tailscale. Prevent MagicDNS forwarding loops.
- **Nextcloud:** configure `trusted_domains`, `overwrite.cli.url`, `overwriteprotocol`, and trusted proxy behavior. Test web UI, WebDAV, desktop sync, mobile sync, cron, previews, and `.well-known` redirects.
- **Vaultwarden:** set the external `DOMAIN` to the Tailscale hostname. Test login, clients, invitations, WebSocket notifications, and attachments. Route UI and `/notifications/hub` through the same HTTPS Service.
- **Home Assistant:** preserve LAN integrations and MQTT. Update mobile app/webhook URL only after testing notification links and trusted proxy settings.
- **ESPHome:** preserve device discovery and LAN access; migrate dashboard UI separately.

## LAN DNS

Tailscale names are for tailnet clients. LAN-only clients cannot resolve or reach TailVIPs unless they also run Tailscale.

Keep LAN service access through the server's LAN address and Pi-hole. Update Pi-hole/local DNS records only where a LAN hostname is useful. Do not point LAN records at Tailscale-only names unless the LAN client can route to Tailscale and resolve MagicDNS.

During transition, retain old `germerica.us` records as rollback aliases. Remove them only after application clients and integrations no longer use them.

## Rollback

Per service:

1. Set the Tailscale Serve endpoint `advertised = false` and drain the Service if applicable.
2. Restore its prior LAN/public host binding.
3. Restore its Traefik labels/router.
4. Redeploy the Compose project without changing volumes.
5. Restore application URL settings if required.
6. Use the service snapshot only if data corruption occurred.

Foundation rollback:

- Keep local route/exit-node state evidence before tagging.
- Restore prior Tailscale authentication only after confirming the device identity consequences.
- Do not destroy OpenTofu resources or reset the tailnet policy during an incident.
- Keep Traefik and Cloudflare credentials available until final retirement acceptance.

## Traefik Retirement Criteria

Retire Traefik only when:

- Every required web UI has an accepted Tailscale Service.
- MBP and Pixel can reach each required Service over HTTPS.
- LAN-only protocols still work from relevant devices.
- No application, webhook, mobile client, desktop client, or bookmark uses `germerica.us`.
- No service requires public internet access. If one does, explicitly evaluate Funnel or retain another public ingress path.
- Tailscale ACL tests pass and service advertisements survive reboot.
- NixOS firewall rules are active and verified.
- Backups and ZFS snapshots have been tested.

Then stop Traefik, close router forwards for `80/443`, remove Cloudflare API credentials, archive Traefik ACME data, and remove old DNS records after a defined retention period.

## Validation Commands

From `infrastructure/tailscale/`:

```bash
tofu fmt -check
tofu init
tofu validate
tofu plan
```

Do not run `tofu apply` from automation without explicit operator approval. Review all create/update/destroy actions, especially ACL replacement, device tagging, and Service changes.

From repository root:

```bash
nix flake check --show-trace
nixos-rebuild build --flake .#nix-server
```

After reviewing the first foundation change, it may be deployed with:

```bash
sudo nixos-rebuild switch --flake .#nix-server
```

Run Docker and Compose inspection as `cameron`, without `sudo`, using Compose definitions under `/home/cameron/compose`.

On `nix-server` and clients, verify:

```bash
tailscale status --json
tailscale serve status --json
ss -ltnup
```

For each cutover, record:

- Service DNS resolution.
- Valid HTTPS certificate.
- ACL authorization result.
- Application smoke-test result.
- LAN protocol checks.
- Listener bind addresses.
- Container and systemd health.
- Rollback readiness.

## Later Improvements

After routing is stable:

- Move OpenTofu state and execution to a dedicated repository or CI workflow.
- Consider GitHub workload identity federation instead of stored OAuth secrets.
- Split service Compose definitions into a dedicated repository if desired.
- Replace Compose stacks with Nix-managed OCI/systemd units selectively.
- Pin image versions and add automated update review.
- Revisit whether all services need Tailscale Services or whether direct LAN/Tailscale ports are simpler for low-risk tools.
