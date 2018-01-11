/mob
	var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus
	reset_perspective(focus) //Maybe this should be done manually? You figure it out, reader

//called on Life() to clear the focus var if it's deleted
/mob/proc/CheckFocus()
	var/datum/_focus = focus
	if(_focus != src && QDELETED(_focus))
		set_focus(src)