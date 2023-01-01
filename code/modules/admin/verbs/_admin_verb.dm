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

/mob/admin_verb_holder
	var/datum/admin_verb_datum/holder

GENERAL_PROTECT_DATUM(/mob/admin_verb_holder)

/mob/admin_verb_holder/New(loc, verb_datum)
	flags_1 |= INITIALIZED_1
	holder = verb_datum
	var/verb_ref = PROC_REF(_wrap)
	UNLINT(holder.verb_instance = new verb_ref(src, holder.verb_name, holder.verb_desc))

/mob/admin_verb_holder/proc/_wrap()
	set src in usr.group
	set category = "Admin.Debug"

	holder.invoke()

/datum/admin_verb_datum
	var/verb_name = "Default Admin Verb"
	var/verb_desc = ""
	var/verb_category = "Default"

	var/permission_required = R_ADMIN
	var/abstract = /datum/admin_verb_datum

	VAR_PRIVATE/procpath/verb_instance
	VAR_PRIVATE/mob/admin_verb_holder/verb_holder
	VAR_PRIVATE/list/client_to_callbacks

GENERAL_PROTECT_DATUM(/datum/admin_verb_datum)

/datum/admin_verb_datum/New()
	SHOULD_NOT_OVERRIDE(TRUE)
	verb_holder = new(null, src)

/datum/admin_verb_datum/Topic(href, list/href_list)
	..()
	if(!usr.client?.holder?.CheckAdminHref(href, href_list))
		return

	if(href_list["invoke"])
		invoke()

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
	callback.Invoke()

/datum/admin_verb_datum/proc/invoke()
	return

#undef MOB_LOG_IN
#undef MOB_LOG_OUT

/datum/admin_verb_datum/debug
	permission_required = R_DEBUG
	abstract = /datum/admin_verb_datum/debug
	verb_category = "Debug"

/datum/admin_verb_datum/server
	permission_required = R_SERVER
	abstract = /datum/admin_verb_datum/server
	verb_category = "Server"

/datum/admin_verb_datum/debug/ping_a
	verb_name = "PingA"

/datum/admin_verb_datum/debug/ping_b
	verb_name = "PingB"

/datum/admin_verb_datum/debug/ping_c
	verb_name = "PingC"

/datum/admin_verb_datum/debug/ping_d
	verb_name = "PingD"

/datum/admin_verb_datum/server/ping_a
	verb_name = "PingSA"

/datum/admin_verb_datum/server/ping_b
	verb_name = "PingSB"

/datum/admin_verb_datum/server/ping_c
	verb_name = "PingSC"

/datum/admin_verb_datum/server/ping_d
	verb_name = "PingSD"
