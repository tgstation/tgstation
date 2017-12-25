/datum
	var/list/focusers //Only initialized when needed. Contains a list of mobs focusing on this.

/mob
	var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return

	if(new_focus)
		if(!new_focus.focusers) //Set up the new focus
			new_focus.focusers = list()
		new_focus.focusers += src

	if(focus)
		focus.focusers -= src //Tell the old focus we're done with it

	focus = new_focus
	reset_perspective(focus) //Maybe this should be done manually? You figure it out, reader