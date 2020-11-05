/mob/proc/death(gibbed)
	SEND_SIGNAL(src, COMSIG_MOB_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src , gibbed)
