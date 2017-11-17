/datum/component/jammer
	var/active = FALSE
	var/range
	var/name

/datum/component/jammer/Initialize(jammer_range, var/jammer_name = parent)
	if(istype(parent, obj/item))
		RegisterSignal(COMSIG_ITEM_ATTACK_SELF, .proc/Toggle)
	range = range
	name = jammer_name

/datum/component/jammer/Destroy()
	GLOB.active_jammers -= src

/datum/component/jammer/proc/Toggle(mob/user)
	to_chat(user,"<span class='notice'>You [active ? "deactivate" : "activate"] [name].</span>")
	active = !active
	if(active)
		GLOB.active_jammers += src
	else
		GLOB.active_jammers -= src
