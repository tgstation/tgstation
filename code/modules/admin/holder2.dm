GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

#define RESULT_2FA_VALID 1
#define RESULT_2FA_ID 2

/datum/admins
	var/list/datum/admin_rank/ranks

	var/target
	var/name = "nobody's admin datum (no rank)" //Makes for better runtimes
	var/client/owner = null
	var/fakekey = null

	var/datum/marked_datum

	var/spamcooldown = 0

	///Randomly generated signature used for security records authorization name.
	var/admin_signature

	var/href_token

	/// Link from the database pointing to the admin's feedback forum
	var/cached_feedback_link

	var/deadmined

	var/datum/filter_editor/filteriffic
	var/datum/particle_editor/particle_test
	var/datum/colorblind_tester/color_test
	var/datum/plane_master_debug/plane_debug
	var/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/library_manager
	var/datum/pathfind_debug/path_debug

	/// Whether or not the user tried to connect, but was blocked by 2FA
	var/blocked_by_2fa = FALSE

	/// Whether or not this user can bypass 2FA
	var/bypass_2fa = FALSE

	/// A lazylist of tagged datums, for quick reference with the View Tags verb
	var/list/tagged_datums

	var/given_profiling = FALSE

/datum/admins/New(list/datum/admin_rank/ranks, ckey, force_active = FALSE, protected)
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a ckey")
	if(!istype(ranks))
		QDEL_IN(src, 0)
		CRASH("Admin datum created with invalid ranks: [ranks] ([json_encode(ranks)])")
	target = ckey
	name = "[ckey]'s admin datum ([join_admin_ranks(ranks)])"
	src.ranks = ranks
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	href_token = GenerateToken()
	//only admins with +ADMIN start admined
	if(protected)
		GLOB.protected_admins[target] = src
	if (force_active || (rank_flags() & R_AUTOADMIN))
		activate()
	else
		deactivate()

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return QDEL_HINT_LETMELIVE
	QDEL_NULL(path_debug)
	return ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	plane_debug = new(src)
	if (GLOB.directory[target])
		associate(GLOB.directory[target]) //find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	QDEL_NULL(plane_debug)
	QDEL_NULL(path_debug)
	deadmined = TRUE

	var/client/client = owner || GLOB.directory[target]

	if (!isnull(client))
		disassociate()
		add_verb(client, /client/proc/readmin)
		client.disable_combo_hud()
		client.update_special_keybinds()

/datum/admins/proc/associate(client/client)
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return

	if(!istype(client))
		return

	if(client?.ckey != target)
		var/msg = " has attempted to associate with [target]'s admin datum"
		message_admins("[key_name_admin(client)][msg]")
		log_admin("[key_name(client)][msg]")
		return

	var/result_2fa = check_2fa(client)
	if (!result_2fa[RESULT_2FA_VALID])
		blocked_by_2fa = TRUE
		alert_2fa_necessary(client)
		start_2fa_process(client, result_2fa[RESULT_2FA_ID])

		return
	else if (blocked_by_2fa)
		//previously blocked by 2fa but has now verified, sync the lastadminrank column on the player table.
		sync_lastadminrank(client.ckey, client.key, src)

	blocked_by_2fa = FALSE

	if (deadmined)
		activate()

	remove_verb(client, /client/proc/admin_2fa_verify)

	owner = client
	owner.holder = src
	owner.add_admin_verbs()
	remove_verb(owner, /client/proc/readmin)
	owner.init_verbs() //re-initialize the verb list
	owner.update_special_keybinds()
	GLOB.admins |= client

	try_give_profiling()

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		alert_to_permissions_elevation_attempt(usr)
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/// Returns the feedback forum thread for the admin holder's owner, as according to DB.
/datum/admins/proc/feedback_link()
	// This intentionally does not follow the 10-second maximum TTL rule,
	// as this can be reloaded through the Reload-Admins verb.
	if (cached_feedback_link == NO_FEEDBACK_LINK)
		return null

	if (!isnull(cached_feedback_link))
		return cached_feedback_link

	if (!SSdbcore.IsConnected())
		return null

	var/datum/db_query/feedback_query = SSdbcore.NewQuery("SELECT feedback FROM [format_table_name("admin")] WHERE ckey = '[owner.ckey]'")

	if(!feedback_query.Execute())
		log_sql("Error retrieving feedback link for [src]")
		qdel(feedback_query)
		return null

	if(!feedback_query.NextRow())
		qdel(feedback_query)
		return null // no feedback link exists

	cached_feedback_link = feedback_query.item[1] || NO_FEEDBACK_LINK
	qdel(feedback_query)

	if (cached_feedback_link == NO_FEEDBACK_LINK) // Because we don't want to send fake clickable links.
		return null

	return cached_feedback_link

/datum/admins/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank_flags()))
		return FALSE
	return TRUE

/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!other)
		return TRUE //they have no rights
	if(rank_flags() == R_EVERYTHING)
		return TRUE //we have all the rights
	if(src == other)
		return TRUE //you always have more rights than yourself
	if(rank_flags() != other.rank_flags())
		if( (rank_flags() & other.rank_flags()) == other.rank_flags() )
			return TRUE //we have all the rights they have and more
	return FALSE

// TRUE for a vaild connection, null is the id (it is unnecessary)
#define VALID_2FA_CONNECTION list(TRUE, null)

/// Returns whether or not the given client has a verified 2FA connection.
/// The output is in the form of a list with the first index being whether or not the
/// check was successful, the 2nd is the ID of the associated database entry
/// if its a false result and if one can be found.
/datum/admins/proc/check_2fa(client/client)
	if (bypass_2fa)
		return VALID_2FA_CONNECTION

	var/admin_2fa_url = CONFIG_GET(string/admin_2fa_url)

	// 2FA not being enabled == everyone passes
	if (isnull(admin_2fa_url) || admin_2fa_url == "")
		return VALID_2FA_CONNECTION

	// I believe this is only in the case of Dream Seeker.
	if (isnull(client?.address))
		return VALID_2FA_CONNECTION

	if (!SSdbcore.Connect())
		if (verify_admin_from_local_cache(client) || (client.ckey in GLOB.protected_admins))
			return VALID_2FA_CONNECTION
		else
			return list(FALSE, null)

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT id, verification_time FROM [format_table_name("admin_connections")]
		WHERE ckey = :ckey
		AND ip = INET_ATON(:ip)
		AND cid = :cid
	"}, list(
		"ckey" = client.ckey,
		"ip" = client.address,
		"cid" = client.computer_id,
	))

	if (!query.Execute())
		if (verify_admin_from_local_cache(client) || (client.ckey in GLOB.protected_admins))
			return VALID_2FA_CONNECTION
		return list(FALSE, null)

	var/is_valid = FALSE
	var/id = null

	if (query.NextRow())
		id = query.item[1]
		is_valid = !isnull(query.item[2])

	qdel(query)
	return list(is_valid, id)

#undef VALID_2FA_CONNECTION

#define ERROR_2FA_REQUEST_PERMISSIONS "<h1><b class='danger'>You could not be verified, and a DB connection couldn't be established. Please contact an admin with +PERMISSIONS to grant you permission.</b></h1>"

/datum/admins/proc/start_2fa_process(client/client, id)
	add_verb(client, /client/proc/admin_2fa_verify)
	client?.init_verbs()

	var/admin_2fa_url = CONFIG_GET(string/admin_2fa_url)

	if (!SSdbcore.Connect())
		to_chat(
			client,
			type = MESSAGE_TYPE_ADMINLOG,
			html = ERROR_2FA_REQUEST_PERMISSIONS,
			confidential = TRUE,
		)

		return

	if (isnull(id))
		var/datum/db_query/insert_query = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_connections")] (ckey, ip, cid)
			VALUES(:ckey, INET_ATON(:ip), :cid)
		"}, list(
			"ckey" = client.ckey,
			"ip" = client.address,
			"cid" = client.computer_id,
		))

		if (!insert_query.Execute())
			qdel(insert_query)
			to_chat(
				client,
				type = MESSAGE_TYPE_ADMINLOG,
				html = ERROR_2FA_REQUEST_PERMISSIONS,
				confidential = TRUE,
			)

			return

		id = insert_query.last_insert_id

	var/url_for_2fa = replacetextEx(admin_2fa_url, "%ID%", id)
	to_chat(
		client,
		type = MESSAGE_TYPE_ADMINLOG,
		html = {"
			<h1><b class='danger'>You could not be verified.</b></h1>
			<h2><b class='danger'>Please visit <a href='[url_for_2fa]'>[url_for_2fa]</a> to verify.</b></h2>
			<h2><b class='danger'>When you are done, click the 'Verify Admin' button in your admin tab.</b></h2>
		"},
		confidential = TRUE,
	)

#undef ERROR_2FA_REQUEST_PERMISSIONS

/// Returns true if the admin's cid/ip is verified in the local cache
/datum/admins/proc/verify_admin_from_local_cache(client/client)
	var/backup_filename = "data/admin_connections/[ckey(client?.ckey)].json"
	if (!fexists(backup_filename))
		return FALSE
	var/backup_file = file2text(backup_filename)
	if (isnull(backup_file))
		log_world("Unable to load admin connection's last_connections.json backup file.")
		return FALSE

	var/list/connections = json_decode(backup_file)

	if (isnull(connections))
		return FALSE

	for (var/list/connection as anything in connections)
		if (!islist(connection) || length(connection) < 2)
			stack_trace("Invalid connection in admin connections backup file for `[client]`.")
			continue
		if (connection["cid"] == client?.computer_id && connection["ip"] == client?.address)
			return TRUE

	return FALSE


/datum/admins/proc/alert_2fa_necessary(client/client)
	var/msg = " is trying to join, but needs to verify their ckey."
	message_admins("[key_name_admin(client)][msg]")
	log_admin("[key_name(client)][msg]")

	for (var/client/admin_client as anything in GLOB.admins)
		if (admin_client == client)
			continue

		if (!check_rights_for(admin_client, R_PERMISSIONS))
			continue

		to_chat(
			admin_client,
			type = MESSAGE_TYPE_ADMINLOG,
			html = span_admin("[span_prefix("ADMIN 2FA:")] You have the ability to verify [key_name_admin(client)] by using the Permissions Panel."),
			confidential = TRUE,
		)

/datum/admins/proc/backup_connections()
	set waitfor = FALSE
	if (!length(CONFIG_GET(string/admin_2fa_url)))
		return
	var/ckey = ckey(target)
	if (!ckey)
		CRASH("can't backup an admin datum assigned to a blank ckey")

	if (!SSdbcore.Connect())
		return

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT cid, INET_NTOA(ip) as ip FROM [format_table_name("admin_connections")]
		WHERE
			ckey = :ckey AND verification_time IS NOT NULL
	"}, list(
		"ckey" = ckey,
	))

	if (!query.Execute())
		qdel(query)
		return
	var/list/admin_connections = list()
	while (query.NextRow())
		admin_connections += LIST_VALUE_WRAP_LISTS(list(
			"cid" = query.item[1],
			"ip" = query.item[2],
		))

	qdel(query)

	if (length(admin_connections) < 1)
		return


	var/backup_file = "data/admin_connections/[ckey].json"
	if (fexists(backup_file))
		fdel(backup_file)
	WRITE_FILE(file(backup_file), json_encode(admin_connections, JSON_PRETTY_PRINT))

/// Get the rank name of the admin
/datum/admins/proc/rank_names()
	return join_admin_ranks(ranks)

/// Get the rank flags of the admin
/datum/admins/proc/rank_flags()
	var/combined_flags = NONE

	for (var/datum/admin_rank/rank as anything in ranks)
		combined_flags |= rank.rights

	return combined_flags

/// Get the permissions this admin is allowed to edit on other ranks
/datum/admins/proc/can_edit_rights_flags()
	var/combined_flags = NONE

	for (var/datum/admin_rank/rank as anything in ranks)
		combined_flags |= rank.can_edit_rights

	return combined_flags

/datum/admins/proc/try_give_profiling()
	if (CONFIG_GET(flag/forbid_admin_profiling))
		return

	if (given_profiling)
		return

	if (!(rank_flags() & R_DEBUG))
		return

	given_profiling = TRUE
	world.SetConfig("APP/admin", owner.ckey, "role=admin")

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE //nice try trialmin

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

/proc/admin_proc()
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, "you have enough rights!", confidential = TRUE)

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr?.client)
		if (check_rights_for(usr.client, rights_required))
			return TRUE
		else
			if(show_msg)
				to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>", confidential = TRUE)
	return FALSE

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr?.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return TRUE
			return usr.client.holder.check_if_greater_rights_than_holder(other.holder)
	return FALSE

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject?.holder)
		return subject.holder.check_for_rights(rights_required)
	return FALSE

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok

/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"

/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"

#undef RESULT_2FA_VALID
#undef RESULT_2FA_ID
