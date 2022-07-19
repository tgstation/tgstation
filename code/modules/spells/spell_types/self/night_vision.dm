
//Toggle Night Vision
/datum/action/cooldown/spell/night_vision
	name = "Toggle Nightvision"
	desc = "Toggle your nightvision mode."

	cooldown_time = 1 SECONDS
	spell_requirements = NONE

	/// The span the "toggle" message uses when sent to the user
	var/toggle_span = "notice"

/datum/action/cooldown/spell/night_vision/New(Target)
	. = ..()
	name = "[name] \[ON\]"

/datum/action/cooldown/spell/night_vision/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/night_vision/cast(mob/living/cast_on)
	. = ..()
	to_chat(cast_on, "<span class='[toggle_span]'>You toggle your night vision.</span>")

	var/next_mode_text = ""
	switch(cast_on.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			cast_on.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			next_mode_text = "More"
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			cast_on.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			next_mode_text = "Full"
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			cast_on.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			next_mode_text = "OFF"
		else
			cast_on.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			next_mode_text = "ON"

	cast_on.update_sight()
	name = "[initial(name)] \[[next_mode_text]\]"
