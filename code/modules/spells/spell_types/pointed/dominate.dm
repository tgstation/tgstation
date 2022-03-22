/datum/action/cooldown/spell/pointed/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to the will of Nar'Sie, \
		allying it only to her direct followers."
	background_icon_state = "bg_demon"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	cast_range = 7
	active_msg = "You prepare to dominate the mind of a target..."

/datum/action/cooldown/spell/pointed/dominate/is_valid_target(atom/cast_on)
	if(!isanimal(cast_on))
		return FALSE

	var/mob/living/simple_animal/animal = cast_on
	if(animal.mind)
		return FALSE
	if(animal.stat == DEAD)
		return FALSE
	if(animal.sentience_type != SENTIENCE_ORGANIC)
		return FALSE
	if("cult" in animal.faction)
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/dominate/cast(mob/living/simple_animal/cast_on)
	. = ..()
	var/turf/cast_turf = get_turf(cast_on)
	cast_on.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	cast_on.faction |= "cult"
	playsound(cast_turf, 'sound/effects/ghost.ogg', 100, TRUE)
	new /obj/effect/temp_visual/cult/sac(cast_turf)
