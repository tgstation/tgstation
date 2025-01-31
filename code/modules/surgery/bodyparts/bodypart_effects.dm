/// For scaling the effectiveness of certain effects to the total bodypart count
#define GET_BODYPART_COEFFICIENT(X) round(X.len / 6, 0.1)
/// Check if it's full body. These are mostly here so we can change just one place when we ever add more limbs (?)
#define IS_FULL_BODY(X) (X.len == 6)

/// Effects added to a carbon focused on the bodyparts itself, such as adding a photosynthesis component that
/datum/bodypart_effect
	/// List of bodyparts contributing to this effect
	var/list/bodyparts = list()
	/// Minimum amount of bodyparts required for on_apply to be called. When tipping below, on_remove is called
	var/minimum_bodyparts = 1
	/// Are we currently active? We don't NEED to track it, but it's a lot easier and faster if we do
	var/is_active = FALSE
	/// Whether or not to hook into COMSIG_LIVING_LIFE and use /proc/on_life()
	var/process_on_life = FALSE

/datum/bodypart_effect/New(mob/living/carbon/carbon, obj/item/bodypart/bodypart)
	add_bodypart(carbon, bodypart)

	if(process_on_life)
		RegisterSignal(carbon, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/// Merge a bodypart into the effect
/datum/bodypart_effect/proc/add_bodypart(mob/living/carbon/carbon, bodypart)
	RegisterSignal(bodypart, COMSIG_BODYPART_REMOVED, PROC_REF(on_bodypart_removed))

	bodyparts.Add(bodypart)

	if(!is_active && bodyparts.len >= minimum_bodyparts)
		activate(carbon)

/// Remove a bodypart from the effect. Deleting = TRUE is used during clean-up phase
/datum/bodypart_effect/proc/remove_bodypart(mob/living/carbon/carbon, obj/item/bodypart/bodypart, deleting = FALSE)
	UnregisterSignal(bodypart, COMSIG_BODYPART_REMOVED)

	bodyparts.Remove(bodypart)

	if(deleting)
		return

	if(bodyparts.len == 0)
		destroy(carbon)

	else if(is_active && bodyparts.len < minimum_bodyparts)
		deactivate(carbon)

/// Signal called when a bodypart is removed
/datum/bodypart_effect/proc/on_bodypart_removed(obj/item/bodypart/bodypart, mob/living/carbon/owner)
	SIGNAL_HANDLER

	remove_bodypart(owner, bodypart)

/// Activate some sort of effect when a threshold is reached
/datum/bodypart_effect/proc/activate(mob/living/carbon/carbon)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	is_active = TRUE
	// Maybe add support for different stages? AKA add a stronger effect when there are more limbs

/// Remove an effect whenever a threshold is no longer reached
/datum/bodypart_effect/proc/deactivate(mob/living/carbon/carbon)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	is_active = FALSE

/// Called about every 2 seconds if process_on_life was TRUE during instantiation
/datum/bodypart_effect/proc/on_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	return

/// Clean up all references and self-destruct
/datum/bodypart_effect/proc/destroy(mob/living/carbon/carbon)
	PRIVATE_PROC(TRUE)

	deactivate(carbon)
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		remove_bodypart(carbon, bodypart, deleting = TRUE)

	carbon.bodypart_effects -= src
	qdel(src)

/// This limb regens in light! Only BODYTYPE_PLANT limbs will heal, but limbs without the flag (and with the effect) still contribute to healing of the other limbs
/datum/bodypart_effect/photosynthesis
	process_on_life = TRUE

/datum/bodypart_effect/photosynthesis/on_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	var/bodypart_coefficient = GET_BODYPART_COEFFICIENT(bodyparts)

	if(isturf(owner.loc)) //else, there's considered to be no light
		var/turf/turf_loc = owner.loc
		light_amount = min(1, turf_loc.get_lumcount()) - 0.5

		if(owner.nutrition < NUTRITION_LEVEL_ALMOST_FULL)
			owner.adjust_nutrition(5 * light_amount * seconds_per_tick * bodypart_coefficient)

		if(light_amount > 0.2) //if there's enough light, heal
			var/need_mob_update = FALSE
			need_mob_update += owner.heal_overall_damage(brute = 0.5 * seconds_per_tick * bodypart_coefficient, \
				burn = 0.5 * seconds_per_tick * bodypart_coefficient, updating_health = FALSE, required_bodytype = BODYTYPE_PLANT)
			need_mob_update += owner.adjustToxLoss(-0.5 * seconds_per_tick * bodypart_coefficient, updating_health = FALSE)
			need_mob_update += owner.adjustOxyLoss(-0.5 * seconds_per_tick * bodypart_coefficient, updating_health = FALSE)
			if(need_mob_update)
				owner.updatehealth()

	if(owner.nutrition < NUTRITION_LEVEL_STARVING + 50)
		owner.take_overall_damage(brute = 1 * seconds_per_tick * bodypart_coefficient, required_bodytype = BODYTYPE_PLANT)

/// This limb heals in darkness and dies in light!
/// Only BODYTYPE_SHADOW limbs will heal, but limbs without the flag (and with the effect) still contribute to healing of the other limbs
/datum/bodypart_effect/nyxosynthesis
	process_on_life = TRUE

/datum/bodypart_effect/nyxosynthesis/on_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return
	var/light_amount = owner_turf.get_lumcount()

	var/bodypart_coefficient = GET_BODYPART_COEFFICIENT(bodyparts)

	if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
		owner.heal_overall_damage(brute = 1 * seconds_per_tick * bodypart_coefficient, burn = 1 * seconds_per_tick * bodypart_coefficient, required_bodytype = BODYTYPE_SHADOW)
		if(!owner.has_status_effect(/datum/status_effect/shadow/nightmare)) //somewhat awkward, but let's not duplicate the alerts
			owner.apply_status_effect(/datum/status_effect/shadow)
	else
		owner.take_overall_damage(brute = 0.5 * seconds_per_tick * bodypart_coefficient, burn = 0.5 * seconds_per_tick * bodypart_coefficient, required_bodytype = BODYTYPE_SHADOW)

#undef GET_BODYPART_COEFFICIENT
#undef IS_FULL_BODY
