// ALTERNATIVE_JOB_TITLES

/**
 * Shows a list of all current and future polls and buttons to edit or delete them or create a new poll.
 *
 * All extra functionality to run on new player mobs, in a place where we actually have the client,
 * and haven't called COMSIG_GLOB_JOB_AFTER_SPAWN yet, so we are running before the wallet trait,
 * and other things that rely on items already being settled.
 */
/datum/controller/subsystem/job/proc/setup_alt_job_items(mob/living/carbon/human/equipping, datum/job/job, client/player_client)
	if(!player_client)
		return

	if(!ishuman(equipping))
		return

	var/chosen_title = player_client.prefs.alt_job_titles[job.title] || job.title

	var/obj/item/card/id/card = equipping.wear_id
	if(istype(card))
		card.assignment = chosen_title
		card.update_label()

	// Look for PDA in belt or L pocket
	var/obj/item/modular_computer/pda/pda = equipping.belt
	if(!istype(pda))
		pda = equipping.l_store
	if(istype(pda))
		pda.saved_job = chosen_title
		pda.UpdateDisplay()
