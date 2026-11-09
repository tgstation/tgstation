
/mob/living/carbon/alien/proc/findQueen()
	if(!hud_used)
		return
	var/atom/movable/screen/alien/alien_queen_finder/finder = hud_used.screen_objects[HUD_ALIEN_QUEEN_FINDER]
	if (!finder)
		return
	finder.cut_overlays()
	var/mob/queen = get_alien_type(/mob/living/carbon/alien/adult/royal/queen)
	if(!queen)
		return
	var/turf/Q = get_turf(queen)
	var/turf/A = get_turf(src)
	if(Q.z != A.z) //The queen is on a different Z level, we cannot sense that far.
		return
	var/Qdir = get_dir(src, Q)
	var/Qdist = get_dist(src, Q)
	var/finder_icon = "finder_center" //Overlay showed when adjacent to or on top of the queen!
	switch(Qdist)
		if(2 to 7)
			finder_icon = "finder_near"
		if(8 to 20)
			finder_icon = "finder_med"
		if(21 to INFINITY)
			finder_icon = "finder_far"
	var/image/finder_eye = image('icons/hud/screen_alien.dmi', finder_icon, dir = Qdir)
	finder.add_overlay(finder_eye)

/mob/living/carbon/alien/adult/royal/queen/findQueen()
	return //Queen already knows where she is. Hopefully.
