load getopt_long

@test "fails with less than 2 arguments - missing variable name" {
	run getopt_long 'verbose'
	[[ $status -ne 0 ]]
}

@test "fails when no arguments given" {
	run getopt_long
	[[ $status -ne 0 ]]
}

@test "parses a single long option without arguments" {
	getopt_long 'verbose' GETOPT_OPT -verbose
	[[ $GETOPT_OPT == verbose ]]
}

@test "parses two long options without arguments" {
	getopt_long 'debug,verbose' GETOPT_OPT -verbose -debug
	[[ $GETOPT_OPT == verbose ]]
	getopt_long 'debug,verbose' GETOPT_OPT -verbose -debug
	[[ $GETOPT_OPT == debug ]]
}

@test "warns about unrecognized options" {
	getopt_long 'debug,verbose' GETOPT_OPT -error
	[[ $GETOPT_OPT == '?' ]]
}

@test "fails upon non-option arguments" {
	getopt_long 'debug,verbose' GETOPT_OPT some_filename && return 1
	[[ $GETOPT_OPT == '?' ]]
}

@test "reads from GETOPT_ARGV if no extra args given" {
	declare -a -g GETOPT_ARGV
	GETOPT_ARGV=( -verbose )
	OPTIND=1

	getopt_long 'debug,verbose' GETOPT_OPT
	[[ $GETOPT_OPT == verbose ]]
}

@test "reads starting from OPTIND" {
	declare -a -g GETOPT_ARGV
	GETOPT_ARGV=( -verbose -debug )
	OPTIND=2

	getopt_long 'debug,verbose' GETOPT_OPT
	[[ $GETOPT_OPT == debug ]]
	[[ $OPTIND -eq 3 ]]
}

@test "correctly reads multiple arguments from GETOPT_ARGV" {
	declare -a -g GETOPT_ARGV
	GETOPT_ARGV=( -verbose -debug )
	OPTIND=1

	getopt_long 'debug,verbose' GETOPT_OPT
	[[ $GETOPT_OPT == verbose ]]
	getopt_long 'debug,verbose' GETOPT_OPT
	[[ $GETOPT_OPT == debug ]]
}

@test "returns error code when no args left" {
	getopt_long 'verbose' GETOPT_OPT && return 1
	[[ $GETOPT_OPT == '?' ]]
}

@test "parses a single long option with arguments" {
	getopt_long 'name:' GETOPT_OPT -name Werther
	[[ $GETOPT_OPT == name ]]
	[[ $OPTARG == Werther ]]
}

@test "parses options after option with arguments" {
	getopt_long 'name:,quiet' GETOPT_OPT -name Werther -quiet
	[[ $GETOPT_OPT == name ]]
	[[ $OPTARG == Werther ]]
	getopt_long 'name:,quiet' GETOPT_OPT -name Werther -quiet
	[[ $GETOPT_OPT == quiet ]]
}

@test "returns error when option arguments are required and missing" {
	getopt_long 'name:' GETOPT_OPT -name && return 1
	[[ $GETOPT_OPT == '?' ]]
}

@test "returns error for '-' option" {
	getopt_long 'quiet' GETOPT_OPT - && return 1
	[[ $GETOPT_OPT == '?' ]]
}
