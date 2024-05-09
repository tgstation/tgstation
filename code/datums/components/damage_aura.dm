#define DAMAGE_EFFECT_COOLDOWN (1 SECONDS)

/// Applies a status effect and deals damage to people in the area.
/// Will deal more damage the more people are present.
/datum/component/damage_aura
	/// The range of which to damage
	var/range = 5

	/// Whether or not you must be a visible object of the parent
	var/requires_visibility = TRUE

	/// Brute damage to damage over a second
	var/brute_damage = 0

	/// Burn damage to damage over a second
	var/burn_damage = 0

	/// Toxin damage to damage over a second
	var/toxin_damage = 0

	/// Suffocation damage to damage over a second
	var/suffocation_damage = 0

	/// Stamina damage to damage over a second
	var/stamina_damage = 0

	/// Amount of blood to damage over a second
	var/blood_damage = 0

	/// Map of organ (such as ORGAN_SLOT_BRAIN) to damage damage over a second
	var/list/organ_damage = null

	/// Amount of damage to damage on simple mobs over a second
	var/simple_damage = 0

	/// Which factions are immune to the damage aura
	var/list/immune_factions = null

	/// Sets a special set of conditions for the owner
	var/datum/weakref/current_owner = null

	/// Declares the cooldown timer for the damage aura effect to take place
	COOLDOWN_DECLARE(last_damage_effect_time)

/datum/component/damage_aura/Initialize(
	range = 5,
	requires_visibility = TRUE,
	brute_damage = 0,
	burn_damage = 0,
	toxin_damage = 0,
	suffocation_damage = 0,
	stamina_damage = 0,
	blood_damage = 0,
	organ_damage = null,
	simple_damage = 0,
	immune_factions = null,
	mob/living/current_owner = null,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSaura, src)

	src.range = range
	src.requires_visibility = requires_visibility
	src.brute_damage = brute_damage
	src.burn_damage = burn_damage
	src.toxin_damage = toxin_damage
	src.suffocation_damage = suffocation_damage
	src.stamina_damage = stamina_damage
	src.blood_damage = blood_damage
	src.organ_damage = organ_damage
	src.simple_damage = simple_damage
	src.immune_factions = immune_factions
	src.current_owner = WEAKREF(current_owner)

/datum/component/damage_aura/Destroy(force)
	STOP_PROCESSING(SSaura, src)
	return ..()

/// The requirements for the mob to be effected by the damage aura.
/datum/component/damage_aura/proc/check_requirements(mob/living/target_mob)
	if(target_mob.stat == DEAD || faction_check(target_mob.faction, immune_factions))
		return TRUE
	return FALSE

/// What effect the damage aura has if it has an owner.
/datum/component/damage_aura/proc/owner_effect(mob/living/owner_mob, seconds_per_tick)
	var/need_mob_update = FALSE
	need_mob_update += owner_mob.adjustStaminaLoss(-20 * seconds_per_tick, updating_stamina = FALSE)
	need_mob_update += owner_mob.adjustBruteLoss(-1 * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner_mob.adjustFireLoss(-1 * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner_mob.adjustToxLoss(-1 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	need_mob_update += owner_mob.adjustOxyLoss(-1 * seconds_per_tick, updating_health = FALSE)
	if (owner_mob.blood_volume < BLOOD_VOLUME_NORMAL)
		owner_mob.blood_volume += 2 * seconds_per_tick
	if(need_mob_update)
		owner_mob.updatehealth()

/datum/component/damage_aura/process(seconds_per_tick)
	var/should_show_effect = COOLDOWN_FINISHED(src, last_damage_effect_time)
	if (should_show_effect)
		COOLDOWN_START(src, last_damage_effect_time, DAMAGE_EFFECT_COOLDOWN)

	var/list/to_damage = list()
	if(requires_visibility)
		for(var/mob/living/candidate in view(range, parent))
			to_damage += candidate
	else
		for(var/mob/living/candidate in range(range, parent))
			to_damage += candidate

	for (var/mob/living/candidate as anything in to_damage)
		var/mob/living/owner = current_owner?.resolve()
		if (owner && owner == candidate)
			owner_effect(owner, seconds_per_tick)
			continue
		if (check_requirements(candidate))
			continue
		if (candidate.health < candidate.maxHealth)
			new /obj/effect/temp_visual/cosmic_gem(get_turf(candidate))

		if (iscarbon(candidate) || issilicon(candidate) || isbasicmob(candidate))
			candidate.adjustBruteLoss(brute_damage * seconds_per_tick, updating_health = FALSE)
			candidate.adjustFireLoss(burn_damage * seconds_per_tick, updating_health = FALSE)

		if (iscarbon(candidate))
			candidate.adjustToxLoss(toxin_damage * seconds_per_tick, updating_health = FALSE)
			candidate.adjustOxyLoss(suffocation_damage * seconds_per_tick, updating_health = FALSE)
			candidate.adjustStaminaLoss(stamina_damage * seconds_per_tick, updating_stamina = FALSE)

			for (var/organ in organ_damage)
				candidate.adjustOrganLoss(organ, organ_damage[organ] * seconds_per_tick)
		else if (isanimal(candidate))
			var/mob/living/simple_animal/animal_candidate = candidate
			animal_candidate.adjustHealth(simple_damage * seconds_per_tick, updating_health = FALSE)
		else if (isbasicmob(candidate))
			var/mob/living/basic/basic_candidate = candidate
			basic_candidate.adjust_health(simple_damage * seconds_per_tick, updating_health = FALSE)

		if (candidate.blood_volume > BLOOD_VOLUME_SURVIVE)
			candidate.blood_volume -= blood_damage * seconds_per_tick

		candidate.updatehealth()

#undef DAMAGE_EFFECT_COOLDOWN
