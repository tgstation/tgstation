/datum/mutation/human/extendoarm
	name = "Extendo Arm"
	desc = "Allows the affected to stretch their arms to grab objects from a distance."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your arms feel stretchy.</span>"
	text_lose_indication = "<span class='warning'>Your arms feel solid again.</span>"
	power = /obj/effect/proc_holder/spell/aimed/extendoarm
	instability = 30

/obj/effect/proc_holder/spell/aimed/extendoarm
	name = "Arm"
	desc = "Stretch your arm to grab or put stuff down."
	charge_max = 50
	cooldown_min = 50
	clothes_req = FALSE
	range = 50
	projectile_type = /obj/item/projectile/bullet/arm
	base_icon_state = "arm"
	action_icon_state = "arm"
	active_msg = "You loosen up your arm!"
	deactive_msg = "You relax your arm."
	active = FALSE
	projectile_amount = 64

/obj/effect/proc_holder/spell/aimed/extendoarm/ready_projectile(obj/item/projectile/bullet/arm/P, atom/target, mob/user, iteration)
	var/mob/living/carbon/C = user
	var/new_color
	if(C.dna?.species)
		new_color = C.dna.features["mcolor"]
		if(!("#" in new_color))
			new_color = "#[new_color]"
		P.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)

	P.homing = target
	P.beam = new(C, P, time=200, beam_icon_state="2-full", maxdistance=150, beam_sleep_time=1, beam_color = new_color)
	P.beam.Start()

	var/obj/item/I = C.get_active_held_item()
	if(I && C.dropItemToGround(I, FALSE))
		var/obj/item/projectile/bullet/arm/ARM = P
		ARM.grab(I)
	P.arm = C.hand_bodyparts[C.active_hand_index]
	P.arm.drop_limb()
	P.arm.forceMove(P)

/obj/effect/proc_holder/spell/aimed/extendoarm/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!iscarbon(caller))
		return
	var/mob/living/carbon/C = caller
	if(!C.hand_bodyparts[C.active_hand_index])
		return
	return ..()

/obj/effect/proc_holder/spell/aimed/extendoarm/can_cast(mob/user = usr)
	. = ..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.handcuffed) //this doesnt mix well with the whole arm removal thing
		return

/obj/item/projectile/bullet/arm
	name = "arm"
	icon_state = "arm"
	suppressed = TRUE
	damage = 0
	range = 100
	speed = 2
	nodamage = 1
	homing = TRUE
	homing_turn_speed = 360
	var/obj/item/grabbed
	var/obj/item/bodypart/arm
	var/returning = FALSE
	var/datum/beam/beam

/obj/item/projectile/bullet/arm/prehit(atom/target, blocked = FALSE)
	if(returning)
		if(target == firer)
			var/mob/living/L = firer
			if(arm && firer)
				arm.attach_limb(firer, TRUE)
				arm = null
			L.put_in_hands(ungrab())
			return TRUE
		return FALSE //Otherwise we get multiple collisions deleting arms. That'll be handled by range
	else if(!isitem(target) && !grabbed && firer)
		target.attack_hand(firer)
		go_home()
	else
		if(grabbed)
			ungrab()
		else if(isitem(target))
			grab(target)
		go_home()
		return FALSE

/obj/item/projectile/bullet/arm/proc/go_home()
	homing_target = firer
	returning = TRUE
	icon_state += "-reverse"
	range = decayedRange
	ignore_source_check = TRUE

/obj/item/projectile/bullet/arm/proc/grab(obj/item/I)
	if(!I)
		return
	I.forceMove(src)
	var/image/IM = image(I, src)
	IM.appearance_flags = RESET_COLOR //Otherwise skin color leaks to the object
	grabbed = I
	overlays += IM

/obj/item/projectile/bullet/arm/proc/ungrab()
	if(!grabbed)
		return
	grabbed.forceMove(drop_location())
	overlays.Cut()
	. = grabbed
	grabbed = null

/obj/item/projectile/bullet/arm/Destroy()
	if(grabbed)
		grabbed.forceMove(drop_location())
	if(arm)
		arm.forceMove(drop_location())
	qdel(beam)
	return ..()