/**
 * The 'telecomms' library for NTCode, which is supplied to all Nanotrasen telecommunication servers.
 * It contains functions and constants for effective control of the traffic nd signals.
 */
/datum/ntcode/module/telecomms
	module_name = "telecomms"

/datum/ntcode/module/telecomms/New()
	. = ..()

	// Constants with channel frequencies
	add_constant("FREQ_SUPPLY", FREQ_SUPPLY)
	add_constant("FREQ_SERVICE", FREQ_SERVICE)
	add_constant("FREQ_SCIENCE", FREQ_SCIENCE)
	add_constant("FREQ_COMMAND", FREQ_COMMAND)
	add_constant("FREQ_MEDICAL", FREQ_MEDICAL)
	add_constant("FREQ_ENGINEERING", FREQ_ENGINEERING)
	add_constant("FREQ_SECURITY", FREQ_SECURITY)
	add_constant("FREQ_ENTERTAINMENT", FREQ_ENTERTAINMENT)
	add_constant("FREQ_AI_PRIVATE", FREQ_AI_PRIVATE)
	add_constant("FREQ_COMMON", FREQ_COMMON)

	// Functions for working with signals
	add_byond_proc("get_name", TYPE_PROC_REF(/datum/ntcode/module/telecomms, get_name), list("signal"))
	add_byond_proc("get_job", TYPE_PROC_REF(/datum/ntcode/module/telecomms, get_job), list("signal"))
	add_byond_proc("get_language", TYPE_PROC_REF(/datum/ntcode/module/telecomms, get_language), list("signal"))
	add_byond_proc("get_message", TYPE_PROC_REF(/datum/ntcode/module/telecomms, get_message), list("signal"))
	add_byond_proc("set_name", TYPE_PROC_REF(/datum/ntcode/module/telecomms, set_name), list("signal", "name"))
	add_byond_proc("set_job", TYPE_PROC_REF(/datum/ntcode/module/telecomms, set_job), list("signal", "name"))
	add_byond_proc("set_message", TYPE_PROC_REF(/datum/ntcode/module/telecomms, set_message), list("signal", "message"))
	add_byond_proc("set_freq_name", TYPE_PROC_REF(/datum/ntcode/module/telecomms, set_freq_name), list("signal", "name"))

/datum/ntcode/module/telecomms/proc/get_name(datum/signal/signal)
	if(!signal)
		return
	return signal.data["name"]

/datum/ntcode/module/telecomms/proc/get_job(datum/signal/signal)
	if(!signal)
		return
	return signal.data["job"]

/datum/ntcode/module/telecomms/proc/get_language(datum/signal/signal)
	if(signal)
		return
	return signal.data["language"]

/datum/ntcode/module/telecomms/proc/get_message(datum/signal/signal)
	if(!signal)
		return
	return signal.data["message"]

/datum/ntcode/module/telecomms/proc/set_name(datum/signal/signal, name)
	if(!signal || !istext(name))
		return
	signal.data["name"] = name

/datum/ntcode/module/telecomms/proc/set_job(datum/signal/signal, job)
	if(!signal || !istext(job))
		return
	signal.data["job"] = job

/datum/ntcode/module/telecomms/proc/set_message(datum/signal/signal, message)
	if(!signal || !istext(message))
		return
	signal.data["message"] = message

/datum/ntcode/module/telecomms/proc/set_freq_name(datum/signal/signal, name)
	if(!signal || !istext(name))
		return
	signal.data["freq_name"] = name
