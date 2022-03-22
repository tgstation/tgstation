#define BSA_CHANCE_TO_BREAK_TILE_TO_PLATING 80
#define BSA_MAX_DAMAGE 99
#define BSA_PARALYZE_TIME (40 SECONDS)
#define BSA_STUTTER_TIME 20

/// Fires the BSA at the target
/datum/smite/bsa
	name = "Bluespace Artillery Device"

/datum/smite/bsa/effect(client/user, mob/living/target)
	. = ..()

	explosion(target.loc, explosion_cause = src)

	var/turf/open/floor/target_turf = get_turf(target)
	if (istype(target_turf))
		if (prob(BSA_CHANCE_TO_BREAK_TILE_TO_PLATING))
			target_turf.break_tile_to_plating()
		else
			target_turf.break_tile()

	if (target.health <= 1)
		target.gib(
			/* no_brain = */ TRUE,
			/* no_organs = */ TRUE,
		)
	else
		target.adjustBruteLoss(min(BSA_MAX_DAMAGE, target.health - 1))
		target.Paralyze(BSA_PARALYZE_TIME)
		target.stuttering = BSA_STUTTER_TIME

#undef BSA_CHANCE_TO_BREAK_TILE_TO_PLATING
#undef BSA_MAX_DAMAGE
#undef BSA_PARALYZE_TIME
#undef BSA_STUTTER_TIME
