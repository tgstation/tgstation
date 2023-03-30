/datum/deathmatch_lobby
	var/datum/deathmatch_controller/game

	var/host
	var/list/players = list()
	var/list/observers = list()
	var/datum/deathmatch_map/map
	var/datum/deathmatch_map_loc/location
	var/global_chat = FALSE
	var/playing = FALSE
	var/ready_count
	var/list/loadouts

/datum/deathmatch_lobby/New(mob/player)
	. = ..()
	if (!player)
		stack_trace("Attempted to create a deathmatch lobby without a host.")
		return qdel(src)
	host = player.ckey
	game = GLOB.deathmatch_game
	map = game.maps[pick(game.maps)]
	log_game("[host] created a deathmatch lobby.")
	if (map.allowed_loadouts)
		loadouts = map.allowed_loadouts
	else
		loadouts = game.loadouts
	add_player(player, loadouts[1], TRUE)
	ui_interact(player)

/datum/deathmatch_lobby/Destroy(force, ...)
	. = ..()
	for (var/K in players)
		var/datum/tgui/ui = SStgui.get_open_ui(players[K]["mob"], src)
		if (ui) ui.close()
		remove_player(K)
	players = null
	for (var/K in observers)
		var/datum/tgui/ui = SStgui.get_open_ui(observers[K]["mob"], src)
		if (ui) ui.close()
		observers.Remove(K)
	observers = null
	map = null
	location = null
	loadouts = null

/datum/deathmatch_lobby/proc/start_game()
	if (playing)
		return
	location = game.reserve_location(map)
		playing = TRUE
	if (!location)
		to_chat(get_mob_by_ckey(host), span_warning("Couldn't reserve a map location (all locations used?), try again later."))
		playing = FALSE
		return FALSE
	var/list/spawns = game.load_location(location)
	if (!length(spawns) || length(spawns) < length(players))
		stack_trace("Failed to get spawns when loading deathmatch map [map.name] for lobby [host].")
		game.clear_location(location)
		location = null
		playing = FALSE
		return FALSE
	for (var/K in players)
		var/mob/dead/observer/O = players[K]["mob"]
		if (!O || !O.client)
			log_game("Removed player [K] from deathmatch lobby [host], as they couldn't be found.")
			remove_player(K)
			continue
		// pick spawn and remove it.
		var/S = pick_n_take(spawns)
		O.forceMove(get_turf(S))
		qdel(S)
		// equip player
		var/datum/deathmatch_loadout/L = players[K]["loadout"]
		if (!(L in loadouts))
			L = loadouts[1]
		L = new L // agony
		var/mob/living/carbon/human/H = O.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		clean_player(H)
		L.equip(H)
		map.map_equip(H)
		// register death handling.
		RegisterSignal(H, COMSIG_LIVING_DEATH, .proc/player_died)
		if (global_chat)
			RegisterSignal(H, COMSIG_MOB_SAY, .proc/global_chat)
		to_chat(H.client, span_reallybig("GO!"))
		players[K]["mob"] = H
	// Remove rest of spawns.
	for (var/S in spawns)
		qdel(S)
	for (var/K in observers)
		var/mob/M = observers[K]["mob"]
		M.forceMove(location.centre)
		if (global_chat)
			RegisterSignal(M, COMSIG_MOB_DEADSAY, .proc/global_chat)
	log_game("Deathmatch game [host] started.")
	return TRUE

/datum/deathmatch_lobby/proc/end_game()
	if (!location)
		CRASH("Location of deathmatch game [host] deleted during game.")
	var/winner
	for (var/K in players)
		if (!winner) // While there should only be a single player remaining, someone might proccall this so.
			winner = K
		var/mob/living/L = players[K]["mob"]
		to_chat(L.client, span_reallybig("THE GAME HAS ENDED.<BR>THE WINNER IS: [winner ? winner : "no one"]."))
		players[K]["mob"] = null
		UnregisterSignal(L, COMSIG_LIVING_DEATH)
		qdel(L)
	for (var/K in observers)
		var/mob/observer = observers[K]["mob"]
		to_chat(observer.client, span_reallybig("THE GAME HAS ENDED.<BR>THE WINNER IS: [winner ? winner : "no one"]."))
	game.clear_location(location)
	game.remove_lobby(host)
	log_game("Deathmatch game [host] ended.")

/datum/deathmatch_lobby/proc/player_died(mob/living/player)
	for (var/K in players)
		var/mob/P = players[K]["mob"]
		if (!P.client)
			remove_player(K)
			continue
		to_chat(P.client, span_reallybig("[player.ckey] HAS DIED.<br>[players.len-1] REMAINING."))
	for (var/K in observers)
		var/mob/P = observers[K]["mob"]
		if (!P.client)
			remove_observer(K)
			continue
		to_chat(P.client, span_reallybig("[player.ckey] HAS DIED.<br>[players.len-1] REMAINING."))
	players.Remove(player.ckey)
	var/ghost = player.ghostize()
	if (ghost) // If the player has ghosted already this will not work.
		add_observer(ghost, (host == player.ckey))
	player.dust(TRUE, TRUE, TRUE)
	if (players.len <= 1)
		end_game()
		return

/datum/deathmatch_lobby/proc/add_observer(mob/_mob, _host = FALSE)
	if (players[_mob.ckey])
		CRASH("Tried to add [_mob.ckey] as an observer while being a player.")
	if (playing && global_chat)
		RegisterSignal(_mob, COMSIG_MOB_DEADSAY, .proc/global_chat)
	observers[_mob.ckey] = list(mob = _mob, host = _host)

/datum/deathmatch_lobby/proc/add_player(mob/_mob, _loadout, _host = FALSE)
	if (observers[_mob.ckey])
		CRASH("Tried to add [_mob.ckey] as a player while being an observer.")
	players[_mob.ckey] = list(mob = _mob, host = _host, ready = FALSE, loadout = _loadout)

// Players might be stinky, need to make sure they aren't cheating.
/datum/deathmatch_lobby/proc/clean_player(mob/living/carbon/player)
	if (player.mind)
		var/datum/mind/M = new (player.key)
		M.set_assigned_role(SSjob.GetJobType(/datum/job/deathmatch)) // this SHOULD prevent players from getting brain traumas and such.
		M.transfer_to(player) // fuck you REALB in particular

/datum/deathmatch_lobby/proc/remove_player(ckey)
	var/list/L = players[ckey]
	ready_count -= L["ready"]
	L.Cut()
	players[ckey] = null
	players.Remove(ckey)

/datum/deathmatch_lobby/proc/remove_observer(ckey)
	var/list/L = observers[ckey]
	L.Cut()
	observers[ckey] = null
	observers.Remove(ckey)

/datum/deathmatch_lobby/proc/leave(ckey)
	if (host == ckey)
		var/total_count = players.len + observers.len
		if (total_count <= 1) // <= just in case.
			game.remove_lobby(host)
			return
		else
			if (players[ckey] && players.len <= 1)
				for (var/K in observers)
					if (host == K)
						continue
					host = K
					observers[K]["host"] = TRUE
					break
			else
				for (var/K in players)
					if (host == K)
						continue
					host = K
					players[K]["host"] = TRUE
					break
			game.passoff_lobby(ckey, host)
	if (players[ckey])
		remove_player(ckey)
	else if (observers[ckey])
		remove_observer(ckey)

/datum/deathmatch_lobby/proc/join(mob/player)
	if (playing || !player)
		return
	if (players.len >= map.max_players)
		add_observer(player)
	else
		add_player(player, loadouts[1])
	ui_interact(player)

/datum/deathmatch_lobby/proc/spectate(mob/player)
	if (!playing || !location || !player)
		return
	if (!observers[player.ckey])
		add_observer(player)
	player.forceMove(location.centre)

/datum/deathmatch_lobby/proc/change_map(new_map)
	if (!new_map || !game.maps[new_map])
		return
	map = game.maps[new_map]
	var/max_players = map.max_players
	for (var/P in players)
		max_players--
		if (max_players <= 0)
			remove_player(P)
			add_observer(P["mob"])
	if (map.allowed_loadouts)
		var/list/los = map.allowed_loadouts
		loadouts = los
	else
		loadouts = game.loadouts
	for (var/K in players)
		if (players[K]["loadout"] in loadouts)
			continue
		players[K]["loadout"] = loadouts[1]

/datum/deathmatch_lobby/proc/global_chat(mob/speaker, message)
	SIGNAL_HANDLER
	if (islist(message))
		message = message[SPEECH_MESSAGE]
	var/msg = span_prefix("DM: ") + span_name("[speaker.key]") + ": \"[message]\""
	msg = "<span class='game'>[msg]</span>"
	for (var/K in players)
		to_chat(players[K]["mob"], msg)
	for (var/K in observers)
		to_chat(observers[K]["mob"], msg)

/datum/deathmatch_lobby/Topic(href, href_list)
	var/mob/dead/observer/ghost = usr
	if (!istype(ghost))
		return
	if(href_list["join"])
		join(ghost)

/datum/deathmatch_lobby/ui_state(mob/user)
	return GLOB.observer_state

/datum/deathmatch_lobby/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, null)
	if(!ui)
		ui = new(user, src, "DeathmatchLobby")
		ui.open()

/datum/deathmatch_lobby/ui_static_data(mob/user)
	. = ..()
	.["maps"] = list()
	for (var/P in game.maps)
		.["maps"] += P

/datum/deathmatch_lobby/ui_data(mob/user)
	. = ..()
	.["self"] = user.ckey
	.["host"] = (user.ckey == host)
	.["admin"] = check_rights_for(user.client, R_ADMIN)
	.["global_chat"] = global_chat
	.["loadouts"] = list()
	for (var/L in loadouts)
		var/datum/deathmatch_loadout/DML = L
		.["loadouts"] += initial(DML.name)
	.["map"] = list()
	.["map"]["name"] = map.name
	.["map"]["desc"] = map.desc
	.["map"]["min_players"] = map.min_players
	.["map"]["max_players"] = map.max_players
	.["players"] = list()
	for (var/K in players)
		var/list/P = players[K]
		var/mob/PM = P["mob"]
		if (!PM || !PM.client)
			leave(K)
			continue
		.["players"][K] = P.Copy()
		var/datum/deathmatch_loadout/L = P["loadout"]
		.["players"][K]["loadout"] = initial(L.name)
	.["observers"] = list()
	for (var/K in observers)
		var/list/P = observers[K]
		var/mob/PM = P["mob"]
		if (!PM || !PM.client)
			leave(K)
			continue
		.["observers"][K] = observers[K]

/datum/deathmatch_lobby/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isobserver(usr))
		return
	switch(action)
		if ("start_game")
			if (usr.ckey != host)
				return
			if (map.min_players > players.len)
				to_chat(usr, span_warning("Not enough players to start yet."))
				return
			start_game()
		if ("leave_game")
			if (playing)
				return
			leave(usr.ckey)
			ui.close()
			game.ui_interact(usr)
		if ("change_loadout")
			if (playing)
				return
			if (params["player"] != usr.ckey && host != usr.ckey)
				return
			for (var/L in loadouts)
				var/datum/deathmatch_loadout/DML = L
				if (params["loadout"] != initial(DML.name))
					continue
				players[params["player"]]["loadout"] = DML
				return
		if ("observe")
			if (playing)
				return
			if (players[usr.ckey])
				remove_player(usr.ckey)
				add_observer(usr, host == usr.ckey)
			else if (observers[usr.ckey] && players.len < map.max_players)
				remove_observer(usr.ckey)
				add_player(usr, loadouts[1], host == usr.ckey)
		if ("ready")
			players[usr.ckey]["ready"] ^= 1 // Toggle.
			ready_count += (players[usr.ckey]["ready"] * 2) - 1 // scared?
			if (ready_count >= players.len && players.len >= map.min_players)
				start_game()
		if ("host") // Host functions
			if (playing || (usr.ckey != host && !check_rights(R_ADMIN)))
				return
			var/uckey = params["id"]
			switch (params["func"])
				if ("Kick")
					leave(uckey)
					var/umob = get_mob_by_ckey(uckey)
					var/datum/tgui/uui = SStgui.get_open_ui(umob, src)
					uui?.close()
					game.ui_interact(umob)
				if ("Transfer host")
					if (host == uckey)
						return
					game.passoff_lobby(host, uckey)
					host = uckey
				if ("Toggle observe")
					var/umob = get_mob_by_ckey(uckey)
					if (players[uckey])
						remove_player(uckey)
						add_observer(umob, host == uckey)
					else if (observers[uckey] && players.len < map.max_players)
						remove_observer(uckey)
						add_player(umob, loadouts[1], host == uckey)
				if ("change_map")
					if (!(params["map"] in game.maps))
						return
					change_map(params["map"])
				if ("global_chat")
					global_chat = !global_chat
		if ("admin") // Admin functions
			if (!check_rights(R_ADMIN))
				message_admins("[usr.key] has attempted to use admin functions in a deathmatch lobby!")
				log_admin("[key_name(usr)] tried to use the deathmatch lobby admin functions without authorization.")
				return
			switch (params["func"])
				if ("Force start")
					log_admin("[key_name(usr)] force started deathmatch lobby [host].")
					start_game()

