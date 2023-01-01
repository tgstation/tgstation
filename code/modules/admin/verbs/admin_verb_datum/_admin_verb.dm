#define MOB_LOG_IN 1
#define MOB_LOG_OUT 2

GLOBAL_LIST_INIT(admin_verb_datums, init_admin_verb_datums())
GLOBAL_PROTECT(admin_verb_datums)

/proc/init_admin_verb_datums()
	var/list/datums = list()
	for(var/datum/admin_verb_datum/admin_verb_datum as anything in subtypesof(/datum/admin_verb_datum))
		if(initial(admin_verb_datum.abstract) == admin_verb_datum)
			continue
		datums[admin_verb_datum] = new admin_verb_datum
	return datums

/proc/dynamic_invoke_admin_verb(client/target, verb_type, list/arguments)
	if(IsAdminAdvancedProcCall())
		return

	var/datum/admin_verb_datum/admin_verb = GLOB.admin_verb_datums[verb_type]
	if(!admin_verb || !check_rights_for(target, admin_verb.permission_required))
		return


	SSblackbox.record_feedback("tally", "admin_verb_datum", 1, admin_verb.verb_name) // remember to record feedback before invocation
	admin_verb.invoke(target, length(arguments) ? arguments : admin_verb.get_arguments(target))

/**
 * This acts a verb holder for all of the admin verbs, one is instantiated for every verb datum.
 * This is done to ensure that admins can still use the verb bar to call verbs, as this is a requirement for admin tooling.
 */
/mob/admin_verb_holder
	var/datum/admin_verb_datum/holder

GENERAL_PROTECT_DATUM(/mob/admin_verb_holder)

/mob/admin_verb_holder/New(loc, verb_datum)
	flags_1 |= INITIALIZED_1
	holder = verb_datum
	var/verb_ref = PROC_REF(_wrap)
	new verb_ref(src, holder.verb_name, holder.verb_desc)

/mob/admin_verb_holder/proc/_wrap()
	// We use group to act as a list of clients allowed to access this verb
	set src in usr.group

	// But we still double check rights
	if(check_rights_for(usr.client, holder.permission_required))
		SSblackbox.record_feedback("tally", "admin_verb_datum", 1, holder.verb_name) // remember to record feedback before invocation
		holder.invoke(usr.client, holder.get_arguments(usr.client))

/**
 * The base admin verb datum.
 * Essentially just a more readable wrapper for admin verbs over dumping them in a giant ass list.
 */
/datum/admin_verb_datum
	/// The name that will appear in the verb panel
	var/verb_name = "Default Admin Verb"
	/// An optional, CANNOT BE NULL, description to appear when you hover over a verb in the panel.
	var/verb_desc = ""
	/// The category of this verb, needs to be set to something
	var/verb_category = "Admin"

	/// The permissions required to both see and invoke this datum verb
	var/permission_required
	/// The abstract of the verb datum, to prevent creating abstract types
	var/abstract = /datum/admin_verb_datum

	/// The verb holder for this datum, ensuring admins retain verb bar usage
	VAR_PRIVATE/mob/admin_verb_holder/verb_holder
	/// An assosciative list of client -> callbacks[] to allow for mob tracking to update verb grouping
	VAR_PRIVATE/list/client_to_callbacks

GENERAL_PROTECT_DATUM(/datum/admin_verb_datum)

/datum/admin_verb_datum/New()
	SHOULD_NOT_OVERRIDE(TRUE)
	verb_holder = new(null, src)

/datum/admin_verb_datum/Topic(href, list/href_list)
	..()
	if(!usr.client?.holder?.CheckAdminHref(href, href_list))
		return
	if(!check_rights_for(usr.client, permission_required))
		return

	if(href_list["invoke"])
		SSblackbox.record_feedback("tally", "admin_verb_datum", 1, verb_name) // remember to record feedback before invocation
		invoke(usr.client, get_arguments(usr.client))

// The following procs only exist to support verb bar usage and can be removed when that is no longer required.

/datum/admin_verb_datum/proc/on_mob_login(mob/logged_in)
	SHOULD_NOT_OVERRIDE(TRUE)
	logged_in.group |= verb_holder

/datum/admin_verb_datum/proc/on_mob_logout(mob/logged_out)
	SHOULD_NOT_OVERRIDE(TRUE)
	logged_out.group -= verb_holder

/datum/admin_verb_datum/proc/assosciate(client/admin)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!check_rights_for(admin, permission_required))
		return

	var/datum/callback/on_login = CALLBACK(src, PROC_REF(on_mob_login))
	var/datum/callback/on_logout = CALLBACK(src, PROC_REF(on_mob_logout))
	LAZYSET(client_to_callbacks, admin.ckey, list(on_login, on_logout))

	var/datum/player_details/player_details = admin.player_details

	player_details.post_login_callbacks += on_login
	player_details.post_logout_callbacks += on_logout

	// If this is being called in client/New they will not actually have a mob yet!
	if(admin.mob?.flags_1 & INITIALIZED_1)
		on_mob_login(admin.mob)

/datum/admin_verb_datum/proc/deassosciate(client/admin)
	var/datum/callback/callback = LAZYACCESSASSOC(client_to_callbacks, admin.ckey, MOB_LOG_OUT)
	if(!callback)
		return

	LAZYREMOVE(client_to_callbacks, admin.ckey)
	callback.Invoke(admin.mob)

// end group //

/datum/admin_verb_datum/proc/get_arguments(client/target)
	return

/datum/admin_verb_datum/proc/invoke(client/target, list/arguments)
	return

#undef MOB_LOG_IN
#undef MOB_LOG_OUT
