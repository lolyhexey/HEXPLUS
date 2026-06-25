#!/bin/bash
# SSHPlus shared logging + command wrapper
# Source this in any module: source /etc/SSHPlus/lib.sh
# Override location with: SSHPLUS_LOG=/custom/path source /etc/SSHPlus/lib.sh

SSHPLUS_LOG="${SSHPLUS_LOG:-/var/log/sshplus.log}"
SSHPLUS_ERR_LOG="${SSHPLUS_ERR_LOG:-/var/log/sshplus.err}"
SSHPLUS_CTX="${SSHPLUS_CTX:-${0##*/}}"

_sshplus_log_init() {
	local d
	for d in "$(dirname "$SSHPLUS_LOG")" "$(dirname "$SSHPLUS_ERR_LOG")"; do
		[[ -d "$d" ]] || mkdir -p "$d" 2>/dev/null
	done
	touch "$SSHPLUS_LOG" "$SSHPLUS_ERR_LOG" 2>/dev/null
}
_sshplus_log_init

_sshplus_ts() { date '+%Y-%m-%d %H:%M:%S'; }

log_info() {
	printf '[%s] [INFO]  [%s] %s\n' "$(_sshplus_ts)" "$SSHPLUS_CTX" "$*" >>"$SSHPLUS_LOG"
}

log_warn() {
	printf '[%s] [WARN]  [%s] %s\n' "$(_sshplus_ts)" "$SSHPLUS_CTX" "$*" >>"$SSHPLUS_LOG"
}

log_err() {
	printf '[%s] [ERROR] [%s] %s\n' "$(_sshplus_ts)" "$SSHPLUS_CTX" "$*" | tee -a "$SSHPLUS_ERR_LOG" >>"$SSHPLUS_LOG"
}

# run <description> <command...>
# Executes command, captures stderr, logs failure with exit code + stderr snippet.
# Returns the command's exit code so callers can branch on it.
run() {
	local desc="$1"; shift
	local err_file
	err_file=$(mktemp 2>/dev/null) || err_file="/tmp/sshplus.$$.$RANDOM.err"

	"$@" 2>"$err_file" >/dev/null
	local code=$?

	if [[ $code -ne 0 ]]; then
		local snippet
		snippet=$(tr '\n' ' ' <"$err_file" 2>/dev/null | cut -c1-400)
		log_err "$desc failed (exit=$code) cmd=[$*] stderr=[$snippet]"
	else
		log_info "$desc ok"
	fi

	rm -f "$err_file"
	return $code
}

# run_soft <description> <command...>
# Like run() but treats non-zero exit as warning (not error). Use for cleanup
# commands where "already gone" / "not installed" is acceptable.
run_soft() {
	local desc="$1"; shift
	local err_file
	err_file=$(mktemp 2>/dev/null) || err_file="/tmp/sshplus.$$.$RANDOM.err"

	"$@" 2>"$err_file" >/dev/null
	local code=$?

	if [[ $code -ne 0 ]]; then
		local snippet
		snippet=$(tr '\n' ' ' <"$err_file" 2>/dev/null | cut -c1-400)
		log_warn "$desc returned exit=$code stderr=[$snippet]"
	fi

	rm -f "$err_file"
	return $code
}

# die <message>
# Log error and exit. Use for unrecoverable conditions in install scripts.
die() {
	log_err "FATAL: $*"
	printf '\033[1;31m[ผิดพลาด]\033[1;33m %s\n\033[1;36mดูรายละเอียดใน %s\033[0m\n' "$*" "$SSHPLUS_ERR_LOG" >&2
	exit 1
}
