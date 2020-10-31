///Abstract class for an conditional check an AI can make. These are singletons, any non-singleton decorator can be handled manually.
/datum/ai_decorator

///Conditional check for a specific behavior
/datum/ai_decorator/proc/check_condition(datum/ai_controller/controller)
	return FALSE
