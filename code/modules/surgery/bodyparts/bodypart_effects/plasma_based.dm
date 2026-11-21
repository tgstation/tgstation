/// Causes the owner to spontaneously combust when exposed to oxygen
/datum/status_effect/grouped/bodypart_effect/plasma_based
	tick_interval = 1 SECONDS
	id = "plasmaman_limbs"
	/// How many fire stacks do we apply per second?
	/// Default value is 0.25 / 6 (default amount of limbs)
	var/fire_stacks_per_second = 0.0416
	/// How many fire stacks are removed per second when we're exposed to hypernoblium
	/// Default value is 10 / 6 (default amount of limbs)
	var/fire_stacks_loss = 1.66

/datum/status_effect/grouped/bodypart_effect/plasma_based/tick(seconds_between_ticks)
	if (!ishuman(owner) || !owner.loc) // No xenos, sorry
		return

	var/mob/living/carbon/human/as_human = owner
	if (HAS_TRAIT(owner, TRAIT_STASIS) || as_human.is_atmos_sealed(additional_flags = PLASMAMAN_PREVENT_IGNITION, check_hands = TRUE))
		if (!owner.on_fire)
			REMOVE_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, type)
		return

	var/datum/gas_mixture/environment = owner.loc.return_air()
	if (!environment?.total_moles())
		if (!owner.on_fire)
			REMOVE_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, type)
		return

	if(environment.moles[/datum/gas/hypernoblium] >= 5)
		if(owner.on_fire && owner.fire_stacks > 0)
			owner.adjust_fire_stacks(-fire_stacks_loss * seconds_between_ticks * length(bodyparts))
		else
			REMOVE_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, type)
		return

	if (HAS_TRAIT(owner, TRAIT_NOFIRE))
		REMOVE_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, type)
		return

	ADD_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, type)

	if(environment.moles[/datum/gas/oxygen] < 1) //Same threshhold that extinguishes fire
		return

	owner.adjust_fire_stacks(fire_stacks_per_second * seconds_between_ticks * length(bodyparts))
	if(owner.ignite_mob())
		owner.visible_message(span_danger("[owner]'s body reacts with the atmosphere and bursts into flames!"), span_userdanger("Your body reacts with the atmosphere and bursts into flame!"))
