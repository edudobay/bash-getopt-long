getopt_long() {
	if [[ $# -lt 2 ]]; then
		echo "ERROR: ${FUNCNAME[0]}: not enough arguments" 1>&2
		return 2
	fi

	local longopts varname
	IFS=, read -r -a longopts <<<"$1"
	varname=$2
	shift 2

	declare -A optmap
	for opt in "${longopts[@]}"; do
		optmap["${opt%:}"]=$opt
	done

	declare -a args
	if [[ $# -eq 0 ]]; then
		args=( "${GETOPT_ARGV[@]}" )
	else
		args=( "$@" )
	fi

	OPTARG=

	local arg hasarg index foundopt declaredopt
	index=$OPTIND
	for (( index=OPTIND; index<=${#args[@]}; index++ )); do
		arg=${args[$((index-1))]}

		if [[ $arg != -* ]]; then
			echo "error: illegal option: $arg" 1>&2
			printf -v "$varname" '?'
			return 1
		fi

		foundopt=${arg#-}
		declaredopt=${optmap[$foundopt]}
		if [[ -z $declaredopt ]]; then
			echo "error: illegal option: $arg" 1>&2
			foundopt='?'
		fi

		if [[ $declaredopt = *: ]]; then
			hasarg=1
		fi

		[[ $hasarg = 1 ]] && if [[ $index -eq ${#args[@]} ]]; then
			echo "error: option requires an argument: $arg" 1>&2
			printf -v "$varname" '?'
			return 1
		else
			OPTARG=${args[$index]}
			(( index++ ))
		fi

		printf -v "$varname" %s "$foundopt"
		OPTIND=$((index+1))
		return 0
	done

	printf -v "$varname" '?'
	return 1
}
