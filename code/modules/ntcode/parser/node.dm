/datum/ntcode/node
	var/node_type

	var/precedence = NTCODE_PREC_DEFAULT
	var/associativity = NTCODE_LEFT_ASSOCIATIVITY

	var/datum/ntcode/node/next
	var/datum/ntcode/token/node_token

/datum/ntcode/node/proc/analyze(datum/ntcode/analyzer/analyzer)
	return

/datum/ntcode/node/proc/evaluate(datum/ntcode/interpreter/interpreter)
	return

/datum/ntcode/node/proc/parse(datum/ntcode/parser/parser)
	return
	
/datum/ntcode/node/proc/to_string(indent)
	return "[indent][type]"
