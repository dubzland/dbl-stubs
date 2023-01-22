#!/usr/bin/env bats

load test_helper

teardown() {
	stub_teardown
}

@test 'stub() <cmd> succeeds' {
	run stub foo 2>&3 >&3
	test "${#lines[@]}" -eq 0
	test "$status" -eq 0
}

@test 'stub() <cmd> adds the __stubs entry' {
	stub foo
	test -v __stubs[foo]
}

@test 'stub() <cmd> creates a stub function' {
	stub foo
	declare -f foo >/dev/null
}

@test 'stub() <cmd> <override> succeeds' {
	function foo_override() { return 0; }
	run stub foo foo_override
	test "$status" -eq 0
	test "${#lines[@]}" -eq 0
}

@test 'stub() <cmd> for a function sets the __stubs entry to the function' {
	function foo() { return 0; }
	stub foo
	[[ "${__stubs[foo]}" =~ ^'foo ()' ]]
}

@test 'stub() <cmd> for a non-funtion sets the __stubs entry to 0' {
	stub foo
	test ${__stubs[foo]} -eq 0
}

@test 'stub.invoke() succeeds' {
	stub foo
	run foo
	test "$status" -eq 0
	test "${#lines[@]}" -eq 0
}

@test 'stub.invoke() sets the __invoked count to 1' {
	stub foo
	foo
	test "$__stub_foo__invoked" -eq 1
}

@test 'stub.invoke() sets the __args' {
	stub foo
	foo bar baz
	test "${__stub_foo__args[0]}" = bar
	test "${__stub_foo__args[1]}" = baz
}

@test 'stub.invoke() with an override invokes it' {
	local invoked=0
	function foo_override() {
		test $# -eq 2
		test "$1" = bar
		test "$2" = baz
		invoked=1
	}
	stub foo foo_override
	foo bar baz
	test "$invoked" -eq 1
}

@test 'stub_teardown() succeeds' {
	run stub_teardown
	test "$status" -eq 0
	test "${#lines[@]}" -eq 0
}

@test 'stub_teardown() removes the __invoked global' {
	stub foo
	declare -p __stub_foo__invoked 2>/dev/null
	stub_teardown
	! declare -p __stub_foo__invoked 2>/dev/null
}

@test 'stub_teardown() removes the __args global' {
	stub foo
	declare -p __stub_foo__args 2>/dev/null
	stub_teardown
	! declare -p __stub_foo__args 2>/dev/null
}

@test 'stub_teardown() for a function returns the original' {
	function foo() { return 0; }
	stub foo
	[[ "$(declare -f foo)" =~ "_stub_invoked" ]]
	stub_teardown
	[[ ! "$(declare -f foo)" =~ "_stub_invoked" ]]
}
