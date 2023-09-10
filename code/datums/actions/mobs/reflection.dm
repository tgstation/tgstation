/datum/action/cooldown/mob_cooldown/reflection
	name = "Reflection"
	desc = "Reflect projectiles."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "sniper_zoom"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_INCAPACITATED
	cooldown_time = 0.5 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	/// The chance to reflect projectiles.
	var/hit_reflect_chance = 100
	/// How long it takes to become reflective
	var/animation_time = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/reflection/Remove(mob/living/remove_from)
	if(HAS_TRAIT(remove_from, TRAIT_REFLECTION))
		remove_from.alpha = initial(remove_from.alpha)
		REMOVE_TRAIT(remove_from, TRAIT_REFLECTION, name)

	return ..()

/datum/action/cooldown/mob_cooldown/reflection/Activate(atom/target)
	if(HAS_TRAIT(owner, TRAIT_REFLECTION))
		// It's safest to go to the initial alpha of the mob.
		// Otherwise we get permanent invisbility exploits.
		animate(owner, alpha = initial(owner.alpha), time = animation_time)
		owner.balloon_alert(owner, "your chemicals evaporate")
		REMOVE_TRAIT(owner, TRAIT_REFLECTION, name)

	else
		owner.balloon_alert(owner, "your chemicals overflow ")
		ADD_TRAIT(owner, TRAIT_REFLECTION, name)

	return TRUE

