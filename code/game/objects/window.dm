/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <=0)
		new /obj/item/weapon/shard( src.loc )
		new /obj/item/stack/rods( src.loc )
		src.density = 0
		del(src)
	return

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			new /obj/item/weapon/shard( src.loc )
			if(reinf) new /obj/item/stack/rods( src.loc)
			//SN src = null
			del(src)
			return
		if(3.0)
			if (prob(50))
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/stack/rods( src.loc)

				del(src)
				return
	return

/obj/structure/window/blob_act()
	if(reinf) new /obj/item/stack/rods( src.loc)
	density = 0
	del(src)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST)
		return 0 //full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if (get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/meteorhit()

	//*****RM
	//world << "glass at [x],[y],[z] Mhit"
	src.health = 0
	new /obj/item/weapon/shard( src.loc )
	if(reinf) new /obj/item/stack/rods( src.loc)
	src.density = 0


	del(src)
	return


/obj/structure/window/hitby(AM as mob|obj)

	..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src] was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	if(reinf) tforce /= 4.0
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health = max(0, src.health - tforce)
	if (src.health <= 7 && !reinf)
		src.anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
	if (src.health <= 0)
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
		return
	..()
	return

//These all need to be rewritten to use visiblemessage()

/obj/structure/window/attack_hand()
	if ((usr.mutations & HULK))
		usr << "\blue You smash through the window."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [usr] smashes through the window!"
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
		return
	else
		playsound(src.loc, 'Glassknock.ogg', 80, 1)
		usr.visible_message("[usr.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")
		return


/obj/structure/window/attack_paw()
	if ((usr.mutations & HULK))
		usr << "\blue You smash through the window."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [usr] smashes through the window!"
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/stack/rods( src.loc)
		src.density = 0
		del(src)
	return

/obj/structure/window/attack_alien()
	if (istype(usr, /mob/living/carbon/alien/larva))//Safety check for larva. /N
		return
	usr << "\green You smash against the window."
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << "\red [usr] smashes against the window."
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health -= 15
	if(src.health <= 0)
		usr << "\green You smash through the window."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [usr] smashes through the window!"
		src.health = 0
		new /obj/item/weapon/shard(src.loc)
		if(reinf)
			new /obj/item/stack/rods(src.loc)
		src.density = 0
		del(src)
		return
	return


/obj/structure/window/attack_animal(mob/living/simple_animal/M as mob)
	if (M.melee_damage_upper == 0)
		return
	M << "\green You smash against the window."
	for(var/mob/O in viewers(src, null))
		if ((O.client && !( O.blinded )))
			O << "\red [M] smashes against the window."
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health -= M.melee_damage_upper
	if(src.health <= 0)
		M << "\green You smash through the window."
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << "\red [M] smashes through the window!"
		src.health = 0
		new /obj/item/weapon/shard(src.loc)
		if(reinf)
			new /obj/item/stack/rods(src.loc)
		src.density = 0
		del(src)
		return
	return

/obj/structure/window/attack_metroid()
	if(!istype(usr, /mob/living/carbon/metroid/adult))
		return

	usr<< "\green You smash against the window."
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << "\red [usr] smashes against the window."
	playsound(src.loc, 'Glasshit.ogg', 100, 1)
	src.health -= rand(10,15)
	if(src.health <= 0)
		usr << "\green You smash through the window."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [usr] smashes through the window!"
		src.health = 0
		new /obj/item/weapon/shard(src.loc)
		if(reinf)
			new /obj/item/stack/rods(src.loc)
		src.density = 0
		del(src)
		return
	return

/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			usr << ( state==1? "You have unfastened the window from the frame." : "You have fastened the window to the frame." )
		else if(reinf && state == 0)
			anchored = !anchored
			update_nearby_icons()
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the frame to the floor." : "You have unfastened the frame from the floor.")
		else if(!reinf)
			src.anchored = !( src.anchored )
			update_nearby_icons()
			playsound(src.loc, 'Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
	else if(istype(W, /obj/item/weapon/crowbar) && reinf && state <=1)
		state = 1-state;
		playsound(src.loc, 'Crowbar.ogg', 75, 1)
		user << (state ? "You have pried the window into the frame." : "You have pried the window out of the frame.")
	else

		var/aforce = W.force
		if(reinf) aforce /= 2.0
		if(W.damtype == BRUTE || W.damtype == BURN)
			src.health = max(0, src.health - aforce)
		playsound(src.loc, 'Glasshit.ogg', 75, 1)
		if (src.health <= 7)
			src.anchored = 0
			update_nearby_icons()
			step(src, get_dir(user, src))
		if (src.health <= 0)
			if (src.dir == SOUTHWEST)
				var/index = null
				index = 0
				while(index < 2)
					new /obj/item/weapon/shard( src.loc )
					if(reinf) new /obj/item/stack/rods( src.loc)
					index++
			else
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/stack/rods( src.loc)
			src.density = 0
			del(src)
			return
		..()
	return


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.dir = turn(src.dir, 90)

	updateSilicate()

	update_nearby_tiles(need_rebuild=1)

	src.ini_dir = src.dir
	return

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.dir = turn(src.dir, 270)

	updateSilicate()

	update_nearby_tiles(need_rebuild=1)

	src.ini_dir = src.dir
	return

/obj/structure/window/proc/updateSilicate()
	if(silicateIcon && silicate)
		src.icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I

/obj/structure/window/New(Loc,re=0)
	..()

	if(re)	reinf = re

	src.ini_dir = src.dir
	if(reinf)
		icon_state = "rwindow"
		desc = "A reinforced window."
		name = "reinforced window"
		state = 2*anchored
		health = 40
		if(opacity)
			icon_state = "twindow"
	else
		icon_state = "window"

	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()

	return

/obj/structure/window/Del()
	density = 0

	update_nearby_tiles()

	playsound(src, "shatter", 70, 1)

	update_nearby_icons()

	..()

/obj/structure/window/Move()
	update_nearby_tiles(need_rebuild=1)

	..()

	src.dir = src.ini_dir
	update_nearby_tiles(need_rebuild=1)

	return

//This proc has to do with airgroups and atmos, it has nothing to do with smoothwindows, that's update_nearby_tiles().
/obj/structure/window/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/target = get_step(source,dir)

	if(istype(source)) air_master.tiles_to_update += source
	if(istype(target)) air_master.tiles_to_update += target

	return 1

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir in list(5,6,9,10))
		return 1
	return 0

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	src.update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src,direction) )
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src) return
		if (!is_fulltile())
			return
		var/junction = 0 //will be used to determine from which side the window is connected to other windows
		if (src.anchored)
			for(var/obj/structure/window/W in orange(src,1))
				if (W.anchored && W.density	&& W.is_fulltile()) //Only counts anchored, not-destroyed fill-tile windows.
					if (abs(src.x-W.x)-abs(src.y-W.y) ) 		//doesn't count windows, placed diagonally to src
						junction |= get_dir(src,W)
		if (opacity)
			src.icon_state = "twindow[junction]"
		else
			if (reinf)
				src.icon_state = "rwindow[junction]"
			else
				src.icon_state = "window[junction]"

		return
