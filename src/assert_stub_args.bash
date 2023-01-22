assert_stub_args() { local function_name="${1:?function name is required}"; shift
	local args_equal=1 idx arg
	local -n actual_args="__stub_${function_name}__args"

	if [[ $# -eq ${#actual_args[@]} ]]; then
		for (( idx=0; idx < $#; idx++ )); do
			arg=$((idx+1))
			if [[ "${actual_args[$idx]}" != "${!arg}" ]]; then
				args_equal=0
				break
			fi
		done
	else
		args_equal=0
	fi

	if [[ $args_equal -eq 0 ]]; then
		local expected_string actual_string
		expected_string='' actual_string=''
		[[ $# -gt 0 ]] && printf -v expected_string "'%s'," "$@"
		[[ ${#actual_args[@]} -gt 0 ]] &&
			printf -v actual_string "'%s'," "${actual_args[@]}"

		batslib_print_kv_single_or_multi 8 \
		'expected' "[${expected_string%,}]" \
		'actual'   "[${actual_string%,}]" \
		| batslib_decorate 'stub invoked with unexpected args' \
		| fail
	fi
}
