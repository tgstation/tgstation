
ADMIN_VERB(edit_admin_permissions, R_PERMISSIONS, "Permissions Panel", "Edit admin permissions.", ADMIN_CATEGORY_MAIN)
	user.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions(action, target, operation, page)
	if(!check_rights(R_PERMISSIONS))
		return
	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/group/permissions)
	asset_cache_datum.send(usr)
	var/list/output = list("<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url("panels.css")]'><a href='byond://?_src_=holder;[HrefToken()];editrightsbrowser=1'>\[Permissions\]</a>")
	if(action)
		output += " | <a href='byond://?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightspage=0'>\[Log\]</a> | <a href='byond://?_src_=holder;[HrefToken()];editrightsbrowsermanage=1'>\[Management\]</a><hr style='background:#000000; border:0; height:3px'>"
	else
		output += "<br><a href='byond://?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightspage=0'>\[Log\]</a><br><a href='byond://?_src_=holder;[HrefToken()];editrightsbrowsermanage=1'>\[Management\]</a>"
	if(action == 1)
		var/logcount = 0
		var/logssperpage = 20
		var/pagecount = 0
		page = text2num(page)
		var/datum/db_query/query_count_admin_logs = SSdbcore.NewQuery(
			"SELECT COUNT(id) FROM [format_table_name("admin_log")] WHERE (:target IS NULL OR adminckey = :target) AND (:operation IS NULL OR operation = :operation)",
			list("target" = target, "operation" = operation)
		)
		if(!query_count_admin_logs.warn_execute())
			qdel(query_count_admin_logs)
			return
		if(query_count_admin_logs.NextRow())
			logcount = text2num(query_count_admin_logs.item[1])
		qdel(query_count_admin_logs)
		if(logcount > logssperpage)
			output += "<br><b>Page: </b>"
			while(logcount > 0)
				output += "|<a href='byond://?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightstarget=[target];editrightsoperation=[operation];editrightspage=[pagecount]'>[pagecount == page ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
				logcount -= logssperpage
				pagecount++
			output += "|"
		var/datum/db_query/query_search_admin_logs = SSdbcore.NewQuery({"
			SELECT
				datetime,
				round_id,
				IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), adminckey),
				operation,
				IF(ckey IS NULL, target, byond_key),
				log
			FROM [format_table_name("admin_log")]
			LEFT JOIN [format_table_name("player")] ON target = ckey
			WHERE (:target IS NULL OR ckey = :target) AND (:operation IS NULL OR operation = :operation)
			ORDER BY datetime DESC
			LIMIT :skip, :take
		"}, list("target" = target, "operation" = operation, "skip" = logssperpage * page, "take" = logssperpage))
		if(!query_search_admin_logs.warn_execute())
			qdel(query_search_admin_logs)
			return
		while(query_search_admin_logs.NextRow())
			var/datetime = query_search_admin_logs.item[1]
			var/round_id = query_search_admin_logs.item[2]
			var/admin_key = query_search_admin_logs.item[3]
			operation = query_search_admin_logs.item[4]
			target = query_search_admin_logs.item[5]
			var/log = query_search_admin_logs.item[6]
			output += "<p style='margin:0px'><b>[datetime] | Round ID [round_id] | Admin [admin_key] | Operation [operation] on [target]</b><br>[log]</p><hr style='background:#000000; border:0; height:3px'>"
		qdel(query_search_admin_logs)
	if(action == 2)
		output += "<h3>Admin ckeys with invalid ranks</h3>"
		var/datum/db_query/query_check_admin_errors = SSdbcore.NewQuery("SELECT IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("admin")].ckey), ckey), [format_table_name("admin")].`rank` FROM [format_table_name("admin")] LEFT JOIN [format_table_name("admin_ranks")] ON [format_table_name("admin_ranks")].`rank` = [format_table_name("admin")].`rank` WHERE [format_table_name("admin_ranks")].`rank` IS NULL")
		if(!query_check_admin_errors.warn_execute())
			qdel(query_check_admin_errors)
			return
		while(query_check_admin_errors.NextRow())
			var/admin_key = query_check_admin_errors.item[1]
			var/admin_rank = query_check_admin_errors.item[2]
			output += "[admin_key] has non-existent rank [admin_rank] | <a href='byond://?_src_=holder;[HrefToken()];editrightsbrowsermanage=1;editrightschange=[admin_key]'>\[Change Rank\]</a> | <a href='byond://?_src_=holder;[HrefToken()];editrightsbrowsermanage=1;editrightsremove=[admin_key]'>\[Remove\]</a>"
			output += "<hr style='background:#000000; border:0; height:1px'>"
		qdel(query_check_admin_errors)
		output += "<h3>Unused ranks</h3>"
		var/datum/db_query/query_check_unused_rank = SSdbcore.NewQuery("SELECT [format_table_name("admin_ranks")].`rank`, flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")] LEFT JOIN [format_table_name("admin")] ON [format_table_name("admin")].`rank` = [format_table_name("admin_ranks")].`rank` WHERE [format_table_name("admin")].`rank` IS NULL")
		if(!query_check_unused_rank.warn_execute())
			qdel(query_check_unused_rank)
			return
		while(query_check_unused_rank.NextRow())
			var/admin_rank = query_check_unused_rank.item[1]
			output += {"Rank [admin_rank] is not held by any admin | <a href='byond://?_src_=holder;[HrefToken()];editrightsbrowsermanage=1;editrightsremoverank=[admin_rank]'>\[Remove\]</a>
			<br>Permissions: [rights2text(text2num(query_check_unused_rank.item[2])," ")]
			<br>Denied: [rights2text(text2num(query_check_unused_rank.item[3])," ", "-")]
			<br>Allowed to edit: [rights2text(text2num(query_check_unused_rank.item[4])," ", "*")]
			<hr style='background:#000000; border:0; height:1px'>"}
		qdel(query_check_unused_rank)
	else if(!action)
		output += {"
		<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<title>Permissions Panel</title>
		<script type='text/javascript' src='[SSassets.transport.get_asset_url("search.js")]'></script>
		</head>
		<body onload='selectTextField();updateSearch();'>
		<div id='main'><table id='searchable' cellspacing='0'>
		<tr class='title'>
		<th style='width:150px;'>CKEY <a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=add'>\[+\]</a></th>
		<th style='width:125px;'>RANK</th>
		<th>PERMISSIONS</th>
		</tr>
		"}
		for(var/adm_ckey in GLOB.admin_datums+GLOB.deadmins)
			var/datum/admins/D = GLOB.admin_datums[adm_ckey]
			if(!D)
				D = GLOB.deadmins[adm_ckey]
				if (!D)
					continue
			var/deadminlink = ""
			if(D.owner)
				adm_ckey = D.owner.key
			if (D.deadmined)
				deadminlink = " <a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=activate;key=[adm_ckey]'>\[RA\]</a>"
			else
				deadminlink = " <a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=deactivate;key=[adm_ckey]'>\[DA\]</a>"

			var/verify_link = ""
			if (D.blocked_by_2fa)
				verify_link += " | <a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=verify;key=[adm_ckey]'>\[2FA VERIFY\]</a>"

			output += "<tr>"
			output += "<td style='text-align:center;'>[adm_ckey]<br>[deadminlink]<a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=remove;key=[adm_ckey]'>\[-\]</a><a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=sync;key=[adm_ckey]'>\[SYNC TGDB\]</a>[verify_link]</td>"
			output += "<td><a href='byond://?src=[REF(src)];[HrefToken()];editrights=rank;key=[adm_ckey]'>[D.rank_names()]</a></td>"
			output += "<td><a class='small' href='byond://?src=[REF(src)];[HrefToken()];editrights=permissions;key=[adm_ckey]'>[rights2text(D.rank_flags(), " ")]</a></td>"
			output += "</tr>"
		output += "</table></div><div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div></body>"
	if(QDELETED(usr))
		return
	usr << browse("<!DOCTYPE html><html>[jointext(output, "")]</html>","window=editrights;size=1000x650")

/datum/admins/proc/edit_rights_topic(list/href_list)
	if(!check_rights(R_PERMISSIONS))
		message_admins("[key_name_admin(usr)] attempted to edit admin permissions without sufficient rights.")
		log_admin("[key_name(usr)] attempted to edit admin permissions without sufficient rights.")
		return
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Edit blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return
	var/datum/asset/permissions_assets = get_asset_datum(/datum/asset/simple/namespaced/common)
	permissions_assets.send(usr.client)
	var/admin_key = href_list["key"]
	var/admin_ckey = ckey(admin_key)

	var/task = href_list["editrights"]
	var/datum/admins/target_admin_datum = GLOB.admin_datums[admin_ckey]
	if(!target_admin_datum)
		target_admin_datum = GLOB.deadmins[admin_ckey]
	if (!target_admin_datum && task != "add")
		return
	var/use_db
	var/skip
	var/legacy_only
	if(task == "activate" || task == "deactivate" || task == "sync" || task == "verify")
		skip = TRUE
	if(!CONFIG_GET(flag/admin_legacy_system) && CONFIG_GET(flag/protect_legacy_admins) && task == "rank")
		if(admin_ckey in GLOB.protected_admins)
			to_chat(usr, "<span class='admin prefix'>Editing the rank of this admin is blocked by server configuration.</span>", confidential = TRUE)
			return
	if(!CONFIG_GET(flag/admin_legacy_system) && CONFIG_GET(flag/protect_legacy_ranks) && task == "permissions")
		if((target_admin_datum.ranks & GLOB.protected_ranks).len > 0)
			to_chat(usr, "<span class='admin prefix'>Editing the flags of this rank is blocked by server configuration.</span>", confidential = TRUE)
			return
	if(CONFIG_GET(flag/load_legacy_ranks_only) && (task == "add" || task == "rank" || task == "permissions"))
		to_chat(usr, "<span class='admin prefix'>Database rank loading is disabled, only temporary changes can be made to a rank's permissions and permanently creating a new rank is blocked.</span>", confidential = TRUE)
		legacy_only = TRUE
	if(check_rights(R_DBRANKS, FALSE))
		if(!skip)
			if(!SSdbcore.Connect())
				to_chat(usr, span_danger("Unable to connect to database, changes are temporary only."), confidential = TRUE)
				use_db = FALSE
			else
				use_db = tgui_alert(usr,"Permanent changes are saved to the database for future rounds, temporary changes will affect only the current round", "Permanent or Temporary?", list("Permanent", "Temporary", "Cancel"))
				if(use_db == "Cancel")
					return
				if(use_db == "Permanent")
					use_db = TRUE
				else
					use_db = FALSE
			if(QDELETED(usr))
				return

	if(target_admin_datum && (task != "sync" && task != "verify") && !check_if_greater_rights_than_holder(target_admin_datum))
		message_admins("[key_name_admin(usr)] attempted to change the rank of [admin_key] without sufficient rights.")
		log_admin("[key_name(usr)] attempted to change the rank of [admin_key] without sufficient rights.")
		return
	switch(task)
		if("add")
			admin_ckey = add_admin(admin_ckey, admin_key, use_db)
			if(!admin_ckey)
				return

			if(!admin_key) // Prevents failures in logging admin rank changes.
				admin_key = admin_ckey

			change_admin_rank(admin_ckey, admin_key, use_db, null, legacy_only)
		if("remove")
			remove_admin(admin_ckey, admin_key, use_db, target_admin_datum)
		if("rank")
			change_admin_rank(admin_ckey, admin_key, use_db, target_admin_datum, legacy_only)
		if("permissions")
			change_admin_flags(admin_ckey, admin_key, target_admin_datum)
		if("activate")
			force_readmin(admin_key, target_admin_datum)
		if("deactivate")
			force_deadmin(admin_key, target_admin_datum)
		if("sync")
			sync_lastadminrank(admin_ckey, admin_key, target_admin_datum)
		if("verify")
			var/msg = "has authenticated [admin_ckey]"
			message_admins("[key_name_admin(usr)] [msg]")
			log_admin("[key_name(usr)] [msg]")

			target_admin_datum.bypass_2fa = TRUE
			target_admin_datum.associate(GLOB.directory[admin_ckey])
	edit_admin_permissions()

/datum/admins/proc/add_admin(admin_ckey, admin_key, use_db)
	if(admin_ckey)
		. = admin_ckey
	else
		admin_key = input("New admin's key","Admin key") as text|null
		. = ckey(admin_key)
	if(!.)
		return FALSE
	if(!admin_ckey && (. in (GLOB.admin_datums+GLOB.deadmins)))
		to_chat(usr, span_danger("[admin_key] is already an admin."), confidential = TRUE)
		return FALSE
	if(use_db)
		//if an admin exists without a datum they won't be caught by the above
		var/datum/db_query/query_admin_in_db = SSdbcore.NewQuery(
			"SELECT 1 FROM [format_table_name("admin")] WHERE ckey = :ckey",
			list("ckey" = .)
		)
		if(!query_admin_in_db.warn_execute())
			qdel(query_admin_in_db)
			return FALSE
		if(query_admin_in_db.NextRow())
			qdel(query_admin_in_db)
			to_chat(usr, span_danger("[admin_key] already listed in admin database. Check the Management tab if they don't appear in the list of admins."), confidential = TRUE)
			return FALSE
		qdel(query_admin_in_db)
		var/datum/db_query/query_add_admin = SSdbcore.NewQuery(
			"INSERT INTO [format_table_name("admin")] (ckey, `rank`) VALUES (:ckey, 'NEW ADMIN')",
			list("ckey" = .)
		)
		if(!query_add_admin.warn_execute())
			qdel(query_add_admin)
			return FALSE
		qdel(query_add_admin)
		var/datum/db_query/query_add_admin_log = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
			VALUES (NOW(), :round_id, :adminckey, INET_ATON(:adminip), 'add admin', :target, CONCAT('New admin added: ', :target))
		"}, list("round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "target" = .))
		if(!query_add_admin_log.warn_execute())
			qdel(query_add_admin_log)
			return FALSE
		qdel(query_add_admin_log)

/datum/admins/proc/remove_admin(admin_ckey, admin_key, use_db, datum/admins/D)
	if(tgui_alert(usr,"Are you sure you want to remove [admin_ckey]?","Confirm Removal",list("Do it","Cancel")) == "Do it")
		GLOB.admin_datums -= admin_ckey
		GLOB.deadmins -= admin_ckey
		if(D)
			D.disassociate()
		var/m1 = "[key_name_admin(usr)] removed [admin_key] from the admins list [use_db ? "permanently" : "temporarily"]"
		var/m2 = "[key_name(usr)] removed [admin_key] from the admins list [use_db ? "permanently" : "temporarily"]"
		if(use_db)
			var/datum/db_query/query_add_rank = SSdbcore.NewQuery(
				"DELETE FROM [format_table_name("admin")] WHERE ckey = :ckey",
				list("ckey" = admin_ckey)
			)
			if(!query_add_rank.warn_execute())
				qdel(query_add_rank)
				return
			qdel(query_add_rank)
			var/datum/db_query/query_add_rank_log = SSdbcore.NewQuery({"
				INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
				VALUES (NOW(), :round_id, :adminckey, INET_ATON(:adminip), 'remove admin', :admin_ckey, CONCAT('Admin removed: ', :admin_ckey))
			"}, list("round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "admin_ckey" = admin_ckey))
			if(!query_add_rank_log.warn_execute())
				qdel(query_add_rank_log)
				return
			qdel(query_add_rank_log)
			sync_lastadminrank(admin_ckey, admin_key)
		message_admins(m1)
		log_admin(m2)

/datum/admins/proc/force_readmin(admin_key, datum/admins/D)
	if(!D || !D.deadmined)
		return
	D.activate()
	message_admins("[key_name_admin(usr)] forcefully readmined [admin_key]")
	log_admin("[key_name(usr)] forcefully readmined [admin_key]")

/datum/admins/proc/force_deadmin(admin_key, datum/admins/D)
	if(!D || D.deadmined)
		return
	message_admins("[key_name_admin(usr)] forcefully deadmined [admin_key]")
	log_admin("[key_name(usr)] forcefully deadmined [admin_key]")
	D.deactivate() //after logs so the deadmined admin can see the message.

/datum/admins/proc/auto_deadmin()
	if(owner.is_localhost())
		return FALSE
	if(owner.prefs.read_preference(/datum/preference/toggle/bypass_deadmin_in_centcom) && is_centcom_level(owner.mob.z) && !istype(owner.mob, /mob/dead/new_player))
		return FALSE

	to_chat(owner, span_interface("You are now a normal player."), confidential = TRUE)
	var/old_owner = owner
	deactivate()
	message_admins("[old_owner] deadmined via auto-deadmin config.")
	log_admin("[old_owner] deadmined via auto-deadmin config.")
	return TRUE

#define RANK_DONE ":) I'm Done"

/datum/admins/proc/change_admin_rank(admin_ckey, admin_key, use_db, datum/admins/D, legacy_only)
	if(!check_rights(R_PERMISSIONS))
		return

	var/list/rank_names = list()
	if(!use_db || (use_db && !legacy_only))
		rank_names += "*New Rank*"
	for(var/datum/admin_rank/admin_rank as anything in GLOB.admin_ranks)
		if((admin_rank.rights & usr.client.holder.can_edit_rights_flags()) == admin_rank.rights)
			rank_names[admin_rank.name] = admin_rank

	var/list/new_rank_names = list()
	var/list/custom_ranks = list()

	while (TRUE)
		var/list/display_rank_names = list(RANK_DONE)

		if (new_rank_names.len > 0)
			display_rank_names += "** SELECTED **"
			for (var/rank_name in new_rank_names)
				display_rank_names += rank_name
			display_rank_names += "---------"

		for (var/rank_name in rank_names)
			if (!(rank_name in display_rank_names))
				display_rank_names += rank_name

		var/next_rank = input("Please select a rank, or select [RANK_DONE] if you are finished.") as null|anything in display_rank_names

		if (isnull(next_rank))
			return

		if (next_rank == RANK_DONE)
			break

		// They clicked "** SELECTED **" or something silly.
		if (!(next_rank in rank_names))
			continue

		if (next_rank in new_rank_names)
			new_rank_names -= next_rank
			continue

		if (next_rank == "*New Rank*")
			var/new_rank_name = input("Please input a new rank", "New custom rank") as text|null
			if (!new_rank_name)
				return

			var/datum/admin_rank/custom_rank = rank_names[new_rank_name]
			if (isnull(custom_rank))
				if (D)
					custom_rank = new(new_rank_name, D.rank_flags())
				else
					custom_rank = new(new_rank_name)

				GLOB.admin_ranks += custom_rank
				custom_ranks += custom_rank
				new_rank_names += new_rank_name

		new_rank_names += next_rank

	var/list/new_ranks = list()
	for (var/datum/admin_rank/admin_rank as anything in GLOB.admin_ranks)
		if (admin_rank.name in new_rank_names)
			new_ranks += admin_rank
			new_rank_names -= admin_rank.name

			if (new_rank_names.len == 0)
				break

	var/joined_rank = join_admin_ranks(new_ranks)
	var/m1 = "[key_name_admin(usr)] edited the admin rank of [admin_key] to [joined_rank] [use_db ? "permanently" : "temporarily"]"
	var/m2 = "[key_name(usr)] edited the admin rank of [admin_key] to [joined_rank] [use_db ? "permanently" : "temporarily"]"
	if(use_db)
		//if a player was tempminned before having a permanent change made to their rank they won't yet be in the db
		var/old_rank
		var/datum/db_query/query_admin_in_db = SSdbcore.NewQuery(
			"SELECT `rank` FROM [format_table_name("admin")] WHERE ckey = :admin_ckey",
			list("admin_ckey" = admin_ckey)
		)
		if(!query_admin_in_db.warn_execute())
			qdel(query_admin_in_db)
			return
		if(!query_admin_in_db.NextRow())
			add_admin(admin_ckey, admin_key, TRUE)
			old_rank = "NEW ADMIN"
		else
			old_rank = query_admin_in_db.item[1]
		qdel(query_admin_in_db)

		for (var/datum/admin_rank/custom_rank in custom_ranks)
			//similarly if a temp rank is created it won't be in the db if someone is permanently changed to it
			var/datum/db_query/query_rank_in_db = SSdbcore.NewQuery(
				"SELECT 1 FROM [format_table_name("admin_ranks")] WHERE `rank` = :new_rank",
				list("new_rank" = custom_rank.name)
			)
			if(!query_rank_in_db.warn_execute())
				qdel(query_rank_in_db)
				return
			if(!query_rank_in_db.NextRow())
				QDEL_NULL(query_rank_in_db)
				var/datum/db_query/query_add_rank = SSdbcore.NewQuery({"
					INSERT INTO [format_table_name("admin_ranks")] (`rank`, flags, exclude_flags, can_edit_flags)
					VALUES (:new_rank, '0', '0', '0')
				"}, list("new_rank" = custom_rank.name))
				if(!query_add_rank.warn_execute())
					qdel(query_add_rank)
					return
				qdel(query_add_rank)
				var/datum/db_query/query_add_rank_log = SSdbcore.NewQuery({"
					INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
					VALUES (NOW(), :round_id, :adminckey, INET_ATON(:adminip), 'add rank', :new_rank, CONCAT('New rank added: ', :new_rank))
				"}, list("round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "new_rank" = custom_rank.name))
				if(!query_add_rank_log.warn_execute())
					qdel(query_add_rank_log)
					return
				qdel(query_add_rank_log)
			qdel(query_rank_in_db)
		var/datum/db_query/query_change_rank = SSdbcore.NewQuery(
			"UPDATE [format_table_name("admin")] SET `rank` = :new_rank WHERE ckey = :admin_ckey",
			list("new_rank" = joined_rank, "admin_ckey" = admin_ckey)
		)
		if(!query_change_rank.warn_execute())
			qdel(query_change_rank)
			return
		qdel(query_change_rank)
		var/datum/db_query/query_change_rank_log = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
			VALUES (NOW(), :round_id, :adminckey, INET_ATON(:adminip), 'change admin rank', :target, CONCAT('Rank of ', :target, ' changed from ', :old_rank, ' to ', :new_rank))
		"}, list("round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "target" = admin_ckey, "old_rank" = old_rank, "new_rank" = joined_rank))
		if(!query_change_rank_log.warn_execute())
			qdel(query_change_rank_log)
			return
		qdel(query_change_rank_log)
	if(D) //they were previously an admin
		D.disassociate() //existing admin needs to be disassociated
		D.ranks = new_ranks //set the admin_rank as our rank
		D.bypass_2fa = TRUE // Another admin has cleared us
		var/client/C = GLOB.directory[admin_ckey]
		D.associate(C)
	else
		D = new(new_ranks, admin_ckey) //new admin
		D.bypass_2fa = TRUE // Another admin has cleared us
		D.activate()
	message_admins(m1)
	log_admin(m2)

#undef RANK_DONE

/datum/admins/proc/change_admin_flags(admin_ckey, admin_key, datum/admins/admin_holder)
	var/new_flags = input_bitfield(
		usr,
		"Admin rights<br>This will affect only the current admin [admin_key]",
		"admin_flags",
		admin_holder.rank_flags(),
		350,
		590,
		allowed_edit_field = usr.client.holder.can_edit_rights_flags(),
	)
	if(isnull(new_flags))
		return

	admin_holder.disassociate()

	if (findtext(admin_holder.rank_names(), "([admin_ckey])"))
		var/datum/admin_rank/rank = admin_holder.ranks[1]
		rank.rights = new_flags
		rank.include_rights = new_flags
		rank.exclude_rights = NONE
		rank.can_edit_rights = rank.can_edit_rights
	else
		// Not a modified subrank, need to duplicate the admin_rank datum to prevent modifying others too.
		var/datum/admin_rank/new_admin_rank = new(
			/* init_name = */ "[admin_holder.rank_names()]([admin_ckey])",
			/* init_rights = */ new_flags,

			// rank_flags() includes the exclude rights, so we no longer need to handle them separately.
			/* init_exclude_rights = */ NONE,

			/* init_edit_rights = */ admin_holder.can_edit_rights_flags(),
		)

		admin_holder.ranks = list(new_admin_rank)

	var/log = "[key_name(usr)] has updated the admin rights of [admin_ckey] into [rights2text(new_flags)]"
	message_admins(log)
	log_admin(log)

	var/client/admin_client = GLOB.directory[admin_ckey]
	admin_holder.associate(admin_client)

/datum/admins/proc/remove_rank(admin_rank)
	if(!admin_rank)
		return
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		if(R.name == admin_rank && (!(R.rights & usr.client.holder.can_edit_rights_flags()) == R.rights))
			to_chat(usr, "<span class='admin prefix'>You don't have edit rights to all the rights this rank has, rank deletion not permitted.</span>", confidential = TRUE)
			return
	if(!CONFIG_GET(flag/admin_legacy_system) && CONFIG_GET(flag/protect_legacy_ranks) && (admin_rank in GLOB.protected_ranks))
		to_chat(usr, "<span class='admin prefix'>Deletion of protected ranks is not permitted, it must be removed from admin_ranks.txt.</span>", confidential = TRUE)
		return
	if(CONFIG_GET(flag/load_legacy_ranks_only))
		to_chat(usr, "<span class='admin prefix'>Rank deletion not permitted while database rank loading is disabled.</span>", confidential = TRUE)
		return
	var/datum/db_query/query_admins_with_rank = SSdbcore.NewQuery(
		"SELECT 1 FROM [format_table_name("admin")] WHERE `rank` = :admin_rank",
		list("admin_rank" = admin_rank)
	)
	if(!query_admins_with_rank.warn_execute())
		qdel(query_admins_with_rank)
		return
	if(query_admins_with_rank.NextRow())
		qdel(query_admins_with_rank)
		to_chat(usr, span_danger("Error: Rank deletion attempted while rank still used; Tell a coder, this shouldn't happen."), confidential = TRUE)
		return
	qdel(query_admins_with_rank)
	if(tgui_alert(usr,"Are you sure you want to remove [admin_rank]?","Confirm Removal",list("Do it","Cancel")) == "Do it")
		var/m1 = "[key_name_admin(usr)] removed rank [admin_rank] permanently"
		var/m2 = "[key_name(usr)] removed rank [admin_rank] permanently"
		var/datum/db_query/query_add_rank = SSdbcore.NewQuery(
			"DELETE FROM [format_table_name("admin_ranks")] WHERE `rank` = :admin_rank",
			list("admin_rank" = admin_rank)
		)
		if(!query_add_rank.warn_execute())
			qdel(query_add_rank)
			return
		qdel(query_add_rank)
		var/datum/db_query/query_add_rank_log = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
			VALUES (NOW(), :round_id, :adminckey, INET_ATON(:adminip), 'remove rank', :admin_rank, CONCAT('Rank removed: ', :admin_rank))
		"}, list("round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "admin_rank" = admin_rank))
		if(!query_add_rank_log.warn_execute())
			qdel(query_add_rank_log)
			return
		qdel(query_add_rank_log)
		message_admins(m1)
		log_admin(m2)

/datum/admins/proc/sync_lastadminrank(admin_ckey, admin_key, datum/admins/D)
	var/sqlrank = "Player"
	if (D)
		sqlrank = D.rank_names()
	var/datum/db_query/query_sync_lastadminrank = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET lastadminrank = :rank WHERE ckey = :ckey",
		list("rank" = sqlrank, "ckey" = admin_ckey)
	)
	if(!query_sync_lastadminrank.warn_execute())
		qdel(query_sync_lastadminrank)
		return
	qdel(query_sync_lastadminrank)
	to_chat(usr, span_admin("Sync of [admin_key] successful."), confidential = TRUE)
