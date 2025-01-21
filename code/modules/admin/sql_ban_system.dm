#define MAX_ADMINBANS_PER_ADMIN 1
#define MAX_ADMINBANS_PER_HEADMIN 3

#define MAX_REASON_LENGTH 600

/**
 * Checks client ban cache or, if it doesn't exist, queries the DB ban table to see if the player's
 * ckey is banned from at least one of the provided roles.
 *
 * Returns TRUE if the player matches with one or more role bans.
 * Returns FALSE if the player doesn't match with any role bans. Possible errors states also return FALSE.
 *
 * Args:
 * * player_key - Either key or ckey of the player you want to check for role bans.
 * * roles - Accepts either a single role string, or a list of role strings.
 */
/proc/is_banned_from(player_key, list/roles)
	if(!player_key)
		stack_trace("Called is_banned_from without specifying a ckey.")
		return FALSE

	// Convert to ckey. This allows is_banned_from to take either key or ckey interchangably,
	// and is officially a feature of the proc.
	var/player_ckey = ckey(player_key)

	var/client/player_client = GLOB.directory[player_ckey]

	// If there's a player client, we try to set up their ban cache (if it doesn't already exist) and test from that.
	if(player_client)
		var/list/ban_cache = retrieve_ban_cache(player_client)

		// If this isn't a list, the client disconnected while building it.
		if(!islist(ban_cache))
			return FALSE

		// If it is a list, check each role.
		if(islist(roles))
			for(var/role in roles)
				if(role in ban_cache)
					return TRUE //they're banned from at least one role, no need to keep checking

			return FALSE

		// Otherwise, it's just a single role string. Return if it's in the ban cache.
		return (roles in ban_cache)

	// If there's no player client, we'll ask the database.
	var/values = list(
		"player_ckey" = player_ckey,
		"must_apply_to_admins" = !!(GLOB.admin_datums[player_ckey] || GLOB.deadmins[player_ckey]),
	)

	var/sql_roles
	if(islist(roles))
		var/list/sql_roles_list = list()
		for (var/i in 1 to roles.len)
			values["role[i]"] = roles[i]
			sql_roles_list += ":role[i]"
		sql_roles = sql_roles_list.Join(", ")
	else
		values["role"] = roles
		sql_roles = ":role"

	var/datum/db_query/query_check_ban = SSdbcore.NewQuery({"
		SELECT 1
		FROM [format_table_name("ban")]
		WHERE
			ckey = :player_ckey AND
			role IN ([sql_roles]) AND
			unbanned_datetime IS NULL AND
			(expiration_time IS NULL OR expiration_time > NOW())
			AND (NOT :must_apply_to_admins OR applies_to_admins = 1)
	"}, values)

	// If there's an SQL error, return FALSE.
	if(!query_check_ban.warn_execute())
		qdel(query_check_ban)
		return FALSE

	// If there are any rows, we got a match and they're role banned from at least one role.
	if(query_check_ban.NextRow())
		qdel(query_check_ban)
		return TRUE

	// Otherwise, they're not banned from any roles in the DB.
	qdel(query_check_ban)
	return FALSE

//checks DB ban table if a ckey, ip and/or cid is banned from a specific role
//returns an associative nested list of each matching row's ban id, bantime, ban round id, expiration time, ban duration, applies to admins, reason, key, ip, cid and banning admin's key in that order
/proc/is_banned_from_with_details(player_ckey, player_ip, player_cid, role)
	if(!player_ckey && !player_ip && !player_cid)
		return
	var/datum/db_query/query_check_ban = SSdbcore.NewQuery({"
		SELECT
			id,
			bantime,
			round_id,
			expiration_time,
			TIMESTAMPDIFF(MINUTE, bantime, expiration_time),
			applies_to_admins,
			reason,
			IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey), ckey),
			INET_NTOA(ip),
			computerid,
			IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey)
		FROM [format_table_name("ban")]
		WHERE role = :role
			AND (ckey = :ckey OR ip = INET_ATON(:ip) OR computerid = :computerid)
			AND unbanned_datetime IS NULL
			AND (expiration_time IS NULL OR expiration_time > NOW())
		ORDER BY bantime DESC
	"}, list("role" = role, "ckey" = player_ckey, "ip" = player_ip, "computerid" = player_cid))
	if(!query_check_ban.warn_execute())
		qdel(query_check_ban)
		return
	. = list()
	while(query_check_ban.NextRow())
		. += list(list("id" = query_check_ban.item[1], "bantime" = query_check_ban.item[2], "round_id" = query_check_ban.item[3], "expiration_time" = query_check_ban.item[4], "duration" = query_check_ban.item[5], "applies_to_admins" = query_check_ban.item[6], "reason" = query_check_ban.item[7], "key" = query_check_ban.item[8], "ip" = query_check_ban.item[9], "computerid" = query_check_ban.item[10], "admin_key" = query_check_ban.item[11]))
	qdel(query_check_ban)

/// Gets the ban cache of the passed in client
/// If the cache has not been generated, we start off a query
/// If we still have a query going for this request, we just sleep until it's received back
/proc/retrieve_ban_cache(client/player_client)
	if(QDELETED(player_client))
		return

	if(player_client.ban_cache)
		return player_client.ban_cache

	var/config_delay = CONFIG_GET(number/blocking_query_timeout) SECONDS
	// If we haven't got a query going right now, or we've timed out on the old query
	if(player_client.ban_cache_start + config_delay < REALTIMEOFDAY)
		return build_ban_cache(player_client)

	// Ok so we've got a request going, lets start a wait cycle
	// If we wait longer then config/db_ban_timeout we'll send another request
	// We use timeofday here because we're talking human time
	// We do NOT cache the start time because it can update, and we want it to be able to
	while(player_client && player_client?.ban_cache_start + config_delay >= REALTIMEOFDAY && !player_client?.ban_cache)
		// Wait a decisecond or two would ya?
		// If this causes lag on client join, increase this delay. it doesn't need to be too fast since this should
		// Realllly only happen near Login, and we're unlikely to make any new requests in that time
		stoplag(2)

	// If we have a ban cache, use it. if we've timed out, go ahead and start another query would you?
	// This will update any other sleep loops, so we should only run one at a time
	return player_client?.ban_cache || build_ban_cache(player_client)

/proc/build_ban_cache(client/player_client)
	if(!SSdbcore.Connect())
		return
	if(QDELETED(player_client))
		return
	var/current_time = REALTIMEOFDAY
	player_client.ban_cache_start = current_time

	var/ckey = player_client.ckey
	var/list/ban_cache = list()
	var/is_admin = FALSE
	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		is_admin = TRUE
	var/datum/db_query/query_build_ban_cache = SSdbcore.NewQuery(
		"SELECT role, applies_to_admins FROM [format_table_name("ban")] WHERE ckey = :ckey AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())",
		list("ckey" = ckey)
	)
	var/query_successful = query_build_ban_cache.warn_execute()
	// After we sleep, we check if this was the most recent cache build, and if so we clear our start time
	if(player_client?.ban_cache_start == current_time)
		player_client.ban_cache_start = 0
	if(!query_successful)
		qdel(query_build_ban_cache)
		return

	while(query_build_ban_cache.NextRow())
		if(is_admin && !text2num(query_build_ban_cache.item[2]))
			continue
		ban_cache[query_build_ban_cache.item[1]] = TRUE
	qdel(query_build_ban_cache)
	if(QDELETED(player_client)) // Disconnected while working with the DB.
		return
	player_client.ban_cache = ban_cache
	return ban_cache


/datum/admins/proc/ban_panel(player_key, player_ip, player_cid, role, duration = 1440, applies_to_admins, reason, edit_id, page, admin_key)
	if (duration == BAN_PANEL_PERMANENT)
		duration = null

	var/panel_height = 620
	if(edit_id)
		panel_height = 240
	var/datum/browser/panel = new(usr, "banpanel", "Banning Panel", 910, panel_height)
	panel.add_stylesheet("admin_panelscss", 'html/admin/admin_panels.css')
	panel.add_stylesheet("banpanelcss", 'html/admin/banpanel.css')
	var/tgui_fancy = usr.client.prefs.read_preference(/datum/preference/toggle/tgui_fancy)
	if(tgui_fancy) //some browsers (IE8) have trouble with unsupported css3 elements and DOM methods that break the panel's functionality, so we won't load those if a user is in no frills tgui mode since that's for similar compatability support
		panel.add_stylesheet("admin_panelscss3", 'html/admin/admin_panels_css3.css')
		panel.add_script("banpaneljs", 'html/admin/banpanel.js')
	var/list/output = list("<form method='get' action='?src=[REF(src)]'>[HrefTokenFormField()]")
	output += {"<input type='hidden' name='src' value='[REF(src)]'>
	<label class='inputlabel checkbox'>Key:
	<input type='checkbox' id='keycheck' name='keycheck' value='1'[player_key ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='keytext' size='26' value='[player_key]'>
	<label class='inputlabel checkbox'>IP:
	<input type='checkbox' id='ipcheck' name='ipcheck' value='1'[isnull(duration) ? " checked" : ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='iptext' size='18' value='[player_ip]'>
	<label class='inputlabel checkbox'>CID:
	<input type='checkbox' id='cidcheck' name='cidcheck' value='1' checked>
	<div class='inputbox'></div></label>
	<input type='text' name='cidtext' size='14' value='[player_cid]'>
	<br>
	<label class='inputlabel checkbox'>Use IP and CID from last connection of key
	<input type='checkbox' id='lastconn' name='lastconn' value='1' [(isnull(duration) && !player_ip) || (!player_cid) ? " checked": ""]>
	<div class='inputbox'></div></label>
	<label class='inputlabel checkbox'>Applies to Admins
	<input type='checkbox' id='applyadmins' name='applyadmins' value='1'[applies_to_admins ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='submit' value='Submit'>
	<br>
	<div class='row'>
		<div class='column left'>
			Duration type
			<br>
			<label class='inputlabel radio'>Permanent
			<input type='radio' id='permanent' name='radioduration' value='permanent'[isnull(duration) ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Temporary
			<input type='radio' id='temporary' name='radioduration' value='temporary'[duration ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<input type='text' name='duration' size='7' value='[duration]'>
			<div class="select">
				<select name='intervaltype'>
					<option value='SECOND'>Seconds</option>
					<option value='MINUTE' selected>Minutes</option>
					<option value='HOUR'>Hours</option>
					<option value='DAY'>Days</option>
					<option value='WEEK'>Weeks</option>
					<option value='MONTH'>Months</option>
					<option value='YEAR'>Years</option>
				</select>
			</div>
		</div>
		<div class='column middle'>
			Ban type
			<br>
			<label class='inputlabel radio'>Server
			<input type='radio' id='server' name='radioban' value='server'[role == "Server" ? " checked" : ""][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Role
			<input type='radio' id='role' name='radioban' value='role'[role == "Server" ? "" : " checked"][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column right'>
			Severity
			<br>
			<label class='inputlabel radio'>None
			<input type='radio' id='none' name='radioseverity' value='none'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>Medium
			<input type='radio' id='medium' name='radioseverity' value='medium'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Minor
			<input type='radio' id='minor' name='radioseverity' value='minor'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>High
			<input type='radio' id='high' name='radioseverity' value='high'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column'>
			Reason
			<br>
			<textarea class='reason' name='reason' maxlength='[MAX_REASON_LENGTH]'>[reason]</textarea>
		</div>
	</div>
	"}

	if(edit_id)
		output += {"<label class='inputlabel checkbox'>Mirror edits to matching bans
		<input type='checkbox' id='mirroredit' name='mirroredit' value='1'>
		<div class='inputbox'></div></label>
		<input type='hidden' name='editid' value='[edit_id]'>
		<input type='hidden' name='oldkey' value='[player_key]'>
		<input type='hidden' name='oldip' value='[player_ip]'>
		<input type='hidden' name='oldcid' value='[player_cid]'>
		<input type='hidden' name='oldapplies' value='[applies_to_admins]'>
		<input type='hidden' name='oldduration' value='[duration]'>
		<input type='hidden' name='oldreason' value='[reason]'>
		<input type='hidden' name='page' value='[page]'>
		<input type='hidden' name='adminkey' value='[admin_key]'>
		<input type='hidden' name='role' value='[role]'>
		<br>
		When ticked, edits here will also affect bans created with matching ckey, IP, CID and time. Use this to edit all role bans which were made at the same time.
		"}
	else
		output += "<input type='hidden' name='roleban_delimiter' value='1'>"
		//there's not always a client to use the bancache of so to avoid many individual queries from using is_banned_form we'll build a cache to use here
		var/banned_from = list()
		if(player_key)
			var/datum/db_query/query_get_banned_roles = SSdbcore.NewQuery({"
				SELECT role
				FROM [format_table_name("ban")]
				WHERE
					ckey = :player_ckey AND
					role <> 'server'
					AND unbanned_datetime IS NULL
					AND (expiration_time IS NULL OR expiration_time > NOW())
			"}, list("player_ckey" = ckey(player_key)))
			if(!query_get_banned_roles.warn_execute())
				qdel(query_get_banned_roles)
				return
			while(query_get_banned_roles.NextRow())
				banned_from += query_get_banned_roles.item[1]
			qdel(query_get_banned_roles)
		var/break_counter = 0
		output += "<div class='row'>"

		for(var/datum/job_department/department as anything in SSjob.joinable_departments)
			var/label_class = department.label_class
			var/department_name = department.department_name
			output += "<div class='column'><label class='rolegroup [label_class]'>[tgui_fancy ? "<input type='checkbox' name='[label_class]' class='hidden' onClick='header_click_all_checkboxes(this)'>" : ""] \
			[department_name]</label><div class='content'>"
			for(var/datum/job/job_datum as anything in department.department_jobs)
				if(break_counter > 0 && (break_counter % 3 == 0))
					output += "<br>"
				break_counter++
				var/job_name = job_datum.title
				if(length(job_datum.departments_list) > 1) //This job is in multiple departments, so we need to check all the boxes.
					// Clicking this will also toggle all the other boxes, minus this one.
					var/department_index = job_datum.departments_list.Find(department.type)
					if(!department_index)
						stack_trace("Failed to find a department index for [department.type] in the departments_list of [job_datum.type]")
					output += {"<label class='inputlabel checkbox'>[job_name]
						<input type='checkbox' id='[job_name]_[department_index]' name='[job_name]' class='[label_class]' value='1'[tgui_fancy ? " onClick='toggle_other_checkboxes(this, \"[length(job_datum.departments_list)]\", \"[department_index]\")'" : ""]>
						<div class='inputbox[(job_name in banned_from) ? " banned" : ""]'></div></label>
						"}
				else
					output += {"<label class='inputlabel checkbox'>[job_name]
							<input type='checkbox' name='[job_name]' class='[label_class]' value='1'>
							<div class='inputbox[(job_name in banned_from) ? " banned" : ""]'></div></label>
							"}
			output += "</div></div>"
			break_counter = 0

		var/list/other_job_lists = list(
			"Abstract" = list("Appearance", "Emote", "Deadchat", "OOC", "Urgent Adminhelp"),
			)
		for(var/department in other_job_lists)
			output += "<div class='column'><label class='rolegroup [ckey(department)]'>[tgui_fancy ? "<input type='checkbox' name='[department]' class='hidden' onClick='header_click_all_checkboxes(this)'>" : ""][department]</label><div class='content'>"
			break_counter = 0
			for(var/job in other_job_lists[department])
				if(break_counter > 0 && (break_counter % 3 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		var/list/long_job_lists = list(
			"Ghost and Other Roles" = list(
				ROLE_PAI,
				ROLE_BOT,
				ROLE_BRAINWASHED,
				ROLE_DEATHSQUAD,
				ROLE_DRONE,
				ROLE_LAVALAND,
				ROLE_MIND_TRANSFER,
				ROLE_POSIBRAIN,
				ROLE_SENTIENCE,
			),
			"Antagonist Positions" = list(
				ROLE_ABDUCTOR,
				ROLE_ALIEN,
				ROLE_BLOB,
				ROLE_BROTHER,
				ROLE_CHANGELING,
				ROLE_CULTIST,
				ROLE_HERETIC,
				ROLE_HIVE,
				ROLE_MALF,
				ROLE_NINJA,
				ROLE_OPERATIVE,
				ROLE_OVERTHROW,
				ROLE_REV,
				ROLE_REVENANT,
				ROLE_REV_HEAD,
				ROLE_SPACE_DRAGON,
				ROLE_SPIDER,
				ROLE_SPY,
				ROLE_SYNDICATE,
				ROLE_TRAITOR,
				ROLE_WIZARD,
				ROLE_VOIDWALKER,
			),
		)
		for(var/department in long_job_lists)
			output += "<div class='column'><label class='rolegroup long [ckey(department)]'>[tgui_fancy ? "<input type='checkbox' name='[department]' class='hidden' onClick='header_click_all_checkboxes(this)'>" : ""][department]</label><div class='content'>"
			break_counter = 0
			for(var/job in long_job_lists[department])
				if(break_counter > 0 && (break_counter % 10 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		output += "</div>"
	output += "</form>"
	panel.set_content(output.Join())
	panel.open()


/datum/admins/proc/ban_parse_href(list/href_list)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/list/error_state = list()
	var/player_key
	var/ip_check = FALSE
	var/player_ip
	var/cid_check = FALSE
	var/player_cid
	var/use_last_connection = FALSE
	var/applies_to_admins = FALSE
	var/duration
	var/interval
	var/severity
	var/reason
	var/mirror_edit
	var/edit_id
	var/old_key
	var/old_ip
	var/old_cid
	var/old_applies
	var/page
	var/admin_key
	var/list/changes = list()
	var/list/roles_to_ban = list()
	if(href_list["keycheck"])
		player_key = href_list["keytext"]
		if(!player_key)
			error_state += "Key was ticked but none was provided."
	if(href_list["ipcheck"])
		ip_check = TRUE
	if(href_list["cidcheck"])
		cid_check = TRUE
	if(href_list["lastconn"])
		if(player_key)
			use_last_connection = TRUE
	else
		if(ip_check)
			player_ip = href_list["iptext"]
			if(!player_ip && !use_last_connection)
				error_state += "IP was ticked but none was provided."
		if(cid_check)
			player_cid = href_list["cidtext"]
			if(!player_cid && !use_last_connection)
				error_state += "CID was ticked but none was provided."
	if(!use_last_connection && !player_ip && !player_cid && !player_key)
		error_state += "At least a key, IP or CID must be provided."
	if(use_last_connection && !ip_check && !cid_check)
		error_state += "Use last connection was ticked, but neither IP nor CID was."
	if(href_list["applyadmins"])
		applies_to_admins = TRUE
	switch(href_list["radioduration"])
		if("permanent")
			duration = null
		if("temporary")
			duration = href_list["duration"]
			interval = href_list["intervaltype"]
			if(!duration)
				error_state += "Temporary ban was selected but no duration was provided."
		else
			error_state += "No duration was selected."
	reason = href_list["reason"]
	if(!reason)
		error_state += "No reason was provided."
	if(length(reason) > MAX_REASON_LENGTH)
		error_state += "Reason cannot be more than [MAX_REASON_LENGTH] characters."
	if(href_list["editid"])
		edit_id = href_list["editid"]
		if(href_list["mirroredit"])
			mirror_edit = TRUE
		old_key = href_list["oldkey"]
		old_ip = href_list["oldip"]
		old_cid = href_list["oldcid"]
		page = href_list["page"]
		admin_key = href_list["adminkey"]
		if(player_key != old_key)
			changes += list("Key" = "[old_key] to [player_key]")
		if(player_ip != old_ip)
			changes += list("IP" = "[old_ip] to [player_ip]")
		if(player_cid != old_cid)
			changes += list("CID" = "[old_cid] to [player_cid]")
		old_applies = text2num(href_list["oldapplies"])
		if(applies_to_admins != old_applies)
			changes += list("Applies to admins" = "[old_applies] to [applies_to_admins]")
		if(duration != href_list["oldduration"])
			changes += list("Duration" = "[href_list["oldduration"]] MINUTE to [duration] [interval]")
		if(reason != href_list["oldreason"])
			changes += list("Reason" = "[href_list["oldreason"]]<br>to<br>[reason]")
		if(!changes.len)
			error_state += "No changes were detected."
		roles_to_ban += href_list["role"]
	else
		severity = href_list["radioseverity"]
		if(!severity)
			error_state += "No severity was selected."
		switch(href_list["radioban"])
			if("server")
				roles_to_ban += "Server"
			if("role")
				href_list.Remove("Command", "Security", "Engineering", "Medical", "Science", "Supply", "Silicon", "Abstract", "Service", "Ghost and Other Roles", "Antagonist Positions") //remove the role banner hidden input values
				var/delimiter_pos = href_list.Find("roleban_delimiter")
				if(href_list.len == delimiter_pos)
					error_state += "Role ban was selected but no roles to ban were selected."
				else if(delimiter_pos == 0)
					error_state += "roleban_delimiter not found in href. Report this to coders."
				else
					href_list.Cut(1, delimiter_pos+1)//remove every list element before and including roleban_delimiter so we have a list of only the roles to ban
					for(var/key in href_list) //flatten into a list of only unique keys
						roles_to_ban |= key
			else
				error_state += "No ban type was selected."
	if(error_state.len)
		to_chat(usr, span_danger("Ban not [edit_id ? "edited" : "created"] because the following errors were present:\n[error_state.Join("\n")]"), confidential = TRUE)
		return
	if(edit_id)
		edit_ban(edit_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, mirror_edit, old_key, old_ip, old_cid, old_applies, page, admin_key, changes, roles_to_ban[1] == "Server")
	else
		create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, roles_to_ban)

/datum/admins/proc/create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, list/roles_to_ban)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/player_ckey = ckey(player_key)
	if(player_ckey)
		var/datum/db_query/query_create_ban_get_player = SSdbcore.NewQuery({"
			SELECT byond_key, INET_NTOA(ip), computerid FROM [format_table_name("player")] WHERE ckey = :player_ckey
		"}, list("player_ckey" = player_ckey))
		if(!query_create_ban_get_player.warn_execute())
			qdel(query_create_ban_get_player)
			return
		if(query_create_ban_get_player.NextRow())
			player_key = query_create_ban_get_player.item[1]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_create_ban_get_player.item[2]
				if(cid_check)
					player_cid = query_create_ban_get_player.item[3]
		else
			if(use_last_connection)
				if(tgui_alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to create a ban for them?", "Unknown key", list("Yes", "No", "Cancel")) != "Yes")
					qdel(query_create_ban_get_player)
					return
			else
				if(tgui_alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to create a ban for them?", "Unknown key", list("Yes", "No", "Cancel")) != "Yes")
					qdel(query_create_ban_get_player)
					return
		qdel(query_create_ban_get_player)
	var/admin_ckey = usr.client.ckey
	if(applies_to_admins && !can_place_additional_admin_ban(admin_ckey))
		return
	var/admin_ip = usr.client.address
	var/admin_cid = usr.client.computer_id
	duration = text2num(duration)
	if (!(interval in list("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR")))
		interval = "MINUTE"
	var/time_message = "[duration] [LOWER_TEXT(interval)]" //no DisplayTimeText because our duration is of variable interval type
	if(duration > 1) //pluralize the interval if necessary
		time_message += "s"
	var/is_server_ban = (roles_to_ban[1] == "Server")
	var/note_reason = "Banned from [is_server_ban ? "the server" : " Roles: [roles_to_ban.Join(", ")]"] [isnull(duration) ? "permanently" : "for [time_message]"] - [reason]"
	var/list/clients_online = GLOB.clients.Copy()
	var/list/admins_online = list()
	for(var/client/C in clients_online)
		if(C.holder) //deadmins aren't included since they wouldn't show up on adminwho
			admins_online += C
	var/who = clients_online.Join(", ")
	var/adminwho = admins_online.Join(", ")
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)

	var/special_columns = list(
		"bantime" = "NOW()",
		"server_ip" = "INET_ATON(?)",
		"ip" = "INET_ATON(?)",
		"a_ip" = "INET_ATON(?)",
		"expiration_time" = "IF(? IS NULL, NULL, NOW() + INTERVAL ? [interval])"
	)
	var/sql_ban = list()
	for(var/role in roles_to_ban)
		sql_ban += list(list(
			"server_ip" = world.internet_address || 0,
			"server_port" = world.port,
			"round_id" = GLOB.round_id,
			"role" = role,
			"expiration_time" = duration,
			"applies_to_admins" = applies_to_admins,
			"reason" = reason,
			"ckey" = player_ckey || null,
			"ip" = player_ip || null,
			"computerid" = player_cid || null,
			"a_ckey" = admin_ckey,
			"a_ip" = admin_ip || null,
			"a_computerid" = admin_cid,
			"who" = who,
			"adminwho" = adminwho,
		))
	if(!SSdbcore.MassInsert(format_table_name("ban"), sql_ban, warn = TRUE, special_columns = special_columns))
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	var/msg = "has created a [isnull(duration) ? "permanent" : "temporary [time_message]"] [applies_to_admins ? "admin " : ""][is_server_ban ? "server ban" : "role ban from [roles_to_ban.len] roles"] for [target]."
	log_admin_private("[kn] [msg][is_server_ban ? "" : " Roles: [roles_to_ban.Join(", ")]"] Reason: [reason]")
	message_admins("[kna] [msg][is_server_ban ? "" : " Roles: [roles_to_ban.Join("\n")]"]\nReason: [reason]")
	if(applies_to_admins)
		send2adminchat("BAN ALERT","[kn] [msg]")
	if(player_ckey)
		create_message("note", player_ckey, admin_ckey, note_reason, null, null, 0, 0, null, 0, severity)

	var/player_ban_notification = span_boldannounce("You have been [applies_to_admins ? "admin " : ""]banned by [usr.client.key] from [is_server_ban ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]</span><br>[span_danger("This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] The round ID is [GLOB.round_id].")]")
	var/other_ban_notification = span_boldannounce("Another player sharing your IP or CID has been banned by [usr.client.key] from [is_server_ban ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]</span><br>[span_danger("This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] The round ID is [GLOB.round_id].")]")

	notify_all_banned_players(player_ckey, player_ip, player_cid, player_ban_notification, other_ban_notification, is_server_ban, applies_to_admins)

	var/datum/admin_help/linked_ahelp_ticket = admin_ticket_log(player_ckey, "[kna] [msg]")

	if(is_server_ban && linked_ahelp_ticket)
		linked_ahelp_ticket.Resolve()

/datum/admins/proc/unban_panel(player_key, admin_key, player_ip, player_cid, page = 0)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/datum/browser/unban_panel = new(usr, "unbanpanel", "Unbanning Panel", 850, 600)
	unban_panel.add_stylesheet("unbanpanelcss", 'html/admin/unbanpanel.css')
	var/list/output = list("<div class='searchbar'>")
	output += {"<form method='get' action='?src=[REF(src)]'>[HrefTokenFormField()]
	<input type='hidden' name='src' value='[REF(src)]'>
	Key:<input type='text' name='searchunbankey' size='18' value='[player_key]'>
	Admin Key:<input type='text' name='searchunbanadminkey' size='18' value='[admin_key]'>
	IP:<input type='text' name='searchunbanip' size='12' value='[player_ip]'>
	CID:<input type='text' name='searchunbancid' size='10' value='[player_cid]'>
	<input type='submit' value='Search'>
	</form>
	</div>
	<div class='main'>
	"}
	if(player_key || admin_key || player_ip || player_cid)
		var/bancount = 0
		var/bansperpage = 10
		page = text2num(page)
		var/datum/db_query/query_unban_count_bans = SSdbcore.NewQuery({"
			SELECT COUNT(id)
			FROM [format_table_name("ban")]
			WHERE
				(:player_key IS NULL OR ckey = :player_key) AND
				(:admin_key IS NULL OR a_ckey = :admin_key) AND
				(:player_ip IS NULL OR ip = INET_ATON(:player_ip)) AND
				(:player_cid IS NULL OR computerid = :player_cid)
		"}, list(
			"player_key" = ckey(player_key),
			"admin_key" = ckey(admin_key),
			"player_ip" = player_ip || null,
			"player_cid" = player_cid || null,
		))
		if(!query_unban_count_bans.warn_execute())
			qdel(query_unban_count_bans)
			return
		if(query_unban_count_bans.NextRow())
			bancount = text2num(query_unban_count_bans.item[1])
		qdel(query_unban_count_bans)
		if(bancount > bansperpage)
			output += "<b>Page: </b>"
			var/pagecount = 1
			var/list/pagelist = list()
			while(bancount > 0)
				pagelist += "<a href='byond://?_src_=holder;[HrefToken()];unbanpagecount=[pagecount - 1];unbankey=[player_key];unbanadminkey=[admin_key];unbanip=[player_ip];unbancid=[player_cid]'>[pagecount == page ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
				bancount -= bansperpage
				pagecount++
			output += pagelist.Join(" | ")
		var/datum/db_query/query_unban_search_bans = SSdbcore.NewQuery({"
			SELECT
				id,
				bantime,
				round_id,
				role,
				expiration_time,
				TIMESTAMPDIFF(MINUTE, bantime, expiration_time),
				IF(expiration_time < NOW(), 1, NULL),
				applies_to_admins,
				reason,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey
				), ckey),
				INET_NTOA(ip),
				computerid,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey
				), a_ckey),
				IF(edits IS NOT NULL, 1, NULL),
				unbanned_datetime,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].unbanned_ckey
				), unbanned_ckey),
				unbanned_round_id
			FROM [format_table_name("ban")]
			WHERE
				(:player_key IS NULL OR ckey = :player_key) AND
				(:admin_key IS NULL OR a_ckey = :admin_key) AND
				(:player_ip IS NULL OR ip = INET_ATON(:player_ip)) AND
				(:player_cid IS NULL OR computerid = :player_cid)
			ORDER BY id DESC
			LIMIT :skip, :take
		"}, list(
			"player_key" = ckey(player_key),
			"admin_key" = ckey(admin_key),
			"player_ip" = player_ip || null,
			"player_cid" = player_cid || null,
			"skip" = bansperpage * page,
			"take" = bansperpage,
		))
		if(!query_unban_search_bans.warn_execute())
			qdel(query_unban_search_bans)
			return
		while(query_unban_search_bans.NextRow())
			var/ban_id = query_unban_search_bans.item[1]
			var/ban_datetime = query_unban_search_bans.item[2]
			var/ban_round_id = query_unban_search_bans.item[3]
			var/role = query_unban_search_bans.item[4]
			var/expiration_time = query_unban_search_bans.item[5]
			//we don't cast duration as num because if the duration is large enough to be converted to scientific notation by byond then the + character gets lost when passed through href causing SQL to interpret '4.321e 007' as '4'
			var/duration = query_unban_search_bans.item[6]
			var/expired = query_unban_search_bans.item[7]
			var/applies_to_admins = text2num(query_unban_search_bans.item[8])
			var/reason = query_unban_search_bans.item[9]
			var/banned_player_key = query_unban_search_bans.item[10]
			var/banned_player_ip = query_unban_search_bans.item[11]
			var/banned_player_cid = query_unban_search_bans.item[12]
			var/banning_admin_key = query_unban_search_bans.item[13]
			var/edits = query_unban_search_bans.item[14]
			var/unban_datetime = query_unban_search_bans.item[15]
			var/unban_key = query_unban_search_bans.item[16]
			var/unban_round_id = query_unban_search_bans.item[17]
			var/target = ban_target_string(banned_player_key, banned_player_ip, banned_player_cid)

			output += "<div class='banbox'><div class='header [unban_datetime ? "unbanned" : "banned"]'><b>[target]</b>[applies_to_admins ? " <b>ADMIN</b>" : ""] banned by <b>[banning_admin_key]</b> from <b>[role]</b> on <b>[ban_datetime]</b> during round <b>#[ban_round_id]</b>.<br>"
			if(!expiration_time)
				output += "<b>Permanent ban</b>."
			else
				output += "Duration of <b>[DisplayTimeText(text2num(duration) MINUTES)]</b>, <b>[expired ? "expired" : "expires"]</b> on <b>[expiration_time]</b>."
			if(unban_datetime)
				output += "<br>Unbanned by <b>[unban_key]</b> on <b>[unban_datetime]</b> during round <b>#[unban_round_id]</b>."
			output += "</div><div class='container'><div class='reason'>[reason]</div><div class='edit'>"

			var/un_or_reban_href
			if(unban_datetime)
				un_or_reban_href = "<a href='byond://?_src_=holder;[HrefToken()];rebanid=[ban_id];applies_to_admins=[applies_to_admins];rebankey=[banned_player_key];rebanadminkey=[banning_admin_key];rebanip=[banned_player_ip];rebancid=[banned_player_cid];rebanrole=[role];rebanpage=[page]'>Reban</a>"
			else
				un_or_reban_href = "<a href='byond://?_src_=holder;[HrefToken()];unbanid=[ban_id];unbankey=[banned_player_key];unbanadminkey=[banning_admin_key];unbanip=[banned_player_ip];unbancid=[banned_player_cid];unbanrole=[role];unbanpage=[page]'>Unban</a>"
			output += "<a href='byond://?_src_=holder;[HrefToken()];editbanid=[ban_id];editbankey=[banned_player_key];editbanip=[banned_player_ip];editbancid=[banned_player_cid];editbanrole=[role];editbanduration=[duration];editbanadmins=[applies_to_admins];editbanreason=[url_encode(reason)];editbanpage=[page];editbanadminkey=[banning_admin_key]'>Edit</a><br>[un_or_reban_href]"

			if(edits)
				output += "<br><a href='byond://?_src_=holder;[HrefToken()];unbanlog=[ban_id]'>Edit log</a>"
			output += "</div></div></div>"
		qdel(query_unban_search_bans)
		output += "</div>"
	unban_panel.set_content(jointext(output, ""))
	unban_panel.open()

/datum/admins/proc/unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	// Make sure the only input that doesn't early return is "Yes" - This is the only situation in which we want the unban to proceed.
	if(tgui_alert(usr, "Please confirm unban of [target] from [role].", "Unban confirmation", list("Yes", "No")) != "Yes")
		return
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/change_message = "[usr.client.key] unbanned [target] from [role] on [ISOtime()] during round #[GLOB.round_id]<hr>"
	var/datum/db_query/query_unban = SSdbcore.NewQuery({"
		UPDATE [format_table_name("ban")] SET
			unbanned_datetime = NOW(),
			unbanned_ckey = :admin_ckey,
			unbanned_ip = INET_ATON(:admin_ip),
			unbanned_computerid = :admin_cid,
			unbanned_round_id = :round_id,
			edits = CONCAT(IFNULL(edits,''), :change_message)
		WHERE id = :ban_id
	"}, list("ban_id" = ban_id, "admin_ckey" = usr.client.ckey, "admin_ip" = usr.client.address, "admin_cid" = usr.client.computer_id, "round_id" = GLOB.round_id, "change_message" = change_message))
	if(!query_unban.warn_execute())
		qdel(query_unban)
		return
	qdel(query_unban)
	log_admin_private("[kn] has unbanned [target] from [role].")
	message_admins("[kna] has unbanned [target] from [role].")
	var/client/C = GLOB.directory[player_key]
	if(C)
		build_ban_cache(C)
		to_chat(C, span_boldannounce("[usr.client.key] has removed a ban from [role] for your key."), confidential = TRUE)
	for(var/client/i in GLOB.clients - C)
		if(i.address == player_ip || i.computer_id == player_cid)
			build_ban_cache(i)
			to_chat(i, span_boldannounce("[usr.client.key] has removed a ban from [role] for your IP or CID."), confidential = TRUE)
	unban_panel(player_key, admin_key, player_ip, player_cid, page)

/// Sometimes an admin did not intend to unban a player. This proc undoes an unbanning operation by setting the unbanned_ keys in the DB back to null.
/datum/admins/proc/reban(ban_id, applies_to_admins, player_key, player_ip, player_cid, role, page, admin_key)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return

	var/target = ban_target_string(player_key, player_ip, player_cid)
	// Make sure the only input that doesn't early return is "Yes" - This is the only situation in which we want the unban to proceed.
	if(tgui_alert(usr, "Please confirm undoing of unban of [target] from [role].", "Reban confirmation", list("Yes", "No")) != "Yes")
		return

	if(applies_to_admins && !can_place_additional_admin_ban(usr.client.ckey))
		return

	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/change_message = "[usr.client.key] re-activated ban of [target] from [role] on [ISOtime()] during round #[GLOB.round_id]<hr>"
	var/datum/db_query/query_reban = SSdbcore.NewQuery({"
		UPDATE [format_table_name("ban")] SET
			unbanned_datetime = NULL,
			unbanned_ckey = NULL,
			unbanned_ip = NULL,
			unbanned_computerid = NULL,
			unbanned_round_id = NULL,
			edits = CONCAT(IFNULL(edits,''), :change_message)
		WHERE id = :ban_id
	"}, list("change_message" = change_message, "ban_id" = ban_id))
	if(!query_reban.warn_execute())
		qdel(query_reban)
		return
	qdel(query_reban)
	log_admin_private("[kn] has rebanned [target] from [role].")
	message_admins("[kna] has rebanned [target] from [role].")

	var/banned_player_message = span_boldannounce("[usr.client.key] has re-activated a removed ban from [role] for your key.")
	var/banned_other_message = span_boldannounce("[usr.client.key] has re-activated a removed ban from [role] for your IP or CID.")
	var/kick_banned_players = (role == "Server")

	notify_all_banned_players(ckey(player_key), player_ip, player_cid, banned_player_message, banned_other_message, kick_banned_players, applies_to_admins)
	unban_panel(player_key, admin_key, player_ip, player_cid, page)

/datum/admins/proc/edit_ban(ban_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, mirror_edit, old_key, old_ip, old_cid, old_applies, admin_key, page, list/changes, is_server_ban)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/player_ckey = ckey(player_key)
	var/bantime
	if(player_ckey)
		var/datum/db_query/query_edit_ban_get_player = SSdbcore.NewQuery({"
			SELECT
				byond_key,
				(SELECT bantime FROM [format_table_name("ban")] WHERE id = :ban_id),
				ip,
				computerid
			FROM [format_table_name("player")]
			WHERE ckey = :player_ckey
		"}, list("player_ckey" = player_ckey, "ban_id" = ban_id))
		if(!query_edit_ban_get_player.warn_execute())
			qdel(query_edit_ban_get_player)
			return
		if(query_edit_ban_get_player.NextRow())
			player_key = query_edit_ban_get_player.item[1]
			bantime = query_edit_ban_get_player.item[2]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_edit_ban_get_player.item[3]
				if(cid_check)
					player_cid = query_edit_ban_get_player.item[4]
		else
			if(use_last_connection)
				if(tgui_alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to edit a ban for them?", "Unknown key", list("Yes", "No", "Cancel")) != "Yes")
					qdel(query_edit_ban_get_player)
					return
			else
				if(tgui_alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to edit a ban for them?", "Unknown key", list("Yes", "No", "Cancel")) != "Yes")
					qdel(query_edit_ban_get_player)
					return
		qdel(query_edit_ban_get_player)

	if(applies_to_admins && (applies_to_admins != old_applies) && !can_place_additional_admin_ban(usr.client.ckey))
		return

	if (!(interval in list("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR")))
		interval = "MINUTE"

	var/list/changes_text = list()
	var/list/changes_keys = list()
	for(var/i in changes)
		changes_text += "[i]: [changes[i]]"
		changes_keys += i
	var/change_message = "[usr.client.key] edited the following [jointext(changes_text, ", ")]<hr>"

	var/list/arguments = list(
		"duration" = duration || null,
		"reason" = reason,
		"applies_to_admins" = applies_to_admins,
		"ckey" = player_ckey || null,
		"ip" = player_ip || null,
		"cid" = player_cid || null,
		"change_message" = change_message,
	)
	var/where
	if(text2num(mirror_edit))
		var/list/wherelist = list("bantime = '[bantime]'")
		if(old_key)
			wherelist += "ckey = :old_ckey"
			arguments["old_ckey"] = ckey(old_key)
		if(old_ip)
			wherelist += "ip = INET_ATON(:old_ip)"
			arguments["old_ip"] = old_ip || null
		if(old_cid)
			wherelist += "computerid = :old_cid"
			arguments["old_cid"] = old_cid
		where = wherelist.Join(" AND ")
	else
		where = "id = :ban_id"
		arguments["ban_id"] = ban_id

	var/datum/db_query/query_edit_ban = SSdbcore.NewQuery({"
		UPDATE [format_table_name("ban")]
		SET
			expiration_time = IF(:duration IS NULL, NULL, bantime + INTERVAL :duration [interval]),
			applies_to_admins = :applies_to_admins,
			reason = :reason,
			ckey = :ckey,
			ip = INET_ATON(:ip),
			computerid = :cid,
			edits = CONCAT(IFNULL(edits,''), :change_message)
		WHERE [where]
	"}, arguments)
	if(!query_edit_ban.warn_execute())
		qdel(query_edit_ban)
		return
	qdel(query_edit_ban)

	var/changes_keys_text = jointext(changes_keys, ", ")
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	log_admin_private("[kn] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].") //if a ban doesn't have a key it must have an ip and/or a cid to have reached this point normally
	message_admins("[kna] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].")
	if(changes["Applies to admins"])
		send2adminchat("BAN ALERT","[kn] has edited a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"] to [applies_to_admins ? "" : "not"]affect admins")

	var/player_edit_message = span_boldannounce("[usr.client.key] has edited the [changes_keys_text] of a ban for your key.")
	var/other_edit_message = span_boldannounce("[usr.client.key] has edited the [changes_keys_text] of a ban for your IP or CID.")

	var/kick_banned_players = (is_server_ban && (changes["Key"] || changes["IP"] || changes["CID"]))

	notify_all_banned_players(player_ckey, player_ip, player_cid, player_edit_message, other_edit_message, kick_banned_players, applies_to_admins)

	unban_panel(player_key, null, null, null, page)

/datum/admins/proc/ban_log(ban_id)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/datum/db_query/query_get_ban_edits = SSdbcore.NewQuery({"
		SELECT edits FROM [format_table_name("ban")] WHERE id = :ban_id
	"}, list("ban_id" = ban_id))
	if(!query_get_ban_edits.warn_execute())
		qdel(query_get_ban_edits)
		return
	if(query_get_ban_edits.NextRow())
		var/edits = query_get_ban_edits.item[1]
		var/datum/browser/edit_log = new(usr, "baneditlog", "Ban edit log")
		edit_log.set_content(edits)
		edit_log.open()
	qdel(query_get_ban_edits)

/datum/admins/proc/ban_target_string(player_key, player_ip, player_cid)
	. = list()
	if(player_key)
		. += player_key
	else
		if(player_ip)
			. += player_ip
		else
			. += "NULL"
		if(player_cid)
			. += player_cid
		else
			. += "NULL"
	. = jointext(., "/")

/**
 * Checks if the admin can place an additional admin ban.
 *
 * Returns FALSE if the query fails to execute.
 * Returns FALSE and notifies the admin in chat if they are at their max number of admin bans already.
 * Returns TRUE if an admin can place an additional admin ban.
 *
 * Arguments:
 * * admin_ckey - The ckey of the admin who is trying to place an admin ban.
 */
/datum/admins/proc/can_place_additional_admin_ban(admin_ckey)
	var/datum/db_query/query_check_adminban_count = SSdbcore.NewQuery({"
		SELECT COUNT(DISTINCT bantime)
		FROM [format_table_name("ban")]
		WHERE
			a_ckey = :admin_ckey AND
			applies_to_admins = 1 AND
			unbanned_datetime IS NULL AND
			(expiration_time IS NULL OR expiration_time > NOW())
	"}, list("admin_ckey" = admin_ckey))
	if(!query_check_adminban_count.warn_execute()) //count distinct bantime to treat rolebans made at the same time as one ban
		qdel(query_check_adminban_count)
		return FALSE
	if(query_check_adminban_count.NextRow())
		var/adminban_count = text2num(query_check_adminban_count.item[1])
		var/max_adminbans = MAX_ADMINBANS_PER_ADMIN
		if(check_rights(R_PERMISSIONS, show_msg = FALSE) && (can_edit_rights_flags() & R_EVERYTHING) == R_EVERYTHING) //edit rights are a more effective way to check hierarchical rank since many non-headmins have R_PERMISSIONS now
			max_adminbans = MAX_ADMINBANS_PER_HEADMIN
		if(adminban_count >= max_adminbans)
			to_chat(usr, span_danger("You've already logged [max_adminbans] admin ban(s) or more. Do not abuse this function!"), confidential = TRUE)
			qdel(query_check_adminban_count)
			return FALSE
	qdel(query_check_adminban_count)
	return TRUE

/**
 * Notifies all banned players about their ban and gives them a link to appeal from the config. If it was a server ban, it also kicks them.
 *
 * If the banned player's ckey has a linked client on the server, it notifies them of the ban details and kicks them if it was a server ban.
 * If there is anyone else sharing the banned player's IP or CID, it notifies them of the ban details and kicks them if it was a server ban.
 *
 * Builds the ban cache for every client impacted by the ban.
 *
 * Arguments:
 * * banned_player_ckey - The ckey of the banned player.
 * * banned_player_ip - IP address of the banned player.
 * * banned_player_cid - CID of the banned player.
 * * banned_player_message - The message to show to only the specifically banned player.
 * * banned_other_message - The message to show to any other players who share the banned player's IP or CID.
 * * kick_banned_players - TRUE if we want to kick affected players, FALSE otherwise. This should generally only be TRUE for server bans.
 * * applies_to_admins - TRUE if this ban applies to admins and we may need to kick them, FALSE otherwise.
 */
/datum/admins/proc/notify_all_banned_players(banned_player_ckey, banned_player_ip, banned_player_cid, banned_player_message, banned_other_message, kick_banned_players, applies_to_admins)
	var/client/player_client = GLOB.directory[banned_player_ckey]

	var/appeal_url = "No ban appeal url set!"
	appeal_url = CONFIG_GET(string/banappeals)

	var/is_admin = FALSE
	if(player_client)
		build_ban_cache(player_client)
		to_chat(player_client, span_boldannounce("[banned_player_message]<br><span class='danger'>To appeal this ban go to [appeal_url]"), confidential = TRUE)
		if(GLOB.admin_datums[player_client.ckey] || GLOB.deadmins[player_client.ckey])
			is_admin = TRUE
		if(kick_banned_players && (!is_admin || (is_admin && applies_to_admins)))
			qdel(player_client)

	for(var/client/other_player_client in GLOB.clients - player_client)
		if(other_player_client.address == banned_player_ip || other_player_client.computer_id == banned_player_cid)
			build_ban_cache(other_player_client)
			to_chat(other_player_client, span_boldannounce("[banned_other_message]<br><span class='danger'>To appeal this ban go to [appeal_url]"), confidential = TRUE)
			if(GLOB.admin_datums[other_player_client.ckey] || GLOB.deadmins[other_player_client.ckey])
				is_admin = TRUE
			if(kick_banned_players && (!is_admin || (is_admin && applies_to_admins)))
				qdel(other_player_client)

#undef MAX_ADMINBANS_PER_ADMIN
#undef MAX_ADMINBANS_PER_HEADMIN
#undef MAX_REASON_LENGTH
