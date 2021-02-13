///Global list that stores the 4 kinds of waves the crystal invasion can have and the portals each one can spawn
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
		/obj/structure/crystal_portal/big=2
		),
	"huge wave" = list(
		/obj/structure/crystal_portal/small=7,
		/obj/structure/crystal_portal/medium=5,
		/obj/structure/crystal_portal/big=3
		),
	))
///Global list that stores the all the instantiated portals around the station, used when stabilizing the crystal
GLOBAL_LIST_EMPTY(crystal_portals)
///Global list that store the huge portals that spawn at the start of the event
GLOBAL_LIST_EMPTY(huge_crystal_portals)

/*
This section is for the event controller
*/
/datum/round_event_control/crystal_invasion
	name = "Crystal Invasion"
	typepath = /datum/round_event/crystal_invasion
	weight = 0
	min_players = 35
	max_occurrences = 0 //no random chance to you
	earliest_start = 25 MINUTES

/datum/round_event/crystal_invasion
	startWhen = 5
	announceWhen = 1
	endWhen = 460
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
	///Ticks that have to pass before second wave
	var/second_wave = 310
	///Store the areas where the huge portals appears
	var/list/center_areas = list()

/datum/round_event/crystal_invasion/start()
	destabilize_supermatter_crystal()
	choose_wave_type()
	addtimer(CALLBACK(src, .proc/create_random_portals), 2 SECONDS)

///Destabilize the Supermatter crystal and spawn 6 portals around it
/datum/round_event/crystal_invasion/proc/destabilize_supermatter_crystal()
	var/list/sm_crystal = list()
	for(var/obj/machinery/power/supermatter_crystal/temp in GLOB.machines)
		if(istype(temp, /obj/machinery/power/supermatter_crystal/shard))
			continue
		sm_crystal += temp
	if(!length(sm_crystal))
		log_game("No engine found, killing the crystal invasion event.")
		kill()
		return

	var/obj/machinery/power/supermatter_crystal/crystal = pick(sm_crystal)
	dest_crystal = crystal.destabilize(portal_numbers)
	RegisterSignal(dest_crystal, COMSIG_PARENT_QDELETING, .proc/on_dest_crystal_qdel)

	for(var/t in RANGE_TURFS(8, dest_crystal.loc))
		var/turf/turf_loc = t
		var/distance_from_center = get_dist(turf_loc, dest_crystal)
		switch(distance_from_center)
			if(0)
				distance_from_center = 1 //Same tile, let's avoid a division by zero.
			if(-1)
				kill()
				CRASH("Negative distance measurement from the center turf detected, this should never happen")
		if(prob(325 / distance_from_center))
			if(isopenturf(turf_loc) || isspaceturf(turf_loc))
				turf_loc.ChangeTurf(/turf/open/indestructible/crystal_floor, flags = CHANGETURF_INHERIT_AIR)
			else
				turf_loc.ChangeTurf(/turf/closed/indestructible/crystal_wall)

	var/list/crystal_spawner_turfs = list()
	for(var/range_turf in RANGE_TURFS(6, dest_crystal.loc))
		if(!isopenturf(range_turf) || isspaceturf(range_turf))
			continue
		crystal_spawner_turfs += range_turf

	for(var/i in 1 to 6)
		var/pick_portal = pickweight(GLOB.crystal_invasion_waves["big wave"])
		var/turf/portal_spawner_turf = pick(crystal_spawner_turfs)
		new pick_portal(portal_spawner_turf)

///Chooses random areas where to put the main huge portals and then spawn around them 6 more portals
/datum/round_event/crystal_invasion/proc/create_random_portals()
	var/list/center_finder = list()
	for(var/es in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/temp = es
		if(is_station_level(temp.z))
			center_finder += temp
	if(!center_finder.len)
		kill()
		CRASH("No landmarks on the station map, aborting")
	for(var/j in 1 to portal_numbers)
		if(!length(center_finder))
			kill()
			CRASH("center_finder had less entries than portal_numbers ([j]/[portal_numbers])")
		var/obj/center = pick_n_take(center_finder)
		var/turf/center_turf = center.loc
		var/area/center_area = get_area(center_turf)
		center_areas += center_area

		explosion(center_turf,0,0,5,7,7)

		new /obj/structure/crystal_portal/huge(center_turf)

		for(var/t in RANGE_TURFS(5, center_turf))
			var/turf/turf_loc = t
			var/distance_from_center = GET_TRUE_DIST(turf_loc, center_turf)
			switch(distance_from_center)
				if(0)
					distance_from_center = 1 //Same tile, let's avoid a division by zero.
				if(-1)
					kill()
					CRASH("Negative distance measurement from the center turf detected, this should never happen")
			if(prob(250 / distance_from_center))
				if(isopenturf(turf_loc) || isspaceturf(turf_loc))
					turf_loc.ChangeTurf(/turf/open/indestructible/crystal_floor, flags = CHANGETURF_INHERIT_AIR)
				else
					turf_loc.ChangeTurf(/turf/closed/indestructible/crystal_wall)

		var/list/portal_spawner_turfs = list()
		for(var/range_turf in RANGE_TURFS(6, center_turf))
			if(!isopenturf(range_turf) || isspaceturf(range_turf))
				continue
			portal_spawner_turfs += range_turf

		for(var/i in 1 to 6)
			if(!length(portal_spawner_turfs))
				break
			var/pick_portal = pickweight(GLOB.crystal_invasion_waves[wave_name])
			var/turf/portal_spawner_turf = pick_n_take(portal_spawner_turfs)
			new pick_portal(portal_spawner_turf)
	dest_crystal.icon_state = "psy_shielded"
	dest_crystal.changed_icon = FALSE
	addtimer(CALLBACK(src, .proc/announce_locations), 8 SECONDS)

///After 8 seconds from the initial explosions centcom will announce the location of the huge portals
/datum/round_event/crystal_invasion/proc/announce_locations()
	priority_announce("WARNING - After tracking the powerspikes from your station we have determined that huge portals have appeared at the following locations:[center_areas.Join(", ")]. \
						Please close those before attempting to stabilize the crystal.", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

/datum/round_event/crystal_invasion/announce(fake)
	priority_announce("WARNING - Destabilization of the Supermatter Crystal Matrix detected, please stand by and await further instructions.", "Alert")
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
			portal_numbers = 2
		if("medium wave")
			portal_numbers = rand(2, 3)
		if("big wave")
			portal_numbers = rand(3, 4)
		if("huge wave")
			portal_numbers = rand(4, 5)
		else
			kill()
			CRASH("Wave name of [wave_name] not recognised.")

	priority_announce("WARNING - Numerous energy fluctuations have been detected from your Supermatter; we estimate a [wave_name] of crystalline creatures \
						coming from \[REDACTED]; there will be [portal_numbers] main portals spread around the station that you must close. Harvest a \[REDACTED] \
						crystal from a portal by using the anomaly neutralizer, place it inside a crystal stabilizer, and inject it into your Supermatter to stop a ZK-Lambda-Class Cosmic Fragmentation Scenario from occurring.", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')

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
						cause a \[REDACTED] class event we assume you have five more minutes before total crystal annihilation", "Alert")
	sound_to_playing_players('sound/misc/notice1.ogg')
	var/list/spawners = list()
	for(var/es in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/temp = es
		if(is_station_level(temp.z))
			spawners += temp
	for(var/i in 1 to rand(10, 15))
		spawn_portal(GLOB.crystal_invasion_waves["medium wave"], spawners)

/datum/round_event/crystal_invasion/tick()
	if(activeFor == second_wave)
		more_portals()
	if(dest_crystal.is_stabilized == TRUE)
		processing = FALSE
		is_zk_scenario = FALSE
		finish_event()
	if(activeFor == endWhen - 10)
		processing = FALSE
		finish_event()

///Handles wich end the event shall have
/datum/round_event/crystal_invasion/proc/finish_event()
	if(is_zk_scenario == TRUE)
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
	message_admins("Deleted Destabilized crystal, aborting")
	dest_crystal = null
	kill()

/turf/open/indestructible/crystal_floor
	name = "Crystal floor"
	desc = "A crystallized floor"
	icon_state = "noslip-damaged1"
	baseturfs = /turf/open/space

/turf/open/indestructible/crystal_floor/examine(mob/user)
	. += ..()
	. += "<span class='notice'>The floor is made of sturdy crystals.</span>"

/turf/open/indestructible/crystal_floor/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=0))
		return FALSE
	to_chat(user, "<span class='notice'>You begin heating up the crystal...</span>")
	if(I.use_tool(src, user, 2.5 SECONDS, volume=100))
		to_chat(user, "<span class='notice'>The crystal crumbles into dust.</span>")
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/closed/indestructible/crystal_wall
	name = "Crystal wall"
	desc = "A crystallized wall"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_highchance"
	baseturfs = /turf/open/space

/turf/closed/indestructible/crystal_wall/examine(mob/user)
	. += ..()
	. += "<span class='notice'>The wall is made of sturdy crystals.</span>"

/turf/open/indestructible/crystal_floor/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=0))
		return FALSE
	to_chat(user, "<span class='notice'>You begin heating up the crystal...</span>")
	if(I.use_tool(src, user, 2.5 SECONDS, volume=100))
		to_chat(user, "<span class='notice'>The crystal crumbles into dust.</span>")
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

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
	///Our sound loop
	var/datum/looping_sound/destabilized_crystal/soundloop

	var/changed_icon = TRUE

/obj/machinery/destabilized_crystal/Initialize()
	. = ..()
	soundloop = new(list(src), TRUE)

/obj/machinery/destabilized_crystal/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/destabilized_crystal/process()
	if(!active)
		return
	if(prob(75))
		radiation_pulse(src, 250, 6)
	if(prob(30))
		playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	if(prob(15))
		fire_nuclear_particle()
	if(length(GLOB.huge_crystal_portals) == 0 && !changed_icon)
		icon_state = "psy"
		changed_icon = TRUE

	var/turf/loc_turf = loc
	var/datum/gas_mixture/env = loc_turf.return_air()
	var/datum/gas_mixture/removed
	var/gasefficency = 0.5
	removed = env.remove(gasefficency * env.total_moles())

	if(!removed)
		return

	removed.assert_gases(/datum/gas/bz, /datum/gas/miasma)
	if(!removed || !removed.total_moles() || isspaceturf(loc_turf))
		removed.gases[/datum/gas/bz][MOLES] += 0.5
	removed.gases[/datum/gas/bz][MOLES] += 15.5
	removed.gases[/datum/gas/miasma][MOLES] += 5.5
	env.merge(removed)
	air_update_turf(FALSE, FALSE)

/obj/machinery/destabilized_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(user))
		return
	if(istype(W, /obj/item/crystal_stabilizer))
		if(length(GLOB.huge_crystal_portals) > 0)
			to_chat(user, "<span class='notice'>The shield protecting the crystal is still up! Close all the main portals before attempting this again!</span>")
			return
		var/obj/item/crystal_stabilizer/injector = W
		if(!injector.filled)
			to_chat(user, "<span class='notice'>\The [W] is empty!</span>")
			return
		to_chat(user, "<span class='notice'>You carefully begin injecting \the [src] with \the [W]... take care not to move until all the steps are finished!</span>")
		if(!W.use_tool(src, user, 1 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>Seems that \the [src] internal resonance is fading with the fluid!</span>")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
		if(!W.use_tool(src, user, 1.5 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>The [src] is reacting violently with the fluid!</span>")
		fire_nuclear_particle()
		radiation_pulse(src, 1000, 6)
		if(!W.use_tool(src, user, 2 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>The [src] has been restored and restabilized!</span>")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
		injector.filled = FALSE
		active = FALSE
		is_stabilized = TRUE

/obj/machinery/destabilized_crystal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The Crystal appears to be heavily destabilized. Maybe it can be fixed by injecting it with something from another world.</span>"
	if(length(GLOB.huge_crystal_portals) > 0)
		. += "<span class='notice'>The Destabilized Crystal appears to be protected by some kind of shield.</span>"
	else
		. += "<span class='notice'>The shield that was protecting the Crystal is gone, it's time to restore it.</span>"

/obj/machinery/destabilized_crystal/Bumped(atom/movable/movable_atom)
	if(!isliving(movable_atom))
		return
	var/mob/living/user = movable_atom
	if(isnull(user.mind))
		return
	movable_atom.visible_message("<span class='danger'>\The [movable_atom] slams into \the [src] inducing a resonance... [movable_atom.p_their()] body starts to glow and burst into flames before flashing into dust!</span>",\
	"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
	"<span class='hear'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(movable_atom)

/obj/machinery/destabilized_crystal/proc/consume(atom/movable/movable_atom)
	if(isliving(movable_atom))
		var/mob/living/user = movable_atom
		if(user.status_flags & GODMODE || isnull(user.mind))
			return
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_SUPERMATTER)
		user.dust(force = TRUE)
	for(var/find_portal in GLOB.crystal_portals)
		var/obj/structure/crystal_portal/portal = find_portal
		portal.modify_component()
	priority_announce("The sacrifice of a crewmember (hopefully the clown) appears to have weakened the portals and slowed down the number of monsters coming through!")
	sound_to_playing_players('sound/misc/notice2.ogg')

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
	. += "<span class='notice'>There is a compartment for something small... like a crystal...</span>"
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
	name = "otherworld crystals"
	icon_state = "otherworld-crystal"
	singular_name = "otherworld crystal"
	icon = 'icons/obj/stack_objects.dmi'
	material_type = /datum/material/otherworld_crystal
	merge_type = /obj/item/stack/sheet/otherworld_crystal

/*
This section is for the signaler part of the crystal portals
*/
/obj/item/assembly/signaler/crystal_anomaly
	name = "Nothing here"
	desc = "Nothing to see here."
	///Link to the crystal
	var/anomaly_type = /obj/structure/crystal_portal

/obj/item/assembly/signaler/crystal_anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/structure/crystal_portal/portal in get_turf(src))
		portal.closed = TRUE
		qdel(portal)
	return TRUE

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
	light_range = 3
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	///Max amount of mobs that a portal can spawn in any given time
	var/max_mobs = 5
	///Spawn time between each mobs
	var/spawn_time = 0
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
	///Link to the signaler object for signaling uses
	var/obj/item/assembly/signaler/crystal_anomaly/a_signal = /obj/item/assembly/signaler/crystal_anomaly

/obj/structure/crystal_portal/Initialize()
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)
	GLOB.crystal_portals += src
	mob_types = typelist("crystal_portal mob_types", mob_types)
	faction = typelist("crystal_portal faction", faction)
	a_signal = new a_signal(src)
	a_signal.code = rand(1,100)
	a_signal.anomaly_type = type
	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	a_signal.set_frequency(frequency)

/obj/structure/crystal_portal/Destroy()
	GLOB.crystal_portals -= src
	if(a_signal)
		QDEL_NULL(a_signal)
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

/obj/structure/crystal_portal/examine(user)
	. = ..()
	. += "<span class='notice'>The [src] seems to be releasing some sort or high frequency wavelength, maybe it could be closed if another signal is sent back or if an equivalent device is used on it.</span>"

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
	if(W.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(a_signal.frequency)], code [a_signal.code].</span>")

/obj/structure/crystal_portal/proc/modify_component()
	spawn_time += 5
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/obj/structure/crystal_portal/small
	name = "Small Portal"
	desc = "A small portal to an unkown dimension!"
	color = COLOR_BRIGHT_BLUE
	max_mobs = 2
	spawn_time = 5 SECONDS
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug
		)

/obj/structure/crystal_portal/medium
	name = "Medium Portal"
	desc = "A medium portal to an unkown dimension!"
	color = COLOR_GREEN
	max_mobs = 3
	spawn_time = 15 SECONDS
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit
		)

/obj/structure/crystal_portal/big
	name = "Big Portal"
	desc = "A big portal to an unkown dimension!"
	color = COLOR_RED
	max_mobs = 4
	spawn_time = 15 SECONDS
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
	max_mobs = 2
	spawn_time = 40 SECONDS
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/boss
		)

/obj/structure/crystal_portal/huge/Initialize()
	. = ..()
	GLOB.huge_crystal_portals += src

/obj/structure/crystal_portal/huge/Destroy()
	GLOB.huge_crystal_portals -= src
	return ..()

/*
This section is for the crystal monsters variations
*/
/mob/living/simple_animal/hostile/crystal_monster
	name = "crystal monster"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon = 'icons/mob/crystal_mobs.dmi'
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	gender = NEUTER
	mob_biotypes = MOB_MINERAL|MOB_HUMANOID
	turns_per_move = 1
	speak_emote = list("resonates")
	emote_see = list("resonates")
	combat_mode = TRUE
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're crystals how would bruise packs help them??
	attack_verb_continuous = "smashes"
	attack_verb_simple = "smash"
	attack_sound = 'sound/effects/supermatter.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = 1
	stat_attack = HARD_CRIT
	faction = list("crystal")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "collapses into dust!"
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = FALSE
	wander = TRUE

/mob/living/simple_animal/hostile/crystal_monster/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE, INNATE_TRAIT)

/mob/living/simple_animal/hostile/crystal_monster/minion
	name = "crystal minion"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	maxHealth = 20
	health = 20
	speed = 0.8
	harm_intent_damage = 7
	melee_damage_lower = 7
	melee_damage_upper = 10
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	var/death_cloud_size = 2

/mob/living/simple_animal/hostile/crystal_monster/minion/Destroy()
	if(isturf(loc))
		var/datum/effect_system/smoke_spread/chem/S = new
		create_reagents(3)
		reagents.add_reagent(/datum/reagent/toxin/lexorin, 4)
		S.attach(loc)
		S.set_up(reagents, death_cloud_size, loc, silent = TRUE)
		S.start()
	return ..()

/mob/living/simple_animal/hostile/crystal_monster/thug
	name = "crystal thug"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon_state = "crystal_thug"
	icon_living = "crystal_thug"
	icon_dead = "crystal_thug"
	maxHealth = 20
	health = 20
	speed = 0.9
	harm_intent_damage = 8
	melee_damage_lower = 8
	melee_damage_upper = 11
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL
	dodging = TRUE
	dodge_prob = 25

/mob/living/simple_animal/hostile/crystal_monster/thug/attackby(obj/item/O, mob/user, params)
	if(prob(30))
		var/list/temp_turfs = list()
		for(var/turf/around_turfs in view(7, src))
			if(!isopenturf(around_turfs) || isspaceturf(around_turfs))
				continue
			temp_turfs += around_turfs
		if(length(temp_turfs))
			var/turf/open/choosen_turf = pick(temp_turfs)
			do_teleport(src, choosen_turf)
			return
	return ..()

/mob/living/simple_animal/hostile/crystal_monster/recruit
	name = "crystal recruit"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon_state = "crystal_recruit"
	icon_living = "crystal_recruit"
	icon_dead = "crystal_recruit"
	maxHealth = 20
	health = 20
	speed = 1.2
	harm_intent_damage = 9
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_force = MOVE_FORCE_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG
	obj_damage = 100
	environment_smash = ENVIRONMENT_SMASH_WALLS

/mob/living/simple_animal/hostile/crystal_monster/recruit/Bump(atom/clong)
	. = ..()
	if(isturf(clong))
		var/turf/turf_bump = clong
		turf_bump.Melt()
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)

/mob/living/simple_animal/hostile/crystal_monster/killer
	name = "crystal killer"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon_state = "crystal_killer"
	icon_living = "crystal_killer"
	icon_dead = "crystal_killer"
	maxHealth = 35
	health = 35
	speed = 0.75
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	dodging = TRUE
	dodge_prob = 35
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	projectiletype = /obj/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "throws"
	ranged_cooldown_time = 3.5 SECONDS

/obj/projectile/temp/crystal_killer
	name = "freezing blast"
	icon_state = "ice_2"
	color = COLOR_YELLOW
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = ENERGY
	temperature = -75

/mob/living/simple_animal/hostile/crystal_monster/killer/Bump(atom/clong)
	. = ..()
	if(isturf(clong))
		var/turf/turf_bump = clong
		turf_bump.Melt()
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)

/mob/living/simple_animal/hostile/crystal_monster/boss
	name = "crystal boss"
	desc = "A monster made of crystals similar to the Supermatter ones."
	icon_state = "crystal_boss"
	icon_living = "crystal_boss"
	icon_dead = "crystal_boss"
	maxHealth = 150
	health = 100
	speed = 1.3
	harm_intent_damage = 15
	melee_damage_lower = 25
	melee_damage_upper = 40
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	projectiletype = /obj/projectile/magic/aoe/lightning/no_zap
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "throws"
	ranged_cooldown_time = 5.5 SECONDS

/mob/living/simple_animal/hostile/crystal_monster/boss/Bump(atom/clong)
	. = ..()
	if(isliving(clong))
		var/mob/living/mob = clong
		if(mob.stat >= HARD_CRIT)
			mob.dust()
			if(health < maxHealth)
				health = min(health+30,maxHealth)
	else if(isturf(clong))
		var/turf/turf_bump = clong
		turf_bump.Melt()
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)

/mob/living/simple_animal/hostile/crystal_monster/boss/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/mob = target
		if(mob.stat >= HARD_CRIT)
			mob.dust()
			if(health < maxHealth)
				health = min(health+30,maxHealth)
		else
			var/obj/item/bodypart/body_part = mob.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			if(body_part)
				body_part.drop_limb(FALSE, TRUE)
	else if(isturf(target))
		var/turf/turf_bump = target
		turf_bump.Melt()
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)


