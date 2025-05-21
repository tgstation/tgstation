/// A tile which drains stamina of people crossing it and deals oxygen damage to people who are prone inside of it
/datum/element/swimming_tile
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// How much stamina does it cost to enter this tile?
	var/stamina_entry_cost
	/// How much stamina does it cost per tick interval to stay in this tile?
	var/ticking_stamina_cost
	/// How fast do we kill people who collapse?
	var/ticking_oxy_damage
	/// Probability to exhaust our swimmer
	var/exhaust_swimmer_prob

/datum/element/swimming_tile/Attach(turf/target, stamina_entry_cost = 7, ticking_stamina_cost = 5, ticking_oxy_damage = 2, exhaust_swimmer_prob = 30)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	src.stamina_entry_cost = stamina_entry_cost
	src.ticking_stamina_cost = ticking_stamina_cost
	src.ticking_oxy_damage = ticking_oxy_damage
	src.exhaust_swimmer_prob = exhaust_swimmer_prob

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

/// When we've validated that someone is actually in the water start drowning the-I mean, start swimming!
/datum/element/swimming_tile/proc/dip_in(mob/living/floater)
	SIGNAL_HANDLER

	if ((!HAS_TRAIT(floater, TRAIT_SWIMMER) && (isnull(floater.buckled) || (!isvehicle(floater.buckled) && !ismob(floater.buckled))) && prob(exhaust_swimmer_prob)))

		//First, we determine our effective stamina entry cost baseline. This includes the value from the water, as well as any heavy clothing being worn. The strength trait halves this value.
		var/effective_stamina_entry_cost = HAS_TRAIT(floater, TRAIT_STRENGTH) ? (stamina_entry_cost + clothing_weight(floater)) : ((stamina_entry_cost + clothing_weight(floater)) / 2)

		//Being in high gravity doubles our effective stamina cost
		var/gravity_modifier = floater.has_gravity() > STANDARD_GRAVITY ? 1 : 2

		//If our floater has a specialized spine, include that as a factor.
		var/obj/item/organ/cyberimp/chest/spine/potential_spine = floater.get_organ_slot(ORGAN_SLOT_SPINE)
		if(istype(potential_spine))
			effective_stamina_entry_cost *= potential_spine.athletics_boost_multiplier

		//Finally, we get our athletics skill as a reduction to the stamina cost. This is a direct reduction.
		var/athletics_skill =  (floater.mind?.get_skill_level(/datum/skill/athletics) || 1) - 1

		floater.apply_damage(clamp((effective_stamina_entry_cost - athletics_skill) * gravity_modifier, 1, 100), STAMINA)
		floater.mind?.adjust_experience(/datum/skill/athletics, (stamina_entry_cost * gravity_modifier) * 0.1)
		floater.apply_status_effect(/datum/status_effect/exercised, 15 SECONDS)

	floater.apply_status_effect(/datum/status_effect/swimming, ticking_stamina_cost, ticking_oxy_damage) // Apply the status anyway for when they stop riding

/// The weight of our swimmers clothing, including slowdown, impacts the amount of stamina damage dealt on dipping in.
/datum/element/swimming_tile/proc/clothing_weight(mob/living/floater)
	var/extra_stamina_weight = 0
	for(var/obj/item/equipped_item in floater.get_equipped_items())
		if(ispath(equipped_item, /obj/item/clothing/under/shorts))
			continue
		extra_stamina_weight += (clamp(equipped_item.w_class - 2, 0, 100) + equipped_item.slowdown) //Clothing that speeds us up reduces the stamina drain!
	return extra_stamina_weight

///Added by the swimming_tile element. Drains stamina over time until the owner stops being immersed. Starts drowning them if they are prone or small.
/datum/status_effect/swimming
	id = "swimming"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5 SECONDS
	/// How much damage do we do every tick interval?
	var/stamina_per_interval
	/// How much oxygen do we lose every tick interval in which we are drowning?
	var/oxygen_per_interval
	/// Probability that we lose breaths while drowning
	var/drowning_process_probability = 20

/datum/status_effect/swimming/on_creation(mob/living/new_owner, ticking_stamina_cost = 7, ticking_oxy_damage = 2)
	. = ..()
	stamina_per_interval = ticking_stamina_cost
	oxygen_per_interval = ticking_oxy_damage
	if (!HAS_TRAIT(owner, TRAIT_SWIMMER))
		owner.add_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED), PROC_REF(stop_swimming))

/datum/status_effect/swimming/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/swimming_deep)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED))

/datum/status_effect/swimming/tick(seconds_between_ticks)
	if (HAS_TRAIT(owner, TRAIT_MOB_ELEVATED))
		return
	if (owner.buckled) // We're going to generously assume that being buckled to any mob or vehicle leaves you above water
		if (isvehicle(owner.buckled) || ismob(owner.buckled))
			return

	var/effective_stamina_per_interval = HAS_TRAIT(owner, TRAIT_STRENGTH) ? stamina_per_interval : (stamina_per_interval / 2)

	var/gravity_modifier = owner.has_gravity() > STANDARD_GRAVITY ? 1 : 2

	var/under_pressure = prob(drowning_process_probability * gravity_modifier)

	if (!HAS_TRAIT(owner, TRAIT_SWIMMER))
		var/athletics_skill =  (owner.mind?.get_skill_level(/datum/skill/athletics) || 1) - 1
		owner.apply_damage(clamp((effective_stamina_per_interval - (athletics_skill / 2)) * gravity_modifier, 1, 100), STAMINA)

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
	owner.apply_damage(oxygen_per_interval * seconds_between_ticks, OXY)
	if(under_pressure)
		owner.losebreath += oxygen_per_interval

/// When we're not in the water any more this don't matter
/datum/status_effect/swimming/proc/stop_swimming()
	SIGNAL_HANDLER
	qdel(src)
