/mob/living/carbon/movement_delay()
	. = ..()
	if(legcuffed)
		. += legcuffed.slowdown

	var/obj/item/organ/internal/cyberimp/chest/thrusters/J = getorganslot("thrusters")
	if(istype(J) && J.on)
		. -= 2


var/const/NO_SLIP_WHEN_WALKING = 1
var/const/SLIDE = 2
var/const/GALOSHES_DONT_HELP = 4

/mob/living/carbon/slip(s_amount, w_amount, obj/O, lube)
	add_logs(src,, "slipped",, "on [O ? O.name : "floor"]")
	return loc.handle_slip(src, s_amount, w_amount, O, lube)


/mob/living/carbon/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	if(!isturf(loc))
		return 0

	// Do we have a jetpack implant (and is it on)?
	var/obj/item/organ/internal/cyberimp/chest/thrusters/T = getorganslot("thrusters")
	if(istype(T) && movement_dir && T.allow_thrust(0.01))
		return 1

	var/obj/item/weapon/tank/jetpack/J = get_jetpack()
	if(istype(J) && (movement_dir || J.stabilizers) && J.allow_thrust(0.01, src))
		return 1



/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2