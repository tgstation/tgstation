/datum
	var/list/focusers // Only initialized when needed. Contains a list of mobs focusing on this.

/mob
	var/datum/focus // What receives our inputs. src by default

/mob/New()
	set_focus(src)
	..()

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return

	if(!new_focus.focusers) // Set up the new focus
		new_focus.focusers = list()
	new_focus.focusers |= src

	if(focus)
		focus.focusers -= src // Tell the old focus we're done with it
		if(!focus.focusers.len)
			focus.focusers = null

	focus = new_focus // Actually set the focus and set our view to it
	reset_view(focus)

	if(client)
		for(var/key in client.keys_held) // Tell the new focus about all the keys we're holding down
			focus.key_down(key, src)
