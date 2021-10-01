/mob/living
	/// The holder for this mob living's admin heal action. It should never be set to null or modified except on qdel
	var/datum/action/cooldown/arena_aheal/arena_action = new

/mob/living/Destroy()
	arena_action.Remove(src)
	QDEL_NULL(arena_action)
	return ..()

/mob/living/Login()
	. = ..()
	arena_action.Grant(src)

/mob/living/Logout()
	. = ..()
	if(!arena_action)
		return
	arena_action.Remove(src)
