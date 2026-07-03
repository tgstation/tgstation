/**
 * Special release of the NTCode interpreter for telecommunication servers
 * with 'telecomms' library on board.
 * Compiles the code and runs it from the entry point - handle_signal(signal).
 */
/datum/ntcode/interpreter/telecomms
	var/datum/ntcode/function/handle_signal

/datum/ntcode/interpreter/telecomms/New()
	. = ..()
	modules += new /datum/ntcode/module/telecomms()

/datum/ntcode/interpreter/telecomms/evaluate(signal)
	if(!istype(signal, /datum/signal/subspace/vocal))
		return
	if(!handle_signal)
		return

	handle_signal.evaluate(src, list(signal))
