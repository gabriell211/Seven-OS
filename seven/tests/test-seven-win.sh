#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WINEXEC="$ROOT_DIR/seven/package/seven-win/files/seven-winexec"
TMP="$(mktemp -d)"

cleanup() {
	rm -rf "$TMP"
}
trap cleanup EXIT

mkdir -p "$TMP/bin" "$TMP/home" "$TMP/apps"

cat > "$TMP/bin/wine" <<'EOF'
#!/bin/sh
printf '%s\n' "WINEPREFIX=$WINEPREFIX"
printf '%s\n' "WINEARCH=$WINEARCH"
printf 'ARGS='
printf '<%s>' "$@"
printf '\n'
EOF
chmod +x "$TMP/bin/wine"

printf 'MZfake-pe\n' > "$TMP/apps/demo.exe"
printf 'fake-msi\n' > "$TMP/apps/setup.msi"

export PATH="$TMP/bin:$PATH"
export HOME="$TMP/home"
export SEVEN_WINE_BINARY=wine

exe_output="$("$WINEXEC" "$TMP/apps/demo.exe" --hello "Seven OS")"
msi_output="$("$WINEXEC" "$TMP/apps/setup.msi" /quiet)"
prefix_one="$("$WINEXEC" --prefix "$TMP/apps/demo.exe")"
prefix_two="$("$WINEXEC" --prefix "$TMP/apps/demo.exe")"

grep -q 'WINEARCH=wow64' <<<"$exe_output"
grep -q '<.*demo.exe><--hello><Seven OS>' <<<"$exe_output"
grep -q '<msiexec></i><.*setup.msi></quiet>' <<<"$msi_output"

[[ "$prefix_one" == "$prefix_two" ]]
[[ "$prefix_one" == *"/seven/windows/apps/demo.exe-"* ]]

printf 'seven-win tests: PASS\n'
