GLOBAL_LIST_INIT(ore_probability, list(
	/obj/item/stack/ore/uranium = 50,
	/obj/item/stack/ore/iron = 100,
	/obj/item/stack/ore/plasma = 75,
	/obj/item/stack/ore/silver = 50,
	/obj/item/stack/ore/gold = 50,
	/obj/item/stack/ore/diamond = 25,
	/obj/item/stack/ore/bananium = 5,
	/obj/item/stack/ore/titanium = 75,
	))

/obj/structure/spawner/ice_moon
	name = "cave entrance"
	desc = "A hole in the ground, filled with monsters ready to defend it."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "hole"
	faction = list(FACTION_MINING)
	max_mobs = 3
	max_integrity = 250
	mob_types = list(/mob/living/basic/mining/wolf)
	move_resist = INFINITY
	anchored = TRUE
	scanner_taggable = TRUE
	mob_gps_id = "WF" // wolf
	spawner_gps_id = "Animal Den"

/obj/structure/spawner/ice_moon/Initialize(mapload)
	. = ..()
	clear_rock()

/**
 * Clears rocks around the spawner when it is created. Ignore any rocks that explicitly do not want to be cleared.
 *
 */
/obj/structure/spawner/ice_moon/proc/clear_rock()
	for(var/turf/potential in RANGE_TURFS(2, src))
		if(abs(src.x - potential.x) + abs(src.y - potential.y) > 3)
			continue
		if(ismineralturf(potential) && !(potential.turf_flags & NO_CLEARING))
			var/turf/closed/mineral/clearable = potential
			clearable.ScrapeAway(flags = CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/atom_deconstruct(disassembled)
	destroy_effect()
	drop_loot()

/**
 * Effects and messages created when the spawner is destroyed
 *
 */
/obj/structure/spawner/ice_moon/proc/destroy_effect()
	playsound(loc,'sound/effects/explosion/explosionfar.ogg', 200, TRUE)
	visible_message(span_bolddanger("[src] collapses, sealing everything inside!</span>\n<span class='warning'>Ores fall out of the cave as it is destroyed!"))

/**
 * Drops items after the spawner is destroyed
 *
 */
/obj/structure/spawner/ice_moon/proc/drop_loot()
	for(var/type in GLOB.ore_probability)
		var/chance = GLOB.ore_probability[type]
		if(!prob(chance))
			continue
		new type(loc, rand(5, 10))

/obj/structure/spawner/ice_moon/polarbear
	max_mobs = 1
	spawn_time = 60 SECONDS
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/polarbear)
	mob_gps_id = "BR" // bear

/obj/structure/spawner/ice_moon/polarbear/clear_rock()
	for(var/turf/potential in RANGE_TURFS(1, src))
		if(ismineralturf(potential) && !(potential.turf_flags & NO_CLEARING))
			var/turf/closed/mineral/clearable = potential
			clearable.ScrapeAway(flags = CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal
	name = "demonic portal"
	desc = "A portal that goes to another world, normal creatures couldn't survive there."
	icon_state = "nether"
	mob_types = list(/mob/living/basic/mining/ice_demon)
	light_range = 1
	light_color = COLOR_SOFT_RED
	mob_gps_id = "WT|B" // watcher | bluespace
	spawner_gps_id = "Netheric Distortion"

/obj/structure/spawner/ice_moon/demonic_portal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Netheric Signal")

/obj/structure/spawner/ice_moon/demonic_portal/clear_rock()
	for(var/turf/potential in RANGE_TURFS(3, src))
		if(abs(src.x - potential.x) + abs(src.y - potential.y) > 5)
			continue
		if(ismineralturf(potential) && !(potential.turf_flags & NO_CLEARING))
			var/turf/closed/mineral/clearable = potential
			clearable.ScrapeAway(flags = CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal/destroy_effect()
	new /obj/effect/collapsing_demonic_portal(loc)

/obj/structure/spawner/ice_moon/demonic_portal/drop_loot()
	return

/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp
	mob_types = list(/mob/living/basic/mining/ice_whelp)
	mob_gps_id = "ID|W" // ice drake | whelp

/obj/structure/spawner/ice_moon/demonic_portal/snowlegion
	mob_types = list(/mob/living/basic/mining/legion/snow/spawner_made)
	mob_gps_id = "LG|S" // legion | snow

/obj/effect/collapsing_demonic_portal
	name = "collapsing demonic portal"
	desc = "It's slowly fading!"
	layer = TABLE_LAYER
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "nether"
	anchored = TRUE
	density = TRUE

/obj/effect/collapsing_demonic_portal/Initialize(mapload)
	. = ..()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	visible_message(span_bolddanger("[src] begins to collapse, cutting it off from this world!"))
	animate(src, transform = matrix().Scale(0, 1), alpha = 50, time = 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(collapse)), 5 SECONDS)

/**
 * Handles portal deletion
 *
 */
/obj/effect/collapsing_demonic_portal/proc/collapse()
	drop_loot()
	qdel(src)

/**
 * Drops loot from the portal
 *
 */
/obj/effect/collapsing_demonic_portal/proc/drop_loot()
	visible_message(span_warning("Something slips out of [src]!"))
	var/loot = rand(1, 100)
	switch(loot)
		if(1 to 80)
			new /obj/structure/closet/crate/necropolis/tendril/demonic(loc)
		if(81 to 90)
			new /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom(loc)
		if(91 to INFINITY)
			new /obj/structure/elite_tumor(loc)
