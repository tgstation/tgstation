/*

CLOCKWORK CULT: Based off of the failed pull requests from /vg/

While Nar-Sie is the oldest and most prominent of the elder gods, there are other forces at work in the universe.
Ratvar, the Clockwork Justiciar, a homage to Nar-Sie granted sentience by its own power, is one such other force.
Imprisoned within a massive construct known as the Celestial Derelict - or Reebe - an intense hatred of the Blood God festers.
Ratvar, unable to act in the mortal plane, seeks to return and forms covenants with mortals in order to bolster his influence.
Due to his mechanical nature, Ratvar is also capable of influencing silicon-based lifeforms, unlike Nar-Sie, who can only influence natural life.

This is a team-based gamemode, and the team's objective is shared by all cultists. It can include summoning Ratvar, escaping on the shuttle, or converting the AI and its cyborgs.

The clockwork version of an arcane tome is the clockwork slab.
While it can perform certain actions, it consumes a resource called components.
Components, which are fallen fragments of Ratvar's body as he rusts in Reebe, are powerful and have various effects.
Game-wise, clockwork slabs will generate components over time, with more powerful components being slower.

This file's folder contains:
	clock_cult.dm: Core gamemode files.
	clock_effect.dm: The base clockwork effect code.
	- Effect files are in game/gamemodes/clock_cult/clock_effects/
	clock_item.dm: The base clockwork item code.
	- Item files are in game/gamemodes/clock_cult/clock_items/
	clock_mobs.dm: Hostile clockwork creatures.
	clock_scripture.dm: The base Scripture code.
	- Scripture files are in game/gamemodes/clock_cult/clock_scripture/
	clock_structure.dm: The base clockwork structure code, including clockwork machines.
	- Structure files, and Ratvar, are in game/gamemodes/clock_cult/clock_structures/

	game/gamemodes/clock_cult/clock_helpers/ contains several helper procs, including the Ratvarian language.

	clockcult defines are in __DEFINES/clockcult.dm

Credit where due:
1. VelardAmakar from /vg/ for the entire design document, idea, and plan. Thank you very much.
2. SkowronX from /vg/ for MANY of the assets
3. FuryMcFlurry from /vg/ for many of the assets
4. PJB3005 from /vg/ for the failed continuation PR
5. Xhuis from /tg/ for coding the basic gamemode as it is today
6. ChangelingRain from /tg/ for maintaining the gamemode for months after its release

*/

///////////
// PROCS //
///////////

/proc/is_servant_of_ratvar(mob/living/M)
	return istype(M) && M.has_antag_datum(/datum/antagonist/clockcultist, TRUE)

/proc/is_eligible_servant(mob/living/M)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(M.mind.enslaved_to && !is_servant_of_ratvar(M.mind.enslaved_to))
			return FALSE
	else
		return FALSE
	if(iscultist(M) || isconstruct(M) || M.isloyal() || ispAI(M))
		return FALSE
	if(ishuman(M) || isbrain(M) || isguardian(M) || issilicon(M) || isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
		return TRUE
	return FALSE

/proc/add_servant_of_ratvar(mob/living/L, silent = FALSE)
	var/update_type = /datum/antagonist/clockcultist
	if(silent)
		update_type = /datum/antagonist/clockcultist/silent
	. = L.gain_antag_datum(update_type)

/proc/remove_servant_of_ratvar(mob/living/L, silent = FALSE)
	var/datum/antagonist/clockcultist/clock_datum = L.has_antag_datum(/datum/antagonist/clockcultist, TRUE)
	if(!clock_datum)
		return FALSE
	clock_datum.silent_update = silent
	clock_datum.on_remove()
	return TRUE

///////////////
// GAME MODE //
///////////////

/datum/game_mode
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/required_escapees = 0 //How many servants need to escape, if applicable
	var/required_silicon_converts = 0 //How many robotic lifeforms need to be converted, if applicable
	var/clockwork_objective = CLOCKCULT_GATEWAY //The objective that the servants must fulfill
	var/clockwork_explanation = "Construct a Gateway to the Celestial Derelict and free Ratvar." //The description of the current objective

/datum/game_mode/clockwork_cult
	name = "clockwork cult"
	config_tag = "clockwork_cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	required_players = 24
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 14
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain") //Silicons can eventually be converted
	restricted_jobs = list("Chaplain", "Captain")
	announce_span = "brass"
	announce_text = "Servants of Ratvar are trying to summon the Justiciar!\n\
	<span class='brass'>Servants</span>: Take over the station and summon Ratvar.\n\
	<span class='notice'>Crew</span>: Stop the servants before they can summon the Clockwork Justiciar."
	var/servants_to_serve = list()
	var/roundstart_player_count

/datum/game_mode/clockwork_cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"
	var/starter_servants = 3 //Guaranteed three servants
	var/number_players = num_players()
	roundstart_player_count = number_players
	if(number_players > 30) //plus one servant for every additional 15 players
		number_players -= 30
		starter_servants += round(number_players/15)
	while(starter_servants)
		var/datum/mind/servant = pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		modePlayer += servant
		servant.special_role = "Servant of Ratvar"
		servant.restricted_roles = restricted_jobs
		starter_servants--
	return 1

/datum/game_mode/clockwork_cult/post_setup()
	forge_clock_objectives()
	for(var/S in servants_to_serve)
		var/datum/mind/servant = S
		log_game("[servant.key] was made an initial servant of Ratvar")
		var/mob/living/L = servant.current
		greet_servant(L)
		equip_servant(L)
		add_servant_of_ratvar(L, TRUE)
	..()
	return 1

/datum/game_mode/clockwork_cult/proc/forge_clock_objectives() //Determine what objective that Ratvar's servants will fulfill
	var/list/possible_objectives = list(CLOCKCULT_ESCAPE, CLOCKCULT_GATEWAY)
	var/silicons_possible = FALSE
	for(var/mob/living/silicon/ai/S in living_mob_list)
		silicons_possible = TRUE
	if(silicons_possible)
		possible_objectives += CLOCKCULT_SILICONS
	clockwork_objective = pick(possible_objectives)
	switch(clockwork_objective)
		if(CLOCKCULT_ESCAPE)
			required_escapees = round(max(1, roundstart_player_count / 3)) //33% of the player count must be cultists
			clockwork_explanation = "Ensure that [required_escapees] servants of Ratvar escape from [station_name()]."
		if(CLOCKCULT_GATEWAY)
			clockwork_explanation = "Construct a Gateway to the Celestial Derelict and free Ratvar."
		if(CLOCKCULT_SILICONS)
			clockwork_explanation = "Ensure that all active silicon-based lifeforms on [station_name()] are servants of Ratvar and Application scripture is unlocked."
	return 1

/datum/game_mode/clockwork_cult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	var/greeting_text = "<br><b><span class='large_brass'>You are a servant of Ratvar, the Clockwork Justiciar.</span>\n\
	Rusting eternally in the Celestial Derelict, Ratvar has formed a covenant of mortals, with you as one of its members. As one of the Justiciar's servants, you are to work to the best of your \
	ability to assist in completion of His agenda. You may not know the specifics of how to do so, but luckily you have a vessel to help you learn.</b>"
	M << greeting_text
	return 1

/datum/game_mode/proc/equip_servant(mob/living/L) //Grants a clockwork slab to the mob, with one of each component
	if(!L || !istype(L))
		return FALSE
	var/obj/item/clockwork/slab/starter/S = new/obj/item/clockwork/slab/starter(null) //start it off in null
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = slot_l_store, "In your right pocket" = slot_r_store, "In your backpack" = slot_in_backpack, "On your belt" = slot_belt)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(slot == "At your feet")
		if(!S.forceMove(get_turf(L)))
			qdel(S)
	if(S && !qdeleted(S))
		L << "<b>[slot] is a link to the halls of Reebe and your master. You may use it to perform many tasks, but also become oriented with the workings of Ratvar and how to best complete your \
		tasks. This clockwork slab will be instrumental in your triumph. Remember: you can speak discreetly with your fellow servants by using the <span class='brass'>Hierophant Network</span> action button, \
		and you can find a concise tutorial by using the slab in-hand and selecting Recollection.</b>"
		L << "<i>Alternatively, check out the wiki page at </i><b>https://tgstation13.org/wiki/Clockwork_Cult</b><i>, which contains additional information.</i>"
		return TRUE
	return FALSE

/datum/game_mode/clockwork_cult/proc/present_tasks(mob/living/L) //Memorizes and displays the clockwork cult's objective
	if(!L || !istype(L) || !L.mind)
		return 0
	var/datum/mind/M = L.mind
	M.current << "<b>This is Ratvar's will:</b> [clockwork_explanation]"
	M.memory += "<b>Ratvar's will:</b> [clockwork_explanation]<br>"
	return 1

/datum/game_mode/clockwork_cult/proc/check_clockwork_victory()
	switch(clockwork_objective)
		if(CLOCKCULT_ESCAPE)
			var/surviving_servants = 0
			for(var/datum/mind/M in servants_of_ratvar)
				if(M.current && M.current.stat != DEAD && (M.current.onCentcom() || M.current.onSyndieBase()))
					surviving_servants++
			clockwork_explanation = "Ensure that [required_escapees] servant(s) of Ratvar escape from [station_name()].<br><i><b>[surviving_servants]</b> managed to escape!</i>"
			if(surviving_servants >= required_escapees)
				ticker.news_report = CULT_ESCAPE
				return TRUE
		if(CLOCKCULT_SILICONS)
			var/total_silicons = 0
			var/valid_silicons = 0
			for(var/mob/living/silicon/S in mob_list) //Only check robots and AIs
				if(isAI(S) || iscyborg(S))
					total_silicons++
					if(is_servant_of_ratvar(S) || S.stat == DEAD)
						valid_silicons++
			clockwork_explanation = "Ensure that all active silicon-based lifeforms on [station_name()] are servants of Ratvar and Application scripture is unlocked.<br>\
			<i><b>[valid_silicons]/[total_silicons]</b> silicons were killed or converted!"
			var/list/scripture_states = scripture_unlock_check()
			if(valid_silicons >= total_silicons && scripture_states[SCRIPTURE_APPLICATION])
				ticker.news_report = CLOCK_SILICONS
				return TRUE
		if(CLOCKCULT_GATEWAY)
			if(ratvar_awakens)
				ticker.news_report = CLOCK_SUMMON
				return TRUE
	ticker.news_report = CULT_FAILURE
	return FALSE

/datum/game_mode/clockwork_cult/declare_completion()
	..()
	return 0 //Doesn't end until the round does

/datum/game_mode/proc/auto_declare_completion_clockwork_cult()
	var/text = ""
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult)) //Possibly hacky?
		var/datum/game_mode/clockwork_cult/C = ticker.mode
		if(C.check_clockwork_victory())
			text += "<span class='large_brass'><b>Ratvar's servants have succeeded in fulfilling His goals!</b></span>"
			feedback_set_details("round_end_result", "win - servants completed their objective ([clockwork_objective])")
		else
			var/half_victory = FALSE
			if(clockwork_objective == CLOCKCULT_GATEWAY)
				var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = locate() in all_clockwork_objects
				if(G)
					half_victory = TRUE
			if(half_victory)
				text += "<span class='large_brass'><b>The crew escaped before Ratvar could rise, but the gateway was successfully constructed!</b></span>"
				feedback_set_details("round_end_result", "halfwin - round ended before the gateway finished")
			else
				text += "<span class='userdanger'>Ratvar's servants have failed!</span>"
				feedback_set_details("round_end_result", "loss - servants failed their objective ([clockwork_objective])")
		if(clockwork_gateway_activated && clockwork_objective != CLOCKCULT_GATEWAY)
			ticker.news_report = CLOCK_PROSELYTIZATION
		text += "<br><b>The servants' objective was:</b> <br>[clockwork_explanation]"
		text += "<br>Ratvar's servants had <b>[clockwork_caches]</b> Tinkerer's Caches."
		text += "<br><b>Construction Value(CV)</b> was: <b>[clockwork_construction_value]</b>"
		var/list/scripture_states = scripture_unlock_check()
		for(var/i in scripture_states)
			if(i != SCRIPTURE_DRIVER)
				text += "<br><b>[i] scripture</b> was: <b>[scripture_states[i] ? "UN":""]LOCKED</b>"
	if(servants_of_ratvar.len)
		text += "<br><b>Ratvar's servants were:</b>"
		for(var/datum/mind/M in servants_of_ratvar)
			text += printplayer(M)
	world << text

/datum/game_mode/proc/update_servant_icons_added(datum/mind/M)
	var/datum/atom_hud/antag/A = huds[ANTAG_HUD_CLOCKWORK]
	A.join_hud(M.current)
	set_antag_hud(M.current, "clockwork")

/datum/game_mode/proc/update_servant_icons_removed(datum/mind/M)
	var/datum/atom_hud/antag/A = huds[ANTAG_HUD_CLOCKWORK]
	A.leave_hud(M.current)
	set_antag_hud(M.current, null)
