/**Shake() and then explode a turf based on the passed vars
 * shake_duration: how long to shake the turf for before calling explosion()
 * explosion_stats: the list of stats to give the called explosion()
 * sound: if passed then what sound to play at the start of the shaking, if a list is passed then it will pick() from that list
 * do_log: do we admin log the explosion
**/
/turf/proc/structural_collapse(shake_duration = 1 SECONDS, explosion_stats = list(1, 2, 3), sound/played_sound, do_log = TRUE)
	if(QDELETED(src))
		return

	if(played_sound)
		playsound(src, (islist(played_sound) ? pick(played_sound) : played_sound), 60)
	visible_message(span_userdanger("\The [src] looks like its about to collapse!"))
	Shake(0.2, 0.2, shake_duration)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), src, explosion_stats[1], explosion_stats[2], explosion_stats[3], 0, 0, do_log), shake_duration)
	explosion()
