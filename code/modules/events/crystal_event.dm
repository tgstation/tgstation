GLOBAL_LIST_INIT(crystal_invasion_waves, list(
	"small wave" = list(
		/obj/structure/crystal_portal/small=4,
		/obj/structure/crystal_portal/medium=1
		),
	"medium wave" = list(
		/obj/structure/crystal_portal/small=4,
		/obj/structure/crystal_portal/medium=3,
		/obj/structure/crystal_portal/big=1
		),
	"big wave" = list(
		/obj/structure/crystal_portal/small=5,
		/obj/structure/crystal_portal/medium=3,
		/obj/structure/crystal_portal/big=2,
		/obj/structure/crystal_portal/huge=1
		),
	"huge wave" = list(
		/obj/structure/crystal_portal/small=7,
		/obj/structure/crystal_portal/medium=5,
		/obj/structure/crystal_portal/big=3,
		/obj/structure/crystal_portal/huge=2
		),
	))
GLOBAL_LIST_EMPTY(crystal_portals)

/*
This section is for the event controller
*/
/datum/round_event_control/crystal_invasion
	name = "Crystal Invasion"
	typepath = /datum/round_event/crystal_invasion
	weight = 8
	min_players = 35
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/crystal_invasion
	startWhen = 10
	announceWhen = 1
	endWhen = 25 MINUTES
	///Is the name of the wave, used to check wich wave will be generated
	var/wave_name
	///Max number of portals that can spawn per type of wave
	var/portal_numbers
	///Check if this is the first wave or not
	var/spawned = FALSE
	///Store the destabilized crystal
	var/obj/machinery/destabilized_crystal/dest_crystal
	///Check if the event will end badly
	var/is_zk_scenario = TRUE

/datum/round_event/crystal_invasion/start()
	choose_wave_type()

/datum/round_event/crystal_invasion/announce(fake)
	priority_announce("WARNING - Destabilization of the Supermatter Crystal Matrix detected, please stand by waiting further instructions", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

///Choose the type of the wave
/datum/round_event/crystal_invasion/proc/choose_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"small wave" = 35,
			"medium wave" = 45,
			"big wave" = 15,
			"huge wave" = 5))
	switch(wave_name)
		if("small wave")
			portal_numbers = rand(9, 11)
		if("medium wave")
			portal_numbers = rand(8, 12)
		if("big wave")
			portal_numbers = rand(9, 13)
		if("huge wave")
			portal_numbers = rand(11, 15)
		else
			kill()
			CRASH("Wave name of [wave_name] not recognised.")

	var/list/sm_crystal = list()
	for(var/obj/machinery/power/supermatter_crystal/temp in GLOB.machines)
		if(istype(temp, /obj/machinery/power/supermatter_crystal/shard))
			continue
		sm_crystal += temp
	if(sm_crystal == null)
		log_game("No engine found, killing the crystal invasion event.")
		kill()
		return
	var/obj/machinery/power/supermatter_crystal/crystal = pick(sm_crystal)
	dest_crystal = crystal.destabilize(portal_numbers)
	RegisterSignal(dest_crystal, COMSIG_PARENT_QDELETING, .proc/on_dest_crystal_qdel)

	priority_announce("WARNING - Numerous energy fluctuations have been detected from your Supermatter; we estimate a [wave_name] of crystalline creatures \
						coming from \[REDACTED]; there will be [portal_numbers] portals spread around the station that you must close. Harvest a \[REDACTED] \
						anomaly from a portal by using the anomaly neutralizer, place it inside a crystal stabilizer, and inject it into your Supermatter to stop a ZK-Lambda-Class Cosmic Fragmentation Scenario from occurring.", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

	addtimer(CALLBACK(src, .proc/spawn_portals), 10 SECONDS)

///Pick a location from the generic_event_spawns list that are present on the maps and call the spawn anomaly and portal procs
/datum/round_event/crystal_invasion/proc/spawn_portals()
	var/list/spawners = list()
	for(var/es in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/temp = es
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to portal_numbers)
		spawn_portal(GLOB.crystal_invasion_waves[wave_name], spawners)
	for(var/i in 1 to 6)
		spawn_anomaly(spawners)

	addtimer(CALLBACK(src, .proc/more_portals, GLOB.crystal_invasion_waves[wave_name]), 15 MINUTES)

///Spawn an anomaly randomly in a different location than spawn_portal()
/datum/round_event/crystal_invasion/proc/spawn_anomaly(list/spawners)
	if(!spawners.len)
		CRASH("No landmarks on the station map, aborting")
	var/obj/spawner = pick(spawners)
	new/obj/effect/anomaly/flux(spawner.loc)

///Spawn one portal in a random location choosen from the generic_event_spawns list
/datum/round_event/crystal_invasion/proc/spawn_portal(list/wave_type, list/spawners)
	if(!spawners.len)
		CRASH("No landmarks on the station map, aborting")
	var/pick_portal = pickweight(wave_type)
	var/obj/spawner = pick(spawners)
	new pick_portal(spawner.loc)

///If after 10 minutes the crystal is not stabilized more portals are spawned and the event progress further
/datum/round_event/crystal_invasion/proc/more_portals()
	priority_announce("WARNING - Detected another spike from the destabilized crystal. More portals are spawning all around the station, the next spike could \
						cause a \[REDACTED] class event we assume you have 10 more minutes before total crystal annihilation", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')
	var/list/spawners = list()
	for(var/es in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/temp = es
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to rand(10, 15))
		spawn_portal(GLOB.crystal_invasion_waves["small wave"], spawners)

/datum/round_event/crystal_invasion/tick()
	if(dest_crystal == null)
		processing = FALSE
		message_admins("Deleted Destabilized crystal, aborting")
		kill()
	if(dest_crystal.is_stabilized == TRUE)
		processing = FALSE
		is_zk_scenario = FALSE
		end()

/datum/round_event/crystal_invasion/end()
	if(is_zk_scenario == TRUE)
		processing = FALSE
		zk_event_announcement()
	else
		restore()
	kill()

///This proc announces that the event is concluding with the worst scenario
/datum/round_event/crystal_invasion/proc/zk_event_announcement()
	dest_crystal.active = FALSE
	priority_announce("WARNING - The crystal has reached critical instability point. ZK-Event inbound, please do not panic, anyone who panics will \
						be terminated on the spot. Have a nice day", "Alert")
	sound_to_playing_players('sound/machines/alarm.ogg')
	addtimer(CALLBACK(src, .proc/do_zk_event), 10 SECONDS)

///This proc actually manages the end of the event
/datum/round_event/crystal_invasion/proc/do_zk_event()
	var/list/spawners = list()
	for(var/es in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/temp = es
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to rand(15, 25))
		spawn_portal(GLOB.crystal_invasion_waves["huge wave"], spawners)
	explosion(dest_crystal.loc, 15, 26, 33, 35, 1, 1) //a bit smaller than max supermatter explosion
	priority_announce("WARNING - Portal are appearing everywhere, you failed to contain the event. You people should feel ashamed of yourselves!","Alarm")
	QDEL_NULL(dest_crystal)

///Restore the Destabilized Crystal as it was before
/datum/round_event/crystal_invasion/proc/restore()
	priority_announce("The Crystal has been restored and is now stable again, your sector of space is now safe from the ZK-Lambda-Class Scenario, \
						kill the remaining crystal monsters and go back to work")
	sound_to_playing_players('sound/misc/notice2.ogg')
	var/turf/loc_turf = get_turf(dest_crystal.loc)
	new/obj/machinery/power/supermatter_crystal(loc_turf)
	for(var/Portal in GLOB.crystal_portals)
		qdel(Portal)
	QDEL_NULL(dest_crystal)

///Handle the dest_crystal var to be null if the destabilized crystal is deleted by a badmin before the end of the event
/datum/round_event/crystal_invasion/proc/on_dest_crystal_qdel()
	UnregisterSignal(dest_crystal, COMSIG_PARENT_QDELETING)
	processing = FALSE
	dest_crystal = null
	kill()

/*
This section is for the destabilized SM
*/
/obj/machinery/destabilized_crystal
	name = "destabilized crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "psy"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	///If not active the crystal will not emit radiations and gases
	var/active = TRUE
	///Check if the crew managed to stop the ZK-class event by stabilizing the crystal
	var/is_stabilized = FALSE

/obj/machinery/destabilized_crystal/process()
	if(!active)
		return
	if(prob(75))
		radiation_pulse(src, 250, 6)
	var/turf/loc_turf = loc
	var/datum/gas_mixture/env = loc_turf.return_air()
	var/datum/gas_mixture/removed
	var/gasefficency = 0.5
	removed = env.remove(gasefficency * env.total_moles())
	removed.assert_gases(/datum/gas/bz, /datum/gas/miasma)
	removed.gases[/datum/gas/bz][MOLES] += 15.5
	removed.gases[/datum/gas/miasma][MOLES] += 5.5
	env.merge(removed)
	air_update_turf()

/obj/machinery/destabilized_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(user))
		return
	if(istype(W, /obj/item/crystal_stabilizer))
		var/obj/item/crystal_stabilizer/injector = W
		if(!injector.filled)
			to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
			return
		to_chat(user, "<span class='notice'>You carefully begin injecting \the [src] with \the [W]... take care not to move untill all the steps are finished!</span>")
		if(!W.use_tool(src, user, 5 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>Seems that \the [src] internal resonance is fading with the fluid!</span>")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
		if(!W.use_tool(src, user, 6.5 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>The [src] is reacting violently with the fluid!</span>")
		fire_nuclear_particle()
		radiation_pulse(src, 2500, 6)
		if(!W.use_tool(src, user, 7.5 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>The [src] has been restored and restabilized!</span>")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
		injector.filled = FALSE
		active = FALSE
		is_stabilized = TRUE

/*
This section is for the crystal stabilizer item and the crystal from the closed portals
*/
/obj/item/crystal_stabilizer
	name = "Supermatter Stabilizer"
	desc = "Used when the Supermatter Matrix is starting to reach the destruction point."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "stabilizer"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	///The stabilizer is one use only
	var/filled = FALSE

/obj/item/crystal_stabilizer/examine(user)
	. = ..()
	if(!filled)
		. += "<span class='notice'>The [src] is empty.</span>"
	else
		. += "<span class='notice'>The [src] is full and can be used to stabilize the Supermatter.</span>"

/obj/item/crystal_stabilizer/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if((W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/stack/sheet/otherworld_crystal))
		if(filled)
			return
		to_chat(user, "<span class='notice'>You refill the [src]</span>")
		playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
		filled = TRUE
		qdel(W)

/obj/item/stack/sheet/otherworld_crystal
	name = "Otherworld Crystals"
	icon_state = "otherworld-crystal"
	singular_name = "Otherworld Crystal"
	icon = 'icons/obj/stack_objects.dmi'
	material_type = /datum/material/otherworld_crystal

/*
This section is for the crystal portals variations
*/
/obj/structure/crystal_portal
	name = "crystal portal"
	desc = "this shouldn't be here"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = COLOR_SILVER
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	///Max amount of mobs that a portal can spawn in any given time
	var/max_mobs = 5
	///Spawn time between each mobs
	var/spawn_time = 1000
	///Type of mob that the portal will spawn, if more than one type in the list will choose randomly
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	///Fluff text for each mob spawned
	var/spawn_text = "emerges from"
	///Affiliation to a faction, used to stop mobs from destroying their portals (unused for now)
	var/faction = list("hostile")
	///Spawner component
	var/spawner_type = /datum/component/spawner
	///This var check if the portal has been closed by a player with a neutralizer
	var/closed = FALSE

/obj/structure/crystal_portal/Initialize()
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)
	GLOB.crystal_portals += src
	mob_types = typelist("crystal_portal mob_types", mob_types)
	faction = typelist("crystal_portal faction", faction)

/obj/structure/crystal_portal/Destroy()
	GLOB.crystal_portals -= src
	if(!closed)
		switch(name)
			if("Small Portal")
				explosion(loc, 0,1,3)
			if("Medium Portal")
				explosion(loc, 0,3,5)
			if("Big Portal")
				explosion(loc, 1,3,5)
			if("Huge Portal")
				explosion(loc, 2,5,7)
	new/obj/item/stack/sheet/otherworld_crystal(loc)
	return ..()

/obj/structure/crystal_portal/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return ..()

/obj/structure/crystal_portal/attackby(obj/item/W, mob/living/user, params)
	if((W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/anomaly_neutralizer))
		to_chat(user, "<span class='notice'>You start closing \the [src]...</span>")
		if(W.use_tool(src, user, 5.5 SECONDS, volume = 100))
			to_chat(user, "<span class='notice'>You successfully close \the [src]!</span>")
			closed = TRUE
			qdel(src)

/obj/structure/crystal_portal/small
	name = "Small Portal"
	desc = "A small portal to an unkown dimension!"
	color = COLOR_BRIGHT_BLUE
	max_mobs = 3
	spawn_time = 200
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug
		)

/obj/structure/crystal_portal/medium
	name = "Medium Portal"
	desc = "A medium portal to an unkown dimension!"
	color = COLOR_GREEN
	max_mobs = 5
	spawn_time = 180
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit
		)

/obj/structure/crystal_portal/big
	name = "Big Portal"
	desc = "A big portal to an unkown dimension!"
	color = COLOR_RED
	max_mobs = 8
	spawn_time = 160
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit,
		/mob/living/simple_animal/hostile/crystal_monster/killer
		)

/obj/structure/crystal_portal/huge
	name = "Huge Portal"
	desc = "A huge portal to an unkown dimension!"
	color = COLOR_BLACK
	max_mobs = 12
	spawn_time = 140
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit,
		/mob/living/simple_animal/hostile/crystal_monster/killer,
		/mob/living/simple_animal/hostile/crystal_monster/boss,
		)

/*
This section is for the crystal monsters variations
*/
/mob/living/simple_animal/hostile/crystal_monster
	name = "crystal monster"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	gender = NEUTER
	mob_biotypes = MOB_MINERAL|MOB_HUMANOID
	turns_per_move = 5
	speak_emote = list("resonates")
	emote_see = list("resonates")
	a_intent = INTENT_HARM
	maxHealth = 25
	health = 25
	speed = 1.2
	harm_intent_damage = 2.5
	melee_damage_lower = 5
	melee_damage_upper = 5
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're crystals how would bruise packs help them??
	attack_verb_continuous = "smashes"
	attack_verb_simple = "smash"
	attack_sound = 'sound/effects/supermatter.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	faction = list("crystal")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "collapses into dust!"
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/crystal_monster/minion
	name = "crystal minion"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	maxHealth = 40
	health = 40
	speed = 1.5
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10

/mob/living/simple_animal/hostile/crystal_monster/thug
	name = "crystal thug"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_thug"
	icon_living = "crystal_thug"
	icon_dead = "crystal_thug"
	maxHealth = 50
	health = 50
	speed = 1.3
	harm_intent_damage = 9
	melee_damage_lower = 15
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/crystal_monster/recruit
	name = "crystal recruit"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_recruit"
	icon_living = "crystal_recruit"
	icon_dead = "crystal_recruit"
	maxHealth = 65
	health = 65
	speed = 1.2
	harm_intent_damage = 11
	melee_damage_lower = 20
	melee_damage_upper = 35

/mob/living/simple_animal/hostile/crystal_monster/killer
	name = "crystal killer"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_killer"
	icon_living = "crystal_killer"
	icon_dead = "crystal_killer"
	maxHealth = 80
	health = 80
	speed = 1.2
	harm_intent_damage = 13
	melee_damage_lower = 30
	melee_damage_upper = 45

/mob/living/simple_animal/hostile/crystal_monster/boss
	name = "crystal boss"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_boss"
	icon_living = "crystal_boss"
	icon_dead = "crystal_boss"
	maxHealth = 150
	health = 150
	speed = 1
	harm_intent_damage = 15
	melee_damage_lower = 45
	melee_damage_upper = 65
