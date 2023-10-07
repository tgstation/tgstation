/atom/movable/screen/fullscreen/soul_punishment
	icon_state = "soul_punishment"


/datum/antagonist/slasher/proc/check_soul_punishment()
	if(last_soul_sucked + soul_digestion < world.time)
		return
	soul_punishment++
	addtimer(CALLBACK(src, PROC_REF(remove_punishment_layer)), 5 MINUTES)

	if(soul_punishment == 1)
		owner.current.overlay_fullscreen("punishment", /atom/movable/screen/fullscreen/soul_punishment, 1)

/datum/antagonist/slasher/proc/remove_punishment_layer()
	soul_punishment--
	if(soul_punishment == 0)
		owner.current.clear_fullscreen("punishment", 50)
