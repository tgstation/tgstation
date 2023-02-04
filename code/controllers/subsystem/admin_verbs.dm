#define VERB_MAP_MODULE 1
#define VERB_MAP_NAME 2
#define VERB_MAP_DESCRIPTION 3
#define VERB_MAP_PERMISSIONS 4

#define CONTEXT_MAP_NAME 1
#define CONTEXT_MAP_PERMISSIONS 2

#define LINKUPMAP_LOGOUT 1
#define LINKUPMAP_LOGIN 2
#define LINKUPMAP_CONTEXT_MAP 3

SUBSYSTEM_DEF(admin_verbs)
	name = "Admin Verbs"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ADMIN_VERBS
	VAR_PRIVATE/list/admin_verb_map
	VAR_PRIVATE/list/holder_map
	VAR_PRIVATE/list/context_map
	VAR_PRIVATE/list/admin_linkup_map

	var/list/waiting_to_assosciate = list()
	var/list/assosciations_by_ckey

GENERAL_PROTECT_DATUM(/datum/controller/subsystem/admin_verbs)

/datum/controller/subsystem/admin_verbs/Recover()
	admin_verb_map = SSadmin_verbs.admin_verb_map
	holder_map = SSadmin_verbs.holder_map
	context_map = SSadmin_verbs.context_map
	admin_linkup_map = SSadmin_verbs.admin_linkup_map
	assosciations_by_ckey = SSadmin_verbs.assosciations_by_ckey

/datum/controller/subsystem/admin_verbs/Initialize()
	RegisterSignal(src, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(assosciate_with_waiting))
	admin_verb_map = list()
	admin_linkup_map = list()
	generate_holder_map()
	context_map = list()
	populate_context_map(context_map)
	assosciations_by_ckey = list()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/admin_verbs/proc/generate_stat_data(client/target)
	var/static/list/abbreviations = list(
		"ERT"
	)
	var/static/list/cached_formats = list()

	if(!initialized || !target.holder)
		return list()

	var/list/stat_data = list()
	for(var/verb_type in assosciations_by_ckey[target.ckey])
		var/list/verb_information = admin_verb_map[verb_type]
		var/verb_permissions = verb_information[VERB_MAP_PERMISSIONS]
		if(!check_rights_for(target, verb_permissions))
			continue

		var/verb_module = lowertext(verb_information[VERB_MAP_MODULE])
		if(!verb_module || verb_module == "null")
			continue

		if(!cached_formats[verb_module])
			var/verb_module_formatted = ""
			for(var/verb_module_part in splittext(verb_module, "_"))
				if(verb_module_part in abbreviations)
					verb_module_formatted += "[uppertext(verb_module_part)] "
				else
					verb_module_formatted += "[capitalize(verb_module_part)] "
			verb_module_formatted = copytext(verb_module_formatted, 1, -1)
			cached_formats[verb_module] = verb_module_formatted

		var/original_name = verb_information[VERB_MAP_NAME]

		var/verb_desc = verb_information[VERB_MAP_DESCRIPTION]
		if(!stat_data[cached_formats[verb_module]])
			stat_data[cached_formats[verb_module]] = list()
		stat_data[cached_formats[verb_module]] += list(list(original_name, verb_desc, original_name))
	var/sorted_stat_data = list()
	for(var/verb_category in stat_data)
		sorted_stat_data[verb_category] = sort_list(stat_data[verb_category], GLOBAL_PROC_REF(cmp_admin_verb_name))
	return sorted_stat_data

/proc/cmp_admin_verb_name(list/info_left, list/info_right)
	return sorttext(info_right[1], info_left[1])

/datum/controller/subsystem/admin_verbs/proc/populate_context_map(list/context_map)
	return

/datum/controller/subsystem/admin_verbs/proc/generate_holder_map()
	admin_verb_map = list()
	holder_map = list()
	var/list/processing = typecacheof(sort_list(subtypesof(/mob/admin_module_holder), GLOBAL_PROC_REF(cmp_typepaths_asc)))
	processing -= typecache_next_level(/mob/admin_module_holder)
	for(var/mob/admin_module_holder/holder_type as anything in processing)
		var/mob/admin_module_holder/holder = new holder_type
		holder_map[holder_type] = holder
		admin_verb_map[holder_type] = holder.dynamic_map_generate()

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_admin_verb(mob/target, verb_type, ...)
	if(IsAdminAdvancedProcCall())
		return

	var/mob/admin_module_holder/holder = holder_map[verb_type]
	if(!istype(holder))
		to_chat(usr, span_big("Attempted to dynamic invoke an admin verb that didnt exist, this is a really bad problem!"))
		CRASH("Admin Verb Holder '[verb_type]' did not exist when an attempt to access the dynmap occured.")

	if(IS_CLIENT_OR_MOCK(target))
		var/client/clientele = target
		target = clientele.mob

	usr = target
	var/holder_proc = text2path("[verb_type]/verb/invoke")
	var/list/arguments = args.Copy(3)
	call(holder, holder_proc)(arglist(arguments))

/datum/controller/subsystem/admin_verbs/proc/link_admin(mob/admin)
	assosciations_by_ckey[admin.ckey] = list()
	for(var/mob/admin_module_holder/holder as anything in holder_map)
		holder = holder_map[holder]
		if(check_rights_for(admin.client, admin_verb_map[holder.type][VERB_MAP_PERMISSIONS]))
			admin.group |= holder
			assosciations_by_ckey[admin.ckey] |= list(holder.type)

	var/list/client_context_verbs = admin_linkup_map[admin.ckey][LINKUPMAP_CONTEXT_MAP]
	for(var/context_entry in context_map)
		var/list/context_information = context_map[context_entry]

		var/procpath/existing = client_context_verbs[context_entry]
		if(existing)
			admin.client.verbs -= existing

		if(!check_rights_for(admin.client, context_information[CONTEXT_MAP_PERMISSIONS]))
			continue
		client_context_verbs[context_entry] = new context_entry(admin.client, context_information[CONTEXT_MAP_NAME])

/datum/controller/subsystem/admin_verbs/proc/unlink_admin(mob/adwas)
	for(var/mob/admin_module_holder/holder as anything in holder_map)
		holder = holder_map[holder]
		adwas.group -= holder
	assosciations_by_ckey -= adwas.canon_client.ckey

	// we use canon_client here because ckey will already have moved when this is called
	var/list/client_context_verbs = admin_linkup_map[adwas.canon_client.ckey][LINKUPMAP_CONTEXT_MAP]
	for(var/context_entry in context_map)
		adwas.canon_client.verbs -= client_context_verbs[context_entry]

/datum/controller/subsystem/admin_verbs/proc/assosciate_admin(client/admin)
	if(!initialized)
		to_chat_immediate(admin, span_admin("SSadmin_verbs has either not begun or has not finished initialization procedures, please wait!"))
		waiting_to_assosciate |= admin.ckey
		return

	var/list/existing_map = admin_linkup_map[admin.ckey]
	if(existing_map)
		admin.player_details.post_login_callbacks -= existing_map[LINKUPMAP_LOGIN]

		var/datum/callback/old_logout = existing_map[LINKUPMAP_LOGOUT]
		admin.player_details.post_logout_callbacks -= old_logout
		old_logout.Invoke(admin.mob)

	var/on_login = CALLBACK(src, PROC_REF(link_admin))
	var/on_logout = CALLBACK(src, PROC_REF(unlink_admin))
	admin_linkup_map[admin.ckey] = list(on_logout, on_login, list())

	admin.player_details.post_login_callbacks += list(on_login)
	admin.player_details.post_logout_callbacks += list(on_logout)
	link_admin(admin.mob)
	SSstatpanels.set_admin_verb_tab(admin)

/datum/controller/subsystem/admin_verbs/proc/deassosciate_admin(client/adwas)
	unlink_admin(adwas.mob) // we unlink before clearing the linkup map because unlink checks the map for context entries to remove
	admin_linkup_map -= list(adwas.ckey)
	SSstatpanels.set_admin_verb_tab(adwas)

/datum/controller/subsystem/admin_verbs/proc/assosciate_with_waiting()
	for(var/waiting in waiting_to_assosciate)
		if(waiting in GLOB.directory)
			assosciate_admin(GLOB.directory[waiting])
	waiting_to_assosciate.Cut()

/datum/controller/subsystem/admin_verbs/proc/handle_admin_holder_topic(client/user, href, href_list)
	if(href_list["adminchecklaws"])
		dynamic_invoke_admin_verb(user, /mob/admin_module_holder/game/check_ai_laws)
		return TRUE
	return FALSE
