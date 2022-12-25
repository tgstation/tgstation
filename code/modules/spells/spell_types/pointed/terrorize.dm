/datum/action/cooldown/spell/pointed/terrorize
	name = "Terrorize"
	desc = "Stare down a victim with your piercing red eyes, inflicting them with terror buildup. \
		Targets must be in the dark to be terrorized and, if they remain in the darkness, will suffer increasingly adverse effects. \
		Prey will be weakened, and may even pass out from terror buildup in extreme amounts. \
		Swatting a victim with an open hand will boost terror buildup considerably."
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 25 SECONDS
	cast_range = 9
	active_msg = "You prepare to stare down a target..."
	deactive_msg = "You refocus your eyes..."

/datum/action/cooldown/spell/pointed/terrorize/is_valid_target(atom/cast_on)
	. = ..()

	if(!ishuman(cast_on))
		to_chat(owner, span_notice("[cast_on] cannot be terrorized!"))
		return FALSE

	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/open/turf_to_check in range(1, cast_on)) //We have to use range for this because fully darkened tiles get blocked by view()'s visibility checks
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	if(lit_tiles > unlit_tiles)
		to_chat(owner, span_warning("[cast_on] must be surrounded by darkness to be terrorized!"))
		return FALSE //For reference, having a active seclite on your person is enough to block the spell, forcing the nightmare to get an initial hit with the light eater

/datum/action/cooldown/spell/pointed/terrorize/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(cast_on.has_status_effect(/datum/status_effect/terrified)) //TODO: somehow get this functionality onto the status effect
		var/datum/status_effect/terrified/terrified_status_effect
		terrified_status_effect.terror_buildup += 125 //It stacks, and then some
	else
		cast_on.apply_status_effect(/datum/status_effect/terrified)

	cast_on.balloon_alert("spooked!")
