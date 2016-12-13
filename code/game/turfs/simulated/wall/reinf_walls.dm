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
	new sheet_type(src)
	return (new /obj/structure/girder/reinforced(src))

/turf/closed/wall/r_wall/devastate_wall()
	new sheet_type(src)
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
			if(!istype(src, /turf/closed/wall/r_wall) || !W)
				return 1
			D.playDigSound()
			visible_message("<span class='warning'>[user] smashes through the [name] with the [D.name]!</span>", "<span class='italics'>You hear the grinding of metal.</span>")
			dismantle_wall()
			return 1
	return 0

/turf/closed/wall/r_wall/try_decon(obj/item/weapon/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src, W.usesound, 100, 1)
				d_state = SUPPORT_LINES
				update_icon()
				user << "<span class='notice'>You cut the outer grille.</span>"
				return 1

		if(SUPPORT_LINES)
			if(istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin unsecuring the support lines...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != SUPPORT_LINES)
						return 1
					d_state = COVER
					update_icon()
					user << "<span class='notice'>You unsecure the support lines.</span>"
				return 1

			else if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src, W.usesound, 100, 1)
				d_state = INTACT
				update_icon()
				user << "<span class='notice'>You repair the outer grille.</span>"
				return 1

		if(COVER)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin slicing through the metal cover...</span>"
					playsound(src, W.usesound, 100, 1)
					if(do_after(user, 60*W.toolspeed, target = src))
						if(!istype(src, /turf/closed/wall/r_wall) || !WT || !WT.isOn() || d_state != COVER)
							return 1
						d_state = CUT_COVER
						update_icon()
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				user << "<span class='notice'>You begin slicing through the metal cover...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				if(do_after(user, 60*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != COVER)
						return 1
					d_state = CUT_COVER
					update_icon()
					user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return 1

			if(istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin securing the support lines...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != COVER)
						return 1
					d_state = SUPPORT_LINES
					update_icon()
					user << "<span class='notice'>The support lines have been secured.</span>"
				return 1

		if(CUT_COVER)
			if(istype(W, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You struggle to pry off the cover...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 100*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != CUT_COVER)
						return 1
					d_state = BOLTS
					update_icon()
					user << "<span class='notice'>You pry off the cover.</span>"
				return 1

			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin welding the metal cover back to the frame...</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					if(do_after(user, 60*WT.toolspeed, target = src))
						if(!istype(src, /turf/closed/wall/r_wall) || !WT || !WT.isOn() || d_state != CUT_COVER)
							return 1
						d_state = COVER
						update_icon()
						user << "<span class='notice'>The metal cover has been welded securely to the frame.</span>"
				return 1

		if(BOLTS)
			if(istype(W, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != BOLTS)
						return 1
					d_state = SUPPORT_RODS
					update_icon()
					user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return 1

			if(istype(W, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You start to pry the cover back into place...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 20*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != BOLTS)
						return 1
					d_state = CUT_COVER
					update_icon()
					user << "<span class='notice'>The metal cover has been pried back into place.</span>"
				return 1

		if(SUPPORT_RODS)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin slicing through the support rods...</span>"
					playsound(src, W.usesound, 100, 1)
					if(do_after(user, 100*W.toolspeed, target = src))
						if(!istype(src, /turf/closed/wall/r_wall) || !WT || !WT.isOn() || d_state != SUPPORT_RODS)
							return 1
						d_state = SHEATH
						update_icon()
						user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

			if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
				user << "<span class='notice'>You begin slicing through the support rods...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				if(do_after(user, 70*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != SUPPORT_RODS)
						return 1
					d_state = SHEATH
					update_icon()
					user << "<span class='notice'>You slice through the support rods.</span>"
				return 1

			if(istype(W, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start tightening the bolts which secure the support rods to their frame...</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != SUPPORT_RODS)
						return 1
					d_state = BOLTS
					update_icon()
					user << "<span class='notice'>You tighten the bolts anchoring the support rods.</span>"
				return 1

		if(SHEATH)
			if(istype(W, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You struggle to pry off the outer sheath...</span>"
				playsound(src, W.usesound, 100, 1)
				if(do_after(user, 100*W.toolspeed, target = src))
					if(!istype(src, /turf/closed/wall/r_wall) || !W || d_state != SHEATH)
						return 1
					user << "<span class='notice'>You pry off the outer sheath.</span>"
					dismantle_wall()
				return 1

			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user << "<span class='notice'>You begin welding the support rods back together...</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					if(do_after(user, 100*WT.toolspeed, target = src))
						if(!istype(src, /turf/closed/wall/r_wall) || !WT || !WT.isOn() || d_state != SHEATH)
							return 1
						d_state = SUPPORT_RODS
						update_icon()
						user << "<span class='notice'>You weld the support rods back together.</span>"
					return 1
	return 0

/turf/closed/wall/r_wall/proc/update_icon()
	if(d_state)
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
		icon_state = "r_wall-[d_state]"
	else
		smooth = SMOOTH_TRUE
		queue_smooth_neighbors(src)
		icon_state = "r_wall"

/turf/closed/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()
