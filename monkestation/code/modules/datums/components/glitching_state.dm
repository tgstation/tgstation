/datum/component/glitching_state
	var/count = 5
	var/list/obj/effect/after_image/after_images

/datum/component/glitching_state/Initialize(count = 5)
	. = ..()
	var/atom/movable/movable = parent
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.after_images = list()
	src.count = count
	if(count > 1)
		for(var/number = 1 to count)
			var/obj/effect/after_image/added_image = new /obj/effect/after_image(null, time_a = 1, time_b = 5, finalized_alpha = 128 - 64 * (number - 1) / (count - 1))
			after_images += added_image
			movable.vis_contents += added_image
			added_image.active = TRUE
			added_image.sync_with_parent(parent, actual_loc = FALSE)
	else
		var/obj/effect/after_image/added_image = new /obj/effect/after_image(null, time_a = 1, time_b = 5, finalized_alpha = 64)
		after_images |= added_image
		movable.vis_contents += added_image
		added_image.active = TRUE
		added_image.sync_with_parent(parent, actual_loc = FALSE)

	START_PROCESSING(SSobj, src)

/datum/component/glitching_state/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	var/atom/movable/movable = parent
	movable?.vis_contents -= after_images
	QDEL_LIST(after_images)
	return ..()

/datum/component/glitching_state/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))

/datum/component/glitching_state/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_DIR_CHANGE)

/datum/component/glitching_state/process(seconds_per_tick)
	for(var/obj/effect/after_image/image as anything in after_images)
		image.sync_with_parent(parent, actual_loc = FALSE)

/datum/component/glitching_state/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	for(var/obj/effect/after_image/image as anything in after_images)
		image.sync_with_parent(parent, actual_loc = FALSE, dir_override = new_dir)

