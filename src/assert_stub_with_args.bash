assert_stub_with_args() {
	local function_name="${1:?function name is required}"; shift
	assert_stub "$function_name"
	assert_stub_args "$function_name" "$@"
}
