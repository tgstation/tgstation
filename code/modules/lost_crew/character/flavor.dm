/// Apply some flavor to the character to make it seem more 'alive'
/datum/corpse_flavor

/datum/corpse_flavor/proc/apply_flavor(mob/living/carbon/human/working_dead, list/job_gear, list/datum/callback/on_revive_and_player_occupancy)

/// Applies a quirk when selected
/datum/corpse_flavor/quirk
	var/datum/quirk/quirk

/datum/corpse_flavor/quirk/apply_flavor(mob/living/carbon/human/working_dead, list/job_gear, list/datum/callback/on_revive_and_player_occupancy)
	working_dead.add_quirk(quirk, announce = FALSE)

/datum/corpse_flavor/quirk/prosthetic_limb
	quirk = /datum/quirk/prosthetic_limb
