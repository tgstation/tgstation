/datum/action/cooldown/spell/pointed/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to the will of Nar'Sie, \
		allying it only to her direct followers."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	// An UNHOLY, MAGIC SPELL that INFLUECNES THE MIND - all things work here, logically
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

	cast_range = 7
	active_msg = "You prepare to dominate the mind of a target..."

/datum/action/cooldown/spell/pointed/dominate/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE

	var/mob/living/animal = cast_on
	if(animal.mind)
		return FALSE
	if(animal.stat == DEAD)
		return FALSE
	if(!animal.compare_sentience_type(SENTIENCE_ORGANIC)) // Will also return false if not a basic or simple mob, which are the only two we want anyway
		return FALSE
	if("cult" in animal.faction)
		return FALSE
	if(HAS_TRAIT(animal, TRAIT_HOLY))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/dominate/cast(mob/living/simple_animal/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_warning("Your feel someone attempting to subject your mind to terrible machinations!"))
		to_chat(owner, span_warning("[cast_on] resists your domination!"))
		return FALSE

	var/turf/cast_turf = get_turf(cast_on)
	cast_on.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	cast_on.faction |= "cult"
	playsound(cast_turf, 'sound/effects/ghost.ogg', 100, TRUE)
	new /obj/effect/temp_visual/cult/sac(cast_turf)
