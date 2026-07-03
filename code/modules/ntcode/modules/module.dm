/datum/ntcode/module
	var/module_name

	var/list/datum/ntcode/variable/variables = list()

	var/list/datum/ntcode/function/functions = list()

/datum/ntcode/module/proc/add_byond_proc(name, proc_ref, list/arguments)
	functions += new /datum/ntcode/function/byond(name, arguments, src, proc_ref)

/datum/ntcode/module/proc/add_variable(name, value)
	variables += new /datum/ntcode/variable(name, value)

/datum/ntcode/module/proc/add_constant(name, value)
	variables += new /datum/ntcode/variable/const(name, value)
