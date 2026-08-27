# Firefox URL handling on macOS

## Routing

`/usr/bin/open URL` and links from other applications use LaunchServices.
`BROWSER=firefox` is advisory for programs that honor it. On Darwin, the Nix
Firefox package supplies an application bundle, not a `bin/firefox` shell
command; launch Firefox with `open -a Firefox -- URL` or the managed app picker.

Home Manager installs a stable `Firefox.app` with bundle ID
`org.nixos.firefox-launcher`. Its executable
forwards every URL argument to the current Nix Firefox binary and appears as
Firefox in application pickers.
Activation unregisters mac-app-util's argument-dropping trampoline, registers
the stable launcher, and selects it for HTTP/HTTPS when it is not already the
selected handler. This check avoids repeated default-handler writes during
rebuilds.

On macOS 26, LaunchServices may reject programmatic default-browser changes
with error `-54`. If activation prints the Firefox URL-handler guidance, select
Firefox once in System Settings > Apps > Default web browser. Later rebuilds
will detect the existing handler and stay quiet.

No reboot is required after activation. Quit and reopen Firefox, Alacritty, and
other callers if they were already running. Open System Settings > Desktop &
Dock > Default web browser and select Firefox once if macOS still has an old
handler preference.

## Profile stability

Firefox uses `~/Library/Application Support/Firefox` on macOS. Managed config
sets `profileVersion = 2` and `profiles.cameron.storeId = "0111914c"`.
Verify after rebuild:

```sh
grep -E 'StoreID|Version' "$HOME/Library/Application Support/Firefox/profiles.ini"
```

Expected: `Version=2` and `StoreID=0111914c`.

## Alacritty URL Hints

Alacritty has two URL discovery paths:

- Regex hints scan visible terminal text. Alt-L selects a match and passes it as
  the final argument to the configured command.
- OSC 8 hyperlinks are included because `hyperlinks = true`; these may work
  even when visible text does not match the regex.

On Darwin, configured command is `/usr/bin/open`. Alacritty does not choose
Firefox, parse URL fragments, or repair malformed matches. `/usr/bin/open`
passes its URL to LaunchServices, which selects stable `Firefox.app`.

Regex escaping has two layers. Nix source must contain `\s` and `\^`, and the
rendered TOML must contain one backslash:

```toml
regex = '...(?:)[^\u0000-\u001F\u007F-\u009F<>"\s{-}\^⟨⟩`\\]+'
```

Rendered config must not contain `\\s` or `\\^`. In a TOML literal string,
those are two literal backslashes and can make `s` or `^` behave as URL
boundaries. Malformed `\\s` truncated this Wiz URL:

```text
https://app.wiz.io/findings/code-cicd-scans#~(event~(~%27006a8038
```

`post_processing = true` removes likely trailing punctuation. It does not
understand every site's fragment grammar, so verify long URLs containing `#`,
`~`, parentheses, percent encoding, apostrophes, and query strings. Regex hints
only see visible terminal text and stop at whitespace, control characters,
angle brackets, quotes, braces, backslash, caret, and configured Unicode
delimiters. OSC 8 is preferred for exact long links.

After changing this config, restart Alacritty or reload its config, then test:

```sh
open 'https://app.wiz.io/findings/code-cicd-scans#~(event~(~%27006a8038'
```

Inspect generated config before activation:

```sh
rg 'regex = ' "$HOME/.config/alacritty/alacritty.toml"
```

## One-time Homebrew cleanup

The declarative Homebrew list does not install Firefox. If an old Homebrew cask
or wrapper remains, remove only that cask. This fixes shell command lookup; it
does not control `open URL`:

```sh
type -a firefox
ls -l /opt/homebrew/bin/firefox
brew list --versions firefox
brew uninstall --cask firefox
```

Do not remove unrelated packages. Start a new shell after cleanup. Expected:
`type -a firefox` shows the Home Manager/Nix command, not
`/opt/homebrew/bin/firefox`.

## LaunchServices diagnosis

Use these commands after activation:

```sh
ls -ld "$HOME/Applications/Firefox.app"
open -a Firefox -- 'https://example.com'
open 'https://example.com/?source=open'
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LSREGISTER" -dump | grep -A 8 -B 2 'handlerpref id:.*https'
grep -E 'StoreID|Version' "$HOME/Library/Application Support/Firefox/profiles.ini"
```

The selected handler should be `org.nixos.firefox-launcher`. Do not reset the
LaunchServices database or manually delete Nix store paths.

## Verification

```sh
nix-instantiate --parse modules/home-manager/desktop/firefox.nix >/dev/null
nix flake check --show-trace
darwin-rebuild build --flake .#mbp
git diff --check
```

After explicitly approved activation, test `open -a Firefox -- URL`,
`open 'https://example.com/?source=open'`, Alacritty URL hints, 1Password SSO
and native `onepassword://` return, normal Firefox launch, and the exact Wiz
URL above. Repeat after Firefox updates; do not delete old Nix store paths.
Roll back through normal nix-darwin generation mechanism if needed.

## Rejected approaches

Do not use `/Applications` symlinks, LaunchServices database resets, forced
profiles, or historical Nix store-path registrations. The upstream
`mac-app-util/link-contents` branch has reports of fixing URL arguments, but
remains unmerged and has documented Launchpad/Spotlight/icon regressions; do
not pin it for this fix. `duti` is used only declaratively to select the stable
launcher for HTTP/HTTPS, not as an ad-hoc manual repair.
