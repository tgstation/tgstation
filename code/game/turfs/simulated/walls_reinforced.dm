/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"

	var/d_state = 0
	hardness = 10

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob)

	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such


	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( is_hot(W) )
			thermitemelt(user)

		if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

		return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		user << "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>"
		return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				src.d_state = 1
				src.icon_state = "r_wall-1"
				new /obj/item/stack/rods( src )
				user << "<span class='notice'>You cut the outer grille.</span>"
				return

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines.</span>"
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user, 40))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( d_state == 1 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 2
						src.icon_state = "r_wall-2"
						user << "<span class='notice'>You remove the support lines.</span>"
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/O = W
				if (O.use(1))
					src.d_state = 0
					src.icon_state = "r_wall"
					relativewall_neighbours()	//call smoothwall stuff
					user << "<span class='notice'>You replace the outer grille.</span>"
				else
					user << "<span class='warning'>You need one rod to repair the wall.</span>"
					return
				return

		if(2)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 60))
						if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return

						if( d_state == 2 && user.loc == T && user.get_active_hand() == WT )
							src.d_state = 3
							src.icon_state = "r_wall-3"
							user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the metal cover.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 60))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( d_state == 2 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 3
						src.icon_state = "r_wall-3"
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( d_state == 3 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 4
						src.icon_state = "r_wall-4"
						user << "<span class='notice'>You pry off the cover.</span>"
				return

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( d_state == 4 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 5
						src.icon_state = "r_wall-5"
						user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return

		if(5)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 100))
						if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return

						if( d_state == 5 && user.loc == T && user.get_active_hand() == WT )
							src.d_state = 6
							src.icon_state = "r_wall-6"
							new /obj/item/stack/rods( src )
							user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the support rods.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( d_state == 5 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 6
						src.icon_state = "r_wall-6"
						new /obj/item/stack/rods( src )
						user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return

		if(6)
			if( istype(W, /obj/item/weapon/crowbar) )

				user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return

					if( user.loc == T && user.get_active_hand() == W )
						user << "<span class='notice'>You pry off the outer sheath.</span>"
						dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		if(do_after(user, 200))
			if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
				return

			if( user.loc == T && user.get_active_hand() == W )
				user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
				dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		if (MS.get_amount() < 1)
			user << "<span class='warning'>You need one sheet of metal to repair the wall.</span>"
			return

		user << "<span class='notice'>You begin patching-up the wall with \a [MS].</span>"

		if (do_after(user, max(20*d_state,100)))//time taken to repair is proportional to the damage! (max 10 seconds)
			if(loc == null || MS.get_amount() < 1)
				return
			MS.use(1)
			src.d_state = 0
			src.icon_state = "r_wall"
			relativewall_neighbours()	//call smoothwall stuff
			user << "<span class='notice'>You repair the last of the damage.</span>"


	//APC
	else if( istype(W,/obj/item/apc_frame) )
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/newscaster_frame))     //Be damned the man who thought only mobs need attack() and walls dont need inheritance, hitler incarnate
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return

	else if( istype(W,/obj/item/alarm_frame) )
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/contraband/poster))
		place_poster(W,user)
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()