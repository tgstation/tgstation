/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Maximum number of connection records allowed to analyze.
 * Should match the value set in the browser.
 */
#define TGUI_TELEMETRY_MAX_CONNECTIONS 5

/**
 * Maximum time allocated for sending a telemetry packet.
 */
#define TGUI_TELEMETRY_RESPONSE_WINDOW (30 SECONDS)

/// Time of telemetry request
/datum/tgui_panel/var/telemetry_requested_at
/// Time of telemetry analysis completion
/datum/tgui_panel/var/telemetry_analyzed_at
/// List of previous client connections
/datum/tgui_panel/var/list/telemetry_connections

/**
 * private
 *
 * Requests some telemetry from the client.
 */
/datum/tgui_panel/proc/request_telemetry()
	telemetry_requested_at = world.time
	telemetry_analyzed_at = null
	window.send_message("telemetry/request", list(
		"limits" = list(
			"connections" = TGUI_TELEMETRY_MAX_CONNECTIONS,
		),
	))

/**
 * private
 *
 * Analyzes a telemetry packet.
 *
 * Is currently only useful for detecting ban evasion attempts.
 */
/datum/tgui_panel/proc/analyze_telemetry(payload)
	if(world.time > telemetry_requested_at + TGUI_TELEMETRY_RESPONSE_WINDOW)
		message_admins("[key_name(client)] sent telemetry outside of the allocated time window.")
		return
	if(telemetry_analyzed_at)
		message_admins("[key_name(client)] sent telemetry more than once.")
		return
	telemetry_analyzed_at = world.time
	if(!payload)
		return
	telemetry_connections = payload["connections"]
	var/len = length(telemetry_connections)
	if(len == 0)
		return
	if(len > TGUI_TELEMETRY_MAX_CONNECTIONS)
		message_admins("[key_name(client)] was kicked for sending a huge telemetry payload")
		qdel(client)
		return

	var/ckey = client?.ckey
	if (!ckey)
		return

	var/list/all_known_alts = GLOB.known_alts.load_known_alts()
	var/list/our_known_alts = list()

	for (var/known_alt in all_known_alts)
		if (known_alt[1] == ckey)
			our_known_alts += known_alt[2]
		else if (known_alt[2] == ckey)
			our_known_alts += known_alt[1]

	var/list/found

	var/list/query_data = list()

	for(var/i in 1 to len)
		if(QDELETED(client))
			// He got cleaned up before we were done
			return
		var/list/row = telemetry_connections[i]

		// Check for a malformed history object
		if (!row || row.len < 3 || (!row["ckey"] || !row["address"] || !row["computer_id"]))
			return

		if (!isnull(GLOB.round_id))
			query_data += list(list(
				"telemetry_ckey" = row["ckey"],
				"address" = row["address"],
				"computer_id" = row["computer_id"],
			))

		if (row["ckey"] in our_known_alts)
			continue

		if (world.IsBanned(row["ckey"], row["address"], row["computer_id"], real_bans_only = TRUE))
			found = row
			break

		CHECK_TICK

	// This fucker has a history of playing on a banned account.
	if(found)
		var/msg = "[key_name(client)] has a banned account in connection history! (Matched: [found["ckey"]], [found["address"]], [found["computer_id"]])"
		message_admins(msg)
		send2tgs_adminless_only("Banned-user", msg)
		log_admin_private(msg)
		log_suspicious_login(msg, access_log_mirror = FALSE)

	// Only log them all at the end, since it's not as important as reporting an evader
	for (var/list/one_query as anything in query_data)
		var/datum/db_query/query = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("telemetry_connections")] (
				ckey,
				telemetry_ckey,
				address,
				computer_id,
				first_round_id,
				latest_round_id
			) VALUES(
				:ckey,
				:telemetry_ckey,
				INET_ATON(:address),
				:computer_id,
				:round_id,
				:round_id
			) ON DUPLICATE KEY UPDATE latest_round_id = :round_id
		"}, list(
			"ckey" = ckey,
			"telemetry_ckey" = one_query["telemetry_ckey"],
			"address" = one_query["address"],
			"computer_id" = one_query["computer_id"],
			"round_id" = GLOB.round_id,
		))
		query.Execute()
		qdel(query)

#undef TGUI_TELEMETRY_MAX_CONNECTIONS
#undef TGUI_TELEMETRY_RESPONSE_WINDOW
