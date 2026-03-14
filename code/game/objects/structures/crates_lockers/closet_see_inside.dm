/// Responsible for showing the insides of a closet to those inside it.
/datum/closet_see_inside
	///Closet grayed out image so players can click on it to get out of closet
	var/image/background_image
	///Stuff inside closet image
	var/image/contents_image

/datum/closet_see_inside/New(obj/structure/closet/closet)
	RegisterSignal(closet, COMSIG_CLOSET_PRE_OPEN, PROC_REF(on_closet_pre_open))
	RegisterSignal(closet, COMSIG_CLOSET_POST_CLOSE, PROC_REF(on_closet_closed))

/datum/closet_see_inside/Destroy(force)
	on_closet_pre_open(src)
	return ..()

/**
 * Creates the closet background & contents image to display for the client
 *
 * Arguments
 * * obj/structure/closet/closet - the closet whose insides we are taking a snapshot of
*/
/datum/closet_see_inside/proc/create_image(obj/structure/closet/closet)
	PRIVATE_PROC(TRUE)

	if(contents_image)
		return

	///closet grayed out image
	background_image = image(
		icon = closet.icon,
		icon_state = isnull(closet.base_icon_state) ? initial(closet.icon_state) : closet.base_icon_state,
		loc = closet,
		layer = BELOW_OBJ_LAYER,
	)
	background_image.color = COLOR_GRAY
	background_image.opacity = MOUSE_OPACITY_TRANSPARENT
	background_image.override = TRUE

	//all stuff inside the closet image
	contents_image = new
	contents_image.loc = closet
	contents_image.appearance_flags |= KEEP_TOGETHER
	contents_image.add_filter(
		"mask",
		1,
		list(
			type = "alpha",
			icon = icon('icons/effects/closet_see_inside_mask.dmi', "mask"),
			y = -3,
		)
	)
	contents_image.add_filter(
		"color",
		2,
		list(
			type = "color",
			color = COLOR_GRAY,
		)
	)

	//door & contents to add to image
	if (closet.enable_door_overlay)
		var/obj/effect/overlay/door = new
		door.icon = closet.icon
		door.icon_state = "[closet.icon_door || background_image.icon_state]_door"
		door.alpha = 85
		door.layer = ABOVE_ALL_MOB_LAYER
		door.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		contents_image.vis_contents += door
	for (var/atom/movable/movable in closet)
		contents_image.vis_contents += movable

/datum/closet_see_inside/proc/on_closet_pre_open(obj/structure/closet/source, mob/user)
	SIGNAL_HANDLER

	if(contents_image)
		for(var/atom/movable/movable in source)
			if(ismob(movable))
				var/client/client = GET_CLIENT(astype(movable, /mob))
				if (client)
					client.images -= background_image
					client.images -= contents_image
		contents_image.vis_contents.Cut()

/datum/closet_see_inside/proc/on_closet_closed(obj/structure/closet/source, mob/user)
	SIGNAL_HANDLER

	for(var/atom/movable/movable in source)
		if(ismob(movable))
			var/client/client = GET_CLIENT(astype(movable, /mob))
			if (client)
				create_image(source)
				client.images += background_image
				client.images += contents_image
		if(contents_image)
			contents_image.vis_contents += movable
