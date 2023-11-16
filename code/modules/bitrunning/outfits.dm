/datum/outfit/cyber_police
	name = "Cyber Police"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/cyber_police
	uniform = /obj/item/clothing/under/suit/black_really
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	/// A list of hex codes for blonde, brown, black, and red hair.
	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		"#000000",
		"#8D4A43",
		"#D2B48C",
	)
	/// List of business ready styles
	var/static/list/approved_hairstyles = list(
		/datum/sprite_accessory/hair/business,
		/datum/sprite_accessory/hair/business2,
		/datum/sprite_accessory/hair/business3,
		/datum/sprite_accessory/hair/business4,
		/datum/sprite_accessory/hair/mulder,
	)

/datum/outfit/cyber_police/pre_equip(mob/living/carbon/human/user, visualsOnly)
	var/datum/sprite_accessory/hair/picked_hair = pick(approved_hairstyles)
	var/picked_color = pick(approved_hair_colors)

	if(visualsOnly)
		picked_hair = /datum/sprite_accessory/hair/business
		picked_color = "#4B3D28"

	user.set_facial_hairstyle("Shaved", update = FALSE)
	user.set_haircolor(picked_color, update = FALSE)
	user.set_hairstyle(initial(picked_hair.name))

/datum/outfit/cyber_police/post_equip(mob/living/carbon/human/user, visualsOnly)
	var/obj/item/clothing/under/officer_uniform = user.w_uniform
	if(officer_uniform)
		officer_uniform.has_sensor = NO_SENSORS
		officer_uniform.sensor_mode = SENSOR_OFF
		user.update_suit_sensors()

/datum/outfit/echolocator
	name = "Bitrunning Echolocator"
	glasses = /obj/item/clothing/glasses/blindfold
	ears = /obj/item/radio/headset/psyker //Navigating without these is horrible.
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	id = /obj/item/card/id/advanced

/datum/outfit/echolocator/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()
	user.psykerize()
