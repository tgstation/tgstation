/datum/antagonist/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_police/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	convert_agent()

	var/datum/martial_art/the_sleeping_carp/carp = new(src)
	carp.teach(owner.current)

/datum/outfit/cyber_police
	name = ROLE_CYBER_POLICE
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/cyber_police
	shoes = /obj/item/clothing/shoes/laceup
	uniform = /obj/item/clothing/under/suit/black_really

/datum/outfit/cyber_police/pre_equip(mob/living/carbon/human/user, visuals_only)
	if(!visuals_only)
		return

	user.set_facial_hairstyle("Shaved", update = FALSE)
	user.set_haircolor("#4B3D28", update = FALSE)
	user.set_hairstyle("Business Hair")

/datum/outfit/cyber_police/post_equip(mob/living/carbon/human/user, visuals_only)
	var/obj/item/clothing/under/officer_uniform = user.w_uniform
	if(istype(officer_uniform))
		officer_uniform.set_has_sensor(NO_SENSORS)
		officer_uniform.set_sensor_mode(SENSOR_OFF)
