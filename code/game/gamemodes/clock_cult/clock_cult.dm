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
	var/clockwork_explanation = "Defend the Ark of the Clockwork Justiciar and free Ratvar." //The description of the current objective

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
	<span class='brass'>Servants</span>: Construct defenses to protect the Ark. Sabotage the station!\n\
	<span class='notice'>Crew</span>: Stop the servants before they can summon the Clockwork Justiciar."
	var/servants_to_serve = list()
	var/roundstart_player_count
	var/ark_time //In minutes, how long the Ark waits before activation; this is equal to 20 + (number of players / 5)

/datum/game_mode/clockwork_cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"
	var/starter_servants = 3 //Guaranteed three servants
	var/number_players = num_players()
	roundstart_player_count = number_players
	if(number_players > 30) //plus one servant for every additional 10 players above 30
		number_players -= 30
		starter_servants += round(number_players/10)
	starter_servants = min(starter_servants, 8) //max 8 servants (this should only happen with 110 players or more!)
	while(starter_servants)
		var/datum/mind/servant = pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		modePlayer += servant
		servant.assigned_role = "Servant of Ratvar"
		servant.special_role = "Servant of Ratvar"
		starter_servants--
	ark_time = 25 + round((roundstart_player_count / 5)) //In minutes, how long the Ark will wait before activation
	ark_time = min(ark_time, 35) //35 minute maximum for the activation timer
	return 1

/datum/game_mode/clockwork_cult/post_setup()
	for(var/S in servants_to_serve)
		var/datum/mind/servant = S
		log_game("[servant.key] was made an initial servant of Ratvar")
		var/mob/living/L = servant.current
		var/turf/T = pick(GLOB.servant_spawns)
		L.forceMove(T)
		GLOB.servant_spawns -= T
		greet_servant(L)
		equip_servant(L)
		add_servant_of_ratvar(L, TRUE)
	addtimer(CALLBACK(src, .proc/unlock_application_scripture), (ark_time * 0.5) * 600)
	addtimer(CALLBACK(src, .proc/cry_havoc), ark_time * 600) //600 deciseconds in a minute * number of minutes
	..()
	return 1

/datum/game_mode/clockwork_cult/proc/unlock_application_scripture()
	GLOB.application_scripture_unlocked = TRUE
	hierophant_message("<span class='large_brass bold'>The Ark is halfway prepared. Application scripture has been unlocked!</span>")

/datum/game_mode/clockwork_cult/proc/cry_havoc()
	if(GLOB.ark_of_the_clockwork_justiciar)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		G.cry_havoc()

/datum/game_mode/clockwork_cult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	to_chat(M, "<span class='bold large_brass'>You are a servant of Ratvar, the Clockwork Justiciar!</span>")
	to_chat(M, "<span class='brass'>You have approximately <b>[ark_time]</b> minutes until the Ark activates.</span>")
	to_chat(M, "<span class='brass'>Unlock <b>Script</b> scripture by converting a new servant.</span>")
	to_chat(M, "<span class='brass'><b>Application</b> scripture will be unlocked halfway until the Ark's activation.</span>")
	M.playsound_local(get_turf(M), 'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, pressure_affected = FALSE)
	return 1

/datum/game_mode/proc/equip_servant(mob/living/M) //Grants a clockwork slab to the mob, with one of each component
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	L.set_species(/datum/species/human)
	L.equipOutfit(/datum/outfit/servant_of_ratvar)
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
	if(S && !QDELETED(S))
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
		to_chat(L, "<span class='sevtug_small'>In your backpack is an <b>abscondence bijou</b>, your primary tool for getting to and from the station. From Reebe, you can view the \
		station through the camera consoles and click on a tile while holding the bijou to teleport there. While on the station, you can use the bijou directly to teleport back.</span>")
		to_chat(L, "<span class='italics alloy'>If you'd like, check out the wiki page at <b>https://tgstation13.org/wiki/Clockwork_Cult</b>, which contains additional information.</span>")
		return TRUE
	return FALSE

/datum/game_mode/clockwork_cult/proc/check_clockwork_victory()
	if(GLOB.clockwork_gateway_activated)
		SSticker.news_report = CLOCK_SUMMON
		return TRUE
	else
		SSticker.news_report = CULT_FAILURE
	return FALSE

/datum/game_mode/clockwork_cult/declare_completion()
	..()
	return //Doesn't end until the round does

/datum/game_mode/proc/auto_declare_completion_clockwork_cult()
	var/text = ""
	if(istype(SSticker.mode, /datum/game_mode/clockwork_cult)) //Possibly hacky?
		var/datum/game_mode/clockwork_cult/C = SSticker.mode
		if(C.check_clockwork_victory())
			text += "<span class='large_brass'><b>Ratvar's servants defended the Ark until its activation!</b></span>"
			SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
		else
			text += "<span class='userdanger'>The Ark was destroyed! Ratvar will rust away for all eternity!</span>"
			SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"
		text += "<br><b>The servants' objective was:</b> [CLOCKCULT_OBJECTIVE]."
		text += "<br>Ratvar's servants had <b>[GLOB.clockwork_caches]</b> Tinkerer's Caches."
		text += "<br><b>Construction Value(CV)</b> was: <b>[GLOB.clockwork_construction_value]</b>"
		for(var/i in SSticker.scripture_states)
			if(i != SCRIPTURE_DRIVER)
				text += "<br><b>[i] scripture</b> was: <b>[SSticker.scripture_states[i] ? "UN":""]LOCKED</b>"
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



//Servant of Ratvar outfit
/datum/outfit/servant_of_ratvar
	name = "Servant of Ratvar"

	head = /obj/item/clothing/head/hardhat/white
	uniform = /obj/item/clothing/under/color/yellow
	shoes = /obj/item/clothing/shoes/sneakers/green
	back = /obj/item/weapon/storage/backpack
	ears = /obj/item/device/radio/headset
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/weapon/storage/belt/utility/servant
	backpack_contents = list(/obj/item/weapon/storage/box/engineer = 1, /obj/item/clockwork/abscondence_bijou = 1, \
	/obj/item/clockwork/replica_fabricator/preloaded = 1, /obj/item/stack/tile/brass/thirty = 1)
	id = /obj/item/weapon/card/id

/datum/outfit/servant_of_ratvar/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/weapon/card/id/W = H.wear_id
	W.assignment = "Assistant"
	W.access += ACCESS_MAINT_TUNNELS
	W.registered_name = H.real_name
	W.update_label()
