// All movable things can have a Nano UI, always use ui_interact to open/interact with a Nano UI
/atom/movable/proc/ui_interact(mob/user, ui_key = "main")
	return
	
// Used by the Nano UI Manager (/datum/nanomanager) to track UIs opened by this mob
/mob/var/list/open_uis = list()
