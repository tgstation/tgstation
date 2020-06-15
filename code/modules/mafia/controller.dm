/datum/mafia_controller
	var/list/all_roles = list()
	var/list/player_role_lookup = list() //This only exists to speed up role retrieval
	var/phase = MAFIA_PHASE_SETUP
	var/turn = 0

	var/player_old_bodies = list() //We send players back to their bodies after

	var/day_phase_period = 4 MINUTES
	var/voting_phase_period = 2 MINUTES
	var/night_phase_period = 3 MINUTES
	var/victory_lap_period = 1 MINUTES

	var/list/current_setup_text //Redable list of roles in current game

	var/game_id //Used to sync all parts - signup boards, spawns, night curtains, defaults to "mafia"
	var/list/signed_up = list()

	var/player_outfit = /datum/outfit/mafia //todo some fluffy outfit

	var/list/landmarks = list()
	var/list/votes = list()
	var/next_phase_timer

	var/debug = FALSE

/datum/mafia_controller/New(game_id = "mafia")
	. = ..()
	src.game_id = game_id
	GLOB.mafia_games[game_id] = src
	for(var/obj/effect/landmark/mafia/possible_spawn in GLOB.landmarks_list)
		if(possible_spawn.game_id == game_id)
			landmarks += possible_spawn

/datum/mafia_controller/Destroy(force, ...)
	. = ..()
	end_game()
	GLOB.mafia_games[game_id] = null

/datum/mafia_controller/proc/prepare_game(setup_list,ready_players)
	current_setup_text = list()
	for(var/rtype in setup_list)
		for(var/i in 1 to setup_list[rtype])
			all_roles += new rtype(src)
		var/datum/mafia_role/rp = rtype
		current_setup_text += "[initial(rp.name)] x[setup_list[rtype]]"
	var/list/spawnpoints = landmarks.Copy()
	for(var/datum/mafia_role/role in all_roles)
		role.assigned_landmark = pick_n_take(spawnpoints)
		if(!debug)
			role.player_key = pick_n_take(ready_players)
		else
			role.player_key = pop(ready_players)

/datum/mafia_controller/proc/send_message(msg,team)
	for(var/datum/mafia_role/R in all_roles)
		if(team && R.team != team)
			continue
		to_chat(R.body,msg)

/datum/mafia_controller/proc/start_game()
	create_bodies()
	start_day()

/datum/mafia_controller/proc/start_day()
	turn += 1
	phase = MAFIA_PHASE_DAY
	if(!check_victory())
		next_phase_timer = addtimer(CALLBACK(src,.proc/start_voting_phase),day_phase_period,TIMER_STOPPABLE)
		send_message("<span class='big'>Day [turn] started! Voting will start in 4 minutes.</span>")
	SStgui.update_uis(src)


/datum/mafia_controller/proc/start_voting_phase()
	phase = MAFIA_PHASE_VOTING
	next_phase_timer = addtimer(CALLBACK(src, .proc/lynch),voting_phase_period,TIMER_STOPPABLE)
	send_message("<span class='big'>Voting started! Vote for who you want to see lynched today.</span>")
	SStgui.update_uis(src)

/datum/mafia_controller/proc/lynch()
	var/datum/mafia_role/loser = get_vote_winner("Day")
	if(loser)
		send_message("<span class='big'>[loser.body.real_name] wins the day vote and will be killed.</span>")
		loser.kill(src,lynch=TRUE)
		reset_votes("Day")
	if(!check_victory())
		lockdown()
	SStgui.update_uis(src)

/datum/mafia_controller/proc/check_victory()
	var/alive_town = 0
	var/alive_mafia = 0
	var/solo_present = FALSE
	for(var/datum/mafia_role/R in all_roles)
		if(R.game_status == MAFIA_ALIVE)
			switch(R.team)
				if(MAFIA_TEAM_MAFIA)
					alive_mafia++
				if(MAFIA_TEAM_TOWN)
					alive_town++
				if(MAFIA_TEAM_SOLO)
					solo_present = TRUE
	if(solo_present && alive_town + alive_mafia <= 1)
		start_the_end("<span class='big red'>!! TRAITOR VICTORY !!</span>")
		return TRUE
	if(alive_mafia == 0 && !solo_present)
		start_the_end("<span class='big green'>!! TOWN VICTORY !!</span>")
		return TRUE
	else if(alive_mafia >= alive_town && !solo_present) //guess could change if town nightkill is added
		start_the_end("<span class='big red'>!! MAFIA VICTORY !!</span>")
		return TRUE

/datum/mafia_controller/proc/start_the_end(message)
	send_message(message)
	phase = MAFIA_PHASE_VICTORY_LAP
	next_phase_timer = addtimer(CALLBACK(src,.proc/end_game),victory_lap_period,TIMER_STOPPABLE)

/datum/mafia_controller/proc/end_game()
	restore_player_bodies()
	player_old_bodies = list()
	QDEL_LIST(all_roles)
	turn = 0
	votes = list()
	phase = MAFIA_PHASE_SETUP

/datum/mafia_controller/proc/restore_player_bodies()
	for(var/mob/living/old_body in player_old_bodies)
		old_body.key = player_old_bodies[old_body]

/datum/mafia_controller/proc/lockdown()
	toggle_night_curtains(close=TRUE)
	start_night()

/datum/mafia_controller/proc/toggle_night_curtains(close)
	for(var/obj/machinery/door/poddoor/D in GLOB.machines) //I really dislike pathing of these
		if(D.id != game_id)
			continue
		if(close)
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/close)
		else
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/open)

/datum/mafia_controller/proc/start_night()
	phase = MAFIA_PHASE_NIGHT
	send_message("<span class='big'>Night [turn] started! Lockdown will end in 4 minutes.</span>")
	send_message("<span class='big'>Vote for who to kill tonight. The killer will be chosen randomly from voters.</span>",MAFIA_TEAM_MAFIA)
	next_phase_timer = addtimer(CALLBACK(src, .proc/resolve_night),night_phase_period,TIMER_STOPPABLE)
	SStgui.update_uis(src)

/datum/mafia_controller/proc/resolve_night()
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_START)
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_ACTION_PHASE)
	//resolve mafia kill, todo unsnowflake this
	var/datum/mafia_role/R = get_vote_winner("Mafia")
	if(R)
		R.kill(src)
	reset_votes("Mafia")
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_KILL_PHASE)
	SEND_SIGNAL(src,COMSIG_MAFIA_NIGHT_END)
	toggle_night_curtains(close=FALSE)
	start_day()
	SStgui.update_uis(src)

/datum/mafia_controller/proc/vote_for(datum/mafia_role/voter,datum/mafia_role/target,vt)
	if(!votes[vt])
		votes[vt] = list()
	var/old_vote = votes[vt][voter]
	if(old_vote && old_vote == target)
		votes[vt] -= voter
	else
		votes[vt][voter] = target
	if(vt=="Day")
		if(old_vote && old_vote == target)
			send_message("<span class='notice'>[voter.body.real_name] retracts their vote for [target.body.real_name]!</span>")
		else
			send_message("<span class='notice'>[voter.body.real_name] voted for [target.body.real_name]!</span>")
			target.body.update_icon() //Update the vote display
		if(old_vote)
			var/datum/mafia_role/old = old_vote
			old.body.update_icon()

/datum/mafia_controller/proc/reset_votes(vt)
	var/list/bodies_to_update = list()
	for(var/vote in votes[vt])
		var/datum/mafia_role/R = votes[vt][vote]
		bodies_to_update += R.body
	votes[vt] = list()
	for(var/mob/M in bodies_to_update)
		M.update_icon()

/datum/mafia_controller/proc/get_vote_count(role,vt)
	. = 0
	for(var/votee in votes[vt])
		if(votes[vt][votee] == role)
			. += 1

/datum/mafia_controller/proc/get_vote_winner(vt)
	var/list/tally = list()
	for(var/votee in votes[vt])
		if(!tally[votes[vt][votee]])
			tally[votes[vt][votee]] = 1
		else
			tally[votes[vt][votee]] += 1
	sortTim(tally,/proc/cmp_numeric_dsc,associative=TRUE)
	return length(tally) ? tally[1] : null

/datum/mafia_controller/proc/get_random_voter(vt)
	if(length(votes[vt]))
		return pick(votes[vt])

/datum/mafia_controller/proc/display_votes(atom/source, list/overlay_list)
	if(phase != MAFIA_PHASE_VOTING)
		return
	var/v = get_vote_count(player_role_lookup[source],"Day")
	var/mutable_appearance/MA = mutable_appearance('icons/obj/mafia.dmi',"vote_[v]")
	overlay_list += MA

/datum/mafia_controller/proc/create_bodies()
	for(var/datum/mafia_role/role in all_roles)
		var/mob/living/carbon/human/H = new(get_turf(role.assigned_landmark))
		H.equipOutfit(player_outfit)
		RegisterSignal(H,COMSIG_ATOM_UPDATE_OVERLAYS,.proc/display_votes)
		var/datum/action/innate/mafia_panel/mafia_panel = new(null,src)
		mafia_panel.Grant(H)
		var/client/player_client = GLOB.directory[role.player_key]
		var/mob/living/old_body
		if(player_client)
			player_client.prefs.copy_to(H, antagonist = TRUE) ///yikes
			old_body = player_client.mob
		else
			//warn about guy being afk on start
			for(var/mob/living/M in GLOB.mob_list)
				if(M.key == role.player_key)
					old_body = M
					break
		if(istype(old_body))
			player_old_bodies[old_body] = role.player_key
		role.body = H
		player_role_lookup[H] = role
		H.key = role.player_key
		role.greet()

/datum/mafia_controller/ui_data(mob/user)
	. = ..()
	switch(phase)
		if(MAFIA_PHASE_DAY,MAFIA_PHASE_VOTING)
			.["phase"] = "Day [turn]"
		if(MAFIA_PHASE_NIGHT)
			.["phase"] = "Night [turn]"
		else
			.["phase"] = "No Game"
	if(user.client?.holder)
		.["admin_controls"] = TRUE //show admin buttons to start/setup/stop
	var/datum/mafia_role/user_role = player_role_lookup[user]
	if(user_role)
		.["role_info"] = list("role" = user_role.name,"desc" = user_role.desc, "action_log" = user_role.role_notes)
		var/actions = list()
		for(var/action in user_role.actions)
			if(user_role.validate_action_target(src,action,null))
				actions += action
		.["actions"] = actions
	var/list/player_data = list()
	for(var/datum/mafia_role/R in all_roles)
		var/list/player_info = list()
		var/list/actions = list()
		//Awful snowflake, could use generalizing
		if(phase == MAFIA_PHASE_VOTING)
			player_info["votes"] = get_vote_count(R,"Day")
			if(R.game_status == MAFIA_ALIVE && R != user_role)
				actions += "Vote"
		if(phase == MAFIA_PHASE_NIGHT && user_role.team == MAFIA_TEAM_MAFIA && R.game_status == MAFIA_ALIVE && R.team != MAFIA_TEAM_MAFIA)
			actions += "Kill Vote"
		if(user_role)
			for(var/action in user_role.targeted_actions)
				if(user_role.validate_action_target(src,action,R))
					actions += action
		player_info["name"] = R.body.real_name
		player_info["ref"] = REF(R)
		player_info["actions"] = actions
		player_info["alive"] = R.game_status == MAFIA_ALIVE
		player_data += list(player_info)
	.["players"] = player_data
	.["timeleft"] = next_phase_timer ? timeleft(next_phase_timer) : 0

	//Not sure on this, should this info be visible
	.["all_roles"] = current_setup_text

/datum/mafia_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/mafia_role/user_role = player_role_lookup[usr]
	//Admin actions
	if(usr.client?.holder)
		switch(action)
			if("new_game")
				end_game()
				basic_setup()
			if("next_phase")
				var/datum/timedevent/timer = SStimer.timer_id_dict[next_phase_timer]
				if(!timer.spent)
					var/datum/callback/tc = timer.callBack
					deltimer(next_phase_timer)
					tc.InvokeAsync()
				return TRUE
	if(!user_role)
		return
	//User actions
	switch(action)
		if("mf_action")
			if(!user_role.actions.Find(params["atype"]))
				return
			user_role.handle_action(src,params["atype"],null)
			return TRUE //vals for self-ui update
		if("mf_targ_action")
			var/datum/mafia_role/target = locate(params["target"]) in all_roles
			if(!istype(target))
				return
			switch(params["atype"])
				if("Vote")
					if(phase != MAFIA_PHASE_VOTING)
						return
					vote_for(user_role,target,vt="Day")
				if("Kill Vote")
					if(phase != MAFIA_PHASE_NIGHT || user_role.team != MAFIA_TEAM_MAFIA)
						return
					vote_for(user_role,target,vt="Mafia")
					to_chat(user_role.body,"You will vote for [target.body.real_name] for tonights killing.")
				else
					if(!user_role.targeted_actions.Find(params["atype"]))
						return
					if(!user_role.validate_action_target(src,params["atype"],target))
						return
					user_role.handle_action(src,params["atype"],target)
			return TRUE

/datum/mafia_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, null, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MafiaPanel", "Mafia", 500, 500, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/proc/assoc_value_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/datum/mafia_controller/proc/find_best_setup(ready_count)
	var/list/all_setups = GLOB.mafia_setups
	var/valid_setups = list()
	for(var/S in all_setups)
		var/req_players = assoc_value_sum(S)
		if(req_players <= ready_count)
			valid_setups += list(S)
	return length(valid_setups) > 0 ? pick(valid_setups) : null

/datum/mafia_controller/proc/basic_setup()
	var/ready_count = GLOB.minigame_signups.GetCurrentPlayerCount("mafia")
	var/list/setup = find_best_setup(ready_count)
	if(!setup)
		return
	var/req_players = assoc_value_sum(setup)
	var/list/filtered_keys = GLOB.minigame_signups.GetPlayers("mafia",req_players,!debug)
	prepare_game(setup,filtered_keys)
	start_game()

/datum/mafia_controller/proc/try_autostart()
	if(phase != MAFIA_PHASE_SETUP)
		return
	var/min_players = 999 // fairly sure mmo mafia is not a thing and i'm lazy
	for(var/setup in GLOB.mafia_setups)
		min_players = min(min_players,assoc_value_sum(setup))
	if(GLOB.minigame_signups.GetCurrentPlayerCount("mafia") >= min_players)
		basic_setup()

/datum/action/innate/mafia_panel
	name = "Mafia Panel"
	desc = "Use this to play."
	icon_icon = 'icons/obj/mafia.dmi'
	button_icon_state = "board"
	var/datum/mafia_controller/parent

/datum/action/innate/mafia_panel/New(Target,mf)
	. = ..()
	parent = mf

/datum/action/innate/mafia_panel/Activate()
	parent.ui_interact(owner)

/datum/saymode/mafia
	key = "j"

/datum/saymode/mafia/handle_message(mob/living/user, message, datum/language/language)
	for(var/key in GLOB.mafia_games)
		var/datum/mafia_controller/MF = GLOB.mafia_games[key]
		var/datum/mafia_role/R = MF.player_role_lookup[user]
		if(!R || R.team != MAFIA_TEAM_MAFIA)
			continue
		MF.send_message("<span class='changeling'><b>[R.body.real_name]:</b> [message]</span>",MAFIA_TEAM_MAFIA)
		return FALSE
	return TRUE

/proc/create_mafia_game(game_key)
	if(GLOB.mafia_games[game_key])
		QDEL_NULL(GLOB.mafia_games[game_key])
	var/datum/mafia_controller/MF = new(game_key)
	return MF

/datum/outfit/mafia
	name = "Mafia Game Outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
