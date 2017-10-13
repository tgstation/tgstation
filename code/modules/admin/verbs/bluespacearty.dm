/client/proc/bluespace_artillery(mob/M in GLOB.mob_list)
	if(!holder || !check_rights(R_FUN))
		return

	var/mob/living/target = M

	if(!isliving(target))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return
	target.bluespace_artillery()

/mob/living/proc/bluespace_artillery()
	var/turf/open/floor/T = get_turf(src)
	explosion(T, 0, 0, 0, 0)
	if(istype(T))
		if(prob(80))
			T.break_tile_to_plating()
		else
			T.break_tile()

	if(health <= 1)
		gib(1, 1)
	else
		adjustBruteLoss(min(99,(health - 1)))
		Knockdown(400)
		stuttering = 20

