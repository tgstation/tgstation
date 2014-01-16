//LOOK G-MA, I'VE JOINED CARBON PROCS THAT ARE IDENTICAL IN ALL CASES INTO ONE PROC, I'M BETTER THAN LIFE()
//I thought about mob/living but silicons and simple_animals don't want this just yet.
//Right now just handles lying down and cloaking, but could handle other cases later.
//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_alpha = 255

	if(lying != lying_prev)
		ntransform.TurnTo(lying_prev,lying)
		lying_prev = lying	//so we don't try to animate until there's been another change.

	if(cloak_stacks.len > 0)
		final_alpha = 15

	animate(src, transform = ntransform, alpha = final_alpha, time = 5, easing = EASE_IN|EASE_OUT)