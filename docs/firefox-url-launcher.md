Problem
- Nix Firefox bundles share CFBundleIdentifier across versions. mac-app-util creates trampolines pointing at store paths that change on updates. Result: LaunchServices resolves HTTP/HTTPS to stale bundle → URL open fails.

Root cause
- Previous fix copied launcher from Nix store into ~/Applications via cp -R. That copy preserved store-derived permissions (read-only directories), so later activations could not rm -rf the bundle (permission denied). Activation entered loop.

Solution implemented
- Made launcher fully declarative under Home Manager using home.file entries:
  - Applications/Firefox Launcher.app/Contents/Info.plist — written as plain text
  - Applications/Firefox Launcher.app/Contents/MacOS/launcher — text executable that execs current Firefox binary and forwards "$@"
- Removed cp -R and rm -rf from activation.
- Added one-time guarded cleanup during activation: chmod -R u+w + rm -rf on existing ~/Applications/Firefox Launcher.app (best-effort, ignores failures). This removes stale read-only store copy so Home Manager can place managed files.
- Activation registers launcher with LaunchServices (lsregister) and pins default handlers with duti (id: org.nixos.firefox-launcher) only when not already set.

Why this works
- home.file writes real files under ~/Applications (not symlink to store). Files owned/writable by user; future activations can update them idempotently.
- Launcher uses stable bundle identifier org.nixos.firefox-launcher and forwards args to current finalPackage Firefox binary; launcher survives Firefox version bumps and GC.

One-time impact
- First darwin-rebuild switch runs guarded cleanup. If stale read-only launcher exists, it will be removed. If not, cleanup is no-op.
- After switch, LaunchServices will know the stable launcher. macOS may show one-time default-browser security prompt when user first approves the new handler; subsequent activations won't re-show it because duti check is idempotent.

How to verify
1. Run: nix-instantiate --parse modules/home-manager/desktop/firefox.nix
2. Run repo verify (optional): nix run .#verify or bash scripts/verify-opencode-config.sh
3. Apply on mac host: sudo darwin-rebuild switch --flake .#mbp --override-input opencode-config path:../opencode-config
4. After switch completes:
   - Check ~/Applications/Firefox Launcher.app exists and is not a symlink
   - Check Info.plist contains bundle id org.nixos.firefox-launcher
   - Run: duti -d https → should print org.nixos.firefox-launcher
   - Click an http/https link from another app; URL should open in Firefox with managed profile
5. Re-run darwin-rebuild switch to confirm idempotency (no permission errors or repeated prompt)

Reverting
- To revert, remove home.file entries and restore previous activation block (not recommended). Manual cleanup may be needed: rm -rf ~/Applications/Firefox Launcher.app; then re-run darwin-rebuild.

Notes
- This approach keeps lifecycle declarative and avoids imperative file copying into user tree.
- If you prefer a bundle built via pkgs.runCommand (single artifact) and then copied recursively, that works too — but declarative home.file is simpler and avoids store-mode permission traps.

Contact
- If activation still errors, paste darwin-rebuild logs and output of: ls -la "$HOME/Applications/Firefox Launcher.app" and stat Info.plist
