/datum/hover_data/chicken_info
	var/obj/effect/overlay/hover/chicken_egg

/datum/hover_data/chicken_info/Destroy(force, ...)
	. = ..()
	qdel(chicken_egg)

/datum/hover_data/chicken_info/New(datum/component/hovering_information, mob/living/basic/chicken/parent)
	. = ..()
	chicken_egg = new(null)
	var/obj/item/food/egg/egg = parent.egg_type
	chicken_egg.icon_state = initial(egg.icon_state)
	chicken_egg.icon = initial(egg.icon)
	chicken_egg.pixel_y = 10
	chicken_egg.pixel_x = -22
	chicken_egg.maptext_x = 24
	chicken_egg.maptext_y = 10

/datum/hover_data/chicken_info/setup_data(mob/living/basic/chicken/source, mob/enterer)
	chicken_egg.maptext = "x[source.eggs_left]"

	var/image/new_image = new(source)
	new_image.appearance = chicken_egg.appearance
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)

