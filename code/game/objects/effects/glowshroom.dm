//separate dm since hydro is getting bloated already

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	/// Time interval between glowshroom "spreads"
	var/delay_spread = 2 MINUTES
	/// Time interval between glowshroom decay checks
	var/delay_decay = 30 SECONDS
	/// Boolean to indicate if the shroom is on the floor/wall
	var/floor = 0
	/// Mushroom generation number
	var/generation = 1
	/// Chance to spread into adjacent tiles (0-100)
	var/spreadIntoAdjacentChance = 75
	/// Internal seed of the glowshroom, stats are stored here
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom

	/// If we fail to spread this many times we stop trying to spread
	var/max_failed_spreads = 5
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
 *	Creates a new glowshroom structure.
 *
 * Arguments:
 * * newseed - Seed of the shroom
 * * mutate_stats - If the plant needs to mutate their stats
 * * spread - If the plant is a result of spreading, reduce its stats
 */

/obj/structure/glowshroom/Initialize(mapload, obj/item/seeds/newseed, mutate_stats, spread)
	. = ..()
	if(newseed)
		myseed = newseed.Copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
	if(spread)
		myseed.potency -= round(myseed.potency * 0.25) // Reduce potency of the little mushie if it's spreading
	if(mutate_stats) //baby mushrooms have different stats :3
		myseed.adjust_potency(rand(-4,3))
		myseed.adjust_yield(rand(-3,2))
		myseed.adjust_production(rand(-3,3))
		myseed.endurance = clamp(myseed.endurance + rand(-3,2), 0, 100) // adjust_endurance has a min value of 10, need to edit directly
	if(myseed.production >= 1) //In case production is varedited to -1 or less which would cause unlimited or negative delay.
		delay_spread = delay_spread - (11 - myseed.production) * 100 //Because lower production speed stat gives faster production speed, which should give faster mushroom spread. Range 200-1100 deciseconds.
	var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
	if(ispath(G)) // Seeds were ported to initialize so their genes are still typepaths here, luckily their initializer is smart enough to handle us doing this
		myseed.genes -= G
		G = new G
		myseed.genes += G
	set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
	setDir(CalcDir())
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


	addtimer(CALLBACK(src, .proc/Spread), delay_spread, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
	addtimer(CALLBACK(src, .proc/Decay), delay_decay, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/structure/glowshroom/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/**
 * Causes glowshroom spreading across the floor/walls.
 */

/obj/structure/glowshroom/proc/Spread()

	//We could be deleted at any point and the timers might not be cleaned up
	if(QDELETED(src))
		return

	var/turf/ownturf = get_turf(src)
	if(!TURF_SHARES(ownturf)) //If we are in a 1x1 room
		addtimer(CALLBACK(src, .proc/Spread), delay_spread, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
		return //Deal with it not now

	var/shrooms_planted = 0
	var/list/possibleLocs = list()
	//Lets collect a list of possible viewable turfs BEFORE we iterate for yield so we don't call view multiple
	//times when there's no real chance of the viewable range changing, really you could do this once on item
	//spawn and most people probably would not notice.
	for(var/turf/open/floor/earth in view(3,src))
		if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
			continue
		if(!TURF_SHARES(earth))
			continue
		possibleLocs += earth

	//Lets not even try to spawn again if somehow we have ZERO possible locations
	if(!possibleLocs.len)
		return

	for(var/i in 1 to myseed.yield)
		var/chance_stats = ((myseed.potency + myseed.endurance * 2) * 0.2) // Chance of generating a new mushroom based on stats
		var/chance_generation = (100 / (generation * generation)) // This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...

		// Whatever is the higher chance we use it (this is really stupid as the diminishing returns are effectively pointless???)
		if(prob(max(chance_stats, chance_generation)))
			var/spreadsIntoAdjacent = prob(spreadIntoAdjacentChance)
			var/turf/newLoc = null

			//Try three random locations to spawn before giving up tradeoff
			//between running view(1, earth) on every single collected possibleLoc
			//and failing to spread if we get 3 bad picks, which should only be a problem
			//if there's a lot of glow shroom clustered about
			for(var/Potato in 1 to 3)
				var/turf/possibleLoc = pick(possibleLocs)
				if(spreadsIntoAdjacent || !locate(/obj/structure/glowshroom) in view(1,possibleLoc))
					newLoc = possibleLoc
					break

			//We failed to find any location, skip trying to yield
			if(newLoc == null)
				break

			var/shroomCount = 0 //hacky
			var/placeCount = 1
			for(var/obj/structure/glowshroom/shroom in newLoc)
				shroomCount++
			for(var/wallDir in GLOB.cardinals)
				var/turf/isWall = get_step(newLoc,wallDir)
				if(isWall.density)
					placeCount++
			if(shroomCount >= placeCount)
				continue

			Decay(TRUE, 2) // Decay before spawning new mushrooms to reduce their endurance
			if(QDELETED(src))	//Decay can end us
				return
			var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE, TRUE)
			child.generation = generation + 1
			shrooms_planted++

	if(!shrooms_planted)
		max_failed_spreads--

	//if we didn't get all possible shrooms planted or we haven't failed to spread at least 5 times then try to spread again later
	if( (shrooms_planted <= myseed.yield) && (max_failed_spreads >= 0)  )
		myseed.adjust_yield(-shrooms_planted)
		//Lets make this a unique hash
		addtimer(CALLBACK(src, .proc/Spread), delay_spread, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/structure/glowshroom/proc/CalcDir(turf/location = loc)
	var/direction = 16

	for(var/wallDir in GLOB.cardinals)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/**
 * Causes the glowshroom to decay by decreasing its endurance.
 *
 * Arguments:
 * * spread - Boolean to indicate if the decay is due to spreading or natural decay.
 * * amount - Amount of endurance to be reduced due to spread decay.
 */
/obj/structure/glowshroom/proc/Decay(spread, amount)
	if (spread) // Decay due to spread
		myseed.endurance -= amount
	else // Timed decay
		myseed.endurance -= 1
		if (myseed.endurance > 0)
			addtimer(CALLBACK(src, .proc/Decay), delay_decay, TIMER_UNIQUE|TIMER_NO_HASH_WAIT) // Recall decay timer
			return
	if (myseed.endurance < 1) // Plant is gone
		qdel(src)

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/glowshroom/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/glowshroom/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)
	return TRUE

/obj/structure/glowshroom/attackby(obj/item/I, mob/living/user, params)
	if (istype(I, /obj/item/plant_analyzer))
		return myseed.attackby(I, user, params) // Hacky I guess
	return ..() // Attack normally
