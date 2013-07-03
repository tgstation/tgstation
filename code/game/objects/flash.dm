proc/flash(var/atom/target, var/intensity = 0, var/range = 0, var/mob/user)
	if(!target)
		return 0;
	if(istype(target,/mob))					//We're just flashing a mob, not an area
		return flashmob(target,intensity)			//Flash just that mob.
	target = get_turf(target)					//We're not flashing a mob; prepare to flash an area.
	for (var/mob/O in viewers(target, null))
		if (get_dist(src, O) > range || O == user)
			continue	//He's out of range, or he's the one who's used the flash; skip him.
		flashmob(O, intensity)
	return 1


proc/flashmob(mob/target, intensity)
	if(istype(target,/mob/living/carbon/human) || istype(target,/mob/living/carbon/monkey)) //Monkies and humans should probably be separated from slimes and aliums, but until then, this will have to do.
		if(target:eyecheck() || target.blinded) return 0 	//He's got protection, or can't see shit.
		target.Weaken(intensity)
		flick("e_flash", target.flash)
		if(prob(50))
			if (locate(/obj/item/weapon/cloaking_device, target))
				for(var/obj/item/weapon/cloaking_device/S in target)
					S.active = 0
					S.icon_state = "shield0"
		return 1
	else if(istype(target,/mob/living/silicon/robot))
		target.Weaken(max(intensity-5,0))	//Robots aren't quite as vulnerable to flashes
		flick("e_flash", target.flash)
		return 1
	return 0