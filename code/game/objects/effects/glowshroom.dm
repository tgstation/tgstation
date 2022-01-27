
GLOBAL_VAR_INIT(glowshrooms, 0)

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = GLOWSHROOM_BASE_INTEGRITY
	///Cooldown for when next to try to spread.
	COOLDOWN_DECLARE(spread_cooldown)
	/// Min time interval between glowshroom "spreads"
	var/min_delay_spread = 20 SECONDS
	/// Max time interval between glowshroom "spreads"
	var/max_delay_spread = 30 SECONDS
	/// Boolean to indicate if the shroom is on the floor/wall
	var/floor = 0
	/// Mushroom generation number
	var/generation = 1
	/// Chance to spread into adjacent tiles (0-100)
	var/spread_into_adjacent_chance = 75
	///Amount of decay when decay happens on process.
	var/idle_decay_min = 1
	///Amount of decay when decay happens on process
	var/idle_decay_max = 2
	///Amount of percentage decay affects endurance.max_integrity =
	var/endurance_decay_rate = 0.1
	/// Internal seed of the glowshroom, stats are stored here
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom

	/// Turfs where the glowshroom cannot spread to
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/lava,
	/turf/open/floor/plating/beach/water))

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = "Mycena Ruthenia, a species of mushroom that, while it does glow in the dark, is not actually bioluminescent."
	icon_state = "glowcap"
	myseed = /obj/item/seeds/glowshroom/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = "Mycena Umbra, a species of mushroom that emits shadow instead of light."
	icon_state = "shadowshroom"
	myseed = /obj/item/seeds/glowshroom/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	. += "This is a [generation]\th generation [name]!"

/**
 * Creates a new glowshroom structure.
 *
 * Arguments:
 * * newseed - Seed of the shroom
 */



/obj/structure/glowshroom/Initialize(mapload, obj/item/seeds/newseed)
	. = ..()
	GLOB.glowshrooms++
	if(istype(newseed))
		myseed = newseed
		myseed.forceMove(src)
	else
		myseed = new myseed(src)

	modify_max_integrity(GLOWSHROOM_BASE_INTEGRITY + ((100 - GLOWSHROOM_BASE_INTEGRITY) / 100 * myseed.endurance)) //goes up to 100 with peak endurance

	var/datum/plant_gene/trait/glow/our_glow_gene = myseed.get_gene(/datum/plant_gene/trait/glow)
	if(ispath(our_glow_gene)) // Seeds were ported to initialize so their genes are still typepaths here, luckily their initializer is smart enough to handle us doing this
		myseed.genes -= our_glow_gene
		our_glow_gene = new our_glow_gene
		myseed.genes += our_glow_gene
	if(istype(our_glow_gene))
		set_light(our_glow_gene.glow_range(myseed), our_glow_gene.glow_power(myseed), our_glow_gene.glow_color)
	setDir(calc_dir())
	base_icon_state = initial(icon_state)
	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "[base_icon_state][rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = base_icon_state

	AddElement(/datum/element/atmos_sensitive, mapload)
	COOLDOWN_START(src, spread_cooldown, rand(min_delay_spread, max_delay_spread))

	START_PROCESSING(SSobj, src)

/obj/structure/glowshroom/Destroy()
	if(isatom(myseed))
		QDEL_NULL(myseed)
	GLOB.glowshrooms--
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
 * Causes glowshroom spreading across the floor/walls.
 */

/obj/structure/glowshroom/process(delta_time)
	if(COOLDOWN_FINISHED(src, spread_cooldown))
		COOLDOWN_START(src, spread_cooldown, rand(min_delay_spread, max_delay_spread))
		Spread()

	Decay(rand(idle_decay_min, idle_decay_max) * delta_time)



/obj/structure/glowshroom/proc/Spread()
	var/turf/ownturf = get_turf(src)
	if(!TURF_SHARES(ownturf)) //If we are in a 1x1 room
		return //Deal with it not now

	var/list/possible_locs = list()
	//Lets collect a list of possible viewable turfs BEFORE we iterate for yield so we don't call view multiple
	//times when there's no real chance of the viewable range changing, really you could do this once on item
	//spawn and most people probably would not notice.
	for(var/turf/open/floor/earth in oview(2,src))
		if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
			continue
		if(!TURF_SHARES(earth))
			continue
		possible_locs += earth

	//Lets not even try to spawn again if somehow we have ZERO possible locations
	if(!possible_locs.len)
		return

	var/chance_generation = 100 * (NUM_E ** -((GLOWSHROOM_SPREAD_BASE_DIMINISH_FACTOR + GLOWSHROOM_SPREAD_DIMINISH_FACTOR_PER_GLOWSHROOM * GLOB.glowshrooms) / myseed.potency * (generation - 1))) //https://www.desmos.com/calculator/istvjvcelz

	for(var/i in 1 to myseed.yield)
		if(!prob(chance_generation))
			continue
		var/spreads_into_adjacent = prob(spread_into_adjacent_chance)
		var/turf/new_loc = null

		//Try three random locations to spawn before giving up tradeoff
		//between running view(1, earth) on every single collected possibleLoc
		//and failing to spread if we get 3 bad picks, which should only be a problem
		//if there's a lot of glow shroom clustered about
		for(var/iterator in 1 to 3)
			var/turf/possibleLoc = pick(possible_locs)
			if(spreads_into_adjacent || !locate(/obj/structure/glowshroom) in view(1,possibleLoc))
				new_loc = possibleLoc
				break

		//We failed to find any location, skip trying to yield
		if(new_loc == null)
			break


		var/shroom_count = 0
		var/place_count = 1
		for(var/obj/structure/glowshroom/shroom in new_loc)
			shroom_count++
		for(var/wall_dir in GLOB.cardinals)
			var/turf/potential_wall = get_step(new_loc,wall_dir)
			if(potential_wall.density)
				place_count++
		if(shroom_count >= place_count)
			continue

		var/obj/structure/glowshroom/child = new type(new_loc, myseed.Copy())
		child.generation = generation + 1

/obj/structure/glowshroom/proc/calc_dir(turf/location = loc)
	var/direction = 16

	for(var/wall_dir in GLOB.cardinals)
		var/turf/new_turf = get_step(location,wall_dir)
		if(new_turf.density)
			direction |= wall_dir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dir_list = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dir_list += i

	if(dir_list.len)
		var/new_dir = pick(dir_list)
		if(new_dir == 16)
			floor = 1
			new_dir = 1
		return new_dir

	floor = 1
	return 1

/**
 * Causes the glowshroom to decay by decreasing its endurance, destroying it when it gets too low.
 *
 * Arguments:
 * * amount - Amount of endurance to be reduced due to spread decay.
 */
/obj/structure/glowshroom/proc/Decay(amount)
	myseed.adjust_endurance(-amount * endurance_decay_rate)
	take_damage(amount)
	// take_damage could qdel our shroom, so check beforehand
	// if our endurance dropped before the min plant endurance, then delete our shroom anyways
	if (!QDELETED(src) && myseed.endurance <= MIN_PLANT_ENDURANCE)
		qdel(src)

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/glowshroom/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/glowshroom/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	visible_message(span_danger("[src] melts away!"))
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)
	return TRUE

/obj/structure/glowshroom/extreme/Initialize(mapload, obj/item/seeds/newseed)
	. = ..()
	if(generation == 1)
		myseed.potency = 100
		myseed.endurance = 100
		myseed.yield = 10

/obj/structure/glowshroom/medium/Initialize(mapload, obj/item/seeds/newseed)
	. = ..()
	if(generation == 1)
		myseed.potency = 50
		myseed.endurance = 50
		myseed.yield = 5
