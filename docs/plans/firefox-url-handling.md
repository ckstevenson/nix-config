# Firefox URL Handling on macOS

## Goal

Make Firefox URL handling reliable on the `mbp` host without shell aliases or
forced Firefox profiles.

Required behavior:

- `open -a Firefox -- URL` resolves to the managed Nix Firefox application.
- `BROWSER=firefox` remains the shell/browser preference for tools that honor
  it.
- `open URL` and links from other applications resolve through macOS
  LaunchServices to the current managed Firefox application.
- Alacritty URL hints and 1Password SSO preserve URL arguments.
- Firefox upgrades do not leave LaunchServices pointing at stale Nix store
  paths or the broken Homebrew wrapper.

## Findings

### Shell command and macOS URL handling are separate

On Darwin, Nix Firefox supplies an application bundle rather than a shell
`bin/firefox` command. `open URL` and links from other applications use
LaunchServices. `BROWSER=firefox` is advisory only.

Historical shell command lookup used `PATH`. It did not use `BROWSER`, and it
did not consult LaunchServices. The old result was:

```text
/opt/homebrew/bin/firefox
```

That Homebrew wrapper points to the removed application:

```text
/Applications/Firefox.app/Contents/MacOS/firefox
```

`BROWSER=firefox` is already configured in `hosts/mbp/home.nix`. It should be
preserved, but it cannot repair the stale executable found by `PATH`.

macOS `/usr/bin/open URL` uses LaunchServices. It ignores `BROWSER` and needs a
valid registered `http`/`https` application handler.

### Nix Firefox profile state

Firefox uses the native macOS profile directory:

```text
~/Library/Application Support/Firefox
```

The managed configuration now sets:

```nix
profileVersion = 2;
profiles.cameron.storeId = "0111914c";
```

This must remain. It prevents each Nix store-path change from being treated as
a new Firefox installation and avoids selecting an unintended `*.default`
profile.

### LaunchServices state

Nix Firefox bundles share `org.nixos.firefox` across versions. `mac-app-util`
also creates a Home Manager application wrapper whose target can become stale
and whose URL argument forwarding is unreliable.

The previous launcher attempt failed because activation deleted its own managed
bundle after Home Manager linked it. The permanent implementation keeps the
launcher declarative, registers it after linking, and forwards `"$@"` to the
current Firefox executable. It uses `duti` declaratively for only `http` and
`https`, and does not force a Firefox profile.

## Implementation Plan

### 1. Remove stale Homebrew Firefox command

Confirm the Homebrew cask and wrapper before changing anything:

```sh
type -a firefox
ls -l /opt/homebrew/bin/firefox
brew list --versions firefox
```

Remove only the stale Firefox cask. Do not enable broad Homebrew cleanup, and
do not remove unrelated casks:

```sh
brew uninstall --cask firefox
```

The declarative Homebrew list already does not contain Firefox. Document this
as a one-time cleanup rather than adding a permanent shell wrapper or alias.

After cleanup, verify that the managed app is present:

```sh
ls -ld "$HOME/Applications/Firefox.app"
open -a Firefox -- 'https://example.com'
```

Do not add a direct store-path shell alias. The app launcher is the stable
entrypoint.

### 2. Keep browser environment configuration

Retain:

```nix
BROWSER = "firefox";
```

Retain the Homebrew path because other Homebrew tools use it. Do not remove the
entire `/opt/homebrew/bin` path merely to hide Firefox. The stale Firefox
executable must be removed at its source.

Update documentation to state that `BROWSER` is advisory and applies only to
programs that honor it. It does not control `/usr/bin/open`.

### 3. Register stable launcher app

Add a small Darwin-only Home Manager activation step in
`modules/home-manager/desktop/firefox.nix`:

1. Wait until Home Manager has linked the current generation.
2. Unregister the current `Home Manager Apps/Firefox.app` wrapper when it is
   present.
3. Register `~/Applications/Firefox.app`, whose stable bundle ID is
   `org.nixos.firefox-launcher`.
4. Ignore missing paths so first activation and non-Darwin hosts remain safe.

Use the existing macOS `lsregister` tool. Do not:

- use `lsregister -kill` or reset the whole LaunchServices database;
- create `/Applications/Firefox.app` symlinks;
- register arbitrary historical `/nix/store` Firefox paths;
- set handlers manually through `duti` or `defaultbrowser`;
- force a profile from the launcher;
- pass `-P` or otherwise force a profile during URL handling.

The current default handler should remain Firefox, while LaunchServices is
given the current real bundle instead of the argument-dropping wrapper.

### 4. Preserve and verify Alacritty behavior

Keep Darwin Alacritty hints using `/usr/bin/open` with the URL supplied by
Alacritty. Nix source must render regex `\s` and `\^` as one backslash in TOML;
rendered `\\s` makes `s` act as a delimiter and truncates URLs such as
`https://app.wiz.io/findings/code-cicd-scans#~(event~(~%27006a8038`.
Test regex hints and OSC 8 hyperlinks separately. `post_processing` may strip
trailing punctuation, and regex hints only scan visible terminal text.

Verify direct LaunchServices path:

```sh
open "https://example.com/?source=open"
```

Then activate both regex and OSC 8 HTTPS hints in Alacritty and confirm the
exact URL opens in the managed `cameron` profile.

### 5. Verify profile and SSO behavior

Check generated profile metadata:

```sh
grep -E 'StoreID|Version' \
  "$HOME/Library/Application Support/Firefox/profiles.ini"
```

Expected values:

```text
Version=2
StoreID=0111914c
```

Test:

- an HTTP URL;
- an HTTPS URL with query parameters;
- an Alacritty URL hint;
- a 1Password SSO handoff and native `onepassword://` return;
- a normal Firefox launch with no URL;
- `open -a Firefox -- URL` from a fresh shell.

### 6. Test across Firefox updates

The failure mode is store-path rotation, so one successful rebuild is not
enough. After a Firefox input/package update:

1. Build and activate the new generation.
2. Confirm `open -a Firefox -- 'about:version'` opens current Nix Firefox.
3. Dump LaunchServices entries and confirm the current real bundle is present.
4. Confirm the old store path is not the selected handler.
5. Repeat `open URL`, Alacritty, and SSO tests.

Do not remove old Nix store paths manually. Nix garbage collection owns their
lifecycle.

## Documentation Changes

Update `docs/firefox-url-launcher.md` to become the authoritative operational
guide. It should explain:

- shell `PATH` lookup versus macOS LaunchServices;
- the stale Homebrew wrapper and one-time cask cleanup;
- why `BROWSER=firefox` is retained but does not affect `open URL`;
- native Firefox `StoreID` profile handling;
- current real-bundle LaunchServices registration;
- rejected launcher, `duti`, forced-profile, symlink, and database-reset
  approaches;
- rebuild, update, and rollback verification commands.

Update `docs/README.md` with a link to this plan and the operational Firefox
guide.

Update `hosts/mbp/README.md` so its shell section distinguishes `BROWSER` from
macOS's default application handler.

Document stable launcher lifecycle, URL argument forwarding, and declarative
HTTP/HTTPS handler registration. Do not describe the launcher as a forced
profile wrapper.

## Validation

Before activation:

```sh
nix-instantiate --parse modules/home-manager/desktop/firefox.nix >/dev/null
nix flake check --show-trace
darwin-rebuild build --flake .#mbp
git diff --check
```

Inspect only intended Firefox, Homebrew, and documentation changes. Preserve
unrelated worktree modifications.

Apply only after explicit confirmation:

```sh
sudo darwin-rebuild switch --flake .#mbp \
  --override-input opencode-config path:../opencode-config
```

After applying, restart affected shell sessions so `PATH` reflects removal of
the Homebrew wrapper. Do not perform a whole-system apply without confirmation.

## Rollback

If URL handling or SSO regresses:

1. Revert to the previous Darwin generation using the normal nix-darwin
   rollback mechanism.
2. Do not bypass the stable launcher or delete Firefox profiles.
3. Preserve the Firefox profile directory and inspect LaunchServices entries.
4. Restore the prior Homebrew cask only if the Nix command itself is missing,
   not as a fix for `open URL`.

Profile data, extensions, and bookmarks must remain untouched during rollback.
