/// A tile which drains stamina of people crossing it and deals oxygen damage to people who are prone inside of it
/datum/element/swimming_tile
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// How much stamina does it cost to enter this tile?
	var/stamina_entry_cost
	/// How much stamina does it cost per second to stay in this tile?
	var/ticking_stamina_cost
	/// How fast do we kill people who collapse?
	var/ticking_oxy_damage

/datum/element/swimming_tile/Attach(turf/target, stamina_entry_cost = 25, ticking_stamina_cost = 15, ticking_oxy_damage = 2)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	src.stamina_entry_cost = stamina_entry_cost
	src.ticking_stamina_cost = ticking_stamina_cost
	src.ticking_oxy_damage = ticking_oxy_damage

	RegisterSignals(target, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(enter_water))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(out_of_water))

	for(var/mob/living/drownee in target.contents)
		if(!(drownee.flags_1 & INITIALIZED_1)) //turfs initialize before movables
			continue
		enter_water(target, drownee)

/datum/element/swimming_tile/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_EXITED))
	for(var/mob/living/dry_guy in source.contents)
		out_of_water(source, dry_guy)
	return ..()

/// When something enters the water set up to start drowning it
/datum/element/swimming_tile/proc/enter_water(atom/source, mob/living/swimmer)
	SIGNAL_HANDLER
	if (!istype(swimmer))
		return
	RegisterSignal(swimmer, SIGNAL_ADDTRAIT(TRAIT_IMMERSED), PROC_REF(dip_in))
	if(HAS_TRAIT(swimmer, TRAIT_IMMERSED))
		dip_in(swimmer)

/// When something exits the water it probably shouldn't drowning
/datum/element/swimming_tile/proc/out_of_water(atom/source, mob/living/landlubber)
	SIGNAL_HANDLER
	UnregisterSignal(landlubber, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSED)))

/// When we've validated that someone is actually in the water start drowning them
/datum/element/swimming_tile/proc/dip_in(mob/living/floater)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(floater, TRAIT_SWIMMER) && (isnull(floater.buckled) || (!isvehicle(floater.buckled) && !ismob(floater.buckled))))
		var/athletics_skill =  (floater.mind?.get_skill_level(/datum/skill/athletics) || 1) - 1
		floater.apply_damage(stamina_entry_cost - athletics_skill, STAMINA)
	floater.apply_status_effect(/datum/status_effect/swimming, ticking_stamina_cost, ticking_oxy_damage) // Apply the status anyway for when they stop riding

///Added by the swimming_tile element. Drains stamina over time until the owner stops being immersed. Starts drowning them if they are prone or small.
/datum/status_effect/swimming
	id = "swimming"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE
	/// How much damage do we do every second?
	var/stamina_per_second
	/// How much oxygen do we lose every second in which we are drowning?
	var/oxygen_per_second

/datum/status_effect/swimming/on_creation(mob/living/new_owner, ticking_stamina_cost = 14, ticking_oxy_damage = 2)
	. = ..()
	stamina_per_second = ticking_stamina_cost
	oxygen_per_second = ticking_oxy_damage
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED), PROC_REF(stop_swimming))

/datum/status_effect/swimming/on_remove()
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED))

/datum/status_effect/swimming/tick(seconds_between_ticks)
	if (HAS_TRAIT(owner, TRAIT_MOB_ELEVATED))
		return
	if (owner.buckled) // We're going to generously assume that being buckled to any mob or vehicle leaves you above water
		if (isvehicle(owner.buckled) || ismob(owner.buckled))
			return

	if (!HAS_TRAIT(owner, TRAIT_SWIMMER))
		var/athletics_skill =  (owner.mind?.get_skill_level(/datum/skill/athletics) || 1) - 1
		owner.apply_damage((stamina_per_second - athletics_skill) * seconds_between_ticks, STAMINA)

	// If you can't move you're not swimming
	if (!HAS_TRAIT(owner, TRAIT_INCAPACITATED) && !HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		owner.mind?.adjust_experience(/datum/skill/athletics, 3)

	// You might not be swimming but you can breathe
	if (HAS_TRAIT(owner, TRAIT_NODROWN) || HAS_TRAIT(owner, TRAIT_NOBREATH) || (owner.mob_size >= MOB_SIZE_HUMAN && owner.body_position == STANDING_UP))
		return
	if (iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		if (carbon_owner.internal || carbon_owner.external)
			return
	if (isbasicmob(owner))
		var/mob/living/basic/basic_owner = owner
		if (basic_owner.unsuitable_atmos_damage == 0)
			return // This mob doesn't "breathe"
	owner.apply_damage(oxygen_per_second * seconds_between_ticks, OXY)
	owner.losebreath += seconds_between_ticks

/// When we're not in the water any more this don't matter
/datum/status_effect/swimming/proc/stop_swimming()
	SIGNAL_HANDLER
	qdel(src)
