/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"

	var/d_state = 0
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	explosion_block = 2

/turf/simulated/wall/r_wall/break_wall()
	builtin_sheet.loc = src
	return (new /obj/structure/girder/reinforced(src))

/turf/simulated/wall/r_wall/devastate_wall()
	builtin_sheet.loc = src
	new /obj/item/stack/sheet/metal(src, 2)

/turf/simulated/wall/r_wall/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.environment_smash == 3)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		M << "<span class='notice'>You smash through the wall.</span>"
	else
		M << "<span class='warning'>This wall is far too strong for you to destroy.</span>"

/turf/simulated/wall/r_wall/try_destroy(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		user << "<span class='notice'>You begin to smash though the [name]...</span>"
		if(do_after(user, 50, target = src))
			if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
				return 1
			if( user.loc == T && user.get_active_hand() == W )
				D.playDigSound()
				visible_message("<span class='warning'>[user] smashes through the [name] with the [D.name]!</span>", "<span class='italics'>You hear the grinding of metal.</span>")
				dismantle_wall()
				return 1
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W
		if (MS.get_amount() < 1)
			user << "<span class='warning'>You need one sheet of metal to repair the wall!</span>"
			return 1
		user << "<span class='notice'>You begin patching-up the wall with \a [MS]...</span>"
		if (do_after(user, max(20*d_state,100), target = src))//time taken to repair is proportional to the damage! (max 10 seconds)
			if(loc == null || MS.get_amount() < 1)
				return 1
			MS.use(1)
			src.d_state = 0
			src.icon_state = "r_wall"
			smoother.update_neighbors()
			user << "<span class='notice'>You repair the last of the damage.</span>"
			return 1
	return 0

/turf/simulated/wall/r_wall/try_decon(obj/item/weapon/W as obj, mob/user as mob, turf/T as turf)
	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				src.d_state = 1
				update_icon()
				user << "<span class='notice'>You cut the outer grille.</span>"
				return 1

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines...</span>"
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user, 40, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( d_state == 1 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 2
						update_icon()
						user << "<span class='notice'>You remove the support lines.</span>"
				return 1

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/O = W
				if (O.use(1))
					src.d_state = 0
					update_icon()
					src.icon_state = "r_wall"
					user << "<span class='notice'>You replace the outer grille.</span>"
				else
					user << "<span class='warning'>Report this to a coder: metal stack had less than one sheet in it when trying to repair wall</span>"
					return 1
				return 1

		if(2)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover...</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 60, target = src))
						if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return 0

						if( d_state == 2 && user.loc == T && user.get_active_hand() == WT )
							src.d_state = 3
							update_icon()
							user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

			if( istype(W, /obj/item/weapon/gun/energy/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the metal cover...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 60, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( d_state == 2 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 3
						update_icon()
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover...</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( d_state == 3 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 4
						update_icon()
						user << "<span class='notice'>You pry off the cover.</span>"
				return 1

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( d_state == 4 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 5
						update_icon()
						user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return 1

		if(5)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods...</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 100, target = src))
						if( !istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return 1

						if( d_state == 5 && user.loc == T && user.get_active_hand() == WT )
							src.d_state = 6
							update_icon()
							user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

			if( istype(W, /obj/item/weapon/gun/energy/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the support rods...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( d_state == 5 && user.loc == T && user.get_active_hand() == W )
						src.d_state = 6
						update_icon()
						user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

		if(6)
			if( istype(W, /obj/item/weapon/crowbar) )

				user << "<span class='notice'>You struggle to pry off the outer sheath...</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100, target = src))
					if( !istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T )
						return 1

					if( user.loc == T && user.get_active_hand() == W )
						user << "<span class='notice'>You pry off the outer sheath.</span>"
						dismantle_wall()
				return 1
	return 0

/turf/simulated/wall/r_wall/proc/update_icon()
	if(d_state)
		icon_state = "r_wall-[d_state]"
		smoother.enable_smoothing(0)
	else
		smoother.enable_smoothing(1)
		icon_state = ""

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()