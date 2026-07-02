/datum/ntcode/module/debug
	module_name = "debug"
	
/datum/ntcode/module/debug/New()
	. = ..()
	
	add_byond_proc("print", TYPE_PROC_REF(/datum/ntcode/module/debug, print), list("text"))

/datum/ntcode/module/debug/proc/print(text)
	world.log << text