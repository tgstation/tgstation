/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	var/climb_time = 20
	var/climb_stun = 2
	var/climbable = FALSE
	var/mob/structureclimber

/obj/structure/New()
	..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
		icon_state = ""
	if(ticker)
		cameranet.updateVisibility(src)

/obj/structure/blob_act(obj/effect/blob/B)
	if(!density)
		qdel(src)
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	if(opacity)
		UpdateAffectingLights()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	if(M.damtype == BRUTE || M.damtype == BURN)
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0

/obj/structure/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)
	if(structureclimber && structureclimber != user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		structureclimber.Weaken(2)
		structureclimber.visible_message("<span class='warning'>[structureclimber.name] has been knocked off the [src]", "You're knocked off the [src]!", "You see [structureclimber.name] get knocked off the [src]</span>")
	interact(user)

/obj/structure/interact(mob/user)
	ui_interact(user)

/obj/structure/ui_act(action, params)
	..()
	add_fingerprint(usr)

/obj/structure/proc/deconstruct(forced = FALSE)
	qdel(src)


/obj/structure/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(ismob(O) && user == O && iscarbon(user))
		if(user.canmove)
			climb_structure(user)
			return
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/proc/climb_structure(mob/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>You start climbing onto [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(istype(user, /mob/living/carbon/alien))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			density = 0
			if(step(user,get_dir(user,src.loc)))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>You climb onto [src].</span>")
				add_logs(user, src, "climbed onto")
				user.Stun(climb_stun)
				. = 1
			else
				user << "<span class='warning'>You fail to climb onto [src].</span>"
			density = 1
	structureclimber = null
