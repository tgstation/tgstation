/datum/component/jammer
	var/active = FALSE
	var/range

/datum/component/jammer/Initialize(range)
	RegisterSignal(COMSIG_ITEM_ATTACK_SELF, .proc/Toggle)
	src.range = range

/datum/component/jammer/Destroy()
	if(active)
		GLOB.active_jammers -= src

/datum/component/jammer/proc/Toggle(mob/user)
	to_chat(user,"<span class='notice'>You [active ? "deactivate" : "activate"] [parent].</span>")
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	parent.update_icon() //For if there are on/off sprites
