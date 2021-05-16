///Allows you to set a theme for a set of areas without tying them to looping sounds explicitly
/datum/component/area_sound_manager
	//area -> looping sound type
	var/list/area_to_looping_type = list()
	//Current sound loop
	var/datum/looping_sound/our_loop

/datum/component/area_sound_manager/Initialize(area_loop_pairs)
	if(!ismovable(parent))
		return
	area_to_looping_type = area_loop_pairs
	change_the_track()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/react_to_move)

/datum/component/area_sound_manager/Destroy(force, silent)
	QDEL_NULL(our_loop)
	. = ..()

/datum/component/area_sound_manager/proc/react_to_move(datum/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	var/list/loop_lookup = area_to_looping_type
	if(loop_lookup[get_area(oldloc)] == loop_lookup[get_area(parent.loc)])
		return
	change_the_track()

/datum/component/area_sound_manager/proc/change_the_track()
	if(our_loop)
		qdel(our_loop)

	var/area/our_area = get_area(parent)
	var/new_loop_type = area_to_looping_type[our_area]
	if(!new_loop_type)
		return

	our_loop = new new_loop_type(parent, FALSE, TRUE)

	var/time_offset = 0
	var/our_id = our_loop.timerid
	if(our_id)
		var/time_remaining = timeleft(our_id, SSsound_loops)
		//If the time remaining is less then start length, cull start length a bit so things sound cohesive
		//If it's greater, offset it a bit so we don't clash audio
		our_loop.start_length -= our_loop.start_length - time_remaining

	our_loop.start()
