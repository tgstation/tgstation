//separate dm since hydro is getting bloated already

<<<<<<< HEAD
var/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/floor/plating/lava,
	/turf/open/floor/plating/beach/water))

/obj/effect/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
=======
/obj/effect/glowshroom
	name = "glowshroom"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi'
<<<<<<< HEAD
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
=======
	icon_state = "glowshroomf"
	layer = 2.1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/endurance = 30
	var/potency = 30
	var/delay = 1200
	var/floor = 0
	var/yield = 3
<<<<<<< HEAD
	var/generation = 1
	var/spreadIntoAdjacentChance = 60

obj/effect/glowshroom/glowcap
	name = "glowcap"
	icon_state = "glowcap"

/obj/effect/glowshroom/single
	yield = 0

/obj/effect/glowshroom/examine(mob/user)
	. = ..()
	user << "This is a [generation]\th generation [name]!"

/obj/effect/glowshroom/New()
	..()
	SetLuminosity(round(potency/10))
	setDir(CalcDir())
	var/base_icon_state = initial(icon_state)
=======
	var/spreadChance = 40
	var/spreadIntoAdjacentChance = 60
	var/evolveChance = 2
	w_type=NOT_RECYCLABLE

/obj/effect/glowshroom/single
	spreadChance = 0

/obj/effect/glowshroom/New()
	..()
	dir = CalcDir()

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
		icon_state = "[base_icon_state][rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = "[base_icon_state]f"

	addtimer(src, "Spread", delay)

/obj/effect/glowshroom/proc/Spread()
	for(var/i = 1 to yield)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			var/list/possibleLocs = list()
			var/spreadsIntoAdjacent = FALSE

			if(prob(spreadIntoAdjacentChance))
				spreadsIntoAdjacent = TRUE

			for(var/turf/open/floor/earth in view(3,src))
				if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
					continue
				if(spreadsIntoAdjacent || !locate(/obj/effect/glowshroom) in view(1,earth))
					possibleLocs += earth
				CHECK_TICK

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

			var/obj/effect/glowshroom/child = new type(newLoc)//The baby mushrooms have different stats :3
			child.potency = max(potency + rand(-3,6), 0)
			child.yield = max(yield + rand(-1,2), 0)
			child.delay = max(delay + rand(-30,60), 0)
			child.endurance = max(endurance + rand(-3,6), 1)
			child.generation = generation + 1

			CHECK_TICK

/obj/effect/glowshroom/proc/CalcDir(turf/location = loc)
=======
		icon_state = "glowshroom[rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = "glowshroomf"

	spawn(delay)
		set_light(round(potency/10))
		// Spread() - Methinks this is broken - N3X

/obj/effect/glowshroom/proc/Spread()
	//set background = 1
	var/spreaded = 1

	while(spreaded)
		spreaded = 0

		for(var/i=1,i<=yield,i++)
			if(prob(spreadChance))
				var/list/possibleLocs = list()
				var/spreadsIntoAdjacent = 0

				if(prob(spreadIntoAdjacentChance))
					spreadsIntoAdjacent = 1

				for(var/turf/unsimulated/floor/asteroid/earth in view(3,src))
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

				var/obj/effect/glowshroom/child = new /obj/effect/glowshroom(newLoc)
				child.potency = potency
				child.yield = yield
				child.delay = delay
				child.endurance = endurance

				spreaded++

		if(prob(evolveChance)) //very low chance to evolve on its own
			potency += rand(4,6)

		sleep(delay)

/obj/effect/glowshroom/proc/CalcDir(turf/location = loc)
	//set background = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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

<<<<<<< HEAD
/obj/effect/glowshroom/attacked_by(obj/item/I, mob/user)
	..()
	if(I.damtype != STAMINA)
		endurance -= I.force
		CheckEndurance()

/obj/effect/glowshroom/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)

/obj/effect/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
=======
/obj/effect/glowshroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	endurance -= W.force

	CheckEndurance()

/obj/effect/glowshroom/ex_act(severity)
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

/obj/effect/glowshroom/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(exposed_temperature > 300)
		endurance -= 5
		CheckEndurance()

/obj/effect/glowshroom/proc/CheckEndurance()
	if(endurance <= 0)
		qdel(src)
<<<<<<< HEAD

/obj/effect/glowshroom/acid_act(acidpwr, toxpwr, acid_volume)
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_item/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
