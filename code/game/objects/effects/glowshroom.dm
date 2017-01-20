//separate dm since hydro is getting bloated already

var/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/floor/plating/lava,
	/turf/open/floor/plating/beach/water))

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	obj_integrity = 30
	max_integrity = 30
	var/potency = 30
	var/delay = 1200
	var/floor = 0
	var/yield = 3
	var/generation = 1
	var/spreadIntoAdjacentChance = 60

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	icon_state = "glowcap"

/obj/structure/glowshroom/single
	yield = 0

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	user << "This is a [generation]\th generation [name]!"

/obj/structure/glowshroom/New()
	..()
	SetLuminosity(round(potency/10))
	setDir(CalcDir())
	var/base_icon_state = initial(icon_state)
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
		icon_state = "[base_icon_state]f"

	addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/Spread()
	for(var/i = 1 to yield)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			var/list/possibleLocs = list()
			var/spreadsIntoAdjacent = FALSE

			if(prob(spreadIntoAdjacentChance))
				spreadsIntoAdjacent = TRUE

			for(var/turf/open/floor/earth in view(3,src))
				if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
					continue
				if(spreadsIntoAdjacent || !locate(/obj/structure/glowshroom) in view(1,earth))
					possibleLocs += earth
				CHECK_TICK

			if(!possibleLocs.len)
				break

			var/turf/newLoc = pick(possibleLocs)

			var/shroomCount = 0 //hacky
			var/placeCount = 1
			for(var/obj/structure/glowshroom/shroom in newLoc)
				shroomCount++
			for(var/wallDir in cardinal)
				var/turf/isWall = get_step(newLoc,wallDir)
				if(isWall.density)
					placeCount++
			if(shroomCount >= placeCount)
				continue

			var/obj/structure/glowshroom/child = new type(newLoc)//The baby mushrooms have different stats :3
			child.potency = max(potency + rand(-3,6), 0)
			child.yield = max(yield + rand(-1,2), 0)
			child.delay = max(delay + rand(-30,60), 0)
			var/newhealth = max(obj_integrity + rand(-3,6), 1)
			child.obj_integrity = newhealth
			child.max_integrity = newhealth
			child.generation = generation + 1

			CHECK_TICK

/obj/structure/glowshroom/proc/CalcDir(turf/location = loc)
	var/direction = 16

	for(var/wallDir in cardinal)
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

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/structure/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)
