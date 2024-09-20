/// Collects information displayed about src when examined by a user with a medical HUD.
/mob/living/carbon/human/get_medhud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = ..()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/undershirt = w_uniform
		var/sensor_text = undershirt.get_sensor_text()
		if(sensor_text)
			. += "Sensor Status: [sensor_text]"
