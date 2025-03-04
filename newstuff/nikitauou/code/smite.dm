/atom/movable/screen/fullscreen/uncanny_cat
	icon = 'newstuff/nikitauou/icons/uncanny.dmi'
	// screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "uncanny_cat"
	show_when_dead = TRUE

/datum/smite/uncanny_cat
	name = "Uncanny cat"

/proc/uncanny_cat(mob/living/target)
	target.overlay_fullscreen("uncanny_cat", /atom/movable/screen/fullscreen/uncanny_cat)
	SEND_SOUND(target, sound('newstuff/nikitauou/sound/stalkerscream.mp3'))
	sleep(5)
	target.clear_fullscreen("uncanny_cat", animated = 5)


/datum/smite/uncanny_cat/effect(client/user, mob/living/target)
	. = ..()
	uncanny_cat(target)


