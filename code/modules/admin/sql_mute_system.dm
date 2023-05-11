/**
 * Wrapper for persistent mute management.
 */
/datum/persistent_mute_manager
	/// This is used to cache db information without needing to poll the database constantly.
	/// ckey -> /list[/datum/persistent_mute_holder]
	var/list/user_cache

	/// All unique ckeys that have persistent mutes.
	var/list/ckey_cache

	/// List of ckeys being polled
	var/list/polling_ckeys

/// This is better than using keys in a list.
/datum/persistent_mute_holder
	var/id
	var/ckey
	var/muted_flag
	var/reason
	var/admin
	var/datetime
	var/deleted
	var/deleted_datetime

/datum/persistent_mute_manager/New()
	user_cache = list()
	ckey_cache = list()
	polling_ckeys = list()

	poll_ckey_cache()
	return ..()

/datum/persistent_mute_manager/Destroy(force, ...)
	user_cache.Cut() // should only be a list of strings, but just in case
	return ..()

/client/proc/view_edit_persistent_mutes()
	set name = "Persistent Mute Manager"
	set category = "Admin"
	set desc = "View and edit persistent mutes."

	var/static/datum/persistent_mute_manager/mute_manager
	if(isnull(mute_manager))
		mute_manager = new
	mute_manager.ui_interact(mob)

/datum/persistent_mute_manager/proc/poll_ckey_cache()
	var/list/ckeys = list()

	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		SELECT DISTINCT ckey FROM [format_table_name("muted")]
	"})

	if(!mute_flags_query.Execute())
		qdel(mute_flags_query)
		return FALSE

	while(mute_flags_query.NextRow())
		ckeys += mute_flags_query.item[1]
	qdel(mute_flags_query)

	ckey_cache = ckeys
	return TRUE

/datum/persistent_mute_manager/proc/poll_ckey_mutes(ckey)
	polling_ckeys |= ckey

	var/found_mutes = get_all_persistent_mutes_for(ckey, FALSE)
	if(isnull(found_mutes))
		polling_ckeys -= ckey
		return FALSE

	var/list/mutes = list()
	for(var/datum/persistent_mute_holder/mute_info as anything in found_mutes)
		mutes += mute_info
	user_cache[ckey] = mutes

	polling_ckeys -= ckey
	SStgui.update_uis(src)
	return TRUE

/datum/persistent_mute_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/persistent_mute_manager/ui_data(mob/user)
	var/list/data = list(
		"ckey_cache" = ckey_cache,
	)

	var/list/mutes = list()
	for(var/ckey in user_cache)
		var/list/mute_data = list()
		for(var/datum/persistent_mute_holder/mute_holder as anything in user_cache[ckey])
			mute_data += list(list(
				"id" = mute_holder.id,
				"muted_flag" = mute_holder.muted_flag,
				"reason" = mute_holder.reason,
				"admin" = mute_holder.admin,
				"datetime" = mute_holder.datetime,
				"deleted" = mute_holder.deleted,
				"deleted_datetime" = mute_holder.deleted_datetime,
				))
		mutes[ckey] = mute_data
	data["mutes"] = mutes
	data["polling_ckeys"] = polling_ckeys
	data["whoami"] = user.ckey
	return data

/datum/persistent_mute_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "PersistentMuteManager")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/persistent_mute_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	if(!check_rights(R_ADMIN))
		return // theoretically handled by GLOB.admin_state

	var/datum/persistent_mute_holder/mute_information
	if("id" in params)
		mute_information = get_mute_by_id(params["id"])

	switch(action)
		if("refresh")
			if(!poll_ckey_cache())
				to_chat(usr, span_alertwarning("Failed to poll ckey cache."))
			return TRUE

		if("poll-ckey")
			ASYNC
				if(!poll_ckey_mutes(params["ckey"], params["active_only"] || TRUE))
					to_chat(usr, span_alertwarning("Failed to poll ckey."))
			return TRUE

		if("delete")
			if(isnull(mute_information))
				to_chat(usr, span_alertwarning("Failed to find mute information."))
				return TRUE

			if(!remove_persistent_mute_for(mute_information.ckey, mute_information.id, mute_information.muted_flag))
				to_chat(usr, span_alertwarning("Failed to remove persistent mute."))
				return TRUE

			to_chat(usr, span_adminnotice("Removed persistent mute."))
			ASYNC
				if(!poll_ckey_mutes(params["ckey"], params["active_only"] || TRUE))
					to_chat(usr, span_alertwarning("Failed to poll ckey."))

			return TRUE

		if("edit")
			return

		if("add")
			return

		else
			stack_trace("unhandled pmm action: [action]")
			return

/datum/persistent_mute_manager/proc/get_all_persistent_mutes_for(ckey, active_only = TRUE)
	var/list/mutes = list()
	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		SELECT id, muted_flag, reason, admin, datetime, deleted, deleted_datetime FROM [format_table_name("muted")]
		WHERE ckey = :ckey
		[active_only ? "AND deleted = 0" : ""]
	"}, list("ckey" = ckey))

	if(!mute_flags_query.Execute())
		qdel(mute_flags_query)
		return null

	while(mute_flags_query.NextRow())
		var/datum/persistent_mute_holder/mute_info = new
		mute_info.ckey = ckey
		mute_info.id = mute_flags_query.item[1]
		mute_info.muted_flag = mute_flags_query.item[2]
		mute_info.reason = mute_flags_query.item[3]
		mute_info.admin = mute_flags_query.item[4]
		mute_info.datetime = mute_flags_query.item[5]
		mute_info.deleted = mute_flags_query.item[6]
		mute_info.deleted_datetime = mute_flags_query.item[7]
		mutes += mute_info

	qdel(mute_flags_query)
	return mutes

/datum/persistent_mute_manager/proc/remove_persistent_mute_for(ckey, id, expected_flag)
	// poll for mutes, grab the id we're expecting
	var/datum/persistent_mute_holder/existing_mute
	for(var/datum/persistent_mute_holder/mute_info as anything in get_all_persistent_mutes_for(ckey))
		if(mute_info.id == id)
			existing_mute = mute_info
			break
	if(!existing_mute)
		return FALSE
	if(existing_mute.muted_flag != expected_flag)
		return FALSE
	if(existing_mute.deleted)
		return FALSE

	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		UPDATE [format_table_name("muted")]
		SET deleted = 1
		SET deleted_datetime = NOW()
		WHERE id = :id
	"}, list("id" = id))
	mute_flags_query.Execute()
	qdel(mute_flags_query)

	// removed, reparse their mutes
	var/client/target = GLOB.directory[ckey]
	if(target)
		target.prefs.load_mutes_from_database()
	return TRUE

/datum/persistent_mute_manager/proc/add_persistent_mute_for(ckey, muted_flag, reason, admin)
	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("muted")] (ckey, muted_flag, reason, admin)
		VALUES (:ckey, :muted_flag, :reason, :admin)
	"}, list(
		"ckey" = ckey,
		"muted_flag" = muted_flag,
		"reason" = reason,
		"admin" = admin,
	))
	mute_flags_query.Execute()
	qdel(mute_flags_query)

	var/client/target = GLOB.directory[ckey]
	if(target)
		target.prefs.load_mutes_from_database()

/datum/persistent_mute_manager/proc/get_mute_by_id(id, from_cache = TRUE)
	if(from_cache)
		for(var/ckey in user_cache)
			for(var/datum/persistent_mute_holder/mute_holder as anything in user_cache[ckey])
				if(mute_holder.id == id)
					return mute_holder

	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		SELECT ckey, muted_flag, reason, admin, datetime, deleted FROM [format_table_name("muted")]
		WHERE id = :id
	"}, list("id" = id))
	mute_flags_query.Execute()
	if(!mute_flags_query.NextRow())
		qdel(mute_flags_query)
		return FALSE

	var/datum/persistent_mute_holder/mute_information = new
	mute_information.id = id
	mute_information.ckey = mute_flags_query.item[1]
	mute_information.muted_flag = mute_flags_query.item[2]
	mute_information.reason = mute_flags_query.item[3]
	mute_information.admin = mute_flags_query.item[4]
	mute_information.datetime = mute_flags_query.item[5]
	mute_information.deleted = mute_flags_query.item[6]

	qdel(mute_flags_query)
	return mute_information
