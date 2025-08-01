/// Responsible for showing the insides of a closet to those inside it.
/datum/closet_see_inside
	var/obj/structure/closet/closet

	var/image/background_image
	var/image/contents_image

	var/list/client/clients_looking_at_image = list()

	var/door_alpha = 85

/datum/closet_see_inside/New(obj/structure/closet/closet)
	src.closet = closet

	RegisterSignal(closet, COMSIG_ATOM_ENTERED, PROC_REF(on_atom_entered))
	RegisterSignal(closet, COMSIG_ATOM_EXITED, PROC_REF(on_atom_exited))

/datum/closet_see_inside/Destroy(force)
	if (contents_image)
		for (var/client/looking_at_image as anything in clients_looking_at_image)
			looking_at_image.images -= background_image
			looking_at_image.images -= contents_image

		contents_image.vis_contents.Cut()

	clients_looking_at_image.Cut()


	return ..()

/datum/closet_see_inside/proc/create_image()
	contents_image = new
	contents_image.loc = closet
	contents_image.appearance_flags |= KEEP_TOGETHER

	background_image = image(
		icon = closet.icon,
		icon_state = closet.base_icon_state == null ? initial(closet.icon_state) : closet.base_icon_state,
		loc = closet,
		layer = BELOW_OBJ_LAYER,
	)
	background_image.color = COLOR_GRAY
	background_image.opacity = MOUSE_OPACITY_TRANSPARENT
	background_image.override = TRUE

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

	if (closet.enable_door_overlay)
		var/obj/effect/overlay/door = new
		door.icon = closet.icon
		door.icon_state = "[closet.icon_door || background_image.icon_state]_door"
		door.alpha = door_alpha
		door.layer = ABOVE_ALL_MOB_LAYER
		door.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		contents_image.vis_contents += door

	for (var/atom/movable/movable in closet)
		contents_image.vis_contents += movable

/datum/closet_see_inside/proc/on_atom_entered(obj/structure/closet/source, atom/movable/arrived)
	SIGNAL_HANDLER

	if (contents_image)
		contents_image.vis_contents += arrived

	if (ismob(arrived))
		var/mob/arrived_mob = arrived
		var/client/client = GET_CLIENT(arrived_mob)
		if (client)
			create_image()
			clients_looking_at_image += client
			client.images += background_image
			client.images += contents_image

/datum/closet_see_inside/proc/on_atom_exited(obj/structure/closet/source, atom/movable/exited)
	SIGNAL_HANDLER

	if (!contents_image)
		return

	contents_image.vis_contents -= exited

	if (ismob(exited))
		var/mob/exited_mob = exited
		var/client/client = GET_CLIENT(exited_mob)
		if (client)
			clients_looking_at_image -= client
			client.images -= background_image
			client.images -= contents_image
