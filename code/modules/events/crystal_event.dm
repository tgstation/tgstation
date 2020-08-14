GLOBAL_LIST_INIT(crystal_invasion_waves, list("small wave" = list(/obj/structure/crystal_portal/small=4, /obj/structure/crystal_portal/medium=1),
"medium wave" = list(/obj/structure/crystal_portal/small=4, /obj/structure/crystal_portal/medium=3, /obj/structure/crystal_portal/big=1),
"big wave" = list(/obj/structure/crystal_portal/small=5, /obj/structure/crystal_portal/medium=3, /obj/structure/crystal_portal/big=2, /obj/structure/crystal_portal/huge=1),
"huge wave" = list(/obj/structure/crystal_portal/small=7, /obj/structure/crystal_portal/medium=5, /obj/structure/crystal_portal/big=3, /obj/structure/crystal_portal/huge=2)))
GLOBAL_LIST_EMPTY(crystal_portals)
GLOBAL_LIST_EMPTY(destabilized_crystals)

/*
This section is for the event controller
*/
/datum/round_event_control/crystal_invasion
	name = "Crystal Invasion"
	typepath = /datum/round_event/crystal_invasion
	weight = 2
	min_players = 35
	max_occurrences = 1
	earliest_start = 45 MINUTES

/datum/round_event/crystal_invasion
	startWhen = 10
	announceWhen = 1
	///Is the name of the wave, used to check wich wave will be generated
	var/wave_name
	///Max number of portals that can spawn per type of wave
	var/portal_numbers
	///Check if this is the first wave or not
	var/spawned = FALSE

/datum/round_event/crystal_invasion/start()
	choose_wave_type()

/datum/round_event/crystal_invasion/announce(fake)
	priority_announce("WARNING - Destabilization of the Supermatter Crystal Matrix detected, please stand by waiting further instructions", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

///Choose the type of the wave
/datum/round_event/crystal_invasion/proc/choose_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"small wave" = 50,
			"medium wave" = 40,
			"big wave" = 5,
			"huge wave" = 5))
	switch(wave_name)
		if("small wave")
			portal_numbers = rand(5, 7)
		if("medium wave")
			portal_numbers = rand(6, 9)
		if("big wave")
			portal_numbers = rand(8, 10)
		if("huge wave")
			portal_numbers = rand(9, 13)
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

	var/list/sm_crystal = list()
	for(var/obj/machinery/power/supermatter_crystal/temp in GLOB.machines)
		if(istype(temp, /obj/machinery/power/supermatter_crystal/shard))
			continue
		sm_crystal += temp
	if(sm_crystal == null)
		log_game("No engine found, killing the crystal invasion event.")
		kill()
	var/obj/machinery/power/supermatter_crystal/crystal = pick(sm_crystal)
	crystal.destabilize(portal_numbers)

	priority_announce("WARNING - Numerous energy fluctuations have been detected from your Supermatter; we estimate a [wave_name] of crystalline creatures \
						coming from \[REDACTED]; there will be [portal_numbers] portals spread around the station that you must close. Harvest a \[REDACTED] \
						anomaly from a portal, place it inside a crystal stabilizer, and inject it into your Supermatter to stop a ZK-Lambda-Class Cosmic Fragmentation Scenario from occurring.", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

	addtimer(CALLBACK(src, .proc/spawn_portals), 10 SECONDS)

///Pick a location from the generic_event_spawns list that are present on the maps and call the spawn anomaly and portal procs
/datum/round_event/crystal_invasion/proc/spawn_portals()
	var/list/spawners = list()
	for(var/obj/effect/landmark/event_spawn/temp in GLOB.generic_event_spawns)
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to portal_numbers)
		spawn_portal(GLOB.crystal_invasion_waves[wave_name], spawners)
		spawn_anomaly(spawners)

	addtimer(CALLBACK(src, .proc/more_portals, GLOB.crystal_invasion_waves[wave_name]), 15 MINUTES)

///Spawn an anomaly randomly in a different location than spawn_portal()
/datum/round_event/crystal_invasion/proc/spawn_anomaly(list/spawners)
	if(!spawners.len)
		message_admins("No landmarks on the station, aborting")
		return
	var/obj/spawner = pick(spawners)
	var/obj/effect/anomaly/flux/A = new(spawner.loc)
	A.is_from_zk_event = TRUE

///Spawn one portal in a random location choosen from the generic_event_spawns list
/datum/round_event/crystal_invasion/proc/spawn_portal(list/wave_type, list/spawners)
	if(!spawners.len)
		message_admins("No landmarks on the station, aborting")
		return

	var/pick_portal = pickweight(wave_type)
	var/obj/spawner = pick(spawners)
	new pick_portal(spawner.loc)

///If after 10 minutes the crystal is not stabilized more portals are spawned and the event progress further
/datum/round_event/crystal_invasion/proc/more_portals()
	priority_announce("WARNING - Detected another spike from the destabilized crystal. More portals are spawning all around the station, the next spike could \
						cause a \[REDACTED] class event we assume you have 10 more minutes before total crystal annihilation", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')
	var/list/spawners = list()
	for(var/obj/effect/landmark/event_spawn/temp in GLOB.generic_event_spawns)
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to 8)
		spawn_portal(GLOB.crystal_invasion_waves["small wave"], spawners)

	for(var/C in GLOB.destabilized_crystals)
		addtimer(CALLBACK(C, /obj/machinery/destabilized_crystal/proc/zk_event_announcement), 10 MINUTES)

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
	///Check if the crew managed to stop the ZK-class event
	var/is_zk = FALSE

/obj/machinery/destabilized_crystal/Initialize()
	. = ..()
	GLOB.destabilized_crystals += src

/obj/machinery/destabilized_crystal/Destroy()
	GLOB.destabilized_crystals -= src
	if(is_zk)
		priority_announce("WARNING - Portal are appearing everywhere, you failed to contain the event. You people should feel ashamed of yourself!","Alarm")
	return..()

/obj/machinery/destabilized_crystal/process()
	if(active)
		if(prob(75))
			radiation_pulse(src, 250, 6)
		var/turf/T = loc
		var/datum/gas_mixture/env = T.return_air()
		var/datum/gas_mixture/removed
		var/gasefficency = 0.5
		removed = env.remove(gasefficency * env.total_moles())
		removed.assert_gases(/datum/gas/bz, /datum/gas/miasma)
		removed.gases[/datum/gas/bz][MOLES] += 15.5
		removed.gases[/datum/gas/miasma][MOLES] += 5.5
		env.merge(removed)
		air_update_turf()

///This proc announces that the event is concluding with the worst scenario
/obj/machinery/destabilized_crystal/proc/zk_event_announcement()
	active = FALSE
	priority_announce("WARNING - The crystal has reached critical instability point. ZK-Event inbound, please do not panic, anyone who panics will \
						be terminated on the spot. Have a nice day", "Alert")
	sound_to_playing_players('sound/machines/alarm.ogg')
	addtimer(CALLBACK(src, .proc/do_zk_event), 10 SECONDS)

///This proc actually manages the end of the event
/obj/machinery/destabilized_crystal/proc/do_zk_event()
	var/list/spawners = list()
	for(var/obj/effect/landmark/event_spawn/temp in GLOB.generic_event_spawns)
		if(QDELETED(temp))
			continue
		if(is_station_level(temp.loc.z))
			spawners += temp

	if(!spawners.len)
		message_admins("No landmarks on the station, aborting")
		return MAP_ERROR

	var/obj/spawner = pick_n_take(spawners)
	var/pick_portal = pickweight(GLOB.crystal_invasion_waves["huge wave"])
	for(var/i in 10 to 15)
		new pick_portal(spawner.loc)
	explosion(src, 7, 10, 25, 25)
	is_zk = TRUE
	qdel(src)

/obj/machinery/destabilized_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(user))
		return
	if(istype(W, /obj/item/crystal_stabilizer))
		var/obj/item/crystal_stabilizer/injector = W
		if(!injector.filled)
			to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
			return
		to_chat(user, "<span class='notice'>You carefully begin inject \the [src] with \the [W]... please don't move untill all the steps are finished</span>")
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
		restore()

///Restore the Destabilized Crystal as it was before
/obj/machinery/destabilized_crystal/proc/restore()
	priority_announce("The Crystal has been restored and is now stable again, your sector of space is now safe from the ZK-Lambda-Class Scenario, \
						kill the remaining crystal monsters and go back to work")
	sound_to_playing_players('sound/misc/notice2.ogg')
	var/turf/T = get_turf(src)
	new/obj/machinery/power/supermatter_crystal(T)
	for(var/Portal in GLOB.crystal_portals)
		qdel(Portal)
	qdel(src)

/*
This section is for the crystal stabilizer item
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
	if(istype(W, /obj/item/assembly/signaler/anomaly))
		if(filled)
			return
		to_chat(user, "<span class='notice'>You refill the [src]</span>")
		filled = TRUE
		qdel(W)

/*
This section is for the crystal portals variations
*/
/obj/structure/crystal_portal
	name = "crystal portal"
	desc = "this shouldn't be here"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = "#B2FFFE"
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
	new/obj/item/assembly/signaler/anomaly(loc)
	return ..()

/obj/structure/crystal_portal/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return ..()

/obj/structure/crystal_portal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/anomaly_neutralizer))
		to_chat(user, "<span class='notice'>You start closing the [src]</span>")
		if(W.use_tool(src, user, 5.5 SECONDS, volume = 100))
			to_chat(user, "<span class='notice'>You you successfully close the [src]</span>")
			closed = TRUE
			qdel(src)

/obj/structure/crystal_portal/small
	name = "Small Portal"
	desc = "A small portal to an unkown dimension!"
	color = "#B2FFFE"
	max_mobs = 3
	spawn_time = 200
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug
		)

/obj/structure/crystal_portal/medium
	name = "Medium Portal"
	desc = "A medium portal to an unkown dimension!"
	color = "#93F3B2"
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
	color = "#F4F48A"
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
	color = "#F97575"
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
	maxHealth = 25
	health = 25
	speed = 1.2
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
	maxHealth = 35
	health = 35
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/crystal_monster/recruit
	name = "crystal recruit"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_recruit"
	icon_living = "crystal_recruit"
	icon_dead = "crystal_recruit"
	maxHealth = 45
	health = 45
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 20
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/crystal_monster/killer
	name = "crystal killer"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_killer"
	icon_living = "crystal_killer"
	icon_dead = "crystal_killer"
	maxHealth = 60
	health = 60
	speed = 0.9
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 40

/mob/living/simple_animal/hostile/crystal_monster/boss
	name = "crystal boss"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "crystal_boss"
	icon_living = "crystal_boss"
	icon_dead = "crystal_boss"
	maxHealth = 80
	health = 80
	speed = 0.9
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 55
