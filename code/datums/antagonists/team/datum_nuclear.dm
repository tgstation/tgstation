/datum/antagonist/team/nuclear_operative
	name = ROLE_OPERATIVE
	landmark_spawn = "Syndicate-Spawn"
	ignore_job_selection = TRUE


/datum/antagonist/team/nuclear_operative/on_gain()
	. = ..()
	//to-do: give nuke code

/datum/antagonist/team/nuclear_operative/apply_innate_effects()
	. = ..()
	//update_synd_icons_added(owner)

/datum/antagonist/team/nuclear_operative/remove_innate_effects()
	. = ..()
	//update_synd_icons_removed(owner)

/datum/antagonist/team/nuclear_operative/give_equipment()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.equipOutfit(/datum/outfit/syndicate)