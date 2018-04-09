//curse_strength bitflag
#define CURSED_ONE_TIME 0 //will only trigger once
#define CURSED_PERMANENT 1 //can trigger more than once
#define CURSED_STRONG 2 //can't be cleansed by chaplain (but still can't affect him)
#define CURSED_UNHOLY 4 //can affect chaplain

/obj/item
	var/list/curses

/obj/item/proc/trigger_curses(mob/user)
	if(!curses || !curses.len)
		return
	var/was_cleansed = 0 //if any of curses were purged
	var/lasted = 0 //if any of curses still last 
	var/was_triggered = 0 //if any of curses were triggered
	for(var/datum/curse/C in curses)
		if(QDELETED(C))
			curses -= C
			continue
		if(user.mind && user.mind.isholy)
			if(C.curse_strength&CURSED_UNHOLY)
				var/T = !!C.trigger(user)
				was_triggered += T
				if(T && !C.curse_strength&CURSED_PERMANENT)
					curses -= C
					qdel(C)
					continue
			if(C.curse_strength&CURSED_STRONG)
				lasted += 1
				continue
			curses -= C
			qdel(C)
			was_cleansed += 1
			continue
		var/T = !!C.trigger(user)
		was_triggered += T
		if(T && !C.curse_strength&CURSED_PERMANENT)
			curses -= C
			qdel(C)
			continue
		lasted += 1
	user.visible_message("<span class='boldannounce'>[usr][was_cleansed ? " flashes in bright warm light as it" : ""] touches [src], and briefly some dark mist erupts from its surface, spreading around in air[was_triggered ? " and enveloping [user]" : ""][lasted ? " before returning back into [src]!" : "!"]</span>")

/obj/item/proc/apply_curse(datum/curse/C)
	if(!curses)
		curses = list()
	curses += C

/datum/curse
	var/curse_name = "generic curse"
	var/curse_desc = "you shouldn't see this"
	var/curse_strength = CURSED_ONE_TIME

/datum/curse/proc/trigger(mob/user) //returns TRUE equivalent if was triggered
	log_game("[user] was cursed by [curse_name] at [atom_loc_line(user)]")
	message_admins("[user] was cursed by [curse_name] at [atom_loc_line(user)]")
	return TRUE