#define DAMAGE_EFFECT_COOLDOWN (1 SECONDS)

/// Applies a status effect and deals damage to people in the area.
/// Will deal more damage the more people are present.
/datum/component/damage_aura
	/// The range of which to damage
	var/range

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

	/// Amount of cloning damage to damage over a second
	var/clone_damage = 0

	/// Amount of blood to damage over a second
	var/blood_damage = 0

	/// Map of organ (such as ORGAN_SLOT_BRAIN) to damage damage over a second
	var/list/organ_damage = null

	/// Amount of damage to damage on simple mobs over a second
	var/simple_damage = 0

	/// Sets a special set of conditions for the owner
	var/datum/weakref/has_owner = null

	/// The color to give the healing visual
	var/healing_color = COLOR_GREEN

	COOLDOWN_DECLARE(last_heal_effect_time)

/datum/component/damage_aura/Initialize(
	range,
	requires_visibility = TRUE,
	brute_damage = 0,
	burn_damage = 0,
	toxin_damage = 0,
	suffocation_damage = 0,
	stamina_damage = 0,
	clone_damage = 0,
	blood_damage = 0,
	organ_damage = null,
	simple_damage = 0,
	mob/living/has_owner = null,
	healing_color = COLOR_GREEN,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSobj, src)

	src.range = range
	src.requires_visibility = requires_visibility
	src.brute_damage = brute_damage
	src.burn_damage = burn_damage
	src.toxin_damage = toxin_damage
	src.suffocation_damage = suffocation_damage
	src.stamina_damage = stamina_damage
	src.clone_damage = clone_damage
	src.blood_damage = blood_damage
	src.organ_damage = organ_damage
	src.simple_damage = simple_damage
	src.has_owner = WEAKREF(has_owner)
	src.healing_color = healing_color

/datum/component/damage_aura/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/damage_aura/proc/check_requirements(mob/living/target_mob)
	if(target_mob.stat == DEAD || faction_check(target_mob.faction, list(FACTION_HERETIC)))
		return TRUE
	return FALSE

/datum/component/damage_aura/proc/owner_effect(mob/living/owner_mob, delta_time)
	owner_mob.adjustStaminaLoss(-20 * delta_time, updating_stamina = FALSE)
	owner_mob.adjustBruteLoss(-1 * delta_time, updating_health = FALSE)
	owner_mob.adjustFireLoss(-1 * delta_time, updating_health = FALSE)
	owner_mob.adjustToxLoss(-1 * delta_time, updating_health = FALSE, forced = TRUE)
	owner_mob.adjustOxyLoss(-1 * delta_time, updating_health = FALSE)
	if (owner_mob.blood_volume < BLOOD_VOLUME_NORMAL)
		owner_mob.blood_volume += 1 * delta_time
	owner_mob.updatehealth()

/datum/component/damage_aura/process(delta_time)
	var/should_show_effect = COOLDOWN_FINISHED(src, last_heal_effect_time)
	if (should_show_effect)
		COOLDOWN_START(src, last_heal_effect_time, DAMAGE_EFFECT_COOLDOWN)

	for (var/mob/living/candidate in (requires_visibility ? view(range, parent) : range(range, parent)))
		var/mob/living/owner = has_owner?.resolve()
		if (owner && owner == candidate)
			owner_effect(owner, delta_time)
			continue
		if (check_requirements(candidate))
			continue
		if (should_show_effect && candidate.health < candidate.maxHealth)
			new /obj/effect/temp_visual/cosmic_gem(get_turf(candidate))

		if (iscarbon(candidate) || issilicon(candidate) || isbasicmob(candidate))
			candidate.adjustBruteLoss(brute_damage * delta_time, updating_health = FALSE)
			candidate.adjustFireLoss(burn_damage * delta_time, updating_health = FALSE)

		if (iscarbon(candidate))
			candidate.adjustToxLoss(toxin_damage * delta_time, updating_health = FALSE)
			candidate.adjustOxyLoss(suffocation_damage * delta_time, updating_health = FALSE)
			candidate.adjustStaminaLoss(stamina_damage * delta_time, updating_stamina = FALSE)
			candidate.adjustCloneLoss(clone_damage * delta_time, updating_health = FALSE)

			for (var/organ in organ_damage)
				candidate.adjustOrganLoss(organ, organ_damage[organ] * delta_time)
		else if (isanimal(candidate))
			var/mob/living/simple_animal/animal_candidate = candidate
			animal_candidate.adjustHealth(simple_damage * delta_time, updating_health = FALSE)
		else if (isbasicmob(candidate))
			var/mob/living/basic/basic_candidate = candidate
			basic_candidate.adjust_health(simple_damage * delta_time, updating_health = FALSE)

		if (candidate.blood_volume > BLOOD_VOLUME_SURVIVE)
			candidate.blood_volume -= blood_damage * delta_time

		candidate.updatehealth()

#undef DAMAGE_EFFECT_COOLDOWN
