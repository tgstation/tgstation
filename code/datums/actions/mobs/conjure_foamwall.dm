/datum/action/cooldown/spell/conjure/foam_wall
	name = "Foam wall"
	desc = "Create a wall of foam."

	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "metalfoam"

	cooldown_time = 2 MINUTES
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/foamedmetal)

/datum/action/cooldown/spell/conjure/foam_wall/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(owner_turf.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE
	return TRUE
