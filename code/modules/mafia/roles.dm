/datum/mafia_role
	var/name = "Assistant"
	var/desc = "You are a crewmember without any special abilities."
	var/team = MAFIA_TEAM_TOWN

	var/player_key
	var/mob/living/carbon/human/body
	var/obj/effect/landmark/mafia/assigned_landmark

	var/datum/outfit/revealed_outfit = /datum/outfit/job/assistant/mafia //the assistants need a special path to call out they were in fact assistant, everything else can just use job equipment
	//action = uses
	var/list/actions = list()
	var/list/targeted_actions = list()

	//so mafia have to also kill them to have a majority
	var/solo_counts_as_town = FALSE//I KNOW IT'S JANK BUT ONLY SET THIS FOR SOLO ANTAGS NOT TOWNIES THEMSELVES THEY'RE AUTO COUNTED

	var/game_status = MAFIA_ALIVE

	var/list/role_notes = list()


/datum/mafia_role/New(datum/mafia_controller/game)
	. = ..()

/datum/mafia_role/proc/kill(datum/mafia_controller/game,lynch=FALSE)
	if(SEND_SIGNAL(src,COMSIG_MAFIA_ON_KILL,game,lynch) & MAFIA_PREVENT_KILL)
		return FALSE
	game_status = MAFIA_DEAD
	body.death()
	if(lynch)
		reveal_role(game, verbose = TRUE)
	return TRUE

/datum/mafia_role/Destroy(force, ...)
	QDEL_NULL(body)
	. = ..()

/datum/mafia_role/proc/greet()
	to_chat(body,"<span class='danger'>You are [name].</span>")
	to_chat(body,"<span class='danger'>[desc].</span>")
	switch(team)
		if(MAFIA_TEAM_MAFIA)
			to_chat(body,"<span class='danger'>You and your co-conspirators win if you outnumber crewmembers.</span>")
		if(MAFIA_TEAM_TOWN)
			to_chat(body,"<span class='danger'>You are a crewmember. Find out and lynch the changelings!</span>")
		if(MAFIA_TEAM_SOLO)
			to_chat(body,"<span class='danger'>You are not aligned to town or mafia. Accomplish your own objectives!</span>")

//please take care with this, they can break shit with their equipment unless you specifically disallow them (aka stun at the end of the game)
/datum/mafia_role/proc/reveal_role(datum/mafia_controller/game, verbose = FALSE)
	if(verbose)
		game.send_message("<span class='big bold notice'>It is revealed that the true role of [body] was [name]!</span>")
	body.equipOutfit(revealed_outfit)

/datum/mafia_role/proc/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	return

/datum/mafia_role/proc/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(SEND_SIGNAL(src,COMSIG_MAFIA_CAN_PERFORM_ACTION,game,action,target) & MAFIA_PREVENT_ACTION)
		return FALSE
	return TRUE

/datum/mafia_role/proc/add_note(note)
	role_notes += note

/datum/mafia_role/proc/check_total_victory(alive_town, alive_mafia) //solo antags can win... solo.
	return FALSE

/datum/mafia_role/proc/block_team_victory(alive_town, alive_mafia) //solo antags can also block team wins.
	return FALSE

/datum/mafia_role/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, null, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MafiaPanel", "Mafia", 500, 500, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()
/*
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
	if(phase == MAFIA_PHASE_JUDGEMENT)
		.["judgement_phase"] = TRUE //show judgement section
	else
		.["judgement_phase"] = FALSE
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
*/
/datum/mafia_role/detective
	name = "Detective"
	desc = "You can investigate a single person each night to reveal their team."
	revealed_outfit = /datum/outfit/job/detective

	targeted_actions = list("Investigate")

	var/datum/mafia_role/current_investigation

/datum/mafia_role/detective/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/investigate)

/datum/mafia_role/detective/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/detective/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>You can only investigate alive people.</span>")
		return
	to_chat(body,"<span class='warning'>You will investigate [target.body.real_name] tonight.</span>")
	current_investigation = target

/datum/mafia_role/detective/proc/investigate(datum/mafia_controller/game)
	var/datum/mafia_role/R = current_investigation
	if(R)
		var/team_text
		var/fluff
		switch(R.team)
			if(MAFIA_TEAM_TOWN)
				team_text = "Town"
				fluff = "a true member of the station."
			if(MAFIA_TEAM_MAFIA)
				team_text = "Mafia"
				fluff = "an unfeeling, hideous changeling!"
			if(MAFIA_TEAM_SOLO)
				team_text = "Solo"
				fluff = "a rogue, with their own objectives..."
		to_chat(body,"<span class='warning'>Your investigations reveal that [R.body.real_name] is [fluff]</span>")
		add_note("N[game.turn] - [R.body.real_name] - [team_text]")
	current_investigation = null

/datum/mafia_role/md
	name = "Medical Doctor"
	desc = "You can protect a single person each night from killing."
	revealed_outfit = /datum/outfit/job/doctor // /mafia <- outfit must be readded (just make a new mafia outfits file for all of these)

	targeted_actions = list("Protect")

	var/datum/mafia_role/current_protected

/datum/mafia_role/md/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/protect)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/end_protection)

/datum/mafia_role/md/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/md/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>You can only protect alive people.</span>")
		return
	to_chat(body,"<span class='warning'>You will protect [target.body.real_name] tonight.</span>")
	current_protected = target

/datum/mafia_role/md/proc/protect(datum/mafia_controller/game)
	if(current_protected)
		RegisterSignal(current_protected,COMSIG_MAFIA_ON_KILL,.proc/prevent_kill)
		add_note("N[game.turn] - Protected [current_protected.body.real_name]")

/datum/mafia_role/md/proc/prevent_kill(datum/source)
	to_chat(body,"<span class='warning'>The person you protected tonight was attacked!</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/md/proc/end_protection(datum/mafia_controller/game)
	if(current_protected)
		UnregisterSignal(current_protected,COMSIG_MAFIA_ON_KILL)
		current_protected = null

/datum/mafia_role/chaplain
	name = "Chaplain"
	desc = "You can communicate with spirits of the dead each night to discover dead crewmember roles."
	revealed_outfit = /datum/outfit/job/chaplain

	targeted_actions = list("Pray")
	var/current_target

/datum/mafia_role/chaplain/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/commune)

/datum/mafia_role/chaplain/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_DEAD && target != src

/datum/mafia_role/chaplain/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	to_chat(body,"<span class='warning'>You will commune with the spirit of [target.body.real_name] tonight.</span>")
	current_target = target

/datum/mafia_role/chaplain/proc/commune(datum/mafia_controller/game)
	var/datum/mafia_role/R = current_target
	if(R)
		to_chat(body,"<span class='warning'>You invoke spirit of [R.body.real_name] and learn their role was <b>[R.name]<b>.</span>")
		add_note("N[game.turn] - [R.body.real_name] - [R.name]")
		current_target = null

/datum/mafia_role/clown
	name = "Clown"
	desc = "If you are lynched you take down one of your voters with you and win. HONK!"
	revealed_outfit = /datum/outfit/job/clown

/datum/mafia_role/clown/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/prank)

/datum/mafia_role/clown/proc/prank(datum/source,datum/mafia_controller/game,lynch)
	if(lynch)
		var/datum/mafia_role/victim = pick(game.judgement_guilty_votes)
		game.send_message("<span class='big clown'>[body.real_name] WAS A CLOWN! HONK! They take down [victim.body.real_name] with their last prank.</span>")
		to_chat(body,"<span class='big green'>!! CLOWN VICTORY !!</span>")
		victim.kill(game,FALSE)

/datum/mafia_role/warden
	name = "Warden"
	desc = "You can choose a person during the day to imprison, preventing them from performing night actions"

	revealed_outfit = /datum/outfit/job/warden
	targeted_actions = list("Imprison")

	var/datum/mafia_role/current_imprison_target

/datum/mafia_role/warden/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_START,.proc/try_to_imprison)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/release)

/datum/mafia_role/warden/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(game.phase != MAFIA_PHASE_DAY && game.phase != MAFIA_PHASE_VOTING)
		return FALSE
	if(target.game_status != MAFIA_ALIVE)
		return FALSE

/datum/mafia_role/warden/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	to_chat(body,"<span class='warning'>You will imprison [target.body.real_name] tonight.</span>")
	current_imprison_target = target

/datum/mafia_role/warden/proc/try_to_imprison(datum/mafia_controller/game)
	if(SEND_SIGNAL(src,COMSIG_MAFIA_CAN_PERFORM_ACTION,game,"imprison",current_imprison_target) & MAFIA_PREVENT_ACTION || game_status != MAFIA_ALIVE) //Got lynched or imprisoned by another warden.
		current_imprison_target = null
	if(current_imprison_target)
		RegisterSignal(current_imprison_target,COMSIG_MAFIA_CAN_PERFORM_ACTION, .proc/prevent_action)
		add_note("N[game.turn] - [current_imprison_target.body.real_name] - Imprisoned")
		to_chat(current_imprison_target.body,"<span class='big red'>YOU HAVE BEEN IMPRISONED! YOU CANNOT PERFORM ANY ACTIONS TONIGHT.</span>")

/datum/mafia_role/warden/proc/release(datum/mafia_controller/game)
	. = ..()
	if(current_imprison_target)
		UnregisterSignal(current_imprison_target)

/datum/mafia_role/warden/proc/prevent_action(datum/source)
	if(game_status == MAFIA_ALIVE) //in case we got killed while imprisoning sk - bad luck edge
		return MAFIA_PREVENT_ACTION

/datum/mafia_role/mafia
	name = "Changeling"
	desc = "You're the informed minority. Use ':j' talk prefix to talk to your comrades"
	team = MAFIA_TEAM_MAFIA
	revealed_outfit = /datum/outfit/mafialing



///SOLO ROLES/// they range from anomalous factors not good or evil to deranged killers that try to win alone.

/datum/mafia_role/traitor
	name = "Traitor"
	desc = "You're a solo traitor. You are immune to night kills, can kill every night and you win by outnumbering everyone else."
	team = MAFIA_TEAM_SOLO
	targeted_actions = list("Night Kill")
	revealed_outfit = /datum/outfit/syndicate_empty // /mafia <- outfit must be readded (just make a new mafia outfits file for all of these)

	var/datum/mafia_role/current_victim

/datum/mafia_role/traitor/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/nightkill_immunity)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_KILL_PHASE,.proc/try_to_kill)

/datum/mafia_role/traitor/check_total_victory(alive_town, alive_mafia) //serial killers just want teams dead
	return alive_town + alive_mafia <= 1

/datum/mafia_role/traitor/block_team_victory(alive_town, alive_mafia) //no team can win until they're dead
	return TRUE //while alive, town AND mafia cannot win (though since mafia know who is who it's pretty easy to win from that point)

/datum/mafia_role/traitor/proc/nightkill_immunity(datum/source,datum/mafia_controller/game,lynch)
	if(game.phase == MAFIA_PHASE_NIGHT && !lynch)
		return MAFIA_PREVENT_KILL

/datum/mafia_role/traitor/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(game.phase != MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE)
		return FALSE

/datum/mafia_role/traitor/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	current_victim = target
	to_chat(body,"<span class='warning'>You will attempt to kill [target.body.real_name] tonight.</span>")

/datum/mafia_role/traitor/proc/try_to_kill(datum/mafia_controller/source)
	if(game_status == MAFIA_ALIVE && current_victim && current_victim.game_status == MAFIA_ALIVE)
		if(!current_victim.kill(source))
			to_chat(body,"<span class='danger'>Your attempt at killing [current_victim.body] was prevented!</span>")
	current_victim = null

//just helps read better
#define FUGITIVE_NOT_PRESERVING 0//will not become night immune tonight
#define FUGITIVE_WILL_PRESERVE 1 //will become night immune tonight

/datum/mafia_role/fugitive
	name = "Fugitive"
	desc = "You're on the run. You can become immune to night kills exactly twice, and you win by surviving to the end of the game with anyone."
	team = MAFIA_TEAM_SOLO
	actions = list("Self Preservation")
	var/charges = 2
	var/protection_status = FUGITIVE_NOT_PRESERVING
	solo_counts_as_town = TRUE //should not count towards mafia victory, they should have the option to work with town
	revealed_outfit = /datum/outfit/yalp_cultist

/datum/mafia_role/fugitive/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_START,.proc/night_start)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/night_end)
	RegisterSignal(game,COMSIG_MAFIA_GAME_END,.proc/survived)

/datum/mafia_role/fugitive/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,"<span class='danger'>You're out of supplies and cannot protect yourself anymore.</span>")
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,"<span class='danger'>You don't have time to prepare, night has already arrived.</span>")
		return
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>You decide to not prepare tonight.</span>")
	else
		to_chat(body,"<span class='danger'>You decide to prepare for a horrible night.</span>")
	protection_status = !protection_status

/datum/mafia_role/fugitive/proc/night_start(datum/mafia_controller/game)
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>Your preparations are complete. Nothing could kill you tonight!</span>")
		RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/prevent_death)

/datum/mafia_role/fugitive/proc/night_end(datum/mafia_controller/game)
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_KILL)
		to_chat(body,"<span class='danger'>You are no longer protected. You have [charges] use[charges == 1 ? "" : "s"] left of your power.</span>")
		protection_status = FUGITIVE_NOT_PRESERVING

/datum/mafia_role/fugitive/proc/prevent_death(datum/mafia_controller/game)
	to_chat(body,"<span class='userdanger'>You were attacked! Luckily, you were ready for this!</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/fugitive/proc/survived(datum/mafia_controller/game)
	if(game_status == MAFIA_ALIVE)
		game.send_message("<span class='big comradio'>!! FUGITIVE VICTORY !!</span>")

#undef FUGITIVE_NOT_PRESERVING
#undef FUGITIVE_WILL_PRESERVE

/datum/mafia_role/obsessed
	name = "Obsessed"
	desc = "You're completely lost in your own mind. You win by lynching your obsession before you get killed in this mess. Obsession assigned on the first night!"
	team = MAFIA_TEAM_SOLO
	revealed_outfit = /datum/outfit/psycho // /mafia <- outfit must be readded (just make a new mafia outfits file for all of these)

	solo_counts_as_town = TRUE //after winning or whatever, can side with whoever. they've already done their objective!
	var/datum/mafia_role/obsession
	var/lynched_target = FALSE

/datum/mafia_role/obsessed/New(datum/mafia_controller/game) //note: obsession is always a townie
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_START,.proc/find_obsession)

/datum/mafia_role/obsessed/proc/find_obsession(datum/mafia_controller/game)
	var/list/all_roles_shuffle = shuffle(game.all_roles)
	for(var/role in all_roles_shuffle)
		var/datum/mafia_role/possible = role
		if(possible.team == MAFIA_TEAM_TOWN)
			obsession = possible
			break
	if(!obsession)
		obsession = pick(all_roles_shuffle) //okay no town just pick anyone here
	//if you still don't have an obsession you're playing a single player game like i can't help your dumb ass
	to_chat(body, "<span class='userdanger'>Your obsession is [obsession.body.real_name]! Get them lynched to win!</span>")
	add_note("N[game.turn] - I vowed to watch my obsession, [obsession.body.real_name], hang!") //it'll always be N1 but whatever
	RegisterSignal(obsession,COMSIG_MAFIA_ON_KILL,.proc/check_victory)
	UnregisterSignal(src,COMSIG_MAFIA_NIGHT_START)

/datum/mafia_role/obsessed/proc/check_victory(datum/source,datum/mafia_controller/game,lynch)
	if(lynch)
		game.send_message("<span class='big red'>!! OBSESSED VICTORY !!</span>") //red since it's a confirmed townie
	else
		to_chat(body, "<span class='userdanger'>Your obsession died alone, WITHOUT YOU THERE! You have failed your objective to lynch them!</span>")
