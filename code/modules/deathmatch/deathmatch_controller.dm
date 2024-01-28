GLOBAL_VAR(deathmatch_game)

/datum/deathmatch_controller
	/// Assoc list of all lobbies (ckey = lobby)
	var/list/datum/deathmatch_lobby/lobbies = list()
	/// All deathmatch map templates
	var/list/datum/map_template/deathmatch/maps = list()
	/// All loadouts
	var/list/datum/outfit/loadouts

	/// All currently present spawnpoints, to be processed by a loading map
	var/list/spawnpoint_processing = list()

/datum/deathmatch_controller/New()
	. = ..()
	if (GLOB.deathmatch_game)
		qdel(src)
		CRASH("A deathmatch controller already exists.")
	GLOB.deathmatch_game = src

	for (var/datum/map_template/template as anything in subtypesof(/datum/map_template/deathmatch))
		var/map_name = initial(template.name)
		if (maps[map_name])
			stack_trace("Deathmatch maps MUST have different names: map_name] already defined.")
		maps[map_name] = new template
	loadouts = subtypesof(/datum/outfit/deathmatch_loadout)

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

/datum/deathmatch_controller/proc/get_unused_point()
	for(var/obj/effect/landmark/deathmatch_map_spawner/point as anything in GLOB.deathmatch_points)
		if(point.map_bounds)
			continue
		if(point.loc == null) // just incase this bug reappears somehow
			stack_trace("[point] is in nullspace!!")
			continue
		return point

/datum/deathmatch_controller/proc/clear_location(obj/effect/landmark/deathmatch_map_spawner/location)
	. = TRUE
	if(!location?.map_bounds) // no map boundaries, pointless
		stack_trace("Deathmatch clear_location was called on a clear map spawner!")
		return FALSE
	var/turf/spawn_loc = get_turf(location)
	if(spawn_loc == null) //emergency
		stack_trace("DM Map Spawner is nullspaced: [spawn_loc] x[location.x] y[location.y]!!")
	qdel(location)
	new /obj/effect/landmark/deathmatch_map_spawner(spawn_loc)

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
		var/datum/deathmatch_lobby/lobby = lobbies[ckey]
		if (user.ckey == ckey)
			.["hosting"] = TRUE
		if (user.ckey in lobby.observers || user.ckey in lobby.players)
			.["playing"] = ckey
		.["lobbies"] += list(list(
			name = ckey,
			players = lobby.players.len,
			max_players = initial(lobby.map.max_players),
			map = initial(lobby.map.name),
			playing = lobby.playing
		))

/datum/deathmatch_controller/proc/find_lobby_by_user(ckey)
	for(var/lobbykey in lobbies)
		var/datum/deathmatch_lobby/lobby = lobbies[lobbykey]
		if(ckey in lobby.players || ckey in lobby.observers)
			return lobby

/datum/deathmatch_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isobserver(usr))
		return
	switch (action)
		if ("host")
			if (lobbies[usr.ckey])
				return
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr, "The round hasn't started yet!")
				return
			ui.close()
			create_new_lobby(usr)
		if ("join")
			if (!lobbies[params["id"]])
				return
			var/datum/deathmatch_lobby/playing_lobby = find_lobby_by_user(usr.ckey)
			var/datum/deathmatch_lobby/chosen_lobby = lobbies[params["id"]]
			if (!isnull(playing_lobby) && playing_lobby != chosen_lobby)
				playing_lobby.leave(usr.ckey)
			
			if(isnull(playing_lobby))
				log_game("[usr.ckey] joined deathmatch lobby [params["id"]] as a player.")
				chosen_lobby.join(usr)

			chosen_lobby.ui_interact(usr)
		if ("spectate")
			var/datum/deathmatch_lobby/playing_lobby = find_lobby_by_user(usr.ckey)
			if (!lobbies[params["id"]])
				return
			var/datum/deathmatch_lobby/chosen_lobby = lobbies[params["id"]]
			// if the player is in this lobby
			if(!isnull(playing_lobby) && playing_lobby != chosen_lobby)
				playing_lobby.leave(usr.ckey)
			else if(playing_lobby == chosen_lobby)
				chosen_lobby.ui_interact(usr)
				return
			// they werent in the lobby, lets add them
			if (!chosen_lobby.playing)
				chosen_lobby.add_observer(usr)
				chosen_lobby.ui_interact(usr)
			else
				chosen_lobby.spectate(usr)
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
