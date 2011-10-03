/*
CONTAINS:
TABLE AND RACK OBJECT INTERATIONS
*/


//TABLE
/obj/station_objects/table/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return


/obj/station_objects/table/blob_act()
	if(prob(75))
		if(istype(src, /obj/station_objects/table/woodentable))
			new /obj/item/weapon/table_parts/wood( src.loc )
			del(src)
			return
		new /obj/item/weapon/table_parts( src.loc )
		del(src)
		return


/obj/station_objects/table/hand_p(mob/user as mob)
	return src.attack_paw(user)
	return


/obj/station_objects/table/attack_paw(mob/user as mob)
	if ((usr.mutations & HULK))
		usr << text("\blue You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes the table apart!", usr)
		if(istype(src, /obj/station_objects/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced( src.loc )
		else if(istype(src, /obj/station_objects/table/woodentable))
			new/obj/item/weapon/table_parts/wood( src.loc )
		else
			new /obj/item/weapon/table_parts( src.loc )
		src.density = 0
		del(src)
	if (!( locate(/obj/station_objects/table, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << text("[] hides under the table!", user)
				//Foreach goto(69)
	return


/obj/station_objects/table/attack_alien(mob/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	usr << text("\green You destroy the table.")
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << text("\red [] slices the table apart!", user)
	if(istype(src, /obj/station_objects/table/reinforced))
		new /obj/item/weapon/table_parts/reinforced( src.loc )
	else if(istype(src, /obj/station_objects/table/woodentable))
		new/obj/item/weapon/table_parts/wood( src.loc )
	else
		new /obj/item/weapon/table_parts( src.loc )
	src.density = 0
	del(src)
	return


/obj/station_objects/table/attack_hand(mob/user as mob)
	if ((usr.mutations & HULK))
		usr << text("\blue You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes the table apart!", usr)
		if(istype(src, /obj/station_objects/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced( src.loc )
		else if(istype(src, /obj/station_objects/table/woodentable))
			new/obj/item/weapon/table_parts/wood( src.loc )
		else
			new /obj/item/weapon/table_parts( src.loc )
		src.density = 0
		del(src)
	return


/obj/station_objects/table/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/station_objects/table/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return


/obj/station_objects/table/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.weakened = 5
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << text("\red [] puts [] on the table.", G.assailant, G.affecting)
		del(W)
		return

	if (istype(W, /obj/item/weapon/wrench))
		user << "\blue Now disassembling table"
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		sleep(50)
		new /obj/item/weapon/table_parts( src.loc )
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		//SN src = null
		del(src)
		return

	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The table was sliced apart by []!", user), 1, text("\red You hear metal coming apart."), 2)
		new /obj/item/weapon/table_parts( src.loc )
		del(src)
		return

	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return


//WOODEN TABLES
/obj/station_objects/table/woodentable/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.weakened = 5
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << text("\red [] puts [] on the wooden table.", G.assailant, G.affecting)
		del(W)
		return
	if (istype(W, /obj/item/weapon/wrench))
		user << "\blue Now disassembling the wooden table"
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		sleep(50)
		new /obj/item/weapon/table_parts/wood( src.loc )
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		del(src)
		return
	if(isrobot(user))
		return
	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The wooden table was sliced apart by []!", user), 1, text("\red You hear wood coming apart."), 2)
		new /obj/item/weapon/table_parts/wood( src.loc )
		del(src)
		return

	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return


//REINFORCED TABLES
/obj/station_objects/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.weakened = 5
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << text("\red [] puts [] on the reinforced table.", G.assailant, G.affecting)
		del(W)
		return

	if (istype(W, /obj/item/weapon/weldingtool))
		if(W:welding == 1)
			if(src.status == 2)
				W:welding = 2
				user << "\blue Now weakening the reinforced table"
				playsound(src.loc, 'Welder.ogg', 50, 1)
				sleep(50)
				user << "\blue Table weakened"
				src.status = 1
				W:welding = 1
			else
				W:welding = 2
				user << "\blue Now strengthening the reinforced table"
				playsound(src.loc, 'Welder.ogg', 50, 1)
				sleep(50)
				user << "\blue Table strengthened"
				src.status = 2
				W:welding = 1
			return
		if(isrobot(user))
			return
		user.drop_item()
		if(W && W.loc)	W.loc = src.loc
		return

	if (istype(W, /obj/item/weapon/wrench))
		if(src.status == 1)
			user << "\blue Now disassembling the reinforced table"
			playsound(src.loc, 'Ratchet.ogg', 50, 1)
			sleep(50)
			new /obj/item/weapon/table_parts/reinforced( src.loc )
			playsound(src.loc, 'Deconstruct.ogg', 50, 1)
			del(src)
			return
	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The reinforced table was sliced apart by []!", user), 1, text("\red You hear metal coming apart."), 2)
		new /obj/item/weapon/table_parts/reinforced( src.loc )
		del(src)
		return

	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return

//RACKS

/obj/station_objects/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.icon_state = "rackbroken"
				src.density = 0
		else
	return

/obj/station_objects/rack/blob_act()
	if(prob(75))
		del(src)
		return
	else if(prob(50))
		src.icon_state = "rackbroken"
		src.density = 0
		return

/obj/station_objects/rack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/station_objects/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/station_objects/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/rack_parts( src.loc )
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		//SN src = null
		del(src)
		return
	if(isrobot(user))
		return
	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return

/obj/station_objects/rack/meteorhit(obj/O as obj)
	if(prob(75))
		del(src)
		return
	else
		src.icon_state = "rackbroken"
		src.density = 0
	return