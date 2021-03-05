/**
 * The exile component: When you really, really want to get rid of someone, shoot them into space!
 */
/datum/component/exile
	var/launch_dir

/datum/component/exile/Initialize(direction)
	. = ..()
	launch_dir = direction

/datum/component/exile/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, .proc/check_z)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_move)

/datum/component/exile/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOVABLE_MOVED))

/// If the exilee crosses into a new z-level without breaking their course after being shot into space, send them to hell
/datum/component/exile/proc/check_z()
	SIGNAL_HANDLER

	var/mob/living/exilee = parent
	if(!istype(exilee) || !exilee.client)
		qdel(src)
		return
	var/youre_on_your_way_to = CONFIG_GET(string/hell)
	if(world.url == CONFIG_GET(string/hell))
		youre_on_your_way_to = CONFIG_GET(string/the_abyss)
	if(!youre_on_your_way_to)
		qdel(src)
		return

	to_chat(exilee, "<span class='userdanger'>Oh no! You've been shot into space and are flying towards another station!</span>")
	var/list/exile_info = list()
	exile_info["expected_ckey"] = exilee.ckey
	exile_info["name"] = exilee.real_name
	exile_info["dir"] = launch_dir
	var/client/exilee_client = exilee.client
	send2otherserver(station_name(), null, "incoming_exile", youre_on_your_way_to, exile_info)
	exilee_client << link(youre_on_your_way_to)
	exilee.dust()
	qdel(src)

/// If the exilee breaks their course before hitting the z-level, they saved themselves
/datum/component/exile/proc/check_move(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(Dir != launch_dir)
		qdel(src)
