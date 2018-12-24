/datum/component/hugcounter
    dupe_mode = COMPONENT_DUPE_UNIQUE
    var/hugnumber = 0
    var/mob/living/target

/datum/component/hugcounter/Initialize()
    if(!iscarbon(parent))
        return COMPONENT_INCOMPATIBLE
    RegisterSignal(parent, COMSIG_MOB_HUG, .proc/hugs)

/datum/component/hugcounter/proc/hugs(var/mob/hugvictim)
	if(target)
		if(target == hugvictim)
			hugnumber++
	else
		hugnumber++