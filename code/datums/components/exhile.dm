/**
 * The exhile component: When you really, really want to get rid of someone, shoot them into space!
 */
/datum/component/exhile
	var/launch_dir

/datum/component/exhile/Initialize(direction)
	. = ..()
	launch_dir = direction

/datum/component/exhile/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, .proc/check_z)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_move)

/datum/component/exhile/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOVABLE_MOVED))

/// If the exhilee crosses into a new z-level without breaking their course after being shot into space, send them to hell
/datum/component/exhile/proc/check_z()
	SIGNAL_HANDLER

	var/mob/living/exhilee = parent
	if(!istype(exhilee) || !exhilee.client)
		qdel(src)
		return
	var/youre_on_your_way_to = HELL
	if(world.url == HELL)
		youre_on_your_way_to = THE_ABYSS

	to_chat(exhilee, "<span class='userdanger'>Oh no! You've been shot into space and are flying towards another station!</span>")
	var/client/exhilee_client = exhilee.client
	exhilee_client << link(youre_on_your_way_to)
	exhilee.dust()

/// If the exhilee breaks their course before hitting the z-level, they saved themselves
/datum/component/exhile/proc/check_move(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(Dir != launch_dir)
		qdel(src)
