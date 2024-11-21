/// Component used by plasmeme limbs. Ignites the owner and prevents fire armor from working if they're exposed to oxygen
/datum/component/self_ignition
	/// How many fire stacks do we apply per second?
	/// Default value is 0.25 / 6 (default amount of limbs)
	var/fire_stacks_per_second = 0.0416
	/// How many fire stacks are removed when we're exposed to hypernoblium
	/// Default value is 10 / 6 (default amount of limbs)
	var/fire_stacks_loss = 1.66

/datum/component/self_ignition/Initialize(fire_stacks_per_second = 0.0416, fire_stacks_loss = 1.66)
	. = ..()
	if(!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	src.fire_stacks_per_second = fire_stacks_per_second
	src.fire_stacks_loss = fire_stacks_loss

/datum/component/self_ignition/RegisterWithParent()
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_attached))
	RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(on_detached))

/datum/component/self_ignition/proc/on_attached(datum/source, mob/living/carbon/human/new_owner)
	SIGNAL_HANDLER
	RegisterSignal(new_owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/self_ignition/proc/on_detached(datum/source, mob/living/carbon/human/old_owner)
	SIGNAL_HANDLER
	UnregisterSignal(old_owner, COMSIG_LIVING_LIFE)
	REMOVE_TRAIT(old_owner, TRAIT_IGNORE_FIRE_PROTECTION, REF(parent))

/datum/component/self_ignition/proc/on_life(mob/living/carbon/human/owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if (HAS_TRAIT(owner, TRAIT_STASIS))
		return

	if (owner.is_atmos_sealed(additional_flags = PLASMAMAN_PREVENT_IGNITION, check_hands = TRUE, alt_flags = TRUE))
		if (!owner.on_fire)
			REMOVE_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, REF(parent))
		return

	var/datum/gas_mixture/environment = owner.loc.return_air()
	if (!environment?.total_moles())
		return

	if(environment.gases[/datum/gas/hypernoblium] && environment.gases[/datum/gas/hypernoblium][MOLES] >= 5)
		if(owner.on_fire && owner.fire_stacks > 0)
			owner.adjust_fire_stacks(-fire_stacks_loss * seconds_per_tick)
		return

	if (HAS_TRAIT(owner, TRAIT_NOFIRE))
		return

	ADD_TRAIT(owner, TRAIT_IGNORE_FIRE_PROTECTION, REF(parent))

	if(!environment.gases[/datum/gas/oxygen] || environment.gases[/datum/gas/oxygen][MOLES] < 1) //Same threshhold that extinguishes fire
		return

	owner.adjust_fire_stacks(fire_stacks_per_second * seconds_per_tick)
	if(owner.ignite_mob())
		owner.visible_message(span_danger("[owner]'s body reacts with the atmosphere and bursts into flames!"), span_userdanger("Your body reacts with the atmosphere and bursts into flame!"))
