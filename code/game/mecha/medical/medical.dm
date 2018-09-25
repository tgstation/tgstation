/obj/mecha/medical
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_MEDICAL)

/obj/mecha/medical/Initialize()
	. = ..()
	trackers += new /obj/item/mecha_parts/mecha_tracking(src)


/obj/mecha/medical/mechturn(direction)
	setDir(direction)
	playsound(src,'sound/mecha/mechmove01.ogg',40,1)
	return 1

/obj/mecha/medical/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/mecha/mechstep.ogg',25,1)
	return result

/obj/mecha/medical/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/mecha/mechstep.ogg',25,1)
	return result