
/datum/artifact_effect/lamp
	weight = ARTIFACT_COMMON
	type_name = "Lamp"
	activation_message = "starts shining!"
	deactivation_message = "stops shining."

	examine_discovered = span_warning("It appears to be some sort of light source")

	research_value = 250

/datum/artifact_effect/lamp/setup()
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

	if(our_artifact.artifact_origin.type_name == ORIGIN_NARSIE && prob(40))
		color = COLOR_BLACK
	our_artifact.holder.set_light_range_power_color(range, power, color)
	potency += (range + power) * 2

/datum/artifact_effect/lamp/effect_touched(mob/user)
	our_artifact.holder.set_light_on(!our_artifact.holder.light_on) //toggle
	to_chat(user, span_hear("[our_artifact.holder] clicks."))

/datum/artifact_effect/lamp/effect_activate()
	our_artifact.holder.set_light_on(TRUE)

/datum/artifact_effect/lamp/effect_deactivate()
	our_artifact.holder.set_light_on(FALSE)
