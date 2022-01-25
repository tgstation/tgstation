GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

#define RESULT_2FA_VALID 1
#define RESULT_2FA_ID 2

/datum/admins
	var/datum/admin_rank/rank

	var/target
	var/name = "nobody's admin datum (no rank)" //Makes for better runtimes
	var/client/owner = null
	var/fakekey = null

	var/datum/marked_datum

	var/spamcooldown = 0

	var/admincaster_screen = 0 //TODO: remove all these 5 variables, they are completly unacceptable
	var/datum/newscaster/feed_message/admincaster_feed_message = new /datum/newscaster/feed_message
	var/datum/newscaster/wanted_message/admincaster_wanted_message = new /datum/newscaster/wanted_message
	var/datum/newscaster/feed_channel/admincaster_feed_channel = new /datum/newscaster/feed_channel
	var/admin_signature

	var/href_token

	var/deadmined

	var/datum/filter_editor/filteriffic

	/// Whether or not the user tried to connect, but was blocked by 2FA
	var/blocked_by_2fa = FALSE

	/// Whether or not this user can bypass 2FA
	var/bypass_2fa = FALSE

	/// A lazylist of tagged datums, for quick reference with the View Tags verb
	var/list/tagged_datums

/datum/admins/New(datum/admin_rank/R, ckey, force_active = FALSE, protected)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a ckey")
	if(!istype(R))
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a rank")
	target = ckey
	name = "[ckey]'s admin datum ([R])"
	rank = R
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	href_token = GenerateToken()
	if(CONFIG_GET(flag/allow_admin_profiling))
		if(R.rights & R_DEBUG) //grant profile access
			world.SetConfig("APP/admin", ckey, "role=admin")
	//only admins with +ADMIN start admined
	if(protected)
		GLOB.protected_admins[target] = src
	if (force_active || (R.rights & R_AUTOADMIN))
		activate()
	else
		deactivate()

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target]) //find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	deadmined = TRUE
	var/client/C
	if ((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		add_verb(C, /client/proc/readmin)

/datum/admins/proc/associate(client/client)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
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
		sync_lastadminrank(client.ckey, client.key)

	blocked_by_2fa = FALSE

	if (deadmined)
		activate()

	remove_verb(client, /client/proc/admin_2fa_verify)

	owner = client
	owner.holder = src
	owner.add_admin_verbs()
	remove_verb(owner, /client/proc/readmin)
	owner.init_verbs() //re-initialize the verb list
	GLOB.admins |= client

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.init_verbs()
		owner.holder = null
		owner = null

/datum/admins/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank.rights))
		return FALSE
	return TRUE


/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!other)
		return TRUE //they have no rights
	if(rank.rights == R_EVERYTHING)
		return TRUE //we have all the rights
	if(src == other)
		return TRUE //you always have more rights than yourself
	if(rank.rights != other.rank.rights)
		if( (rank.rights & other.rank.rights) == other.rank.rights )
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
		if (verify_backup_data(client))
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
		qdel(query)
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

/datum/admins/proc/verify_backup_data(client/client)
	var/backup_file = file2text("data/admins_backup.json")
	if (isnull(backup_file))
		log_world("Unable to locate admins backup file.")
		return FALSE

	var/list/backup_file_json = json_decode(backup_file)
	var/connections = backup_file_json["connections"]

	// This can happen for older admins_backup.json files
	if (isnull(connections))
		return FALSE

	var/most_recent_valid_connection = connections[client?.ckey]
	if (isnull(most_recent_valid_connection))
		return FALSE

	return most_recent_valid_connection["cid"] == client?.computer_id \
		&& most_recent_valid_connection["ip"] == client?.address

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
