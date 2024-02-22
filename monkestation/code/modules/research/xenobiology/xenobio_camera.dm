/mob/camera/ai_eye/remote/xenobio/proc/auto_attach_slime(mob/living/carbon/human/food)
	var/mob/living/simple_animal/slime/glutton
	for(var/mob/living/simple_animal/slime/slime in range(1, loc))
		if(slime.ckey || slime.amount_grown >= SLIME_EVOLUTION_THRESHOLD)
			continue
		var/mob/living/slime_eating = slime.buckled
		if(!isliving(slime_eating) || slime_eating.stat < DEAD)
			continue
		if(glutton?.is_adult && !slime.is_adult)
			// adult slimes can react faster than baby slimes
			continue
		if(QDELETED(glutton) || (!glutton.is_adult && slime.is_adult) || (slime.amount_grown > glutton.amount_grown))
			glutton = slime
	if(!QDELETED(glutton))
		addtimer(CALLBACK(glutton, TYPE_PROC_REF(/mob/living/simple_animal/slime, Feedon), food), rand(0.1 SECONDS, 0.9 SECONDS))
