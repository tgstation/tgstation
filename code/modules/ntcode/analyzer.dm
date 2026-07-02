/datum/ntcode/analyzer
	var/list/errors = list()
	
	var/datum/ntcode/scope/current_scope

	var/list/datum/ntcode/module/modules

	var/list/call_stack = list()

	var/list/analyzed_functions

/datum/ntcode/analyzer/New(datum/ntcode/module/modules)
	. = ..()
	src.modules = modules
	

/datum/ntcode/analyzer/proc/analyze(datum/ntcode/node/head)
	errors = list()
	call_stack = list()
	analyzed_functions = list()
	current_scope = new()

	head.analyze(src)
 
	return errors

/datum/ntcode/analyzer/proc/error(error)
	errors += error