# nix-server Memory Management

## Findings

The 32 GiB `nix-server` host has no configured swap and no explicit ZFS ARC
limit. ZFS ARC currently consumes roughly 22 GiB and can grow toward roughly
30 GiB. User-space services consume roughly 5 GiB combined, with Jellyfin,
Home Assistant, Prometheus, SearXNG, and Apache among the largest consumers.

Relevant configuration:

- `hosts/nix-server/configuration.nix` enables ZFS pools `apps` and `tank`.
- Docker uses the ZFS storage driver.
- `hosts/nix-server/hardware-configuration.nix` declares no swap devices.
- No zram or systemd-oomd configuration is present.

ZFS pools are healthy. ARC hit rate is excellent, and no recent OOM or kernel
memory warnings were found. The issue is insufficient memory headroom, not a
currently identified runaway process.

## Recommended Changes

### 1. Cap ZFS ARC

Add to `hosts/nix-server/configuration.nix`:

```nix
boot.extraModprobeConfig = ''
  options zfs zfs_arc_max=8589934592
'';
```

This caps ARC at 8 GiB and leaves substantially more RAM available for
services. Validate the resulting ARC size after reboot.

### 2. Add compressed emergency swap

Add:

```nix
zramSwap = {
  enable = true;
  memoryPercent = 25;
  algorithm = "zstd";
};
```

This provides up to roughly 8 GiB of compressed swap without disk wear. It is
an emergency buffer, not a replacement for ARC tuning.

### 3. Enable systemd-oomd

Add:

```nix
systemd.oomd = {
  enable = true;
  enableRootSlice = true;
  enableSystemSlice = true;
  enableUserSlices = true;
};
```

This provides controlled process eviction under sustained memory pressure,
reducing the risk of an uncontrolled kernel OOM event.

## Optional Follow-up

The ZFS datasets currently use `primarycache=all`. If ARC pressure remains
after the cap and zram changes, consider setting `primarycache=metadata` for
mostly sequential datasets such as `tank/videos` and possibly `tank/games`.
Keep `primarycache=all` for application databases and Docker data unless
measurement supports changing them.

Avoid per-service memory limits until service growth is observed. Apply those
limits only to the specific service that exhibits abnormal growth.

## Rollout Order

1. Add the ARC cap.
2. Add zram.
3. Enable systemd-oomd.
4. Build and validate the NixOS configuration.
5. Apply and reboot during a maintenance window.
6. Verify ARC size, zram status, available memory, and service health.
7. Tune dataset cache policy only if needed.

## Verification

```bash
cat /sys/module/zfs/parameters/zfs_arc_max
awk '/^(size|c|max)/ {print}' /proc/spl/kstat/zfs/arcstats
zramctl
free -h
systemctl status systemd-oomd
zpool status -x
```

Do not edit the generated `hardware-configuration.nix` for these changes.
