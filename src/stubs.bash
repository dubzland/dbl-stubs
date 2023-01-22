declare -Ag __stubs
__stubs=()

stub() {
  local func="${1:?function name is required}" _stub
  declare -ig "__stub_${func}__invoked"
  declare -ag "__stub_${func}__args"
  local -n __invoked="__stub_${func}__invoked"
  local -n __args="__stub_${func}__args"
  __invoked=0 __args=()

  if declare -f -F "${func}" 2>&1 >/dev/null; then
    __stubs[$func]="$(declare -f $func)"
    unset $func
  else
    __stubs[$func]=0
  fi

  if [[ $# -eq 1 ]]; then
    source /dev/stdin <<- EOF
function ${func}() { _stub_invoked "$func" "\$@"; };
EOF
  else
    source /dev/stdin <<- EOF
function ${func}() { _stub_invoked "$func" "\$@"; $2 "\$@"; };
EOF
  fi
}

stub_teardown() {
  local _stub
  for _stub in "${!__stubs[@]}"; do
    unset "__stub_${_stub}__invoked"
    unset "__stub_${_stub}__args"
    if [[ "${__stubs["$_stub"]}" = "0" ]]; then
      unset "$_stub"
    else
      eval "${__stubs[$_stub]}"
    fi
  done
  __stubs=()
}

_stub_invoked() {
  local func="${1:?function name is required}"

  local -n __invoked="__stub_${func}__invoked"
  local -n __args="__stub_${func}__args"

  __invoked=1 __args=("${@:2}")
}

_stub_was_invoked() {
  local func="${1:?function name is required}"
  local -n __invoked="__stub_${func}__invoked"
  [[ $__invoked -eq 1 ]]
}
