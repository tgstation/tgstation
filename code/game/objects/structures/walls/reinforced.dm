/obj/structure/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	walltype = "rwall"
	var/d_state = 0
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel

/obj/structure/wall/r_wall/break_wall()
	builtin_sheet.loc = loc
	return (new /obj/structure/girder/reinforced(loc))

/obj/structure/wall/r_wall/devastate_wall()
	builtin_sheet.loc = loc
	new /obj/item/stack/sheet/metal(loc, 2)

/obj/structure/wall/r_wall/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.environment_smash == 3)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		M << "<span class='notice'>You smash through the wall.</span>"
	else
		M << "<span class='warning'>This wall is far too strong for you to destroy.</span>"

/obj/structure/wall/r_wall/attack_hand(mob/user as mob)
	//this is ugly
	if ((HULK in user.mutations) || !d_state)
		..()

/obj/structure/wall/r_wall/try_destroy(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	if(istype(W, /obj/item/weapon/melee/energy/blade))
		user << "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>"
		return 1
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		user << "<span class='notice'>You begin to drill though the wall.</span>"
		if(do_after(user, 200))
			if( !src || !user || !W || !T )
				return 1
			if( user.loc == T && user.get_active_hand() == W )
				user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
				dismantle_wall()
				return 1
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W
		if (MS.get_amount() < 1)
			user << "<span class='warning'>You need one sheet of metal to repair the wall.</span>"
			return 1
		user << "<span class='notice'>You begin patching-up the wall with \a [MS].</span>"
		if (do_after(user, max(20*d_state,100)))//time taken to repair is proportional to the damage! (max 10 seconds)
			if(loc == null || MS.get_amount() < 1)
				return 1
			MS.use(1)
			d_state = 0
			icon_state = "r_wall"
			relativewall_neighbours()	//call smoothwall stuff
			user << "<span class='notice'>You repair the last of the damage.</span>"
			return 1
	return 0

/obj/structure/wall/r_wall/try_decon(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				d_state = 1
				icon_state = "r_wall-1"
				new /obj/item/stack/rods( loc )
				user << "<span class='notice'>You cut the outer grille.</span>"
				return 1

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines.</span>"
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user, 40))
					if( !src || !user || !W || !T )
						return 1

					if( d_state == 1 && user.loc == T && user.get_active_hand() == W )
						d_state = 2
						icon_state = "r_wall-2"
						user << "<span class='notice'>You remove the support lines.</span>"
				return 1

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/O = W
				if (O.use(1))
					d_state = 0
					icon_state = "r_wall"
					relativewall_neighbours()	//call smoothwall stuff
					user << "<span class='notice'>You replace the outer grille.</span>"
				else
					user << "<span class='warning'>You need one rod to repair the wall.</span>"
					return 1
				return 1

		if(2)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 60))
						if( !src || !user || !WT || !WT.isOn() || !T )
							return 0

						if( d_state == 2 && user.loc == T && user.get_active_hand() == WT )
							d_state = 3
							icon_state = "r_wall-3"
							user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the metal cover.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 60))
					if( !src || !user || !W || !T )
						return 1

					if( d_state == 2 && user.loc == T && user.get_active_hand() == W )
						d_state = 3
						icon_state = "r_wall-3"
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					if( !src || !user || !W || !T )
						return 1

					if( d_state == 3 && user.loc == T && user.get_active_hand() == W )
						d_state = 4
						icon_state = "r_wall-4"
						user << "<span class='notice'>You pry off the cover.</span>"
				return 1

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40))
					if( !src || !user || !W || !T )
						return 1

					if( d_state == 4 && user.loc == T && user.get_active_hand() == W )
						d_state = 5
						icon_state = "r_wall-5"
						user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return 1

		if(5)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 100))
						if( !src || !user || !WT || !WT.isOn() || !T )
							return 1

						if( d_state == 5 && user.loc == T && user.get_active_hand() == WT )
							d_state = 6
							icon_state = "r_wall-6"
							new /obj/item/stack/rods( loc )
							user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return 1

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the support rods.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70))
					if( !src || !user || !W || !T )
						return 1

					if( d_state == 5 && user.loc == T && user.get_active_hand() == W )
						d_state = 6
						icon_state = "r_wall-6"
						new /obj/item/stack/rods( loc )
						user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return 1

		if(6)
			if( istype(W, /obj/item/weapon/crowbar) )

				user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					if( !src || !user || !W || !T )
						return 1

					if( user.loc == T && user.get_active_hand() == W )
						user << "<span class='notice'>You pry off the outer sheath.</span>"
						dismantle_wall()
				return 1
	return 0

/obj/structure/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= 9)
		if(prob(30))
			dismantle_wall()
