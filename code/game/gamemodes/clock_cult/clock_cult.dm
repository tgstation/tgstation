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
	return istype(M) && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_CLOCKCULT)

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
	if(!L || !L.mind)
		return
	var/update_type = ANTAG_DATUM_CLOCKCULT
	if(silent)
		update_type = ANTAG_DATUM_CLOCKCULT_SILENT
	. = L.mind.add_antag_datum(update_type)

/proc/remove_servant_of_ratvar(mob/living/L, silent = FALSE)
	if(!L || !L.mind)
		return
	var/datum/antagonist/clockcult/clock_datum = L.mind.has_antag_datum(ANTAG_DATUM_CLOCKCULT)
	if(!clock_datum)
		return FALSE
	clock_datum.silent = silent
	clock_datum.on_removal()
	return TRUE

///////////////
// GAME MODE //
///////////////

/datum/game_mode
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/time_to_prepare = 20 //Time in minutes that the servants have to build their base before the Central Command alert comes in

/datum/game_mode/clockwork_cult
	name = "clockwork cult"
	config_tag = "clockwork_cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	required_players = 1
	required_enemies = 1
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
	var/starter_servants = 1 //Guaranteed three servants
	var/number_players = num_players()
	roundstart_player_count = number_players
	if(number_players > 30) //plus one servant for every additional 15 players
		number_players -= 30
		starter_servants += round(number_players/15)
	time_to_prepare = max(20, min(number_players / 2, 30))
	GLOB.clockwork_potential = 25 + (number_players * 2)
	while(starter_servants)
		var/datum/mind/servant = pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		modePlayer += servant
		servant.assigned_role = "Servant of Ratvar"
		servant.special_role = "Servant of Ratvar"
		starter_servants--
	addtimer(CALLBACK(src, .proc/cry_havoc), 100)
	//addtimer(CALLBACK(src, .proc/cry_havoc), time_to_prepare * 600) //600 deciseconds in a minute, so multiply the number of minutes to prepare times 600
	return 1

/datum/game_mode/clockwork_cult/post_setup()
	for(var/S in servants_to_serve)
		var/datum/mind/servant = S
		log_game("[servant.key] was made an initial servant of Ratvar")
		var/mob/living/L = servant.current
		var/turf/T = pick(GLOB.servant_start)
		servant.current.loc = T
		LAZYREMOVE(GLOB.servant_start, T)
		greet_servant(L)
		equip_servant(L)
		add_servant_of_ratvar(L, TRUE)
	..()
	return 1

/datum/game_mode/clockwork_cult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	var/greeting_text = "<br><span class='large_brass bold'>You are a servant of Ratvar!</span>\n\
	<i>You have [round(time_to_prepare)] minutes to prepare before the crew is alerted of your presence and portals open across [station_name()].</i>\n\
	<i>Need help? Look inside the box on your belt for an item called a clockwork slab, and click the Recollection button in the top left."
	to_chat(M, greeting_text)
	to_chat(M, sound('sound/ambience/antag/ClockCultAlr.ogg'))
	return 1

/datum/game_mode/proc/equip_servant(mob/living/carbon/human/L) //Grants a clockwork slab to the mob, with one of each component
	if(!L || !istype(L))
		return
	L.set_species(/datum/species/human)
	L.equipOutfit(/datum/outfit/servant_of_ratvar)
	return TRUE

/datum/game_mode/proc/cry_havoc()
	priority_announce("Massive energy anomaly detected on all scanners. Minor spacetime anomalies appearing across the station. Stay in your workplaces. Do not make voluntary contact with the \
	anomalies without available medical supplies. Please hold while the threat is assessed...", "Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/gateways_open.ogg')
	var/obj/effect/landmark/L
	var/turf/T
	for(var/V in GLOB.generic_event_spawns)
		L = V
		T = get_turf(L)
		addtimer(CALLBACK(src, .proc/open_portal, T), rand(50, 1200))
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/C = GLOB.ark_of_the_clockwork_justiciar
	C.spawn_animation() //get this party started!
	addtimer(CALLBACK(src, .proc/let_slip_the_dogs_of_war), 100)

/datum/game_mode/proc/let_slip_the_dogs_of_war()
	priority_announce("The threat has been assessed. The smaller spacetime anomalies are being created by the energy anomaly, which has been deemed a threat to Nanotrasen. All crew are \
	hereby directed to enter the spacetime anomalies and neutralize their source. Be prepared for unforeseen resistance. This is not a drill.", "Central Command Higher Dimensional Affairs")
	if(get_security_level() != "delta")
		set_security_level("red")

/datum/game_mode/proc/open_portal(turf/portal_loc)
	var/obj/effect/clockwork/reebe_rift/R = new(portal_loc)
	R.visible_message("<span class='warning'>The air above [portal_loc] screeches and shimmers as a portal appears!</span>")
	playsound(portal_loc, 'sound/effects/supermatter.ogg', 50, 0)

/datum/game_mode/clockwork_cult/check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.clockwork_gateway_activated || !GLOB.ark_of_the_clockwork_justiciar)
		return TRUE
	..()

/datum/game_mode/clockwork_cult/proc/check_clockwork_victory()
	if(GLOB.clockwork_gateway_activated || GLOB.ark_of_the_clockwork_justiciar)
		SSticker.news_report = CLOCK_SUMMON
		return TRUE
	SSticker.news_report = CLOCK_FAILURE
	return

/datum/game_mode/clockwork_cult/declare_completion()
	var/text = ""
	var/snd
	if(check_clockwork_victory())
		if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
			text += "<span class='large_brass'><b>Ratvar's servants defended the Ark and summoned Ratvar!</b></span>"
			snd = sound('sound/ambience/antag/ClockCultAlr.ogg', volume = 50)
			SSticker.mode_result = "win - servants defended the ark"
		else
			text += "<span class='large_brass'><b>The crew ran away like wimps, allowing Ratvar to rise unopposed!</b></span>"
			snd = sound('sound/ambience/antag/ClockCultAlr.ogg', volume = 50)
			SSticker.mode_result = "win - crew fled"
	else
		text += "<span class='userdanger'>The Ark has been destroyed! Ratvar will rust away in Reebe for all eternity!</span>"
		snd = sound('sound/magic/clockwork/ratvar_attack.ogg', volume = 50)
		SSticker.mode_result = "loss - ark destroyed"
	to_chat(world, text)
	playsound_global(snd)

/datum/game_mode/proc/auto_declare_completion_clockwork_cult()
	var/text = ""
		/*xt += "<br><b>The servants' objective was:</b> <br>[CLOCKCULT_OBJECTIVE]"
		text += "<br>Ratvar's servants had <b>[GLOB.clockwork_caches]</b> Tinkerer's Caches."
		text += "<br><b>Construction Value(CV)</b> was: <b>[GLOB.clockwork_construction_value]</b>"
		for(var/i in SSticker.scripture_states)
			if(i != SCRIPTURE_DRIVER)
				text += "<br><b>[i] scripture</b> was: <b>[SSticker.scripture_states[i] ? "UN":""]LOCKED</b>"*/
	if(servants_of_ratvar.len)
		text += "<br><b>Ratvar's servants were:</b>"
		for(var/datum/mind/M in servants_of_ratvar)
			text += printplayer(M)
	to_chat(world, text)

/datum/game_mode/proc/update_servant_icons_added(datum/mind/M)
	var/datum/atom_hud/antag/A = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	A.join_hud(M.current)
	set_antag_hud(M.current, "clockwork")

/datum/game_mode/proc/update_servant_icons_removed(datum/mind/M)
	var/datum/atom_hud/antag/A = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	A.leave_hud(M.current)
	set_antag_hud(M.current, null)
