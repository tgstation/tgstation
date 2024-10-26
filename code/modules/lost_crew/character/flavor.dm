/// Apply some flavor to the character to make it seem more 'alive'
/datum/corpse_flavor

/datum/corpse_flavor/proc/apply_flavor(mob/living/carbon/human/working_dead, list/job_gear, list/datum/callback/on_revive_and_player_occupancy)

/// Applies a quirk when selected
/datum/corpse_flavor/quirk
	var/datum/quirk/quirk

/datum/corpse_flavor/quirk/apply_flavor(mob/living/carbon/human/working_dead, list/job_gear, list/datum/callback/on_revive_and_player_occupancy)
	working_dead.add_quirk(quirk)

/datum/corpse_flavor/quirk/prosthetic_limb
	quirk = /datum/quirk/prosthetic_limb

/// A random positive quirk! Why not tbh, even if it gives them an unbalanced quirk score for however long they exist
/datum/corpse_flavor/quirk/positive_quirk

/datum/corpse_flavor/quirk/positive_quirk/apply_flavor(mob/living/carbon/human/working_dead, list/job_gear, list/datum/callback/on_revive_and_player_occupancy)
	var/static/list/positive_quirks
	if(!positive_quirks)
		positive_quirks = list()

		for(var/datum/quirk/quirk as anything in subtypesof(/datum/quirk))
			if(initial(quirk.value) > 0)
				positive_quirks += quirk

	quirk = pick(positive_quirks)

	..()
