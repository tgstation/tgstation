
/datum/component/artifact/lamp
	associated_object = /obj/structure/artifact/lamp
	weight = ARTIFACT_COMMON
	type_name = "Lamp"
	activation_message = "starts shining!"
	deactivation_message = "stops shining."

/datum/component/artifact/lamp/setup()
	var/power
	var/color = pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)
	var/range
	switch(rand(1,100))
		if(1 to 75)
			power = rand(2,5)
			range = rand(2,5)
		if(76 to 100)
			range = rand(4,10)
			power = rand(2,10) // the sun
			
	if(artifact_origin.type_name == ORIGIN_NARSIE && prob(40))
		color = COLOR_BLACK
	holder.set_light_range_power_color(range, power, color)
	potency += (range + power) * 2

/datum/component/artifact/lamp/effect_touched(mob/user)
	holder.set_light_on(!holder.light_on) //toggle
	to_chat(user, span_hear("[holder] clicks."))

/datum/component/artifact/lamp/effect_activate()
	holder.set_light_on(TRUE)

/datum/component/artifact/lamp/effect_deactivate()
	holder.set_light_on(FALSE)
