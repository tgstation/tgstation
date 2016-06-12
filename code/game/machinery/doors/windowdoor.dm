/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 150 //If you change this, consider changing ../door/window/brigdoor/ health at the bottom of this .dm file
	visible = 0
	flags = ON_BORDER
	opacity = 0
	var/obj/item/weapon/electronics/airlock/electronics = null
	var/reinf = 0
	var/shards = 2
	var/rods = 2
	var/cable = 2
	var/list/debris = list()

/obj/machinery/door/window/New(loc, set_dir)
	..()
	if(set_dir)
		setDir(set_dir)
	if(src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	for(var/i in 1 to shards)
		debris += new /obj/item/weapon/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)
	if(cable)
		debris += new /obj/item/stack/cable_coil(src, cable)

/obj/machinery/door/window/Destroy()
	density = 0
	for(var/I in debris)
		qdel(I)
	if(health == 0)
		playsound(src, "shatter", 70, 1)
	electronics = null
	return ..()

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[src.base_state]open"

/obj/machinery/door/window/proc/open_and_close()
	open()
	if(src.check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if( operating || !src.density )
		return
	if (!( ismob(AM) ))
		if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && src.allowed(mecha.occupant))
				open_and_close()
			else
				do_animate("deny")
		return
	if (!( ticker ))
		return
	var/mob/M = AM
	if(!M.restrained())
		bumpopen(M)
	return

/obj/machinery/door/window/bumpopen(mob/user)
	if( operating || !src.density )
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(obj/item/weapon/card/id/ID, to_dir)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(forced=0)
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if(!ticker || !ticker.mode)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	do_animate("opening")
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state ="[src.base_state]open"
	sleep(10)

	src.density = 0
//	src.sd_SetOpacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/window/close(forced=0)
	if (src.operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	src.operating = 1
	do_animate("closing")
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = src.base_state

	src.density = 1
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	src.operating = 0
	return 1

/obj/machinery/door/window/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health = max(0, src.health - damage)
	if(health <= 0)
		shatter()

/obj/machinery/door/window/proc/shatter()
	if(!(flags & NODECONSTRUCT))
		for(var/obj/fragment in debris)
			fragment.forceMove(get_turf(src))
			transfer_fingerprints_to(fragment)
			debris -= fragment
	qdel(src)

/obj/machinery/door/window/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(25))
				shatter()
			else
				take_damage(120, BRUTE, 0)
		if(3)
			take_damage(60, BRUTE, 0)

/obj/machinery/door/window/narsie_act()
	color = "#7D1919"

/obj/machinery/door/window/ratvar_act()
	if(prob(20))
		new/obj/machinery/door/window/clockwork(src.loc, dir)
		qdel(src)

/obj/machinery/door/window/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(round(P.damage / 2), P.damage_type, 0)

/obj/machinery/door/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 200), BURN, 0)
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(atom/movable/AM)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/O = AM
		tforce = O.throwforce
	take_damage(tforce)



/obj/machinery/door/window/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/door/window/emag_act(mob/user)
	if(!operating && density && !emagged)
		operating = 1
		flick("[src.base_state]spark", src)
		sleep(6)
		operating = 0
		desc += "<BR><span class='warning'>Its access panel is smoking slightly.</span>"
		open()
		emagged = 1

/obj/machinery/door/window/attackby(obj/item/weapon/I, mob/living/user, params)

	if(operating)
		return

	add_fingerprint(user)
	if(!(flags&NODECONSTRUCT))
		if(istype(I, /obj/item/weapon/screwdriver))
			if(density || operating)
				user << "<span class='warning'>You need to open the door to access the maintenance panel!</span>"
				return
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			panel_open = !panel_open
			user << "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the [src.name].</span>"
			return

		if(istype(I, /obj/item/weapon/crowbar))
			if(panel_open && !density && !operating)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
				user.visible_message("[user] removes the electronics from the [src.name].", \
									 "<span class='notice'>You start to remove electronics from the [src.name]...</span>")
				if(do_after(user,40/I.toolspeed, target = src))
					if(panel_open && !density && !operating && src.loc)
						var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(src.loc)
						switch(base_state)
							if("left")
								WA.facing = "l"
							if("right")
								WA.facing = "r"
							if("leftsecure")
								WA.facing = "l"
								WA.secure = 1
							if("rightsecure")
								WA.facing = "r"
								WA.secure = 1
						WA.anchored = 1
						WA.state= "02"
						WA.setDir(src.dir)
						WA.ini_dir = src.dir
						WA.update_icon()
						WA.created_name = src.name

						if(emagged)
							user << "<span class='warning'>You discard the damaged electronics.</span>"
							qdel(src)
							return

						user << "<span class='notice'>You remove the airlock electronics.</span>"

						var/obj/item/weapon/electronics/airlock/ae
						if(!electronics)
							ae = new/obj/item/weapon/electronics/airlock( src.loc )
							if(req_one_access)
								ae.one_access = 1
								ae.accesses = src.req_one_access
							else
								ae.accesses = src.req_access
						else
							ae = electronics
							electronics = null
							ae.loc = src.loc

						qdel(src)
				return
	return ..()

/obj/machinery/door/window/try_to_crowbar(obj/item/I, mob/user)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		user << "<span class='warning'>The door's motors resist your efforts to force it!</span>"

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[src.base_state]opening", src)
		if("closing")
			flick("[src.base_state]closing", src)
		if("deny")
			flick("[src.base_state]deny", src)

/obj/machinery/door/window/attack_hulk(mob/user)
	..(user, 1)
	user.visible_message("<span class='danger'>[user] smashes through the windoor!</span>", \
						"<span class='danger'>You tear through the windoor!</span>")
	user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
	take_damage(health)


/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	health = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1

/obj/machinery/door/window/clockwork
	name = "clockwork door"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0

/obj/machinery/door/window/clockwork/New(loc, set_dir)
	..()
	var/obj/effect/E = PoolOrNew(/obj/effect/overlay/temp/ratvar/door/window, get_turf(src))
	if(set_dir)
		E.setDir(set_dir)
	debris += new/obj/item/clockwork/component/vanguard_cogwheel(src)

/obj/machinery/door/window/clockwork/ratvar_act()
	health = initial(health)

/obj/machinery/door/window/clockwork/hasPower()
	return TRUE //yup that's power all right

/obj/machinery/door/window/clockwork/narsie_act()
	take_damage(rand(30, 60), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/window/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
