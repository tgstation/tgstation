/**
 * Infects whoever enters with a virus, that turns them into random creature
 * The cure is Rezadone, so the chance that poor soul will get cured is low
 * However the disease has stage_prob = 1 and 9 stages
 */

/turf/open/water/cursed_spring
	baseturfs = /turf/open/water/cursed_spring
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/water/cursed_spring/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/to_transform = arrived
	if(to_transform.incorporeal_move)
		return

	to_transform.add_mood_event("cursedhotspring", /datum/mood_event/cursedhotspring)

	var/datum/disease/D = /datum/disease/cursedhotsprings

	if(to_transform.HasDisease(D))
		return

	to_transform.ForceContractDisease(new D, FALSE, TRUE)


/datum/mood_event/cursedhotspring
	description = span_nicegreen("I recently had a paddle in some nice warm water! It was almost unusual how good it felt.\n")
	mood_change = 5
	timeout = 20 MINUTES
