
GLOBAL_DATUM_INIT(AdminProcCallHandler, /mob/proccall_handler, new())
GLOBAL_PROTECT(AdminProcCallHandler)

/// Used to handle proccalls called indirectly by an admin (e.g. tgs, circuits).
/// Has to be a mob because IsAdminAdvancedProcCall() checks usr, which is a mob variable.
/// So usr is set to this for any proccalls that don't have any usr mob/client to refer to.
/mob/proccall_handler
	name = "ProcCall Handler"
	desc = "If you are seeing this, tell a coder."

	var/list/callers = list()

	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE

/// Adds a caller.
/mob/proccall_handler/proc/add_caller(caller_name)
	callers += caller_name
	name = "[initial(name)] ([callers.Join(") (")])"

/// Removes a caller.
/mob/proccall_handler/proc/remove_caller(caller_name)
	callers -= caller_name
	name = "[initial(name)] ([callers.Join(") (")])"

/mob/proccall_handler/Initialize(mapload)
	. = ..()
	if(GLOB.AdminProcCallHandler && GLOB.AdminProcCallHandler != src)
		return INITIALIZE_HINT_QDEL
	GLOB.AdminProcCallHandler = src

/mob/proccall_handler/vv_edit_var(var_name, var_value)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	return FALSE

/mob/proccall_handler/vv_do_topic(list/href_list)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	return FALSE

/mob/proccall_handler/CanProcCall(procname)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	return FALSE

// Shit will break if this is allowed to be deleted
/mob/proccall_handler/Destroy(force)
	if(GLOB.AdminProcCallHandler != src)
		return ..()
	if(!force)
		stack_trace("Attempted deletion on [type] - [name], aborting.")
		return QDEL_HINT_LETMELIVE
	return ..()

/**
 * Handles a userless proccall, used by circuits.
 *
 * Arguments:
 * * user - a string used to identify the user
 * * target - the target to proccall on
 * * proc - the proc to call
 * * arguments - any arguments
 */
/proc/HandleUserlessProcCall(user, datum/target, procname, list/arguments)
	if(IsAdminAdvancedProcCall())
		return
	var/mob/proccall_handler/handler = GLOB.AdminProcCallHandler
	handler.add_caller(user)
	var/lastusr = usr
	usr = handler
	. = WrapAdminProcCall(target, procname, arguments)
	usr = lastusr
	handler.remove_caller(user)

/**
 * Handles a userless sdql, used by circuits and tgs.
 *
 * Arguments:
 * * user - a string used to identify the user
 * * query_text - the query text
 */
/proc/HandleUserlessSDQL(user, query_text)
	if(IsAdminAdvancedProcCall())
		return
	var/mob/proccall_handler/handler = GLOB.AdminProcCallHandler
	handler.add_caller(user)
	var/lastusr = usr
	usr = handler
	. = world.SDQL2_query(query_text, user, user)
	usr = lastusr
	handler.remove_caller(user)

ADMIN_VERB(advanced_proc_call, R_DEBUG, "Advanced ProcCall", "Call a proc on any datum in the server.", ADMIN_CATEGORY_DEBUG)
	user.callproc_blocking()

/client/proc/callproc_blocking(list/get_retval)
	if(!check_rights(R_DEBUG))
		return

	var/datum/target
	var/targetselected = FALSE
	var/returnval

	switch(tgui_alert(usr,"Proc owned by something?",,list("Yes","No")))
		if("Yes")
			targetselected = TRUE
			var/list/value = vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT, VV_MARKED_DATUM, VV_TEXT_LOCATE, VV_PROCCALL_RETVAL))
			if (!value["class"] || !value["value"])
				return
			target = value["value"]
			if(!istype(target))
				to_chat(usr, span_danger("Invalid target."), confidential = TRUE)
				return
		if("No")
			target = null
			targetselected = FALSE

	var/procpath = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
	if(!procpath)
		return

	//strip away everything but the proc name
	var/list/proclist = splittext(procpath, "/")
	if (!length(proclist))
		return

	var/procname = proclist[proclist.len]
	var/proctype = ("verb" in proclist) ? "verb" :"proc"

	if(targetselected)
		if(!hascall(target, procname))
			to_chat(usr, span_warning("Error: callproc(): type [target.type] has no [proctype] named [procpath]."), confidential = TRUE)
			return
	else
		procpath = "/[proctype]/[procname]"
		if(!text2path(procpath))
			to_chat(usr, span_warning("Error: callproc(): [procpath] does not exist."), confidential = TRUE)
			return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>", confidential = TRUE)
			return
		var/msg = "[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
		log_admin(msg)
		message_admins(msg) //Proccall announce removed.
		admin_ticket_log(target, msg)
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		message_admins("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].") //Proccall announce removed.
		returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc
	BLACKBOX_LOG_ADMIN_VERB("Advanced ProcCall")
	if(get_retval)
		get_retval += returnval
	. = get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, ., confidential = TRUE)

GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)

/// Wrapper for proccalls where the datum is flagged as vareditted
/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed", confidential = TRUE)
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!", confidential = TRUE)
		return
	var/current_caller = GLOB.AdminProcCaller
	var/user_identifier = usr ? usr.client?.ckey : GLOB.AdminProcCaller
	var/is_remote_handler = usr == GLOB.AdminProcCallHandler
	if(is_remote_handler)
		user_identifier = GLOB.AdminProcCallHandler.name

	if(!user_identifier)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")

	if(!is_remote_handler && current_caller && current_caller != user_identifier)
		to_chat(usr, span_adminnotice("Another set of admin called procs are still running. Try again later."), confidential = TRUE)
		return

	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)

	if(!is_remote_handler)
		GLOB.AdminProcCaller = user_identifier //if this runtimes, too bad for you
		++GLOB.AdminProcCallCount
		. = world.WrapAdminProcCall(target, procname, arguments)
		GLOB.AdminProcCallCount--
		if(GLOB.AdminProcCallCount == 0)
			GLOB.AdminProcCaller = null
	else
		. = world.WrapAdminProcCall(target, procname, arguments)

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call("/proc/[procname]")(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		log_admin("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return (GLOB.AdminProcCaller && GLOB.AdminProcCaller == usr?.client?.ckey) || (GLOB.AdminProcCallHandler && usr == GLOB.AdminProcCallHandler)
#endif

ADMIN_VERB_ONLY_CONTEXT_MENU(call_proc_datum, R_DEBUG, "Atom ProcCall", datum/thing as null|area|mob|obj|turf)
	var/procname = input(user, "Proc name, eg: fake_blood","Proc:", null) as text|null
	if(!procname)
		return
	if(!hascall(thing, procname))
		to_chat(user, "<font color='red'>Error: callproc_datum(): type [thing.type] has no proc named [procname].</font>", confidential = TRUE)
		return
	var/list/lst = user.get_callproc_args()
	if(!lst)
		return

	if(!thing || !is_valid_src(thing))
		to_chat(user, span_warning("Error: callproc_datum(): owner of proc no longer exists."), confidential = TRUE)
		return
	log_admin("[key_name(user)] called [thing]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	var/msg = "[key_name(user)] called [thing]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	message_admins(msg)
	admin_ticket_log(thing, msg)
	BLACKBOX_LOG_ADMIN_VERB("Atom ProcCall")

	var/returnval = WrapAdminProcCall(thing, procname, lst) // Pass the lst as an argument list to the proc
	. = user.get_callproc_returnval(returnval,procname)
	if(.)
		to_chat(user, ., confidential = TRUE)

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += LIST_VALUE_WRAP_LISTS(value["value"])
	if(LAZYLEN(named_args))
		. += named_args

/client/proc/get_callproc_returnval(returnval,procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<font color='blue'>"
		if(returnedlist.len)
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</font>"

	else
		. = "<font color='blue'>[procname] returned: [!isnull(returnval) ? html_encode(returnval) : "null"]</font>"
