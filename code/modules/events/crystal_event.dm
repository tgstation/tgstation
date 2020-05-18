GLOBAL_LIST_INIT(small_wave, list(/obj/structure/crystal_portal/small=4, /obj/structure/crystal_portal/medium=1)) //5
GLOBAL_LIST_INIT(medium_wave, list(/obj/structure/crystal_portal/small=4, /obj/structure/crystal_portal/medium=3, /obj/structure/crystal_portal/big=1)) //8
GLOBAL_LIST_INIT(big_wave, list(/obj/structure/crystal_portal/small=5, /obj/structure/crystal_portal/medium=3, /obj/structure/crystal_portal/big=2, /obj/structure/crystal_portal/huge=1)) //11
GLOBAL_LIST_INIT(huge_wave, list(/obj/structure/crystal_portal/small=7, /obj/structure/crystal_portal/medium=5, /obj/structure/crystal_portal/big=3, /obj/structure/crystal_portal/huge=2)) //17
GLOBAL_LIST_EMPTY(crystal_portals)
/*
This section is for the event controller
*/
/datum/round_event_control/crystal_invasion
	name = "Crystal Invasion : Small"
	typepath = /datum/round_event/crystal_invasion
	weight = 4
	min_players = 15
	max_occurrences = 3
	earliest_start = 25 MINUTES

/datum/round_event/crystal_invasion
	announceWhen = 1
	var/list/wave_type
	var/wave_name = "small wave"
	var/portal_numbers = 5

/datum/round_event/crystal_invasion/announce()
	priority_announce("WARNING - Destabilization of the Supermatter Crystal Matrix detected, please stand by waiting further instructions", "Alert", 'sound/misc/notice1.ogg')

/datum/round_event/crystal_invasion/New()
	. = ..()
	if(!wave_type)
		choose_wave_type()

/datum/round_event/crystal_invasion/proc/choose_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"small wave" = 50,
			"medium wave" = 35,
			"big wave" = 10,
			"huge wave" = 5))
	switch(wave_name)
		if("small wave")
			wave_type = GLOB.small_wave
		if("medium wave")
			wave_type = GLOB.medium_wave
		if("big wave")
			wave_type = GLOB.big_wave
		if("huge wave")
			wave_type = GLOB.huge_wave
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

	sleep(10 SECONDS)
	var/list/sm_crystal = list()
	for(var/obj/machinery/power/supermatter_crystal/temp in GLOB.machines)
		if(QDELETED(temp))
			WARNING("No engine found.")
			kill()
		if(istype(temp, /obj/machinery/power/supermatter_crystal/shard))
			message_admins("found a shard, skipping it")
			continue
		sm_crystal += temp
	var/obj/machinery/power/supermatter_crystal/crystal = pick(sm_crystal)
	crystal.destabilize()

	priority_announce("WARNING - Detected numerous energy fluctuation generated from your Supermatter; we estimate a [wave_name] of crystal-like creatures \
						coming from \[REDACTED]; there will be [portal_numbers] portals spread around the station that you must close. Collect the \[REDACTED] \
						anomaly from the remains of the portals and use it in a crystal stabilizer to stop a ZK-Lambda-Class Cosmic Fragmentation Scenario", "Alert", 'sound/misc/notice1.ogg')

	sleep(10 SECONDS)

	for(var/i = 0, i< portal_numbers, i++)
		spawn_portal(wave_type)


/datum/round_event/crystal_invasion/proc/spawn_portal(list/wave_type)
	var/list/spawners = list()
	for(var/obj/effect/landmark/event_spawn/temp in GLOB.generic_event_spawns)
		if(QDELETED(temp))
			continue
		if(is_station_level(temp.loc.z))
			spawners += temp

	if(!spawners.len)
		message_admins("No APCs on the station, aborting crystal event")
		return MAP_ERROR

	var/pick_portal = pickweight(wave_type)
	var/obj/spawner = pick_n_take(spawners)
	new pick_portal(spawner.loc)

/datum/round_event_control/crystal_invasion/medium
	name = "Crystal Invasion : Medium"
	typepath = /datum/round_event/crystal_invasion/medium
	weight = 6
	min_players = 25
	max_occurrences = 3
	earliest_start = 35 MINUTES

/datum/round_event/crystal_invasion/medium
	wave_name = "medium wave"
	portal_numbers = 8

/datum/round_event_control/crystal_invasion/big
	name = "Crystal Invasion : Big"
	typepath = /datum/round_event/crystal_invasion/big
	weight = 9
	min_players = 35
	max_occurrences = 3
	earliest_start = 35 MINUTES

/datum/round_event/crystal_invasion/big
	wave_name = "big wave"
	portal_numbers = 11

/datum/round_event_control/crystal_invasion/huge
	name = "Crystal Invasion : Huge"
	typepath = /datum/round_event/crystal_invasion/huge
	weight = 4
	min_players = 35
	max_occurrences = 3
	earliest_start = 45 MINUTES

/datum/round_event/crystal_invasion/huge
	wave_name = "huge wave"
	portal_numbers = 17

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
	var/active = TRUE

/obj/machinery/destabilized_crystal/Initialize()
	. = ..()
	SSshuttle.registerHostileEnvironment(src)

/obj/machinery/destabilized_crystal/Destroy()
	SSshuttle.clearHostileEnvironment(src)
	return..()

/obj/machinery/destabilized_crystal/process()
	if(active)
		if(prob(45))
			src.fire_nuclear_particle()
			radiation_pulse(src, 250, 6)
		var/turf/T = loc
		var/datum/gas_mixture/env = T.return_air()
		var/datum/gas_mixture/removed
		var/gasefficency = 0.5
		removed = env.remove(gasefficency * env.total_moles())
		removed.assert_gases(/datum/gas/bz, /datum/gas/stimulum, /datum/gas/nitryl, /datum/gas/miasma)
		removed.gases[/datum/gas/bz][MOLES] += 5.5
		removed.gases[/datum/gas/stimulum][MOLES] += 4.5
		removed.gases[/datum/gas/nitryl][MOLES] += 6.75
		removed.gases[/datum/gas/miasma][MOLES] += 10.5
		env.merge(removed)
		air_update_turf()

/obj/machinery/destabilized_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/crystal_stabilizer))
		var/obj/item/crystal_stabilizer/injector = W
		if(!injector.filled)
			to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
			return
		to_chat(user, "<span class='notice'>You carefully begin inject \the [src] with \the [W]... please don't move untill all the steps are finished</span>")
		if(W.use_tool(src, user, 5 SECONDS, volume=100))
			to_chat(user, "<span class='notice'>Seems that \the [src] internal resonance is fading with the fluid!</span>")
			playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
			if(W.use_tool(src, user, 6.5 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>The [src] is reacting violently with the fluid!</span>")
				src.fire_nuclear_particle()
				radiation_pulse(src, 2500, 6)
				if(W.use_tool(src, user, 7.5 SECONDS, volume=100))
					to_chat(user, "<span class='notice'>The [src] has been restored and restabilized!</span>")
					playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
					injector.filled = FALSE
					active = FALSE
					restore()

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

/obj/item/crystal_stabilizer/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
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

	var/max_mobs = 5
	var/spawn_time = 1000
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_text = "emerges from"
	var/faction = list("hostile")
	var/spawner_type = /datum/component/spawner

/obj/structure/crystal_portal/Initialize()
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)
	GLOB.crystal_portals += src

/obj/structure/crystal_portal/Destroy()
	new/obj/item/assembly/signaler/anomaly(loc)
	GLOB.crystal_portals -= src
	return ..()

/obj/structure/crystal_portal/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE)&&!M.client)
		return
	..()

/obj/structure/crystal_portal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/anomaly_neutralizer))
		to_chat(user, "<span class='notice'>You start closing the [src]</span>")
		if(W.use_tool(src, user, 6.5 SECONDS, volume=100))
			to_chat(user, "<span class='notice'>You you successfully close the [src]</span>")
			qdel(src)


/obj/structure/crystal_portal/small
	name = "Small Portal"
	desc = "A small portal to an unkown dimension!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = "#B2FFFE"
	anchored = TRUE
	max_mobs = 3
	spawn_time = 200
	mob_types = list(/mob/living/simple_animal/hostile/crystal_monster/minion, /mob/living/simple_animal/hostile/crystal_monster/thug)
	spawn_text = "emerges from"
	faction = list("crystal")
/obj/structure/crystal_portal/medium
	name = "Medium Portal"
	desc = "A medium portal to an unkown dimension!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = "#93F3B2"
	anchored = TRUE
	max_mobs = 5
	spawn_time = 180
	mob_types = list(/mob/living/simple_animal/hostile/crystal_monster/minion, /mob/living/simple_animal/hostile/crystal_monster/thug,\
					 /mob/living/simple_animal/hostile/crystal_monster/recruit)
	spawn_text = "emerges from"
	faction = list("crystal")
/obj/structure/crystal_portal/big
	name = "Big Portal"
	desc = "A big portal to an unkown dimension!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = "#F4F48A"
	anchored = TRUE
	max_mobs = 8
	spawn_time = 160
	mob_types = list(/mob/living/simple_animal/hostile/crystal_monster/minion, /mob/living/simple_animal/hostile/crystal_monster/thug,\
					 /mob/living/simple_animal/hostile/crystal_monster/recruit, /mob/living/simple_animal/hostile/crystal_monster/killer)
	spawn_text = "emerges from"
	faction = list("crystal")
/obj/structure/crystal_portal/huge
	name = "Huge Portal"
	desc = "A huge portal to an unkown dimension!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = "#F97575"
	anchored = TRUE
	max_mobs = 12
	spawn_time = 140
	mob_types = list(/mob/living/simple_animal/hostile/crystal_monster/minion, /mob/living/simple_animal/hostile/crystal_monster/thug,\
					 /mob/living/simple_animal/hostile/crystal_monster/recruit, /mob/living/simple_animal/hostile/crystal_monster/killer, \
					 /mob/living/simple_animal/hostile/crystal_monster/boss)
	spawn_text = "emerges from"
	faction = list("crystal")

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
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
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
	harm_intent_damage = 2.5
	melee_damage_lower = 5
	melee_damage_upper = 5

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
	melee_damage_lower = 5
	melee_damage_upper = 7
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
	melee_damage_lower = 5
	melee_damage_upper = 10
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
	melee_damage_lower = 5
	melee_damage_upper = 15
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
	melee_damage_lower = 5
	melee_damage_upper = 25
