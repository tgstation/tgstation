/**
 * The exile component: When you really, really want to get rid of someone, shoot them into space!
 */
/datum/component/exile
	var/launch_dir

	var/fails_allowed = 3

/datum/component/exile/Destroy(force, silent)
	testing("Removing exile from [parent]")
	. = ..()


/datum/component/exile/Initialize(direction)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	launch_dir = direction

/datum/component/exile/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, .proc/check_z)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_move)

/datum/component/exile/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOVABLE_MOVED))

/// If the exilee crosses into a new z-level without breaking their course after being shot into space, send them to hell
/datum/component/exile/proc/check_z()
	SIGNAL_HANDLER

	testing("checking new z-level")
	var/mob/living/exilee = parent
	if(!istype(exilee) || !exilee.client)
		qdel(src)
		return
	var/youre_on_your_way_to = CONFIG_GET(string/hell)
	if(world.url == CONFIG_GET(string/hell))
		youre_on_your_way_to = CONFIG_GET(string/the_abyss)
	if(!youre_on_your_way_to)
		testing("not on way anywhere")
		qdel(src)
		return

	to_chat(exilee, "<span class='userdanger'>Oh no! You've been shot into space and are flying towards another station!</span>")
	var/list/exile_info = list()
	exile_info["expected_ckey"] = exilee.ckey
	exile_info["name"] = exilee.real_name
	exile_info["dir"] = launch_dir
	var/client/exilee_client = exilee.client

	deadchat_broadcast("[exilee.real_name] has been shot towards another station by a mass-driver!")
	message_admins("[exilee.real_name] ([exilee.ckey]) has been shot towards another server ([youre_on_your_way_to]) by a mass-driver.")

	send2otherserver(station_name(), null, "incoming_exile", youre_on_your_way_to, exile_info)
	//exilee_client << link(youre_on_your_way_to)
	exilee.dust()
	qdel(src)

/// If the exilee breaks their course before hitting the z-level, they saved themselves
/datum/component/exile/proc/check_move(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	testing("moved")
	if(Dir != launch_dir)
		fails_allowed--
		testing("checkmove failed [fails_allowed]")
		if(fails_allowed <= 0)
			qdel(src)
