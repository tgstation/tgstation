/obj/structure/artifact/lamp
	assoc_comp = /datum/component/artifact/lamp
	light_system = MOVABLE_LIGHT
	light_on = FALSE
/datum/component/artifact/lamp
	associated_object = /obj/structure/artifact/lamp
	weight = 1000
	type_name = "Lamp"
	activation_message = "starts shining!"
	deactivation_message = "stops shining."

/datum/component/artifact/lamp/effect_process()
	. = ..()
	if(holder.light_power > 4 && prob(75))
		var/strength = holder.light_power - 6
		for(var/mob/living/carbon/human/H in view(1,holder.loc))
			if(H.is_blind())
				continue
			to_chat(H, span_warning("Your eyes are starting to hurt from the bright light of the [holder]!"))
			H.flash_act(intensity = strength, visual = (strength <= 0))
/datum/component/artifact/lamp/setup()
	. = ..()
	var/power = 2
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
		power = 3
		color = COLOR_BLACK
		range = rand(3,6)
	holder.set_light_power(power)
	holder.set_light_color(color)
	holder.set_light_range(range)
	potency += (range + power) * 1.5

/datum/component/artifact/lamp/effect_activate()
	holder.set_light_on(TRUE)

/datum/component/artifact/lamp/effect_deactivate()
	holder.set_light_on(FALSE)