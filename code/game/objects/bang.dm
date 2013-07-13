proc/bang(var/atom/target, var/fluff, var/intensity = 0, var/range = 0) //Fluff- is it a BANG!, a HONK!, or something else?
	if(!target)
		return 0;
	if(istype(target,/mob))					//We're just banging a mob, not an area
		return bangmob(target,intensity)			//Bang just that mob.
	target = get_turf(target)					//We're not banging a mob; prepare to bang an area.
	for(var/mob/living/carbon/O in range(range,target))
		if(get_dist(target, O) > range/2) intensity = round(intensity/2)
		bangmob(O, fluff, intensity)
	for(var/obj/structure/closet/L in range(range,target))		//Check for closets.  Balance!
		if(locate(/mob/living/carbon/, L))
			if(get_dist(target, L) > range/2) intensity = round(intensity/2)
			for(var/mob/living/carbon/M in L)
				bang(M,fluff,intensity)

	return 1


proc/bangmob(mob/living/carbon/target, var/fluff, intensity)
	if(istype(target,/mob/living/carbon))
		var/ear_safety = 1
		if(istype(target,/mob/living/carbon/human))
			if(istype(target:ears,/obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(HULK in target.mutations)
				ear_safety += 1
			if(istype(target:head, /obj/item/clothing/head/helmet))
				ear_safety += 1
		intensity = round(intensity/ear_safety)
		target.sleeping = max(0,intensity)
		target.damage_ear(rand(0,intensity))			//First, your ears should hurt.
		target.Weaken(max(intensity-5,0))			//If it's a strong enough bang, it'll knock people down.
		target.make_dizzy(max(intensity-3,0)*2)			//It doesn't take a huge sound to make you feel woozy
		target.confused += max(intensity-2,0)			//And you'll probably be disoriented briefly
		target.ear_deaf += round(intensity * 1.5)		//Not to mention, you won't be able to hear for a while.
		target << "\red <B>[fluff]</B>"
		return 1
	return 0