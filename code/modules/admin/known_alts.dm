GLOBAL_DATUM_INIT(known_alts, /datum/known_alts, new)

/datum/known_alts
	var/list/cached_known_alts
	COOLDOWN_DECLARE(cache_cooldown)

/datum/known_alts/Topic(href, list/href_list)
	if (!check_rights(R_ADMIN))
		return

	if (!SSdbcore.Connect())
		to_chat(usr, span_warning("Couldn't connect to the database."))
		return

	var/datum/admins/holder = usr.client?.holder
	if (isnull(holder))
		return

	if (!holder.CheckAdminHref(href, href_list))
		return

	switch (href_list["action"])
		if ("add")
			var/ckey1 = input(usr, "Put in the name of the main ckey") as null|text
			if (!ckey1)
				return

			var/ckey2 = input(usr, "Put in the name of their alt") as null|text
			if (!ckey2)
				return

			ckey1 = ckey(ckey1)
			ckey2 = ckey(ckey2)

			var/datum/db_query/query_already_exists = SSdbcore.NewQuery({"
				SELECT id FROM [format_table_name("known_alts")]
				WHERE (ckey1 = :ckey1 AND ckey2 = :ckey2)
				OR (ckey1 = :ckey2 AND ckey2 = :ckey1)
			"}, list(
				"ckey1" = ckey1,
				"ckey2" = ckey2,
			))

			query_already_exists.warn_execute()

			if (query_already_exists.last_error)
				qdel(query_already_exists)
				return

			var/already_exists_row = query_already_exists.NextRow()
			qdel(query_already_exists)

			if (already_exists_row)
				alert(usr, "Those two are already in the list of known alts!")
				return

			var/datum/db_query/query_add_known_alt = SSdbcore.NewQuery({"
				INSERT INTO [format_table_name("known_alts")] (ckey1, ckey2, admin_ckey)
				VALUES (:ckey1, :ckey2, :admin_ckey)
			"}, list(
				"ckey1" = ckey1,
				"ckey2" = ckey2,
				"admin_ckey" = usr.ckey,
			))

			if (query_add_known_alt.warn_execute())
				var/message = "[key_name(usr)] has added a new known alt connection between [ckey1] and [ckey2]."
				message_admins(message)
				log_admin_private(message)

				cached_known_alts = null
				load_known_alts()

			qdel(query_add_known_alt)
			show_panel(usr.client)

			if (!is_banned_from(ckey2, "Server"))
				var/ban_choice = alert("[ckey2] is not banned from the server. Do you want to open up the ban panel as well?",,"Yes", "No")
				if (ban_choice == "Yes")
					holder.ban_panel(ckey2, role = "Server", duration = BAN_PANEL_PERMANENT)
		if ("delete")
			var/id = text2num(href_list["id"])
			if (!id)
				log_admin_private("[key_name(usr)] tried to delete an invalid known alt ID: [href_list["id"]]")
				return

			var/datum/db_query/query_known_alt_info = SSdbcore.NewQuery({"
				SELECT ckey1, ckey2 FROM [format_table_name("known_alts")]
				WHERE id = :id
			"}, list(
				"id" = id,
			))

			if (!query_known_alt_info.warn_execute())
				qdel(query_known_alt_info)
				return

			if (!query_known_alt_info.NextRow())
				alert("Couldn't find the known alt with the ID [id]")
				qdel(query_known_alt_info)
				return

			var/list/result = query_known_alt_info.item
			qdel(query_known_alt_info)

			if (alert("Are you sure you want to delete the alt connection between [result[1]] and [result[2]]?",,"Yes", "No") != "Yes")
				return

			var/datum/db_query/query_delete_known_alt = SSdbcore.NewQuery({"
				DELETE FROM [format_table_name("known_alts")]
				WHERE id = :id
			"}, list(
				"id" = id,
			))

			if (query_delete_known_alt.warn_execute())
				var/message = "[key_name(usr)] has deleted the known alt connection between [result[1]] and [result[2]]."
				message_admins(message)
				log_admin_private(message)

				cached_known_alts = null
				load_known_alts()

			qdel(query_delete_known_alt)
			show_panel(usr.client)

/// Returns the list of known alts, will return an empty list if the DB could not be connected to.
/// This proc can block.
/datum/known_alts/proc/load_known_alts()
	if (!isnull(cached_known_alts) && !COOLDOWN_FINISHED(src, cache_cooldown))
		return cached_known_alts

	if (!SSdbcore.Connect())
		return cached_known_alts || list()

	var/datum/db_query/query_known_alts = SSdbcore.NewQuery("SELECT id, ckey1, ckey2, admin_ckey FROM [format_table_name("known_alts")] ORDER BY id DESC")
	query_known_alts.warn_execute()

	if (query_known_alts.last_error)
		qdel(query_known_alts)
		return cached_known_alts || list()

	cached_known_alts = list()

	while (query_known_alts.NextRow())
		cached_known_alts += list(list(
			query_known_alts.item[2],
			query_known_alts.item[3],
			query_known_alts.item[4],

			// The ID
			query_known_alts.item[1],
		))

	COOLDOWN_START(src, cache_cooldown, 10 SECONDS)
	qdel(query_known_alts)

	return cached_known_alts

/datum/known_alts/proc/show_panel(client/client)
	if (!check_rights_for(client, R_ADMIN))
		return

	if (!SSdbcore.Connect())
		to_chat(usr, span_warning("Couldn't connect to the database."))
		return

	var/list/known_alts_html = list()

	for (var/known_alt in load_known_alts())
		known_alts_html += "<a href='?src=[REF(src)];[HrefToken()];action=delete;id=[known_alt[4]]'>\[-\] Delete</a> <b>[known_alt[1]]</b> is an alt of <b>[known_alt[2]]</b> (added by <b>[known_alt[3]]</b>)."

	var/html = {"
		<head>
			<title>Known Alts</title>
		</head>

		<body>
			<p>Any two ckeys in this panel will not show in "banned connection history".</p>
			<p>Sometimes players switch account, and it's customary to perma-ban the old one.</p>

			<h2>All Known Alts:</h2> <a href='?src=[REF(src)];[HrefToken()];action=add'>\[+\] Add</a><hr>

			[known_alts_html.Join("<br />")]
		</body>
	"}

	client << browse(html, "window=known_alts;size=700x400")

ADMIN_VERB(known_alts_panel, R_ADMIN, "Known Alts Panel", "View a panel of known alts.", ADMIN_CATEGORY_MAIN)
	GLOB.known_alts.show_panel(user)
