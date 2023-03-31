//Here are the procs used to modify status effects of a mob.

///Adjust the disgust level of a mob
/mob/proc/adjust_disgust(amount)
	return

///Set the disgust level of a mob
/mob/proc/set_disgust(amount)
	return

///Adjust the body temperature of a mob, with min/max settings
/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)

/// Sight here is the mob.sight var, which tells byond what to actually show to our client
/// See [code\__DEFINES\sight.dm] for more details
/mob/proc/set_sight(new_value)
	SHOULD_CALL_PARENT(TRUE)
	if(sight == new_value)
		return
	var/old_sight = sight
	sight = new_value

	SEND_SIGNAL(src, COMSIG_MOB_SIGHT_CHANGE, new_value, old_sight)

/mob/proc/add_sight(new_value)
	set_sight(sight | new_value)

/mob/proc/clear_sight(new_value)
	set_sight(sight & ~new_value)

/// see invisibility is the mob's capability to see things that ought to be hidden from it
/// Can think of it as a primitive version of changing the alpha of planes
/// We mostly use it to hide ghosts, no real reason why
/mob/proc/set_invis_see(new_sight)
	SHOULD_CALL_PARENT(TRUE)
	if(new_sight == see_invisible)
		return
	var/old_invis = see_invisible
	see_invisible = new_sight
	SEND_SIGNAL(src, COMSIG_MOB_SEE_INVIS_CHANGE, see_invisible, old_invis)
