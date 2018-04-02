//troll closet


/obj/structure/closet/black_hole
	var/sucked = 0
	var/sucking = 0
	var/suck_speed = 4
	var/suck_time = 40
	var/obj/effect/closet_blackhole/blackhole = null
	var/suck_once = 0

/obj/structure/closet/black_hole/Destroy()
	if(blackhole)
		qdel(blackhole)
		blackhole = null
	return ..()

/obj/structure/closet/black_hole/can_close()
	if(sucking)
		return 0
	return ..()

/obj/structure/closet/black_hole/open()
	. = ..()
	if(. && !sucked && opened)
		spawn(0)
			suck_shit()

/obj/structure/closet/black_hole/close(var/everything = 0)
	. = ..()
	if(everything)
		for(var/atom/movable/AM in loc)
			if(AM == src)
				continue
			if(AM.anchored)
				continue
			AM.forceMove(src)
	if(.)
		if(blackhole)
			qdel(blackhole)
			blackhole = null
		if(sucked && !suck_once && !everything)
			sucked = 0

/obj/structure/closet/black_hole/proc/suck_shit()
	if(!opened)
		return
	sucking = 1
	anchored = 1
	var/speed = suck_speed
	if(speed <= 0)
		speed = 1
	if(blackhole)
		qdel(blackhole)
		blackhole = null
	blackhole = new(loc)
	blackhole.layer = layer + 0.1
	playsound(loc,'sound/effects/spray.ogg', 100, 1)
	loc.visible_message("<font color='red'><B>The [name] opens revealing a black hole that begins sucking everything in!</B></font>","<font color='red'><B>The [name] opens revealing a black hole that begins sucking everything in!</B></font>")
	var/list/moved_items = list()
	var/suckingticktime = round(suck_time/speed,1)
	var/list/ignore_atom = list()
	while(opened && sucking)
		sleep(speed)
		moved_items = list()
		if(suckingticktime <= 0)
			break
		suckingticktime--
		for(var/atom/movable/AM in range(world.view,src))
			if(AM in ignore_atom)
				continue
			if(istype(AM,/obj/structure/closet))
				continue
			if(AM.anchored)
				continue
			if(!istype(AM,/mob) && AM.density)
				continue
			if(!check_los(AM))
				continue
			if(get_turf(src) == get_turf(AM))
				continue
			if(istype(AM,/mob/living))
				var/mob/living/L = AM
				L.SetKnockdown(50)
				L.canmove = 0
				L.update_canmove()
			moved_items += AM
			spawn(0)
				var/turf/T = AM.loc
				step_towards(AM,get_turf(src))
				sleep(4)
				if(AM.loc == T)
					ignore_atom += AM
		if(!moved_items.len)
			break
	sucking = 0
	sucked = 1
	anchored = 0
	if(blackhole)
		qdel(blackhole)
		blackhole = null
	if(close(1))
		welded = 1
		update_icon()
		animate_weld()

/obj/structure/closet/black_hole/proc/check_los(atom/movable/AM)
	var/turf/start = get_turf(src)
	var/turf/end = get_turf(AM)
	if(start == end)
		return 1
	if(!start||!end)
		return 0
	var/turf/current = start
	var/maxrange = 8
	while(current != end)
		var/turf/nextstep = get_step_towards(current,end)
		if(!nextstep.Adjacent(current))
			break
		if(nextstep.density)
			break
		var/blockage = 0
		for(var/obj/O in nextstep)
			if(!O.CanAtmosPass())
				blockage = 1
				break
		if(blockage)
			break
		current = nextstep
		maxrange--
		if(maxrange <= 0)
			return 0
	if(current == end)
		return 1
	return 0

/obj/structure/closet/black_hole/proc/animate_weld()
	spawn(0)
		sleep(5)
		var/turf/srcturf = get_turf(src)
		var/list/imaged_clients = list()
		var/icon/weldericon = icon('icons/obj/tools.dmi',"welder")
		var/icon/welderpercent = icon('icons/obj/tools.dmi',"welder100")
		var/icon/welderflame = icon('icons/obj/tools.dmi',"welder-on")
		weldericon.Flip(WEST)
		welderpercent.Flip(WEST)
		welderflame.Flip(WEST)
		var/image/I = image(weldericon,src,"welder",layer+0.1)
		var/image/O1 = image(welderpercent,null,"welder100")
		var/image/O2 = image(welderflame,null,"welder-on")
		I.overlays += O1
		I.overlays += O2
		I.pixel_x = 22
		I.pixel_y = -8
		playsound(loc,'sound/items/Welder2.ogg', 100, 1)
		src.visible_message("<font color='red'>A floating welding tool seals the [name].</font>","<font color='red'>A floating welding tool seals the [name].</font>","<span class='italics'>You hear welding.</span>")
		for(var/mob/M in world)
			if(!M.client)
				continue
			var/turf/Mturf = get_turf(M)
			if(!Mturf)
				continue
			if(get_dist(srcturf,Mturf) > 7)
				continue
			M.client.images += I
			imaged_clients += M.client
		sleep(1)
		for(var/T=15,T>0,T--)
			I.pixel_y++
			sleep(1)
		for(var/client/C in imaged_clients)
			C.images -= I
		del(I)
		var/turf/welderturf = loc
		var/turf/sidestep = get_step(src,EAST)
		if(sidestep)
			welderturf = sidestep
		var/obj/item/weldingtool/welder = new()
		welder.layer = layer+0.1
		welder.loc = welderturf

/obj/effect/closet_blackhole
	name = "black hole"
	desc = null
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	density = 0
	anchored = 1
	mouse_opacity = 0
	ex_act()
		return

//alternatives
/obj/structure/closet/black_hole/opened
	New()
		. = ..()
		open()

/obj/structure/closet/black_hole/suck_once
	suck_once = 1

/obj/structure/closet/black_hole/suck_once/opened
	New()
		. = ..()
		open()