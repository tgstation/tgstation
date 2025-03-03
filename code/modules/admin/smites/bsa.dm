#define BSA_CHANCE_TO_BREAK_TILE_TO_PLATING 80
#define BSA_MAX_DAMAGE 99
#define BSA_PARALYZE_TIME (40 SECONDS)
#define BSA_STUTTER_TIME (40 SECONDS)

/// Fires the BSA at the target
/datum/smite/bsa
	name = "Bluespace Artillery Device"

/datum/smite/bsa/effect(client/user, mob/living/target)
	. = ..()

	playsound(target.loc, 'newstuff/nikitauou/sound/broneboynii.mp3', 50, FALSE, 5)
	sleep(10 SECONDS)
	explosion(target.loc, explosion_cause = src, flame_range = 2, flash_range = 4, light_impact_range = 2)

	var/turf/open/floor/target_turf = get_turf(target)
	if (istype(target_turf))
		if (prob(BSA_CHANCE_TO_BREAK_TILE_TO_PLATING))
			target_turf.break_tile_to_plating()
		else
			target_turf.break_tile()

	if (target.health <= 1)
		target.gib(DROP_BODYPARTS)
	else
		target.adjustBruteLoss(min(BSA_MAX_DAMAGE, target.health - 1))
		target.Paralyze(BSA_PARALYZE_TIME)
		target.set_stutter(BSA_STUTTER_TIME)

#undef BSA_CHANCE_TO_BREAK_TILE_TO_PLATING
#undef BSA_MAX_DAMAGE
#undef BSA_PARALYZE_TIME
#undef BSA_STUTTER_TIME
