/datum/element/service_style

/datum/element/service_style/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE

	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		"#000000",
		"#8D4A43",
		"#D2B48C",
	)

	var/static/list/approved_hairstyles = list(
		/datum/sprite_accessory/hair/business,
		/datum/sprite_accessory/hair/business2,
		/datum/sprite_accessory/hair/business3,
		/datum/sprite_accessory/hair/business4,
		/datum/sprite_accessory/hair/mulder,
	)

	var/datum/sprite_accessory/hair/picked_hair = pick(approved_hairstyles)
	var/picked_color = pick(approved_hair_colors)

	var/mob/living/carbon/human/player = target
	player.set_facial_hairstyle("Shaved", update = FALSE)
	player.set_haircolor(picked_color, update = FALSE)
	player.set_hairstyle(initial(picked_hair.name))
