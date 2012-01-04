// SPACE VINE OR KUDZU

/obj/effect/spacevine
	name = "Space Kudzu"
	desc = "An extremely expansionistic species of vine."
	icon = 'kudzu.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	var/energy = 0		//Energy sounds like an arbitrary-enough variable name.
	var/obj/effect/spacevine_controller/master = null

	New()
		if(istype(src.loc, /turf/space))
			del(src)
			return

	Del()
		if(master)
			master.vines -= src
			master.growth_queue -= src
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (!W) return
		if (!user) return
		if (istype(W, /obj/item/weapon/circular_saw)) del src
		if (istype(W, /obj/item/weapon/kitchen/utensil/knife)) del src
		if (istype(W, /obj/item/weapon/scalpel)) del src
		if (istype(W, /obj/item/weapon/screwdriver)) del src
		if (istype(W, /obj/item/weapon/shard)) del src
		if (istype(W, /obj/item/weapon/weldingtool)) del src
		if (istype(W, /obj/item/weapon/wirecutters)) del src
		..()

/obj/effect/spacevine_controller
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the kudzu's size to something less than 20 plots, it won't grow anymore.

	New()
		if(!istype(src.loc,/turf/simulated/floor))
			del(src)

		spawn_kudzu_piece(src.loc)
		processing_objects.Add(src)

	Del()
		processing_objects.Remove(src)
		..()

	proc/spawn_kudzu_piece(var/turf/location)
		var/obj/effect/spacevine/SV = new(location)
		growth_queue += SV
		vines += SV
		SV.master = src

	process()
		if(!vines)
			del(src) //Kudzu exterminated
			return
		if(!growth_queue)
			del(src) //Sanity check
			return
		if(vines.len >= 250 && !reached_collapse_size)
			reached_collapse_size = 1
		if(vines.len >= 30 && !reached_slowdown_size )
			reached_slowdown_size = 1

		var/length = 0
		if(reached_collapse_size)
			length = 0
		else if(reached_slowdown_size)
			if(prob(25))
				length = 1
			else
				length = 0
		else
			length = 1
		length = min( 30 , max( length , vines.len / 5 ) )
		var/i = 0
		var/list/obj/effect/spacevine/queue_end = list()

		for( var/obj/effect/spacevine/SV in growth_queue )
			i++
			queue_end += SV
			growth_queue -= SV
			if(SV.energy < 2)
				if(prob(10))
					SV.grow()
			//if(prob(25))
			SV.spread()
			if(i >= length)
				break

		growth_queue = growth_queue + queue_end

		//sleep(5)
		//src.process()

/obj/effect/spacevine/proc/grow()
	switch(energy)
		if (0)
			src.icon_state = pick("Med1", "Med2", "Med3")
			energy = 1
			src.opacity = 1
		if (1)
			src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
			energy = 2
			src.density = 1

/obj/effect/spacevine/proc/spread()
	var/direction = pick(cardinal)
	if(istype(get_step(src,direction),/turf/simulated/floor))
		var/turf/simulated/floor/F = get_step(src,direction)
		if(!locate(/obj/effect/spacevine,F))
			if(F.Enter(src))
				if(master)
					master.spawn_kudzu_piece( F )


/*
/obj/effect/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
	for(var/obj/O in Vspread)
		if (istype(O, /obj/structure/window) || istype(O, /obj/effect/forcefield) || istype(O, /obj/effect/blob) || istype(O, /obj/effect/alien/weeds) || istype(O, /obj/effect/spacevine)) dogrowth = 0
		if (istype(O, /obj/machinery/door/))
			if(O:p_open == 0 && prob(50)) O:open()
			else dogrowth = 0
	if (dogrowth == 1)
		var/obj/effect/spacevine/B = new /obj/effect/spacevine(Vspread)
		B.icon_state = pick("vine-light1", "vine-light2", "vine-light3")
		spawn(20)
			if(B)
				B.Life()
	src.growth += 1
	if (src.growth == 10)
		src.name = "Thick Space Kudzu"
		src.icon_state = pick("vine-med1", "vine-med2", "vine-med3")
		src.opacity = 1
		src.waittime = 80
	if (src.growth == 20)
		src.name = "Dense Space Kudzu"
		src.icon_state = pick("vine-hvy1", "vine-hvy2", "vine-hvy3")
		src.density = 1
	spawn(src.waittime)
		if (src.growth < 20) src.Life()

*/

/obj/effect/spacevine/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(90))
				del(src)
				return
		if(3.0)
			if (prob(50))
				del(src)
				return
		else
	return

/obj/effect/spacevine/temperature_expose(null, temp, volume)
	del src