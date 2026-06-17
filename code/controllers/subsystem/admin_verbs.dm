GENERAL_PROTECT_DATUM(/datum/controller/subsystem/admin_verbs)

SUBSYSTEM_DEF(admin_verbs)
	name = "Admin Verbs"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	/// A list of all admin verbs indexed by their type.
	var/list/datum/admin_verb/admin_verbs_by_type = list()
	/// A list of all admin verbs indexed by their visibility flag.
	var/list/list/datum/admin_verb/admin_verbs_by_visibility_flag = list()
	/// A map of all assosciated admins and their visibility flags.
	var/list/admin_visibility_flags = list()
	/// A list of all admins that are pending initialization of this SS.
	var/list/admins_pending_subsytem_init = list()

/datum/controller/subsystem/admin_verbs/Initialize()
	setup_verb_list()
	process_pending_admins()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/admin_verbs/Recover()
	admin_verbs_by_type = SSadmin_verbs.admin_verbs_by_type

/datum/controller/subsystem/admin_verbs/stat_entry(msg)
	msg = "V:[length(admin_verbs_by_type)]"
	return ..()

/datum/controller/subsystem/admin_verbs/proc/process_pending_admins()
	var/list/pending_admins = admins_pending_subsytem_init
	admins_pending_subsytem_init = null
	for(var/admin_ckey in pending_admins)
		assosciate_admin(GLOB.directory[admin_ckey])

/datum/controller/subsystem/admin_verbs/proc/setup_verb_list()
	if(length(admin_verbs_by_type))
		CRASH("Attempting to setup admin verbs twice!")
	for(var/datum/admin_verb/verb_type as anything in subtypesof(/datum/admin_verb))
		var/datum/admin_verb/verb_singleton = new verb_type
		if(!verb_singleton.__avd_check_should_exist())
			qdel(verb_singleton, force = TRUE)
			continue

		verb_singleton.metadata = new
		var/list/pending = GLOB.____avd_pending_verb_args[verb_type]
		if(pending)
			verb_singleton.metadata.arguments = pending
		admin_verbs_by_type[verb_type] = verb_singleton
		if(verb_singleton.visibility_flag)
			if(!(verb_singleton.visibility_flag in admin_verbs_by_visibility_flag))
				admin_verbs_by_visibility_flag[verb_singleton.visibility_flag] = list()
			admin_verbs_by_visibility_flag[verb_singleton.visibility_flag] |= list(verb_singleton)

/datum/controller/subsystem/admin_verbs/proc/get_valid_verbs_for_admin(client/admin)
	if(isnull(admin.holder))
		CRASH("Why are we checking a non-admin for their valid... ahem... admin verbs?")

	var/list/has_permission = list()
	for(var/permission_flag in GLOB.bitflags)
		if(admin.holder.check_for_rights(permission_flag))
			has_permission["[permission_flag]"] = TRUE

	var/list/valid_verbs = list()
	for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
		var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
		if(!verify_visibility(admin, verb_singleton))
			continue

		var/verb_permissions = verb_singleton.permissions
		if(verb_permissions == R_NONE)
			valid_verbs |= list(verb_singleton)
		else for(var/permission_flag in bitfield_to_list(verb_permissions))
			if(!has_permission["[permission_flag]"])
				continue
			valid_verbs |= list(verb_singleton)

	return valid_verbs

/datum/controller/subsystem/admin_verbs/proc/verify_visibility(client/admin, datum/admin_verb/verb_singleton)
	var/needed_flag = verb_singleton.visibility_flag
	return !needed_flag || (needed_flag in admin_visibility_flags[admin.ckey])

/datum/controller/subsystem/admin_verbs/proc/update_visibility_flag(client/admin, flag, state)
	if(state)
		admin_visibility_flags[admin.ckey] |= list(flag)
		assosciate_admin(admin)
		return

	admin_visibility_flags[admin.ckey] -= list(flag)
	// they lost the flag, iterate over verbs with that flag and yoink em
	for(var/datum/admin_verb/verb_singleton as anything in admin_verbs_by_visibility_flag[flag])
		verb_singleton.unassign_from_client(admin)
	admin.init_verbs()

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_verb(client/admin, datum/admin_verb/verb_type, ...)
	if(IsAdminAdvancedProcCall())
		message_admins("PERMISSION ELEVATION: [key_name_admin(admin)] attempted to dynamically invoke admin verb '[verb_type]'.")
		return

	if(ismob(admin))
		var/mob/mob = admin
		admin = mob.client

	if(!ispath(verb_type, /datum/admin_verb) || verb_type == /datum/admin_verb)
		CRASH("Attempted to dynamically invoke admin verb with invalid typepath '[verb_type]'.")
	if(isnull(admin.holder))
		CRASH("Attempted to dynamically invoke admin verb '[verb_type]' with a non-admin.")

	var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
	if(isnull(verb_singleton))
		CRASH("Attempted to dynamically invoke admin verb '[verb_type]' that doesn't exist.")

	if(!admin.holder.check_for_rights(verb_singleton.permissions))
		to_chat(admin, span_adminnotice("You lack the permissions to do this."))
		return

	// Build structured_args from whatever the caller passed
	var/list/structured_args = list()
	var/list/extra_args = args.Copy(3)
	if(length(extra_args) == 1 && islist(extra_args[1]))
		// Caller passed an explicit assoc list (e.g. context menu hints)
		structured_args = extra_args[1]
	else if(length(extra_args))
		// Map positional args to metadata argument names in order
		var/list/meta_args = verb_singleton.metadata?.arguments
		for(var/i in 1 to min(length(extra_args), length(meta_args)))
			var/datum/admin_verb_metadata/argument/arg = meta_args[i]
			structured_args[arg.name] = extra_args[i]

	if(length(verb_singleton.metadata?.arguments))
		structured_args = collect_verb_args(admin, verb_singleton, structured_args)
		if(isnull(structured_args))
			return

	var/old_usr = usr
	usr = admin.mob
	verb_singleton.__avd_do_verb(admin, structured_args)
	usr = old_usr
	SSblackbox.record_feedback("tally", "dynamic_admin_verb_invocation", 1, "[verb_type]")

/datum/controller/subsystem/admin_verbs/proc/collect_verb_args(client/admin, datum/admin_verb/verb_singleton, list/hints)
	var/list/collected = hints?.Copy() || list()
	var/context_target = collected["__context_target__"]
	collected -= "__context_target__"
	var/context_used = FALSE

	for(var/datum/admin_verb_metadata/argument/arg in verb_singleton.metadata.arguments)
		if(!isnull(collected[arg.name]))
			continue
		if(!context_used && !isnull(context_target) && arg.source == ADMIN_VERB_ARG_SOURCE_WORLD)
			collected[arg.name] = context_target
			context_used = TRUE
			continue
		var/value = prompt_for_arg(admin, verb_singleton.name, arg)
		if(isnull(value))
			return null
		collected[arg.name] = value
	return collected

/datum/controller/subsystem/admin_verbs/proc/prompt_for_arg(client/admin, verb_name, datum/admin_verb_metadata/argument/arg)
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_NUM)
		return tgui_input_number(admin, arg.name, verb_name)
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_TEXT)
		return tgui_input_text(admin, arg.name, verb_name)
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_MESSAGE)
		return tgui_input_text(admin, arg.name, verb_name, multiline = TRUE)
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_SOUND)
		return input(admin, arg.name, verb_name) as null|sound
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_MOB)
		return tgui_input_list(admin, arg.name, verb_name, sort_names(GLOB.mob_list))
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_AREA)
		return tgui_input_list(admin, arg.name, verb_name, get_sorted_areas())
	if(arg.arg_type & ADMIN_VERB_ARG_TYPE_OBJ)
		return tgui_input_list(admin, arg.name, verb_name, sort_names(GLOB.mob_list))
	return null

/**
 * Assosciates and/or resyncs an admin with their accessible admin verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/assosciate_admin(client/admin)
	if(IsAdminAdvancedProcCall())
		return

	if(!isnull(admins_pending_subsytem_init)) // if the list exists we are still initializing
		to_chat(admin, span_big(span_green("Admin Verbs are still initializing. Please wait and you will be automatically assigned your verbs when it is complete.")))
		admins_pending_subsytem_init |= list(admin.ckey)
		return

	// refresh their verbs
	admin_visibility_flags[admin.ckey] ||= list()
	if(admin.is_localhost())
		admin_visibility_flags[admin.ckey] |= list(ADMIN_VERB_VISIBLITY_FLAG_LOCALHOST)
	for(var/datum/admin_verb/verb_singleton as anything in get_valid_verbs_for_admin(admin))
		verb_singleton.assign_to_client(admin)
	admin.init_verbs()

/**
 * Unassosciates an admin from their admin verbs.
 * Goes over all admin verbs because we don't know which ones are assigned to the admin's mob without a bunch of extra bookkeeping.
 * This might be a performance issue in the future if we have a lot of admin verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/deassosciate_admin(client/admin)
	if(IsAdminAdvancedProcCall())
		return

	UnregisterSignal(admin, COMSIG_CLIENT_MOB_LOGIN)
	for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
		admin_verbs_by_type[verb_type].unassign_from_client(admin)
	admin_visibility_flags -= list(admin.ckey)
