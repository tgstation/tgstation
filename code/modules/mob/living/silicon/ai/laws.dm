
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	set desc = "Check what your laws are privately. \
		Also ensures all synced cyborgs are up to date with your laws, reminds them of your laws."
	if(usr.stat == DEAD)
		return //won't work if dead
	src.show_laws()

/mob/living/silicon/ai/show_laws()
	. = ..()
	try_sync_laws() // Yes we lawsync borgs EVERY TIME WE CHECK LAWS

/mob/living/silicon/ai/try_sync_laws()
	for(var/mob/living/silicon/robot/borgo in connected_robots)
		if(borgo.try_sync_laws())
			to_chat(borgo, span_bold("Your AI has reminded you of your laws:"))
			borgo.show_laws()
