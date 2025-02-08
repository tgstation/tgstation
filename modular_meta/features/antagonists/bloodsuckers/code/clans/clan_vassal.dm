/**
 * Vassal Clan
 *
 * Automatically assigned to Vassals who become Bloodsuckers mid-round.
 * We can't level ourselves up or interact with our own Vassals.
 */
/datum/bloodsucker_clan/vassal
	name = CLAN_VASSAL
	description = "As a vassal, you are too young to enter a clan of your own. \n\
		Continue to help your master advance in their aspirations."
	joinable_clan = FALSE
	shows_in_archives = FALSE
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY //You drink the same as your Master.

/datum/bloodsucker_clan/vassal/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	return FALSE

/datum/bloodsucker_clan/vassal/interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	return FALSE
