/datum/component/hovering_information
	var/datum/hover_data/hover_information_data
	var/trait_to_check

/datum/component/hovering_information/Initialize(datum/hover_data/hover_information_data, trait_to_check)
	. = ..()
	if(!hover_information_data)
		return
	var/datum/hover_data/new_hover_data = new hover_information_data(src, parent)
	src.hover_information_data = new_hover_data
	src.trait_to_check = trait_to_check

/datum/component/hovering_information/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(mouse_entered))

/datum/component/hovering_information/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_MOUSE_ENTERED)

/datum/component/hovering_information/Destroy(force, silent)
	. = ..()
	QDEL_NULL(hover_information_data)

/datum/component/hovering_information/proc/mouse_entered(datum/source, mob/living/enterer)
	if(trait_to_check && !HAS_TRAIT(enterer, trait_to_check))
		return
	if(!enterer.client)
		return
	hover_information_data.setup_data(parent, enterer)
	RegisterSignal(enterer.client, COMSIG_CLIENT_HOVER_NEW, PROC_REF(clear_hover))

/datum/component/hovering_information/proc/clear_hover(client/source)
	UnregisterSignal(source, COMSIG_CLIENT_HOVER_NEW)
	hover_information_data.clear_data(parent, source.mob)


/datum/hover_data
	var/list/images_per_client = list()

/datum/hover_data/Destroy(force, ...)
	. = ..()
	if(length(images_per_client))
		for(var/key in images_per_client)
			for(var/client/client in GLOB.clients)
				if(client.ckey != key)
					continue
				remove_client_images(client)

/datum/hover_data/New(datum/component/hovering_information, atom/parent)

/datum/hover_data/proc/setup_data(atom/source, mob/enterer)

/datum/hover_data/proc/clear_data(atom/source, mob/leaver)
	remove_client_images(leaver.client)

/datum/hover_data/proc/add_client_image(image/new_image, client/giver)
	giver.images += new_image
	images_per_client |= giver.ckey
	if(!islist(images_per_client[giver.ckey]))
		images_per_client[giver.ckey] = list()
	images_per_client[giver.ckey] += new_image

/datum/hover_data/proc/remove_client_images(client/remover)
	for(var/image/listed_image as anything in images_per_client[remover.ckey])
		remover.images -= listed_image
		images_per_client[remover.ckey] -= listed_image
		qdel(listed_image)

/obj/effect/overlay/hover
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	layer = ABOVE_HUD_PLANE
	plane = GAME_PLANE_UPPER
