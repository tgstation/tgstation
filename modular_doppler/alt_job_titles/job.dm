// ALTERNATIVE_JOB_TITLES

/**
 * Sets a human's ID/PDA title to match their preferred alt title for the given job.
 * Run after we apply or make modifications to a given assignment during roundstart/latejoin setup.
 */
/datum/controller/subsystem/job/proc/setup_alt_job_title(mob/living/carbon/human/equipping, datum/job/job, client/player_client)
	if(!player_client)
		return

	if(!ishuman(equipping))
		return

	var/chosen_title = player_client.prefs.alt_job_titles[job.title] || job.title

	var/obj/item/card/id/card = equipping.get_idcard(hand_first = FALSE)
	if(istype(card))
		chosen_title = card.get_modified_title(chosen_title)
		card.assignment = chosen_title
		card.update_label()

	// Look for PDA in belt or L pocket
	var/obj/item/modular_computer/pda/pda = equipping.belt
	if(!istype(pda))
		pda = equipping.l_store
	if(istype(pda))
		pda.saved_job = chosen_title
		pda.UpdateDisplay()
