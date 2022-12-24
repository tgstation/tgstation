/datum/action/cooldown/spell/pointed/terrorize //Make sure this requires nightmare eyes to do
	name = "Terrorize"
	desc = "Send your target reeling with panic. Causes panic and tunnel vision when used on someone surrounded by darkness."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "curse"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 50 SECONDS
	cast_range = 9
	active_msg = "You prepare to terrify a target..."

/datum/action/cooldown/spell/pointed/terrorize/is_valid_target(atom/cast_on) //Make sure the target is shrouded in darkness
	. = ..()

	if(!ishuman(cast_on))
		owner.balloon_alert("use this on a human!")
		return FALSE

	var/lit_tiles = 0
	var/unlit_tiles = 0

	for(var/turf/turf_to_check in view(2, get_turf(cast_on)))
		var/light_amount = turf_to_check.get_lumcount()
		if(light_amount > 0.2)
			lit_tiles++
		else
			unlit_tiles++

	if(lit_tiles > unlit_tiles)
		owner.balloon_alert("target isn't in the dark!")
		return FALSE
