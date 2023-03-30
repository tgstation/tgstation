GLOBAL_VAR(deathmatch_game)

/datum/deathmatch_controller
	var/datum/map_generator/massdelete/map_remover = new

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
	var/locations = list()
	for (var/obj/effect/landmark/deathmatch_map_corner/S in GLOB.landmarks_list)
		if (!locations[S.location_id])
			var/datum/deathmatch_map_loc/L = new
			L.x1 = S.x
			L.y1 = S.y
			L.z = S.z
			locations[S.location_id] = L
		else
			var/datum/deathmatch_map_loc/L = locations[S.location_id]
			if (L.centre)
				stack_trace("Deathmatch map location [S.location_id] has three corner markers.")
				continue
			L.x2 = S.x
			L.y2 = S.y
			L.centre = locate((L.x1 + L.x2) / 2, (L.y1 + L.y2) / 2, L.z)
			L.width = abs(L.x1 - L.x2)
			L.height = abs(L.y1 - L.y2)
			map_locations += L
	for (var/M in subtypesof(/datum/deathmatch_map))
		var/datum/deathmatch_map/map = new M
		if (maps[map.name])
			stack_trace("Deathmatch maps MUST have different names: [map.name] already defined.")
		maps[map.name] = map
	loadouts = subtypesof(/datum/deathmatch_loadout)

/datum/deathmatch_controller/proc/create_new_lobby(mob/host)
	lobbies[host.ckey] = new /datum/deathmatch_lobby(host)
	deadchat_broadcast(" has opened a new deathmatch lobby. <a href=?src=[REF(lobbies[host.ckey])];join=1>(Join)</a>", "<B>[host]</B>")

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
		if (map.template.width > L.width || map.template.height > L.height)
			continue
		if (smallest)
			if (map.template.width > L.width || map.template.height > L.height)
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
	if (!M.template.load(location.centre, centered = TRUE))
		return
	if (!spawnpoint_processing.len)
		return
	var/list/spawns = spawnpoint_processing.Copy()
	spawnpoint_processing.Cut()
	return spawns

/datum/deathmatch_controller/proc/clear_location(datum/deathmatch_map_loc/location)
	// lets give the game a moment to do whatever it needs to before we delete.
	set waitfor = FALSE
	sleep(world.tick_lag)
	map_remover.defineRegion(locate(location.x1, location.y1, location.z), locate(location.x2, location.y2, location.z), TRUE)
	map_remover.generate()
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
				lobbies[params["id"]].spectate(usr)
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
