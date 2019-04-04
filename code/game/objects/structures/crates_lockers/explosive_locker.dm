/obj/structure/closet/explosive
	var/hasexploded = FALSE

/obj/structure/closet/explosive/open(mob/living/user)
	if(opened || !can_open(user))
		return
	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
	climb_time *= 0.5 //it's faster to climb onto an open thing
	dump_contents()
	update_icon()
	if(hasexploded == FALSE)
		hasexploded = TRUE
		spawn(100)
		explosion(src.loc,3,4,5,8)
	return 1