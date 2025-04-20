
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 21

/obj/item/camera
	name = "camera"
	icon = 'icons/obj/art/camera.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	inhand_icon_state = "camera"
	worn_icon_state = "camera"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	light_system = OVERLAY_LIGHT_DIRECTIONAL //Used as a flash here.
	light_range = 6
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	light_on = FALSE
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_NECK
	custom_materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT*1.5)
	custom_price = PAYCHECK_CREW * 2

	/// Cooldown before we can take another picture.
	var/cooldown = 6.4 SECONDS
	/// Whether we are currently ready to take a picture.
	var/on = TRUE
	/// Whether we are still processing an image.
	var/blending = FALSE
	/// Our icon_state when ready to take a picture.
	var/state_on = "camera"
	/// Our icon_state when not ready to take a picture.
	var/state_off = "camera_off"

	/// The maximum amount of pictures we can take before needing new film.
	var/pictures_max = 10
	/// The amount of pictures we can still take before needing new film.
	var/pictures_left = 10
	/// Currently inserted holorecord disk.
	var/obj/item/disk/holodisk/disk

	/// Whether we flash upon taking a picture.
	var/flash_enabled = TRUE
	/// Whether we silence our picture taking and zoom adjusting sounds.
	var/silent = FALSE
	/// To what degree ghosts are visible in our pictures.
	var/see_ghosts = CAMERA_NO_GHOSTS //for the spoop of it
	/// Whether the camera should print pictures immediately when a picture is taken.
	var/print_picture_on_snap = TRUE
	/// Whether we allow setting picture label/desc/scribble when a picture is taken.
	var/can_customise = TRUE
	/// Picture name we default to when none is set manually.
	var/default_picture_name

	var/picture_size_x = 2
	var/picture_size_y = 2
	var/picture_size_x_min = 1
	var/picture_size_y_min = 1
	var/picture_size_x_max = 4
	var/picture_size_y_max = 4

/obj/item/camera/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/camera, new /obj/item/circuit_component/remotecam/polaroid), SHELL_CAPACITY_SMALL)
	register_context()

/obj/item/camera/examine(mob/user)
	. = ..()
	. += span_notice("It has [pictures_left] photos left.")
	. += span_notice("Alt-click to change its focusing, allowing you to set how big of an area it will capture.")

	if(isnull(disk))
		. += span_notice("It has a slot for a holorecord disk.")
	else
		. += span_notice("It has \an [disk.name] inserted.")

/obj/item/camera/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Adjust Zoom"

	if(istype(held_item, /obj/item/camera_film))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Film"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/disk/holodisk))
		context[SCREENTIP_CONTEXT_LMB] = disk ? "Swap Disks" : "Insert Disk"
		return CONTEXTUAL_SCREENTIP_SET

	if((isnull(held_item) || (held_item == src)) && disk)
		context[SCREENTIP_CONTEXT_LMB] = "Eject Disk"
		return CONTEXTUAL_SCREENTIP_SET

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/camera/proc/adjust_zoom(mob/user)
	if(loc != user)
		to_chat(user, span_warning("You must be holding the camera to continue!"))
		return FALSE
	var/desired_x = tgui_input_number(user, "How wide do you want the camera to shoot?", "Zoom", picture_size_x, picture_size_x_max, picture_size_x_min)
	if(!desired_x || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || loc != user)
		return FALSE
	var/desired_y = tgui_input_number(user, "How high do you want the camera to shoot", "Zoom", picture_size_y, picture_size_y_max, picture_size_y_min)
	if(!desired_y || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || loc != user)
		return FALSE
	picture_size_x = min(clamp(desired_x, picture_size_x_min, picture_size_x_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	picture_size_y = min(clamp(desired_y, picture_size_y_min, picture_size_y_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	return TRUE

/obj/item/camera/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == disk)
		disk = null

/obj/item/camera/click_alt(mob/user)
	if(!adjust_zoom(user))
		return CLICK_ACTION_BLOCKING
	if(silent) // Don't out your silent cameras
		user.playsound_local(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	else
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return CLICK_ACTION_SUCCESS

/obj/item/camera/attack_self(mob/user)
	if(isnull(disk))
		return
	playsound(src, 'sound/machines/card_slide.ogg', 50)
	user.put_in_hands(disk)
	disk = null

/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/camera/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/camera_film))
		return camera_film_act(user, tool)
	if(istype(tool, /obj/item/disk/holodisk))
		return holodisk_act(user, tool)

/obj/item/camera/proc/camera_film_act(mob/living/user, obj/item/camera_film/new_film)
	if(pictures_left)
		balloon_alert(user, "isn't empty!")
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(new_film))
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	qdel(new_film)
	pictures_left = pictures_max
	return ITEM_INTERACT_SUCCESS

/obj/item/camera/proc/holodisk_act(mob/living/user, obj/item/disk/holodisk/new_disk)
	if(!user.transferItemToLoc(new_disk, src))
		balloon_alert(user, "stuck in hand!")
		return TRUE
	if(disk)
		user.put_in_hands(disk)
		balloon_alert(user, "disks swapped!")
	else
		balloon_alert(user, "disk inserted!")
	playsound(src, 'sound/machines/card_slide.ogg', 50)
	disk = new_disk
	return ITEM_INTERACT_SUCCESS

//user can be atom or mob
/obj/item/camera/proc/can_target(atom/target, mob/user)
	if(!on || blending || !pictures_left)
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(istype(user))
		if(isAI(user) && !GLOB.cameranet.checkTurfVis(T))
			return FALSE
		else if(user.client && !(get_turf(target) in get_hear(user.client.view, user)))
			return FALSE
		else if(!(get_turf(target) in get_hear(CONFIG_GET(string/default_view), user)))
			return FALSE
	else if(isliving(loc))
		if(!(get_turf(target) in view(world.view, loc)))
			return FALSE
	else //user is an atom or null
		if(!(get_turf(target) in view(world.view, user || src)))
			return FALSE
	return TRUE

/obj/item/camera/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// Always skip on storage and tables
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE

	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/camera/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(disk)
		if(!ismob(interacting_with))
			to_chat(user, span_warning("Invalid holodisk target."))
			return ITEM_INTERACT_BLOCKING
		if(disk.record)
			QDEL_NULL(disk.record)

		disk.record = new
		var/mob/recorded_mob = interacting_with
		disk.record.caller_name = recorded_mob.name
		disk.record.set_caller_image(recorded_mob)

	if(!can_target(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	if(!photo_taken(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/item/camera/proc/photo_taken(atom/target, mob/user)

	on = FALSE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown)

	icon_state = state_off

	INVOKE_ASYNC(src, PROC_REF(captureimage), target, user, picture_size_x - 1, picture_size_y - 1)
	return TRUE

/obj/item/camera/proc/cooldown()
	UNTIL(!blending)
	icon_state = state_on
	on = TRUE

/obj/item/camera/proc/show_picture(mob/user, datum/picture/selection)
	var/obj/item/photo/P = new(src, selection)
	P.show(user)
	to_chat(user, P.desc)
	qdel(P)

/obj/item/camera/proc/captureimage(atom/target, mob/user, size_x = 1, size_y = 1)
	if(flash_enabled)
		set_light_on(TRUE)
		addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)
	blending = TRUE
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		blending = FALSE
		return FALSE
	size_x = clamp(size_x, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	size_y = clamp(size_y, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	var/list/desc = list("This is a photo of an area of [size_x+1] meters by [size_y+1] meters.")
	var/list/mobs_spotted = list()
	var/list/dead_spotted = list()
	var/ai_user = isAI(user)
	var/list/seen
	var/list/viewlist = user?.client ? getviewsize(user.client.view) : getviewsize(world.view)
	var/viewr = max(viewlist[1], viewlist[2]) + max(size_x, size_y)
	var/viewc = user?.client ? user.client.eye : target
	seen = get_hear(viewr, viewc)
	var/list/turfs = list()
	var/list/mobs = list()
	var/blueprints = FALSE
	var/clone_area = SSmapping.request_turf_block_reservation(size_x * 2 + 1, size_y * 2 + 1, 1)
	///list of human names taken on picture
	var/list/names = list()

	var/width = size_x * 2 + 1
	var/height = size_y * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, width, height, -size_x, -size_y))
		while(istype(placeholder, /turf/open/openspace)) //Multi-z photography
			placeholder = GET_TURF_BELOW(placeholder)
			if(!placeholder)
				break

		if(placeholder && ((ai_user && GLOB.cameranet.checkTurfVis(placeholder)) || (placeholder in seen)))
			turfs += placeholder
			for(var/mob/M in placeholder)
				mobs += M
			if(locate(/obj/item/blueprints) in placeholder)
				blueprints = TRUE

	// do this before picture is taken so we can reveal revenants for the photo
	steal_souls(mobs)

	for(var/mob/mob as anything in mobs)
		mobs_spotted += mob
		if(mob.stat == DEAD)
			dead_spotted += mob
		desc += mob.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * ICON_SIZE_X
	var/psize_y = (size_y * 2 + 1) * ICON_SIZE_Y
	var/icon/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	get_icon.Blend("#000", ICON_UNDERLAY)
	for(var/mob/living/carbon/human/person in mobs)
		if(person.is_face_visible())
			names += "[person.name]"

	var/datum/picture/picture = new("picture", desc.Join("<br>"), mobs_spotted, dead_spotted, names, get_icon, null, psize_x, psize_y, blueprints, can_see_ghosts = see_ghosts)
	after_picture(user, picture)
	SEND_SIGNAL(src, COMSIG_CAMERA_IMAGE_CAPTURED, target, user, picture)
	blending = FALSE
	return picture

/obj/item/camera/proc/flash_end()
	set_light_on(FALSE)

/obj/item/camera/proc/steal_souls(list/victims)
	return

/obj/item/camera/proc/after_picture(mob/user, datum/picture/picture)
	if(print_picture_on_snap)
		printpicture(user, picture)

	if(!silent)
		playsound(loc, SFX_POLAROID, 75, TRUE, -3)

/obj/item/camera/proc/printpicture(mob/user, datum/picture/picture) //Normal camera proc for creating photos
	pictures_left--
	var/obj/item/photo/new_photo = new(get_turf(src), picture)
	if(user)
		if(in_range(new_photo, user) && user.put_in_hands(new_photo)) //needed because of TK
			to_chat(user, span_notice("[pictures_left] photos left."))

		var/name_customized = FALSE
		if(can_customise)
			var/customise = user.is_holding(new_photo) && tgui_alert(user, "Do you want to customize the photo?", "Customization", list("Yes", "No"))
			if(customise == "Yes")
				var/name1 = user.is_holding(new_photo) && tgui_input_text(user, "Set a name for this photo, or leave blank.", "Name", max_length = 32)
				var/desc1 = user.is_holding(new_photo) && tgui_input_text(user, "Set a description to add to photo, or leave blank.", "Description", max_length = 128)
				var/caption = user.is_holding(new_photo) && tgui_input_text(user, "Set a caption for this photo, or leave blank.", "Caption", max_length = 256)
				if(name1)
					picture.picture_name = name1
					name_customized = TRUE
				if(desc1)
					picture.picture_desc = "[desc1] - [picture.picture_desc]"
				if(caption)
					picture.caption = caption
		if(!name_customized && default_picture_name)
			picture.picture_name = default_picture_name

	else if(isliving(loc))
		var/mob/living/holder = loc
		if(holder.put_in_hands(new_photo))
			to_chat(holder, span_notice("[pictures_left] photos left."))

	new_photo.set_picture(picture, TRUE, TRUE)
	if(CONFIG_GET(flag/picture_logging_camera))
		picture.log_to_file()

/obj/item/circuit_component/camera
	display_name = "Camera"
	desc = "A polaroid camera that takes pictures when triggered. The picture coordinate ports are relative to the position of the camera."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The atom that was photographed from either user click or trigger input.
	var/datum/port/output/photographed_atom
	/// The item that was added/removed.
	var/datum/port/output/picture_taken
	/// If set, the trigger input will target this atom.
	var/datum/port/input/picture_target
	/// If the above is unset, these coordinates will be used.
	var/datum/port/input/picture_coord_x
	var/datum/port/input/picture_coord_y
	/// Adjusts the picture_size_x variable of the camera.
	var/datum/port/input/adjust_size_x
	/// Idem but for picture_size_y.
	var/datum/port/input/adjust_size_y

	/// The camera this circut is attached to.
	var/obj/item/camera/camera

/obj/item/circuit_component/camera/populate_ports()
	picture_taken = add_output_port("Picture Taken", PORT_TYPE_SIGNAL)
	photographed_atom = add_output_port("Photographed Entity", PORT_TYPE_ATOM)

	picture_target = add_input_port("Picture Target", PORT_TYPE_ATOM)
	picture_coord_x = add_input_port("Picture Coordinate X", PORT_TYPE_NUMBER)
	picture_coord_y = add_input_port("Picture Coordinate Y", PORT_TYPE_NUMBER)
	adjust_size_x = add_input_port("Picture Size X", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))
	adjust_size_y = add_input_port("Picture Size Y", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))

/obj/item/circuit_component/camera/register_shell(atom/movable/shell)
	. = ..()
	camera = shell
	RegisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/camera/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED)
	camera = null
	return ..()

/obj/item/circuit_component/camera/proc/sanitize_picture_size()
	camera.picture_size_x = clamp(adjust_size_x.value, camera.picture_size_x_min, camera.picture_size_x_max)
	camera.picture_size_y = clamp(adjust_size_y.value, camera.picture_size_y_min, camera.picture_size_y_max)

/obj/item/circuit_component/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed_atom.set_output(target)
	picture_taken.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/camera/input_received(datum/port/input/port)
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		target = locate(our_turf.x + picture_coord_x.value, our_turf.y + picture_coord_y.value, our_turf.z)
		if(!target)
			return
	if(!camera.can_target(target))
		return
	INVOKE_ASYNC(camera, TYPE_PROC_REF(/obj/item/camera, captureimage), target, null, camera.picture_size_x  - 1, camera.picture_size_y - 1)

#undef CAMERA_PICTURE_SIZE_HARD_LIMIT
