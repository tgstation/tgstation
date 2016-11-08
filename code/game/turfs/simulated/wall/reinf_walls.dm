/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1

	var/d_state = INTACT
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	explosion_block = 2

/turf/closed/wall/r_wall/examine(mob/user)
	..()
	switch(d_state)
		if(INTACT)
			user << "<span class='notice'>The outer <b>grille</b> is fully intact.</span>"
		if(SUPPORT_LINES)
			user << "<span class='notice'>The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.</span>"
		if(COVER)
			user << "<span class='notice'>The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.</span>"
		if(CUT_COVER)
			user << "<span class='notice'>The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.</span>"
		if(BOLTS)
			user << "<span class='notice'>The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.</span>"
		if(SUPPORT_RODS)
			user << "<span class='notice'>The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.</span>"
		if(SHEATH)
			user << "<span class='notice'>The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.</span>"

/turf/closed/wall/r_wall/break_wall()
	builtin_sheet.loc = src
	return (new /obj/structure/girder/reinforced(src))

/turf/closed/wall/r_wall/devastate_wall()
	builtin_sheet.loc = src
	new /obj/item/stack/sheet/metal(src, 2)

/turf/closed/wall/r_wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.environment_smash == 3)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		M << "<span class='warning'>This wall is far too strong for you to destroy.</span>"

/turf/closed/wall/r_wall/try_destroy(obj/item/weapon/W, mob/user, turf/T)
	if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		user << "<span class='notice'>You begin to smash though the [name]...</span>"
		if(do_after(user, 50, target = src))
			if( !istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
				return 1
			if( user.loc == T && user.get_active_held_item() == W )
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
			d_state = INTACT
			src.icon_state = "r_wall"
			queue_smooth_neighbors(src)
			user << "<span class='notice'>You repair the last of the damage.</span>"
			return 1
	return 0

/turf/closed/wall/r_wall/try_decon(obj/item/weapon/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, W.usesound, 100, 1)
				d_state = SUPPORT_LINES
				update_icon()
				user << "<span class='notice'>You cut the outer grille.</span>"
				return 1

		if(SUPPORT_LINES)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines...</span>"
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 40, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(d_state == SUPPORT_LINES && user.loc == T && user.get_active_held_item() == W )
						d_state = COVER
						update_icon()
						user << "<span class='notice'>You remove the support lines.</span>"
				return 1

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/O = W
				if (O.use(1))
					d_state = INTACT
					update_icon()
					src.icon_state = "r_wall"
					user << "<span class='notice'>You replace the outer grille.</span>"
				else
					user << "<span class='warning'>Report this to a coder: metal stack had less than one sheet in it when trying to repair wall</span>"
					return 1
				return 1

		if(COVER)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover...</span>"
					playsound(src, W.usesound, 100, 1)

					if(do_after(user, 60, target = src))
						if(!istype(src, /turf/closed/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return 0

						if(d_state == COVER && user.loc == T && user.get_active_held_item() == WT )
							d_state = CUT_COVER
							update_icon()
							user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))

				user << "<span class='notice'>You begin slicing through the metal cover...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 60, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(d_state == COVER && user.loc == T && user.get_active_held_item() == W )
						d_state = CUT_COVER
						update_icon()
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

		if(CUT_COVER)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover...</span>"
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 100, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(d_state == CUT_COVER && user.loc == T && user.get_active_held_item() == W )
						d_state = BOLTS
						update_icon()
						user << "<span class='notice'>You pry off the cover.</span>"
				return 1

		if(BOLTS)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>"
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 40, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(d_state == BOLTS && user.loc == T && user.get_active_held_item() == W )
						d_state = SUPPORT_RODS
						update_icon()
						user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return 1

		if(SUPPORT_RODS)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods...</span>"
					playsound(src, W.usesound, 100, 1)

					if(do_after(user, 100, target = src))
						if( !istype(src, /turf/closed/wall/r_wall) || !user || !WT || !WT.isOn() || !T )
							return 1

						if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_held_item() == WT )
							d_state = SHEATH
							update_icon()
							user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))

				user << "<span class='notice'>You begin slicing through the support rods...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_held_item() == W )
						d_state = SHEATH
						update_icon()
						user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

		if(SHEATH)
			if(istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the outer sheath...</span>"
				playsound(src, W.usesound, 100, 1)

				if(do_after(user, 100, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !user || !W || !T )
						return 1

					if(user.loc == T && user.get_active_held_item() == W )
						user << "<span class='notice'>You pry off the outer sheath.</span>"
						dismantle_wall()
				return 1
	return 0

/turf/closed/wall/r_wall/proc/update_icon()
	if(d_state)
		icon_state = "r_wall-[d_state]"
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	else
		smooth = SMOOTH_TRUE
		icon_state = ""

/turf/closed/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()
