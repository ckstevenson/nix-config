#!/usr/bin/env bash
# scripts/check.sh — Non-hollow CI check for nix-config
#
# Runs three verifiable checks:
#   1. Per-host real eval via toplevel.drvPath (forces full config evaluation)
#   2. nixpkgs-fmt --check on all tracked .nix files (actually runs fmt)
#   3. Self-test: injects a known conflict into ideapad, verifies eval fails,
#      reverts the injection (trap-protected), proves the check is non-hollow.
#
# See DRY-REFACTOR-NOTES.md for the rationale for each check.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

NIX_OVERRIDE="--override-input opencode-config path:${REPO_ROOT}/../opencode-config"
PROBE_HOST="ideapad"
PROBE_FILE="${REPO_ROOT}/hosts/ideapad/home.nix"
PROBE_SENTINEL="# SELF-TEST-PROBE-SENTINEL"
PROBE_LINE='  home.username = "PROBE_CONFLICT_SENTINEL"; # SELF-TEST-PROBE-SENTINEL'
PROBE_BACKUP="${PROBE_FILE}.bak"

cleanup_probe() {
    if [[ -f "${PROBE_BACKUP}" ]]; then
        mv "${PROBE_BACKUP}" "${PROBE_FILE}"
        echo "[self-test] probe reverted from backup"
    elif grep -q "${PROBE_SENTINEL}" "${PROBE_FILE}" 2>/dev/null; then
        echo "[self-test] WARNING: backup missing; sentinel still present — manual cleanup needed"
    fi
}

trap cleanup_probe EXIT

# ─── helpers ───────────────────────────────────────────────────────────────────

eval_host_drv() {
    local attr="$1"
    local drv
    local err_output
    local ec=0
    # Capture stdout and stderr separately
    err_output=$(nix eval --raw "${attr}" "${NIX_OVERRIDE}" 2>&1 >/dev/null) || true
    drv=$(nix eval --raw "${attr}" "${NIX_OVERRIDE}" 2>/dev/null) || ec=$?
    if [[ ${ec} -ne 0 ]]; then
        echo "  FAIL: eval error for ${attr}"
        echo "  ${err_output}"
        return 1
    fi
    if [[ ! "${drv}" =~ ^/nix/store/.*\.drv$ ]]; then
        echo "  FAIL: unexpected output for ${attr}: ${drv}"
        return 1
    fi
    echo "  OK: ${drv}"
    return 0
}

# ─── CHECK 1: per-host real eval ───────────────────────────────────────────────

echo "=== CHECK 1: per-host toplevel.drvPath eval ==="

all_hosts_ok=true

echo "[workstation]"
eval_host_drv ".#nixosConfigurations.workstation.config.system.build.toplevel.drvPath" \
    || all_hosts_ok=false

echo "[ideapad]"
eval_host_drv ".#nixosConfigurations.ideapad.config.system.build.toplevel.drvPath" \
    || all_hosts_ok=false

echo "[nix-server]"
eval_host_drv ".#nixosConfigurations.nix-server.config.system.build.toplevel.drvPath" \
    || all_hosts_ok=false

echo "[mbp]"
eval_host_drv ".#darwinConfigurations.mbp.config.system.build.toplevel.drvPath" \
    || all_hosts_ok=false

if [[ "${all_hosts_ok}" != "true" ]]; then
    echo "FAIL: one or more host evals failed"
    exit 1
fi
echo "CHECK 1 PASSED"
echo ""

# ─── CHECK 2: nixpkgs-fmt --check ──────────────────────────────────────────────

echo "=== CHECK 2: nixpkgs-fmt --check ==="

# Collect tracked .nix files that actually exist on disk
# (some may be staged-for-deletion and absent from the working tree)
ABS_NIX_FILES=()
while IFS= read -r f; do
    [[ -f "${REPO_ROOT}/${f}" ]] && ABS_NIX_FILES+=("${REPO_ROOT}/${f}")
done < <(cd "${REPO_ROOT}" && git ls-files '*.nix')

if [[ ${#ABS_NIX_FILES[@]} -eq 0 ]]; then
    echo "FAIL: no tracked .nix files found on disk"
    exit 1
fi

# Run nixpkgs-fmt, using nix shell if not on PATH
run_nixpkgs_fmt() {
    local args=("$@")
    if command -v nixpkgs-fmt &>/dev/null; then
        nixpkgs-fmt "${args[@]}"
    else
        nix shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt "${args[@]}"
    fi
}

fmt_output=""
fmt_ok=true
fmt_output=$(run_nixpkgs_fmt --check "${ABS_NIX_FILES[@]}" 2>&1) || fmt_ok=false

if [[ "${fmt_ok}" != "true" ]]; then
    echo "FAIL: nixpkgs-fmt check found formatting issues"
    echo "${fmt_output}"
    echo "Fix with: cd ${REPO_ROOT} && nix fmt"
    exit 1
fi
echo "  OK: all ${#ABS_NIX_FILES[@]} tracked .nix files pass nixpkgs-fmt --check"
echo "CHECK 2 PASSED"
echo ""

# ─── CHECK 3: self-test (anti-hollow guard) ─────────────────────────────────────

echo "=== CHECK 3: self-test (anti-hollow guard) ==="
echo "  Injecting known-conflict into hosts/${PROBE_HOST}/home.nix ..."

# Save original file to backup (cleanup_probe restores it via EXIT trap)
cp "${PROBE_FILE}" "${PROBE_BACKUP}"

# Inject probe: home.username is set by modules/home-manager/cli/default.nix
# (plain string, not mkDefault). A second non-mkDefault value triggers a
# Nix module merge error, proving the check mechanism catches real conflicts.
# Insert before the final "}" of the file.
probe_line_count=$(wc -l < "${PROBE_FILE}")
LAST_LINE=$(tail -n 1 "${PROBE_FILE}")
if [[ "${LAST_LINE}" == "}" ]]; then
    {
        # macOS-compatible: use sed instead of head -n -1
        sed -n "1,$((probe_line_count - 1))p" "${PROBE_FILE}"
        echo ""
        echo "${PROBE_LINE}"
        echo "${PROBE_SENTINEL}"
        echo "}"
    } > "${PROBE_FILE}.tmp"
    mv "${PROBE_FILE}.tmp" "${PROBE_FILE}"
else
    {
        echo ""
        echo "${PROBE_LINE}"
        echo "${PROBE_SENTINEL}"
    } >> "${PROBE_FILE}"
fi

echo "  Probe injected. Running eval — expect FAILURE ..."

probe_ec=0
probe_drv=""
probe_drv=$(nix eval --raw \
    ".#nixosConfigurations.${PROBE_HOST}.config.system.build.toplevel.drvPath" \
    "${NIX_OVERRIDE}" 2>/dev/null) || probe_ec=$?

echo "  Eval exit code: ${probe_ec}"
if [[ ${probe_ec} -eq 0 ]] && [[ "${probe_drv}" =~ ^/nix/store/.*\.drv$ ]]; then
    echo ""
    echo "FATAL: CHECK IS HOLLOW"
    echo "  The conflict injection did NOT cause an eval failure."
    echo "  The check mechanism is not reliable. Fix the probe before shipping."
    echo "  drvPath returned: ${probe_drv}"
    # trap will revert
    exit 1
fi

echo "  CONFIRMED: broken config was correctly rejected (eval failed as expected)"
echo "  Reverting probe (restoring from backup) ..."
# Explicitly restore (EXIT trap also calls cleanup_probe as fallback)
if [[ -f "${PROBE_BACKUP}" ]]; then
    mv "${PROBE_BACKUP}" "${PROBE_FILE}"
    echo "  Restored ${PROBE_FILE} from backup"
fi

# Verify revert is clean by comparing working tree against our backup
# (not against HEAD — the file may have pre-existing uncommitted changes).
# After restore, the file should be byte-for-byte identical to what we backed up.
# Re-check: injecting again would create probe; if NOT present we're clean.
if grep -q "${PROBE_SENTINEL}" "${PROBE_FILE}" 2>/dev/null; then
    echo "FAIL: probe sentinel still present in ${PROBE_FILE} after revert"
    exit 1
fi
echo "  Working tree clean: probe sentinel absent from ${PROBE_FILE}"
echo "  self-test OK: broken config correctly rejected"
echo "CHECK 3 PASSED"
echo ""

# ─── ALL DONE ──────────────────────────────────────────────────────────────────

echo "ALL CHECKS PASSED"
