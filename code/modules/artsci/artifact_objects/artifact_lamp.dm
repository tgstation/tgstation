/obj/structure/artifact/lamp
	assoc_datum = /datum/artifact/lamp
	light_system = MOVABLE_LIGHT
	light_on = FALSE
/datum/artifact/lamp
	associated_object = /obj/structure/artifact/lamp
	weight = 450
	type_name = "Lamp"
	activation_message = span_notice("starts shining!")
	deactivation_message = "stops shining."

/datum/artifact/lamp/setup()
	..()
	if(artifact_origin.type_name == ORIGIN_NARSIE)
		holder.set_light_power(3)
		holder.set_light_color(COLOR_BLACK)
	else
		holder.set_light_power(rand(0,3))
		holder.set_light_color(pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE))
	holder.set_light_range(rand(1.4,4))

/datum/artifact/lamp/effect_activate()
	holder.set_light_on(TRUE)

/datum/artifact/lamp/effect_deactivate()
	holder.set_light_on(FALSE)
	return