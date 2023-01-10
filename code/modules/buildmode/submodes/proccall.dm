/datum/buildmode_mode/proccall
	key = "proccall"
	///The procedure itself, which we will call in the future. For example "qdel"
	var/proc_name = null
	///The list of arguments for the procedure. They may not be. They are selected in the same way in the game, and can be a datum, and other types.
	var/list/proc_args = null

/datum/buildmode_mode/proccall/show_help(client/target_client)
	to_chat(target_client, span_notice("***********************************************************\n\
		Right Mouse Button on buildmode button = Choose procedure and arguments\n\
		Left Mouse Button on machinery = Apply procedure on object.\n\
		***********************************************************"))

/datum/buildmode_mode/proccall/change_settings(client/target_client)
	if(!check_rights_for(target_client, R_DEBUG))
		return

	proc_name = input("Proc name, eg: fake_blood", "Proc:", null) as text|null
	if(!proc_name)
		return

	proc_args = target_client.get_callproc_args()
	if(!proc_args)
		return

/datum/buildmode_mode/proccall/handle_click(client/target_client, params, datum/object as null|area|mob|obj|turf)
	if(!proc_name || !proc_args)
		tgui_alert(target_client, "Undefined ProcCall or arguments.")
		return
	
	if(!hascall(object, proc_name))
		to_chat(target_client, span_warning("Error: callproc_datum(): type [object.type] has no proc named [proc_name]."), confidential = TRUE)
		return

	if(!is_valid_src(object))
		to_chat(target_client, span_warning("Error: callproc_datum(): owner of proc no longer exists."), confidential = TRUE)
		return

	
	var/msg = "[key_name(target_client)] called [object]'s [proc_name]() with [proc_args.len ? "the arguments [list2params(proc_args)]":"no arguments"]."
	log_admin(msg)
	message_admins(msg)
	admin_ticket_log(object, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(object, proc_name, proc_args) // Pass the lst as an argument list to the proc
	. = target_client.get_callproc_returnval(returnval, proc_name)
	if(.)
		to_chat(target_client, ., confidential = TRUE)
