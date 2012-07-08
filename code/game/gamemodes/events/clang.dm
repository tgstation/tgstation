/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/obj/effect/immovablerod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1

	Bump(atom/clong)
		if(istype(clong, /turf/simulated/shuttle)) //Skip shuttles without actually deleting the rod
			return
		if (istype(clong, /turf) && !istype(clong, /turf/unsimulated))
			if(clong.density)
				clong.ex_act(2)
				for (var/mob/O in hearers(src, null))
					O.show_message("CLANG", 2)
		if (istype(clong, /obj))
			if(clong.density)
				clong.ex_act(2)
				for (var/mob/O in hearers(src, null))
					O.show_message("CLANG", 2)
		if (istype(clong, /mob))
			if(clong.density || prob(10))
				clong.meteorhit(src)
		if(clong && prob(25))
			src.loc = clong.loc
		else del(src)

/proc/immovablerod()
	var/startx = 0
	var/starty = 0
	var/endy = 0
	var/endx = 0
	var/startside = pick(cardinal)

	switch(startside)
		if(NORTH)
			starty = 187
			startx = rand(41, 199)
			endy = 38
			endx = rand(41, 199)
		if(EAST)
			starty = rand(38, 187)
			startx = 199
			endy = rand(38, 187)
			endx = 41
		if(SOUTH)
			starty = 38
			startx = rand(41, 199)
			endy = 187
			endx = rand(41, 199)
		if(WEST)
			starty = rand(38, 187)
			startx = 41
			endy = rand(38, 187)
			endx = 199

	//rod time!
	var/obj/effect/immovablerod/immrod = new /obj/effect/immovablerod(locate(startx, starty, 1))
//	world << "Rod in play, starting at [start.loc.x],[start.loc.y] and going to [end.loc.x],[end.loc.y]"
	var/end = locate(endx, endy, 1)
	spawn(0)
		walk_towards(immrod, end,1)
	sleep(1)
	while (immrod)
		if (immrod.z != 1)
			immrod.z = 1
		if(immrod.loc == end)
			del(immrod)
		sleep(10)
	for(var/obj/effect/immovablerod/imm in world)
		return
	sleep(50)
	command_alert("What the fuck was that?!", "General Alert")