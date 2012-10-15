/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.")

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			del(T)
	update_icon()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()

/obj/structure/table/Del()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()
	..()

/obj/structure/table/update_icon()
	spawn(2) //So it properly updates when deleting
		var/dir_sum = 0
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/skip_sum = 0
			for(var/obj/structure/window/W in src.loc)
				if(W.dir == direction) //So smooth tables don't go smooth through windows
					skip_sum = 1
					continue
			var/inv_direction //inverse direction
			switch(direction)
				if(1)
					inv_direction = 2
				if(2)
					inv_direction = 1
				if(4)
					inv_direction = 8
				if(8)
					inv_direction = 4
				if(5)
					inv_direction = 10
				if(6)
					inv_direction = 9
				if(9)
					inv_direction = 6
				if(10)
					inv_direction = 5
			for(var/obj/structure/window/W in get_step(src,direction))
				if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
					skip_sum = 1
					continue
			if(!skip_sum) //means there is a window between the two tiles in this direction
				if(locate(/obj/structure/table,get_step(src,direction)))
					if(direction <5)
						dir_sum += direction
					else
						if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
							dir_sum += 16
						if(direction == 6)
							dir_sum += 32
						if(direction == 8)	//Aherp and Aderp.  Jezes I am stupid.  -- SkyMarshal
							dir_sum += 8
						if(direction == 10)
							dir_sum += 64
						if(direction == 9)
							dir_sum += 128

		var/table_type = 0 //stand_alone table
		if(dir_sum%16 in cardinal)
			table_type = 1 //endtable
			dir_sum %= 16
		if(dir_sum%16 in list(3,12))
			table_type = 2 //1 tile thick, streight table
			if(dir_sum%16 == 3) //3 doesn't exist as a dir
				dir_sum = 2
			if(dir_sum%16 == 12) //12 doesn't exist as a dir.
				dir_sum = 4
		if(dir_sum%16 in list(5,6,9,10))
			if(locate(/obj/structure/table,get_step(src.loc,dir_sum%16)))
				table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
			else
				table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
			dir_sum %= 16
		if(dir_sum%16 in list(13,14,7,11)) //Three-way intersection
			table_type = 5 //full table as three-way intersections are not sprited, would require 64 sprites to handle all combinations.  TOO BAD -- SkyMarshal
			switch(dir_sum%16)	//Begin computation of the special type tables.  --SkyMarshal
				if(7)
					if(dir_sum == 23)
						table_type = 6
						dir_sum = 8
					else if(dir_sum == 39)
						dir_sum = 4
						table_type = 6
					else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
						dir_sum = 4
						table_type = 3
					else
						dir_sum = 4
				if(11)
					if(dir_sum == 75)
						dir_sum = 5
						table_type = 6
					else if(dir_sum == 139)
						dir_sum = 9
						table_type = 6
					else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
						dir_sum = 8
						table_type = 3
					else
						dir_sum = 8
				if(13)
					if(dir_sum == 29)
						dir_sum = 10
						table_type = 6
					else if(dir_sum == 141)
						dir_sum = 6
						table_type = 6
					else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
						dir_sum = 1
						table_type = 3
					else
						dir_sum = 1
				if(14)
					if(dir_sum == 46)
						dir_sum = 1
						table_type = 6
					else if(dir_sum == 78)
						dir_sum = 2
						table_type = 6
					else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
						dir_sum = 2
						table_type = 3
					else
						dir_sum = 2 //These translate the dir_sum to the correct dirs from the 'tabledir' icon_state.
		if(dir_sum%16 == 15)
			table_type = 4 //4-way intersection, the 'middle' table sprites will be used.

		if(istype(src,/obj/structure/table/reinforced))
			switch(table_type)
				if(0)
					icon_state = "reinf_table"
				if(1)
					icon_state = "reinf_1tileendtable"
				if(2)
					icon_state = "reinf_1tilethick"
				if(3)
					icon_state = "reinf_tabledir"
				if(4)
					icon_state = "reinf_middle"
				if(5)
					icon_state = "reinf_tabledir2"
				if(6)
					icon_state = "reinf_tabledir3"
		else if(istype(src,/obj/structure/table/woodentable))
			switch(table_type)
				if(0)
					icon_state = "wood_table"
				if(1)
					icon_state = "wood_1tileendtable"
				if(2)
					icon_state = "wood_1tilethick"
				if(3)
					icon_state = "wood_tabledir"
				if(4)
					icon_state = "wood_middle"
				if(5)
					icon_state = "wood_tabledir2"
				if(6)
					icon_state = "wood_tabledir3"
		else
			switch(table_type)
				if(0)
					icon_state = "table"
				if(1)
					icon_state = "table_1tileendtable"
				if(2)
					icon_state = "table_1tilethick"
				if(3)
					icon_state = "tabledir"
				if(4)
					icon_state = "table_middle"
				if(5)
					icon_state = "tabledir2"
				if(6)
					icon_state = "tabledir3"
		if (dir_sum in list(1,2,4,8,5,6,9,10))
			dir = dir_sum
		else
			dir = 2

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
	if ((HULK in usr.mutations))
		usr << "\blue You destroy the table."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [user] smashes the table apart!"
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
					O << "[user] hides under the table!"
				//Foreach goto(69)
	return


/obj/structure/table/attack_alien(mob/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	usr << "\green You destroy the table."
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << "\red [user] slices the table apart!"
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
		usr << "\red You destroy the table."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [user] smashes the table apart!"
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
	if ((HULK in usr.mutations) || (SUPRSTR in usr.augmentations))
		usr << "\blue You destroy the table."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [user] smashes the table apart!"
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

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/structure/table/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
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
			user << "\red You need a better grip to do that!"
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << "\red [G.assailant] puts [G.affecting] on the table."
		del(W)
		return

	if (istype(W, /obj/item/weapon/wrench))
		user << "\blue Now disassembling table"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user,50))
			new /obj/item/weapon/table_parts( src.loc )
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			//SN src = null
			del(src)
		return

	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message("\blue The table was sliced apart by [user]!", 1, "\red You hear metal coming apart.", 2)
		new /obj/item/weapon/table_parts( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc // Unnecessary -  see: mob/proc/drop_item(atom)    - Doohl
	return


/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon_state = "wood_table"


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
				O << "\red [G.assailant] puts [G.affecting] on the wooden table."
		del(W)
		return
	if (istype(W, /obj/item/weapon/wrench))
		user << "\blue Now disassembling the wooden table"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		sleep(50)
		new /obj/item/weapon/table_parts/wood( src.loc )
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		del(src)
		return
	if(isrobot(user))
		return
	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message("\blue The wooden table was sliced apart by [user]!", 1, "\red You hear wood coming apart.", 2)
		new /obj/item/weapon/table_parts/wood( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc
	return


/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon_state = "reinf_table"
	var/status = 2


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
				O << "\red [G.assailant] puts [G.affecting] on the reinforced table."
		del(W)
		return

	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			if(src.status == 2)
				user << "\blue Now weakening the reinforced table"
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "\blue Table weakened"
					src.status = 1
			else
				user << "\blue Now strengthening the reinforced table"
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "\blue Table strengthened"
					src.status = 2
			return
		if(isrobot(user))
			return
		user.drop_item(src)
		//if(W && W.loc)	W.loc = src.loc
		return

	if (istype(W, /obj/item/weapon/wrench))
		if(src.status == 1)
			user << "\blue Now disassembling the reinforced table"
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if (do_after(user, 50))
				new /obj/item/weapon/table_parts/reinforced( src.loc )
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				del(src)
			return
	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message("\blue The reinforced table was sliced apart by [user]!", 1, "\red You hear metal coming apart.", 2)
		new /obj/item/weapon/table_parts/reinforced( src.loc )
		del(src)
		return

	user.drop_item(src)
	//if(W && W.loc)	W.loc = src.loc
	return


/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.

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
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
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
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
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