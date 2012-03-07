/obj/mecha/medical/New()
	..()
	new /obj/item/mecha_tracking(src)
	return


/obj/mecha/medical/mechturn(direction)
	dir = direction
	playsound(src,'mechmove01.ogg',40,1)
	return 1

/obj/mecha/medical/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'mechstep.ogg',25,1)
	return result

/obj/mecha/medical/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'mechstep.ogg',25,1)
	return result