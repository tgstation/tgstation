/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures.dmi'
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
//	var/silicate = 0 // number of units of silicate
//	var/icon/silicateIcon = null // the silicated icon


/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		new /obj/item/weapon/shard(loc)
		new /obj/item/stack/rods(loc)
		del(src)
	return


/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			new /obj/item/weapon/shard(loc)
			if(reinf) new /obj/item/stack/rods(loc)
			del(src)
			return
		if(3.0)
			if(prob(50))
				new /obj/item/weapon/shard(loc)
				if(reinf) new /obj/item/stack/rods(loc)
				del(src)
				return


/obj/structure/window/blob_act()
	new /obj/item/weapon/shard(loc)
	if(reinf) new /obj/item/stack/rods(loc)
	del(src)


/obj/structure/window/meteorhit()
	//world << "glass at [x],[y],[z] Mhit"
	new /obj/item/weapon/shard( loc )
	if(reinf) new /obj/item/stack/rods( loc)
	del(src)


/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1


/obj/structure/window/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	health = max(0, health - tforce)
	if(health <= 7 && !reinf)
		anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
	if(health <= 0)
		new /obj/item/weapon/shard(loc)
		if(reinf) new /obj/item/stack/rods(loc)
		del(src)

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, 'sound/effects/Glasshit.ogg', 50, 1)

/obj/structure/window/attack_hand(mob/user as mob)
	if(!can_be_reached(user))
		return
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		new /obj/item/weapon/shard(loc)
		if(reinf) new /obj/item/stack/rods(loc)
		del(src)
	else
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 50, 1)


/obj/structure/window/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/structure/window/proc/attack_generic(mob/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	health -= damage
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		new /obj/item/weapon/shard(loc)
		if(reinf) new /obj/item/stack/rods(loc)
		del(src)
	else	//for nicer text~
		user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)


/obj/structure/window/attack_alien(mob/user as mob)
	if(islarva(user)) return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	attack_generic(M, M.melee_damage_upper)


/obj/structure/window/attack_slime(mob/user as mob)
	if(!isslimeadult(user)) return
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/I, mob/user)
	if(!can_be_reached(user))
		return 1 //returning 1 will skip the afterattack()
	if(istype(I, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>")
		else if(reinf && state == 0)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>")
		else if(!reinf)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>")
	else if(istype(I, /obj/item/weapon/crowbar) && reinf && state <= 1)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		user << (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>")
	else if(istype(I, /obj/item/weapon/wrench) && !anchored)
		var/glass_type
		if(reinf)
			glass_type = /obj/item/stack/sheet/rglass
		else
			glass_type = /obj/item/stack/sheet/glass
		new glass_type(user.loc)
		if(is_fulltile())//fulltiles drop two panes
			new glass_type(user.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		src.Del(1)
	else
		if(I.damtype == BRUTE || I.damtype == BURN)
			hit(I.force)
			if(health <= 7)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
		else
			playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()
	return

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!is_fulltile())
		if(get_dir(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1, 0))
					return 0
	return 1

/obj/structure/window/proc/hit(var/damage, var/sound_effect = 1)
	if(reinf) damage *= 0.5
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		if(dir == SOUTHWEST)
			var/index = null
			index = 0
			while(index < 2)
				new /obj/item/weapon/shard(loc)
				if(reinf) new /obj/item/stack/rods(loc)
				index++
		else
			new /obj/item/weapon/shard(loc)
			if(reinf) new /obj/item/stack/rods(loc)
		del(src)
		return


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		usr << "It is fastened to the floor therefore you can't rotate it!"
		return 0

	dir = turn(dir, 90)
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	return


/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		usr << "It is fastened to the floor therefore you can't rotate it!"
		return 0

	dir = turn(dir, 270)
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	return


/*
/obj/structure/window/proc/updateSilicate()
	if(silicateIcon && silicate)
		icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I
*/


/obj/structure/window/New(Loc,re=0)
	..()

	if(re)	reinf = re

	ini_dir = dir
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

	air_update_turf(1)
	update_nearby_icons()

	return


/obj/structure/window/Del(quiet)
	density = 0
	air_update_turf(1)
	if(!quiet)playsound(src, "shatter", 70, 1)
	update_nearby_icons()
	loc = null //garbage collect


/obj/structure/window/Move()
	air_update_turf(1)
	..()
	dir = ini_dir
	air_update_turf(1)

/obj/structure/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return !density
	return 1

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir in list(5,6,9,10))
		return 1
	return 0

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
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
		if(!is_fulltile())
			return
		var/junction = 0 //will be used to determine from which side the window is connected to other windows
		if(anchored)
			for(var/obj/structure/window/W in orange(src,1))
				if(W.anchored && W.density	&& W.is_fulltile()) //Only counts anchored, not-destroyed fill-tile windows.
					if(abs(x-W.x)-abs(y-W.y) ) 		//doesn't count windows, placed diagonally to src
						junction |= get_dir(src,W)
		if(opacity)
			icon_state = "twindow[junction]"
		else
			if(reinf)
				icon_state = "rwindow[junction]"
			else
				icon_state = "window[junction]"

		return

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		hit(round(exposed_volume / 100), 0)
	..()



/obj/structure/window/basic
	icon_state = "window"

/obj/structure/window/reinforced
	name = "reinforced window"
	icon_state = "rwindow"
	reinf = 1

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"
