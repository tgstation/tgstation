/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. Hooked up with an anti-theft system."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			if (occupied)
				new /obj/item/weapon/gun/energy/laser/captain( src.loc )
				occupied = 0
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		if (occupied)
			new /obj/item/weapon/gun/energy/laser/captain( src.loc )
			occupied = 0
		qdel(src)


/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			update_icon()

			//Activate Anti-theft
			if(isinspace()) //No alarms lights in space
				return

			//Trigger alarm effect
			var/area/alarmed_area = get_area(loc)
			var/RAcontents = area_contents(alarmed_area)
			for(var/area/related_areas in alarmed_area.related)
				related_areas.fire = 1
				related_areas.updateicon()
				related_areas.mouse_opacity = 0

				//Lockdown airlocks
				for(var/obj/machinery/door/airlock/DOOR in RAcontents)
					DOOR.close()
					if(DOOR.density)
						DOOR.locked = 1
						DOOR.update_icon()

			//Alert silicons
			var/list/cameras = list()
			for (var/obj/machinery/camera/C in RAcontents)
				cameras += C
			for (var/mob/living/silicon/SILICON in player_list)
				SILICON.triggerAlarm("Burglar", alarmed_area, cameras, src)

	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return


/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	if (src.destroyed && src.occupied)
		new /obj/item/weapon/gun/energy/laser/captain( src.loc )
		user << "\b You deactivate the hover field built into the case."
		src.occupied = 0
		src.add_fingerprint(user)
		update_icon()
		return
	else
		usr << text("\blue You kick the display case.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the display case.", usr)
		src.health -= 2
		healthcheck()
		return


