//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
Space dust
Commonish random event that causes small clumps of "space dust" to hit the station at high speeds.
No command report on the common version of this event.
The "dust" will damage the hull of the station causin minor hull breaches.
*/

/proc/dust_swarm(var/strength = "weak")
	var/numbers = 1
	switch(strength)
		if("weak")
		 numbers = rand(2,4)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/weak()
		if("norm")
		 numbers = rand(5,10)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust()
		if("strong")
		 numbers = rand(10,15)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/strong()
		if("super")
		 numbers = rand(15,25)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/super()
	return


/obj/effect/space_dust
	name = "Space Dust"
	desc = "Dust in space."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "space_dust"
	density = 1
	anchored = 1
	var/strength = 2 //ex_act severity number
	var/life = 2 //how many things we hit before del(src)

	weak
		strength = 3
		life = 1

	strong
		strength = 1
		life = 6

	super
		strength = 1
		life = 40


	New()
		var/startx = 0
		var/starty = 0
		var/endy = 0
		var/endx = 0
		var/startside = pick(cardinal)

		switch(startside)
			if(NORTH)
				starty = world.maxy-8
				startx = rand(8, world.maxx-8)
				endy = 8
				endx = rand(8, world.maxx-8)
			if(EAST)
				starty = rand(8,world.maxy-8)
				startx = world.maxx-8
				endy = rand(8, world.maxy-8)
				endx = 8
			if(SOUTH)
				starty = 8
				startx = rand(8, world.maxx-8)
				endy = world.maxy-8
				endx = rand(1, world.maxx-8)
			if(WEST)
				starty = rand(8, world.maxy-8)
				startx = 8
				endy = rand(8,world.maxy-8)
				endx = world.maxx-8
		var/goal = locate(endx, endy, 1)
		src.x = startx
		src.y = starty
		src.z = 1
		spawn(0)
			walk_towards(src, goal, 1)
		return


	Bump(atom/A)
		spawn(0)
			if(prob(50))
				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))
						shake_camera(M, 3, 1)
			if (A)
				playsound(src.loc, 'meteorimpact.ogg', 40, 1)
				if(ismob(A))
					A.meteorhit(src)//This should work for now I guess
				else
					A.ex_act(strength)
				life--
				if(life <= 0)
					walk(src,0)
					spawn(1)
						del(src)
					return 0
		return


	Bumped(atom/A)
		Bump(A)
		return


	ex_act(severity)
		del(src)
		return
