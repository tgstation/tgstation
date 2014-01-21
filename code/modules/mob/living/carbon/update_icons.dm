//LOOK G-MA, I'VE JOINED CARBON PROCS THAT ARE IDENTICAL IN ALL CASES INTO ONE PROC, I'M BETTER THAN LIFE()
//I thought about mob/living but silicons and simple_animals don't want this just yet.
//Right now just handles lying down and cloaking, but could handle other cases later.
//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = 0
	var/final_dir = dir
	var/changed = 0

	if(lying != lying_prev)
		changed++
		ntransform.TurnTo(lying_prev,lying)
		lying_prev = lying	//so we don't try to animate until there's been another change.
		if(lying != 0)
			final_pixel_y = -6
			if(dir & (EAST|WEST)) //Facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)