GLOBAL_VAR(deathmatch_game)

/datum/deathmatch_controller
	var/list/map_locations = list()
	var/list/used_locations = list()
	var/list/datum/deathmatch_lobby/lobbies = list()
	var/list/datum/deathmatch_map/maps = list()
	var/list/datum/deathmatch_loadout/loadouts

	var/list/spawnpoint_processing = list()

/datum/deathmatch_controller/New()
	. = ..()
	if (GLOB.deathmatch_game)
		qdel(src)
		CRASH("A deathmatch controller already exists.")
	GLOB.deathmatch_game = src
	for (var/obj/effect/landmark/deathmatch_map_spawn/S in GLOB.landmarks_list)
		if (!S.compiled_location)
			continue
		map_locations += S.compiled_location

	for (var/M in subtypesof(/datum/deathmatch_map))
		var/datum/deathmatch_map/map = new M
		if (maps[map.name])
			stack_trace("Deathmatch maps MUST have different names: [map.name] already defined.")
		maps[map.name] = map
	loadouts = subtypesof(/datum/deathmatch_loadout)

/datum/deathmatch_controller/proc/create_new_lobby(mob/host)
	lobbies[host.ckey] = new /datum/deathmatch_lobby(host)

/datum/deathmatch_controller/proc/remove_lobby(ckey)
	var/lobby = lobbies[ckey]
	lobbies[ckey] = null
	lobbies.Remove(ckey)
	qdel(lobby)

/datum/deathmatch_controller/proc/passoff_lobby(host, new_host)
	lobbies[new_host] = lobbies[host]
	lobbies[host] = null
	lobbies.Remove(host)

/datum/deathmatch_controller/proc/reserve_location(datum/deathmatch_map/map)
	if (!map)
		return
	var/datum/deathmatch_map_loc/smallest
	for (var/datum/deathmatch_map_loc/L in map_locations)
		if (map.template.width > L.width && map.template.height > L.height)
			continue
		if (smallest)
			if (smallest && smallest.width > L.width && smallest.height > L.height)
				smallest = L
			continue
		smallest = L
	if (smallest)
		map_locations -= smallest
		used_locations[smallest] = map
	return smallest

/datum/deathmatch_controller/proc/load_location(datum/deathmatch_map_loc/location)
	if (!location || !used_locations[location])
		return
	var/datum/deathmatch_map/M = used_locations[location]
	if (!M.template.load(location.location, centered = TRUE))
		return
	if (!spawnpoint_processing.len)
		return
	var/list/spawns = spawnpoint_processing.Copy()
	spawnpoint_processing.Cut()
	return spawns

/datum/deathmatch_controller/proc/clear_location(datum/deathmatch_map_loc/location)
	var/z = location.location.z
	// Get bottom corner
	var/bX = location.location.x - location.x_offset
	var/bY = location.location.y - location.y_offset
	// Get top corner
	var/tX = location.width + (location.location.x - location.x_offset)
	var/tY = location.height + (location.location.y - location.y_offset)
	// Get space area instance
	var/area/space = GLOB.areas_by_type[/area/space]
	// Locate bottom and top corners
	var/bT = locate(bX, bY, z)
	var/tT = locate(tX, tY, z)
	// Clear area between bottom and top corners
	for (var/turf/T in block(bT, tT))
		space.contents += T // Changes the area.
		T.empty(flags = CHANGETURF_FORCEOP)
	// Free the map location
	used_locations -= location
	map_locations += location

/datum/deathmatch_controller/ui_state(mob/user)
	return GLOB.observer_state

/datum/deathmatch_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, null)
	if(!ui)
		ui = new(user, src, "DeathmatchPanel")
		ui.open()

/datum/deathmatch_controller/ui_data(mob/user)
	. = ..()
	.["lobbies"] = list()
	.["hosting"] = FALSE
	.["admin"] = check_rights_for(user.client, R_ADMIN)
	for (var/ckey in lobbies)
		var/datum/deathmatch_lobby/L = lobbies[ckey]
		if (user.ckey == ckey)
			.["hosting"] = TRUE
		if (L.observers[user.ckey] || L.players[user.ckey])
			.["playing"] = ckey
		.["lobbies"] += list(list(
			name = ckey,
			players = L.players.len,
			max_players = initial(L.map.max_players),
			map = initial(L.map.name),
			playing = L.playing
		))

/datum/deathmatch_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isobserver(usr))
		return
	switch (action)
		if ("host")
			if (lobbies[usr.ckey])
				return
			ui.close()
			create_new_lobby(usr)
		if ("join")
			var/datum/deathmatch_lobby/L = lobbies[usr.ckey]
			if (L && (L.players[usr.ckey] || L.observers[usr.ckey]))
				lobbies[usr.ckey].ui_interact(usr)
				return
			if (!lobbies[params["id"]])
				return
			log_game("[usr.ckey] joined deathmatch lobby [params["id"]] as a player.")
			lobbies[params["id"]].join(usr)
		if ("spectate")
			if (lobbies[usr.ckey] || !lobbies[params["id"]])
				return
			if (!lobbies[params["id"]].playing)
				lobbies[params["id"]].add_observer(usr)
				lobbies[params["id"]].ui_interact(usr)
			else
				lobbies[params["id"]].spectate()
			log_game("[usr.ckey] joined deathmatch lobby [params["id"]] as an observer.")
		if ("admin")
			if (!check_rights(R_ADMIN))
				message_admins("[usr.key] has attempted to use admin functions in the deathmatch panel!")
				log_admin("[key_name(usr)] tried to use the deathmatch panel admin functions without authorization.")
				return
			var/lobby = params["id"]
			switch (params["func"])
				if ("Close")
					remove_lobby(lobby)
					log_admin("[key_name(usr)] removed deathmatch lobby [lobby].")
				if ("View")
					lobbies[lobby].ui_interact(usr)