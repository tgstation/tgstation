//separate dm since hydro is getting bloated already

/obj/glowshroom
	opacity = 0
	density = 0
	icon = 'lighting.dmi'
	icon_state = "glowshroomf"
	layer = 2.1
	var/endurance = 30
	var/potency = 30
	var/delay = 600
	var/floor = 0
	var/yield = 3
	var/spreadChance = 80
	var/spreadIntoAdjacentChance = 60
	var/evolveChance = 2

/obj/glowshroom/single
	spreadChance = 0

/obj/glowshroom/New()
	..()

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

	spawn(2) //allows the luminosity and spread rate to be affected by potency at the moment of creation
		sd_SetLuminosity(potency/10)
		spawn(delay)
			if(src)
				Spread()

/obj/glowshroom/proc/Spread()
	set background = 1
	var/spreaded = 1

	while(spreaded)
		spreaded = 0

		for(var/i=1,i<=yield,i++)
			if(prob(spreadChance))
				var/list/possibleLocs = list()
				var/spreadsIntoAdjacent = 0

				if(prob(spreadIntoAdjacentChance))
					spreadsIntoAdjacent = 1

				for(var/turf/turf in view(3,src))
					if(!turf.density && !istype(turf,/turf/space))
						var/isAdjacent = 0
						if(!spreadsIntoAdjacent)
							for(var/obj/glowshroom in view(1,turf))
								isAdjacent = 1
						if(!isAdjacent)
							possibleLocs += turf

				if(!possibleLocs.len)
					break

				var/turf/newLoc = pick(possibleLocs)

				var/shroomCount = 0 //hacky
				var/placeCount = 1
				for(var/obj/glowshroom/shroom in newLoc)
					shroomCount++
				for(var/wallDir in cardinal)
					var/turf/isWall = get_step(newLoc,wallDir)
					if(isWall.density)
						placeCount++
				if(shroomCount >= placeCount)
					continue

				var/obj/glowshroom/child = new /obj/glowshroom(newLoc)
				child.potency = potency
				child.yield = yield
				child.delay = delay
				child.endurance = endurance

				spreaded++

		if(prob(evolveChance)) //very low chance to evolve on its own
			potency += rand(4,6)

		sleep(delay)

/obj/glowshroom/proc/CalcDir(turf/location = loc)
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=0,i<=4,i++)
		if(direction & 2 ** i)
			dirList += 2 ** i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/glowshroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	endurance -= W.force

	CheckEndurance()

/obj/glowshroom/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		endurance -= 5
		CheckEndurance()

/obj/glowshroom/proc/CheckEndurance()
	if(endurance <= 0)
		del(src)