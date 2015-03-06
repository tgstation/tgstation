//separate dm since hydro is getting bloated already

/obj/effect/glowshroom
	name = "glowshroom"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroomf"
	layer = 2.1
	var/endurance = 30
	var/potency = 30
	var/delay = 1200
	var/floor = 0
	var/yield = 3
	var/generation = 1
	var/spreadIntoAdjacentChance = 60

/obj/effect/glowshroom/single
	yield = 0

/obj/effect/glowshroom/New()
	..()
	SetLuminosity(round(potency/10))
	dir = CalcDir()
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
		icon_state = "glowshroom[rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = "glowshroomf"

	spawn(delay)
		Spread()

/obj/effect/glowshroom/proc/Spread()
	set background = BACKGROUND_ENABLED

	for(var/i=1,i<=yield,i++)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			var/list/possibleLocs = list()
			var/spreadsIntoAdjacent = 0

			if(prob(spreadIntoAdjacentChance))
				spreadsIntoAdjacent = 1

			for(var/turf/simulated/floor/earth in view(3,src))
				if(spreadsIntoAdjacent || !locate(/obj/effect/glowshroom) in view(1,earth))
					possibleLocs += earth

			if(!possibleLocs.len)
				break

			var/turf/newLoc = pick(possibleLocs)

			var/shroomCount = 0 //hacky
			var/placeCount = 1
			for(var/obj/effect/glowshroom/shroom in newLoc)
				shroomCount++
			for(var/wallDir in cardinal)
				var/turf/isWall = get_step(newLoc,wallDir)
				if(isWall.density)
					placeCount++
			if(shroomCount >= placeCount)
				continue

			var/obj/effect/glowshroom/child = new /obj/effect/glowshroom(newLoc)//The baby mushrooms have different stats :3
			child.potency = max(potency+rand(-3,6), 0)
			child.yield = max(yield+rand(-1,2), 0)
			child.delay = max(delay+rand(-30,60), 0)
			child.endurance = max(endurance+rand(-3,6), 1)
			child.generation = generation+1
			child.desc = "This is a [child.generation]\th generation glowshroom!"//I added this for testing, but I figure I'll leave it in.

/obj/effect/glowshroom/proc/CalcDir(turf/location = loc)
	set background = BACKGROUND_ENABLED
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/effect/glowshroom/shroom in location)
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

/obj/effect/glowshroom/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	endurance -= W.force
	CheckEndurance()

/obj/effect/glowshroom/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/effect/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		endurance -= 5
		CheckEndurance()

/obj/effect/glowshroom/proc/CheckEndurance()
	if(endurance <= 0)
		qdel(src)

/obj/effect/glowshroom/acid_act(var/acidpwr, var/toxpwr, var/acid_volume)
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_item/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)