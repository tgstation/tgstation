/*
CONTAINS:
TABLE AND RACK OBJECT INTERATIONS
*/


//TABLE
/obj/structure/table/ex_act(severity)
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


/obj/structure/table/blob_act()
	if(prob(75))
		if(istype(src, /obj/structure/table/woodentable))
			new /obj/item/weapon/table_parts/wood( src.loc )
			del(src)
			return
		new /obj/item/weapon/table_parts( src.loc )
		del(src)
		return


/obj/structure/table/hand_p(mob/user as mob)
	return src.attack_paw(user)
	return


/obj/structure/table/attack_paw(mob/user as mob)
	if ((usr.mutations & HULK))
		usr << text("\blue You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes the table apart!", usr)
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced( src.loc )
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood( src.loc )
		else
			new /obj/item/weapon/table_parts( src.loc )
		src.density = 0
		del(src)
	if (!( locate(/obj/structure/table, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << text("[] hides under the table!", user)
				//Foreach goto(69)
	return


/obj/structure/table/attack_alien(mob/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	usr << text("\green You destroy the table.")
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << text("\red [] slices the table apart!", user)
	if(istype(src, /obj/structure/table/reinforced))
		new /obj/item/weapon/table_parts/reinforced( src.loc )
	else if(istype(src, /obj/structure/table/woodentable))
		new/obj/item/weapon/table_parts/wood( src.loc )
	else
		new /obj/item/weapon/table_parts( src.loc )
	src.density = 0
	del(src)
	return


/obj/structure/table/attack_animal(mob/living/simple_animal/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	if(user.wall_smash)
		usr << text("\red You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes the table apart!", user)
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced( src.loc )
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood( src.loc )
		else
			new /obj/item/weapon/table_parts( src.loc )
		src.density = 0
		del(src)
	return




/obj/structure/table/attack_hand(mob/user as mob)
	if (usr.mutations & HULK)
		usr << text("\blue You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes the table apart!", usr)
		if(istype(src, /obj/structure/table/reinforced))
			new /obj/item/weapon/table_parts/reinforced( src.loc )
		else if(istype(src, /obj/structure/table/woodentable))
			new/obj/item/weapon/table_parts/wood( src.loc )
		else
			new /obj/item/weapon/table_parts( src.loc )
		src.density = 0
		del(src)
	return


/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && (mover.pass_flags & PASSTABLE || (mover.flags & TABLEPASS) || mover.throwing)) //WTF do things hit tables like that?  Jeez.
		return 1
	else
		return 0


/obj/structure/table/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return


/obj/structure/table/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			if(ishuman(G.affecting))
				G.affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been smashed on a table by [G.assailant.name] ([G.assailant.ckey])</font>")
				G.assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Smashed [G.affecting.name] ([G.affecting.ckey]) on a table.</font>")

				log_admin("ATTACK: [G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.")
				message_admins("ATTACK: [G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.")
				log_attack("<font color='red'>[G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.</font>")

				var/mob/living/carbon/human/H = G.affecting
				var/datum/organ/external/affecting = H.get_organ("head")
				if(prob(25))
					add_blood(G.affecting)
					affecting.take_damage(rand(10,15), 0)
					H.Weaken(2)
					if(prob(20)) // One chance in 20 to DENT THE TABLE
						affecting.take_damage(rand(0,5), 0) //Extra damage
						if(dented)
							G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] with enough force to further deform \the [src]!\nYou wish you could unhear that sound.",\
							"\red You smash \the [H]'s head on \the [src] with enough force to leave another dent!\n[prob(50)?"That was a satisfying noise." : "That sound will haunt your nightmares"]",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal and the squeal of said metal deforming.")
						else
							dented = 1
							G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] so hard it left a dent!\nYou wish you could unhear that sound.",\
							"\red You smash \the [H]'s head on \the [src] with enough force to leave a dent!\n[prob(5)?"That was a satisfying noise." : "That sound will haunt your nightmares"]",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal and the squeal of said metal deforming.")
					else if(prob(50))
						G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] bone and cartilage making a loud crunch!",\
						"\red You smash \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] bone and cartilage making a loud crunch!",\
						"\red You hear the nauseating crunch of bone and gristle on solid metal, the noise echoing through the room.")
					else
						G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] nose smashed and face bloodied!",\
						"\red You smash \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] nose smashed and face bloodied!",\
						"\red You hear the nauseating crunch of bone and gristle on solid metal and the gurgling gasp of someone who is trying to breathe through their own blood.")
				else
					affecting.take_damage(rand(5,10), 0)
					G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src]!",\
					"\red You smash \the [H]'s head on \the [src]!",\
					"\red You hear the nauseating crunch of bone and gristle on solid metal.")
				H.UpdateDamageIcon()
				H.updatehealth()
				playsound(src.loc, 'tablehit1.ogg', 50, 1, -3)
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << text("\red [] puts [] on the table.", G.assailant, G.affecting)
		del(W)
		return

	if (istype(W, /obj/item/weapon/wrench))
		user << "\blue Now disassembling table"
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		if(do_after(user,50))
			new /obj/item/weapon/table_parts( src.loc )
			playsound(src.loc, 'Deconstruct.ogg', 50, 1)
			//SN src = null
			del(src)
		return

	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The table was sliced apart by []!", user), 1, text("\red You hear metal coming apart."), 2)
		new /obj/item/weapon/table_parts( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc // Unnecessary -  see: mob/proc/drop_item(atom)    - Doohl
	return


//WOODEN TABLES
/obj/structure/table/woodentable/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
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
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The wooden table was sliced apart by []!", user), 1, text("\red You hear wood coming apart."), 2)
		new /obj/item/weapon/table_parts/wood( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc
	return


//REINFORCED TABLES
/obj/structure/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
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
				if (do_after(user, 50))
					user << "\blue Table weakened"
					src.status = 1
					W:welding = 1
			else
				W:welding = 2
				user << "\blue Now strengthening the reinforced table"
				playsound(src.loc, 'Welder.ogg', 50, 1)
				if (do_after(user, 50))
					user << "\blue Table strengthened"
					src.status = 2
					W:welding = 1
			return
		if(isrobot(user))
			return
		user.drop_item(src)
		//if(W && W.loc)	W.loc = src.loc
		return

	if (istype(W, /obj/item/weapon/wrench))
		if(src.status == 1)
			user << "\blue Now disassembling the reinforced table"
			playsound(src.loc, 'Ratchet.ogg', 50, 1)
			if (do_after(user, 50))
				new /obj/item/weapon/table_parts/reinforced( src.loc )
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				del(src)
			return
	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message(text("\blue The reinforced table was sliced apart by []!", user), 1, text("\red You hear metal coming apart."), 2)
		new /obj/item/weapon/table_parts/reinforced( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc
	return

//RACKS

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			del(src)
			if(prob(50))
				new /obj/item/weapon/rack_parts(src.loc)
		if(3.0)
			if(prob(25))
				del(src)
				new /obj/item/weapon/rack_parts(src.loc)

/obj/structure/rack/blob_act()
	if(prob(75))
		del(src)
		return
	else if(prob(50))
		new /obj/item/weapon/rack_parts(src.loc)
		del(src)
		return

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && (mover.pass_flags & PASSTABLE || mover.flags & TABLEPASS || mover.throwing))
		return 1
	else
		return 0

/obj/structure/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
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

/obj/structure/rack/meteorhit(obj/O as obj)
	del(src)