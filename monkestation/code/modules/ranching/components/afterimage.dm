/datum/component/after_image
	dupe_mode =	 COMPONENT_DUPE_UNIQUE_PASSARGS
	var/rest_time
	var/list/obj/after_image/after_images

/datum/component/after_image/Initialize(count = 4, rest_time = 1)
	..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.rest_time = rest_time
	src.after_images = list()
	if(count > 1)
		for(var/number = 1 to count)
			var/obj/after_image/added_image = new /obj/after_image(null)
			added_image.finalized_alpha = 200 - 100 * (number - 1) / (count - 1)
			after_images += added_image
	else
		var/obj/after_image/added_image = new /obj/after_image(null)
		added_image.finalized_alpha = 100
		after_images |= added_image

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/move)
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, .proc/change_dir)
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, .proc/throw_landed)

/datum/component/after_image/RegisterWithParent()
	for(var/obj/after_image/listed_image in src.after_images)
		listed_image.active = TRUE
	src.sync_after_images()

/datum/component/after_image/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_THROW_LANDED))
	for(var/obj/after_image/listed_image in src.after_images)
		listed_image.active = FALSE
		qdel(listed_image)
	. = ..()

/datum/component/after_image/Destroy()
	if(length(src.after_images))
		for(var/obj/after_image/listed_image in src.after_images)
			qdel(listed_image)
		src.after_images.Cut()
		src.after_images = null
	. = ..()

/datum/component/after_image/proc/change_dir(atom/movable/AM, new_dir, old_dir)
	src.sync_after_images(new_dir)

/datum/component/after_image/proc/set_loc(atom/movable/AM, atom/last_loc)
	return src.move(AM, last_loc, AM.dir)

/datum/component/after_image/proc/move(atom/movable/AM, turf/last_turf, direct)
	src.sync_after_images()

/datum/component/after_image/proc/throw_landed(atom/movable/AM, datum/thrownthing/thing)
	src.sync_after_images() // necessary to fix pixel_x and pixel_y

/datum/component/after_image/proc/sync_after_images(dir_override=null)
	set waitfor = FALSE

	var/obj/after_image/targeted_image = new(null)
	targeted_image.active = TRUE
	targeted_image.sync_with_parent(parent)
	targeted_image.loc = null
	if(!isnull(dir_override))
		targeted_image.setDir(dir_override)
	var/atom/movable/parent_am = parent
	var/atom/target_loc = parent_am.loc
	for(var/obj/after_image/listed_image in src.after_images)
		sleep(src.rest_time)
		listed_image.sync_with_parent(targeted_image, target_loc)
	qdel(targeted_image)





/obj/after_image
	mouse_opacity = FALSE
	anchored = 2
	var/finalized_alpha = 100
	var/appearance_ref = null
	var/active = FALSE

/obj/after_image/New()
	. = ..()
	animate(src, pixel_x=0, time=1, loop=-1)
	var/count = rand(5, 10)
	for(var/number = 1 to count)
		var/time = 0.5 SECONDS + rand() * 3 SECONDS
		var/pixel_x = number == count ? 0 : rand(-2, 2)
		var/pixel_y = number == count ? 0 : rand(-2, 2)
		animate(time = time, easing = pick(LINEAR_EASING, SINE_EASING, CIRCULAR_EASING, CUBIC_EASING), flags = ANIMATION_PARALLEL, pixel_x = pixel_x, pixel_y = pixel_y, loop =- 1)

/obj/after_image/proc/sync_with_parent(atom/movable/parent, loc_override=null)
	if(!src.active)
		return
	src.name = parent.name
	src.desc = parent.desc
	src.glide_size = parent.glide_size

	var/parent_appearance_ref = ref(parent.appearance)
	if(istype(parent, /obj/after_image))
		var/obj/after_image/parent_after_image = parent
		parent_appearance_ref = parent_after_image.appearance_ref

	if(src.appearance_ref != parent_appearance_ref)
		src.appearance_ref = parent_appearance_ref
		src.appearance = parent.appearance
		src.alpha = src.alpha / 255.0 * src.finalized_alpha
		src.plane = initial(src.plane)
		src.mouse_opacity = initial(src.mouse_opacity)
		src.anchored = initial(src.anchored)

	var/atom/target_loc = loc_override ? loc_override : parent.loc

	if(target_loc != src.loc)
		src.loc = target_loc

	if(src.dir != parent.dir)
		src.setDir(parent.dir)

/obj/after_image/Destroy()
	src.active = FALSE
	. = ..()
