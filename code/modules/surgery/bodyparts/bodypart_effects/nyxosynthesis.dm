/// This limb heals in darkness and dies in light!
/// Only BODYTYPE_SHADOW limbs will heal, but limbs without the flag (and with the effect) still contribute to healing of the other limbs
/datum/status_effect/grouped/bodypart_effect/nyxosynthesis
	tick_interval = 1 SECONDS
	id = "nyxosynthesis"

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/tick(seconds_between_ticks)
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return

	var/bodypart_coefficient = GET_BODYPART_COEFFICIENT(bodyparts)
	if (!owner_turf.check_lumcount_below(SHADOW_SPECIES_LIGHT_THRESHOLD))
		owner.take_overall_damage(brute = 1 * bodypart_coefficient, burn = 1 * bodypart_coefficient, required_bodytype = BODYTYPE_SHADOW)
		return

	// Heal in the dark
	owner.heal_overall_damage(brute = 0.5 * bodypart_coefficient, burn = 0.5 * bodypart_coefficient, required_bodytype = BODYTYPE_SHADOW)

	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.dna.species.id != SPECIES_NIGHTMARE) // Somewhat awkward, but let's not duplicate the alerts
		// This only appears when in shadows, don't move to bodypart effect so people with nightvision can still tell if they're in light or not
		owner.apply_status_effect(/datum/status_effect/shadow)
