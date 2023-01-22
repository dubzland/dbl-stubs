assert_stub() {
	local function_name="${1:?function name is required}"; shift
	[[ $# -eq 0 ]] ||
		fail "too man arguments to assert_stub_invoked: [$function_name $@]." \
				"Did you mean assert_stub_invoked_with_args()?"
	if ! _stub_was_invoked $function_name; then
		fail "stub not invoked: ${function_name}"
	fi
}
