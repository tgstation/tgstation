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
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"
	faction = list("mining")
	max_mobs = 3
	max_integrity = 250
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/wolf)
	move_resist = INFINITY
	anchored = TRUE

/obj/structure/spawner/ice_moon/Initialize(mapload)
	. = ..()
	clear_rock()

/**
 * Clears rocks around the spawner when it is created
 *
 */
/obj/structure/spawner/ice_moon/proc/clear_rock()
	for(var/turf/F in RANGE_TURFS(2, src))
		if(abs(src.x - F.x) + abs(src.y - F.y) > 3)
			continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/deconstruct(disassembled)
	destroy_effect()
	drop_loot()
	return ..()

/**
 * Effects and messages created when the spawner is destroyed
 *
 */
/obj/structure/spawner/ice_moon/proc/destroy_effect()
	playsound(loc,'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message(span_boldannounce("[src] collapses, sealing everything inside!</span>\n<span class='warning'>Ores fall out of the cave as it is destroyed!"))

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

/obj/structure/spawner/ice_moon/polarbear/clear_rock()
	for(var/turf/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal
	name = "demonic portal"
	desc = "A portal that goes to another world, normal creatures couldn't survive there."
	icon_state = "nether"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/ice_demon)
	light_range = 1
	light_color = COLOR_SOFT_RED

/obj/structure/spawner/ice_moon/demonic_portal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Netheric Signal")

/obj/structure/spawner/ice_moon/demonic_portal/clear_rock()
	for(var/turf/F in RANGE_TURFS(3, src))
		if(abs(src.x - F.x) + abs(src.y - F.y) > 5)
			continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/demonic_portal/destroy_effect()
	new /obj/effect/collapsing_demonic_portal(loc)

/obj/structure/spawner/ice_moon/demonic_portal/drop_loot()
	return

/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/ice_whelp)

/obj/structure/spawner/ice_moon/demonic_portal/snowlegion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow)

/obj/effect/collapsing_demonic_portal
	name = "collapsing demonic portal"
	desc = "It's slowly fading!"
	layer = TABLE_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "nether"
	anchored = TRUE
	density = TRUE

/obj/effect/collapsing_demonic_portal/Initialize(mapload)
	. = ..()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	visible_message(span_boldannounce("[src] begins to collapse, cutting it off from this world!"))
	animate(src, transform = matrix().Scale(0, 1), alpha = 50, time = 5 SECONDS)
	addtimer(CALLBACK(src, .proc/collapse), 5 SECONDS)

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
	var/loot = rand(1, 28)
	switch(loot)
		if(1)
			new /obj/item/clothing/suit/hooded/cultrobes/hardened(loc)
		if(2)
			new /obj/item/clothing/glasses/godeye(loc)
		if(3)
			new /obj/item/reagent_containers/glass/bottle/potion/flight(loc)
		if(4)
			new /obj/item/organ/heart/cursed/wizard(loc)
		if(5)
			new /obj/item/jacobs_ladder(loc)
		if(6)
			new /obj/item/rod_of_asclepius(loc)
		if(7)
			new /obj/item/warp_cube/red(loc)
		if(8)
			new /obj/item/wisp_lantern(loc)
		if(9)
			new /obj/item/immortality_talisman(loc)
		if(10)
			new /obj/item/book/granter/spell/summonitem(loc)
		if(11)
			new /obj/item/clothing/neck/necklace/memento_mori(loc)
		if(12)
			new /obj/item/borg/upgrade/modkit/lifesteal(loc)
			new /obj/item/bedsheet/cult(loc)
		if(13)
			new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(loc)
		if(14)
			new /obj/item/disk/design_disk/modkit_disc/bounty(loc)
		if(15)
			new /obj/item/ship_in_a_bottle(loc)
			new /obj/item/oar(loc)
		if(16)
			new /obj/item/seeds/gatfruit(loc)
		if(17)
			new /obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola(loc)
		if(18)
			new /obj/item/soulstone/anybody(loc)
		if(19)
			new /obj/item/disk/design_disk/modkit_disc/resonator_blast(loc)
		if(20)
			new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(loc)
		if(21)
			new /obj/item/slimepotion/transference(loc)
		if(22)
			new /obj/item/slime_extract/adamantine(loc)
		if(23)
			new /obj/item/weldingtool/abductor(loc)
		if(24)
			new /obj/structure/elite_tumor(loc)
		if(25)
			new /mob/living/simple_animal/hostile/retaliate/clown/clownhulk(loc)
		if(26)
			new /obj/item/clothing/shoes/winterboots/ice_boots(loc)
		if(27)
			new /obj/item/book/granter/spell/sacredflame(loc)
		if(28)
			new /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom(loc)
