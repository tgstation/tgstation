/datum/action/cooldown/spell/pointed/death_glare
	name = "death glare"
	desc = "give a death stare to the victim"
	var/glare_outline = COLOR_DARK_RED
	spell_requirements = NONE
	cooldown_time = 10 SECONDS

/datum/action/cooldown/spell/pointed/death_glare/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		to_chat(owner, span_warning("Only living things are affected by our glare!"))
		return FALSE
	var/mob/living/living_target = cast_on
	if(living_target.has_movespeed_modifier(/datum/movespeed_modifier/glare_slowdown))
		to_chat(owner, span_warning("This target is already affected by a glare!"))
		return FALSE
	if(!can_see(living_target, owner, 9))
		to_chat(owner, span_warning("This target cannot see our glare!"))
		return FALSE
	var/direction_to_compare = get_dir(living_target, owner)
	var/target_direction = living_target.dir
	if(direction_to_compare != target_direction)
		to_chat(owner, span_warning("This target is facing away from us!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/death_glare/cast(mob/living/cast_on)
	. = ..()
	cast_on.add_filter("glare", 2, list("type" = "outline", "color" = glare_outline, "size" = 1))
	cast_on.add_movespeed_modifier(/datum/movespeed_modifier/glare_slowdown)
	to_chat(cast_on, span_warning("You feel something watching you..."))
	addtimer(CALLBACK(src, PROC_REF(remove_effect), cast_on), 5 SECONDS)
	return TRUE

/datum/action/cooldown/spell/pointed/death_glare/proc/remove_effect(mob/living/cast_on)
	cast_on.remove_movespeed_modifier(/datum/movespeed_modifier/glare_slowdown)
	cast_on.remove_filter("glare")

/datum/movespeed_modifier/glare_slowdown
	multiplicative_slowdown = 3
