
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 21

/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	inhand_icon_state = "camera"
	worn_icon_state = "camera"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_system = MOVABLE_LIGHT //Used as a flash here.
	light_range = 8
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	light_on = FALSE
	atom_size = ITEM_SIZE_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_NECK
	custom_materials = list(/datum/material/iron = 50, /datum/material/glass = 150)
	custom_price = PAYCHECK_EASY * 2
	var/flash_enabled = TRUE
	var/state_on = "camera"
	var/state_off = "camera_off"
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/cooldown = 64
	var/blending = FALSE //lets not take pictures while the previous is still processing!
	var/see_ghosts = CAMERA_NO_GHOSTS //for the spoop of it
	var/obj/item/disk/holodisk/disk
	var/sound/custom_sound
	var/silent = FALSE
	var/picture_size_x = 2
	var/picture_size_y = 2
	var/picture_size_x_min = 1
	var/picture_size_y_min = 1
	var/picture_size_x_max = 4
	var/picture_size_y_max = 4
	var/can_customise = TRUE
	var/default_picture_name

/obj/item/camera/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/camera), SHELL_CAPACITY_SMALL)

/obj/item/camera/attack_self(mob/user)
	if(!disk)
		return
	to_chat(user, span_notice("You eject [disk] out the back of [src]."))
	user.put_in_hands(disk)
	disk = null

/obj/item/camera/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to change its focusing, allowing you to set how big of an area it will capture.")

/obj/item/camera/proc/adjust_zoom(mob/user)
	var/desired_x = input(user, "How wide do you want the camera to shoot, between [picture_size_x_min] and [picture_size_x_max]?", "Zoom", picture_size_x) as num|null

	if (isnull(desired_x))
		return

	var/desired_y = input(user, "How high do you want the camera to shoot, between [picture_size_y_min] and [picture_size_y_max]?", "Zoom", picture_size_y) as num|null

	if (isnull(desired_y))
		return

	picture_size_x = min(clamp(desired_x, picture_size_x_min, picture_size_x_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	picture_size_y = min(clamp(desired_y, picture_size_y_min, picture_size_y_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)

/obj/item/camera/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	adjust_zoom(user)

/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, span_notice("[src] still has some film in it!"))
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, span_notice("You insert [I] into [src]."))
		qdel(I)
		pictures_left = pictures_max
		return
	if(istype(I, /obj/item/disk/holodisk))
		if (!disk)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, span_warning("[I] is stuck to your hand!"))
				return TRUE
			to_chat(user, span_notice("You slide [I] into the back of [src]."))
			disk = I
		else
			to_chat(user, span_warning("There's already a disk inside [src]."))
		return TRUE //no afterattack
	..()

/obj/item/camera/examine(mob/user)
	. = ..()
	. += "It has [pictures_left] photos left."

//user can be atom or mob
/obj/item/camera/proc/can_target(atom/target, mob/user, prox_flag)
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
		else if(!(get_turf(target) in get_hear(world.view, user)))
			return FALSE
	else //user is an atom or null
		if(!(get_turf(target) in view(world.view, user || src)))
			return FALSE
	return TRUE

/obj/item/camera/afterattack(atom/target, mob/user, flag)
	if (disk)
		if(ismob(target))
			if (disk.record)
				QDEL_NULL(disk.record)

			disk.record = new
			var/mob/M = target
			disk.record.caller_name = M.name
			disk.record.set_caller_image(M)
		else
			to_chat(user, span_warning("Invalid holodisk target."))
			return

	if(!can_target(target, user, flag))
		return

	on = FALSE
	addtimer(CALLBACK(src, .proc/cooldown), cooldown)

	icon_state = state_off

	INVOKE_ASYNC(src, .proc/captureimage, target, user, picture_size_x - 1, picture_size_y - 1)


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
		addtimer(CALLBACK(src, .proc/flash_end), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)
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
	var/clone_area = SSmapping.RequestBlockReservation(size_x * 2 + 1, size_y * 2 + 1)
	for(var/turf/placeholder in block(locate(target_turf.x - size_x, target_turf.y - size_y, target_turf.z), locate(target_turf.x + size_x, target_turf.y + size_y, target_turf.z)))
		var/turf/T = placeholder
		while(istype(T, /turf/open/openspace)) //Multi-z photography
			T = SSmapping.get_turf_below(T)
			if(!T)
				break

		if(T && ((ai_user && GLOB.cameranet.checkTurfVis(placeholder)) || (placeholder in seen)))
			turfs += T
			for(var/mob/M in T)
				mobs += M
			if(locate(/obj/item/areaeditor/blueprints) in T)
				blueprints = TRUE
	for(var/i in mobs)
		var/mob/M = i
		mobs_spotted += M
		if(M.stat == DEAD)
			dead_spotted += M
		desc += M.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size
	var/icon/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	get_icon.Blend("#000", ICON_UNDERLAY)

	var/datum/picture/picture = new("picture", desc.Join(" "), mobs_spotted, dead_spotted, get_icon, null, psize_x, psize_y, blueprints, can_see_ghosts = see_ghosts)
	after_picture(user, picture)
	SEND_SIGNAL(src, COMSIG_CAMERA_IMAGE_CAPTURED, target, user)
	blending = FALSE


/obj/item/camera/proc/flash_end()
	set_light_on(FALSE)


/obj/item/camera/proc/after_picture(mob/user, datum/picture/picture)
	printpicture(user, picture)

/obj/item/camera/proc/printpicture(mob/user, datum/picture/picture) //Normal camera proc for creating photos
	var/obj/item/photo/p = new(get_turf(src), picture)
	if(user && in_range(src, user)) //needed because of TK
		if(!ispAI(user))
			user.put_in_hands(p)
			pictures_left--
			to_chat(user, span_notice("[pictures_left] photos left."))
		var/customise = "No"
		if(can_customise)
			customise = tgui_alert(user, "Do you want to customize the photo?", "Customization", list("Yes", "No"))
		if(customise == "Yes")
			var/name1 = tgui_input_text(user, "Set a name for this photo, or leave blank.", "Name", max_length = 32)
			var/desc1 = tgui_input_text(user, "Set a description to add to photo, or leave blank.", "Description", max_length = 128)
			var/caption = tgui_input_text(user, "Set a caption for this photo, or leave blank.", "Caption", max_length = 256)
			if(name1)
				picture.picture_name = name1
			if(desc1)
				picture.picture_desc = "[desc1] - [picture.picture_desc]"
			if(caption)
				picture.caption = caption
		else
			if(default_picture_name)
				picture.picture_name = default_picture_name

	p.set_picture(picture, TRUE, TRUE)
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
	adjust_size_x = add_input_port("Picture Size X", PORT_TYPE_NUMBER, trigger = .proc/sanitize_picture_size)
	adjust_size_y = add_input_port("Picture Size Y", PORT_TYPE_NUMBER, trigger = .proc/sanitize_picture_size)

/obj/item/circuit_component/camera/register_shell(atom/movable/shell)
	. = ..()
	camera = shell
	RegisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED, .proc/on_image_captured)

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
	INVOKE_ASYNC(camera, /obj/item/camera.proc/captureimage, target, null, camera.picture_size_y  - 1, camera.picture_size_y - 1)

#undef CAMERA_PICTURE_SIZE_HARD_LIMIT
