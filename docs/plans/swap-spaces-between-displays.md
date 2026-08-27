# Plan: Swap focused space with the other display's visible space

## Goal
A single skhd keybind that swaps which monitor the focused space and the other display's currently-visible space live on. Whole-space swap (windows + layout preserved). No space numbers to type.

## Assumptions
- Two displays connected (script no-ops on one).
- yabai scripting addition loaded + partial SIP off - already satisfied (`hosts/mbp/yabai.nix:19-20`; existing `space --destroy` binds prove space ops work).
- yabai indexes spaces globally 1-10 across both displays (existing binds rely on this).

## Mechanics
1. Query focused space: `index` + `display`.
2. Query the other display's visible space `index`.
3. Swap displays, capturing indices/displays before moving (first move shifts state):
   ```bash
   yabai -m space $src --display $dst_disp
   yabai -m space $dst --display $src_disp
   ```
4. Re-focus original space for stable focus.

Edge cases: single display -> clean no-op.

## Implementation
- File: `hosts/mbp/skhd.nix`.
- Add keybind `shift + alt - s` (verified unused; no existing `shift+alt` chords).
- Inline compact `yabai`/`jq` one-liner matching existing style (`skhd.nix:125-160`). No new derivation.

## Verification
- `darwin-rebuild build --flake .#mbp`.
- After apply (explicit go-ahead only): focus a space, press `shift+alt-s`, confirm both visible spaces swap monitors with windows intact; test single-display no-op.

## Risks / notes
- Brief macOS space-transition animation; harmless.
- sketchybar refresh handled by existing yabai signals (`yabai.nix:32-38`).

## Rollback
- Remove the keybind line; rebuild.
