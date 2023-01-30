/obj/structure/artifact/lamp
	assoc_datum = /datum/artifact/lamp
	light_system = MOVABLE_LIGHT
	light_on = FALSE
/datum/artifact/lamp
	associated_object = /obj/structure/artifact/lamp
	weight = 1000
	type_name = "Lamp"
	activation_message = "starts shining!"
	deactivation_message = "stops shining."

/datum/artifact/lamp/setup()
	..()
	var/power = 2
	var/color = pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)
	var/range
	if(artifact_origin.type_name == ORIGIN_NARSIE)
		power = 3
		color = COLOR_BLACK
		range = rand(2,4)
	else if(artifact_origin.type_name == ORIGIN_WIZARD)
		range = rand(6,10)
		power = rand(2,10) // the sun
	else
		power = rand(0.5,3)
		range = rand(1.4,4)
	holder.set_light_power(power)
	holder.set_light_color(color)
	holder.set_light_range(range)

/datum/artifact/lamp/effect_activate()
	holder.set_light_on(TRUE)

/datum/artifact/lamp/effect_deactivate()
	holder.set_light_on(FALSE)