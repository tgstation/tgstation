/datum/ntcode/exception

/datum/ntcode/exception/ret
	var/result

/datum/ntcode/exception/ret/New(result)
	. = ..()
	src.result = result

/datum/ntcode/exception/loop_continue

/datum/ntcode/exception/loop_break

/datum/ntcode/exception/error
	var/message
	var/list/datum/ntcode/function/stack = list()

/datum/ntcode/exception/error/maximum_loops
	message = "Reached maximum amount of loops"

/datum/ntcode/exception/error/divide_by_zero
	message = "Attempted divide by zero"
