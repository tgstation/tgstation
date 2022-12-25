/datum/action/cooldown/spell/pointed/terrorize //Make sure this requires nightmare eyes to do
	name = "Terrorize"
	desc = "Send your target reeling in terror. If kept terrified for long enough, targets will grow overwhelmed and be weakened, making them easy prey."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "curse"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 25 SECONDS
	cast_range = 9
	active_msg = "You prepare to terrify a target..."

/datum/action/cooldown/spell/pointed/terrorize/is_valid_target(atom/cast_on) //Make sure the target is shrouded in darkness
	. = ..()

	if(!ishuman(cast_on))
		to_chat(owner, span_notice("[cast_on] cannot be terrorized!"))
		return FALSE

	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/open/turf_to_check in view(2, cast_on))
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	if(lit_tiles > unlit_tiles)
		to_chat(owner, span_warning("[cast_on] must be surrounded by darkness to be terrorized!"))
		return FALSE

/datum/action/cooldown/spell/pointed/terrorize/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(cast_on.has_status_effect(/datum/status_effect/terrified))
		var/datum/status_effect/terrified/terrified_status_effect
		terrified_status_effect.terror_buildup += 125 //It stacks, and then some
	else
		cast_on.apply_status_effect(/datum/status_effect/terrified)

	cast_on.balloon_alert("spooked!")
