// Proc detailing contract kit buys/completed contracts/additional info
/datum/antagonist/traitor/proc/contractor_round_end()
	var/result = ""
	var/total_spent_rep = 0

	var/contractor_item_icons = "" // Icons of purchases
	var/contractor_support_unit = "" // Set if they had a support unit - and shows appended to their contracts completed

	/// Get all the icons/total cost for all our items bought
	for(var/datum/contractor_item/contractor_purchase in uplink_handler.purchased_contractor_items)
		contractor_item_icons += "<span class='tooltip_container'>\[ <i class=\"fas [contractor_purchase.item_icon]\"></i><span class='tooltip_hover'><b>[contractor_purchase.name] - [contractor_purchase.cost] Rep</b><br><br>[contractor_purchase.desc]</span> \]</span>"
//TEST SPANS
		total_spent_rep += contractor_purchase.cost

		/// Special case for reinforcements, we want to show their ckey and name on round end.
		if(istype(contractor_purchase, /datum/contractor_item/contractor_partner))
			var/datum/contractor_item/contractor_partner/partner = contractor_purchase
			contractor_support_unit += "<br><b>[partner.partner_mind.key]</b> played <b>[partner.partner_mind.current.name]</b>, their contractor support unit."

	if(length(uplink_handler.purchased_contractor_items))
		result += "<br>(used [total_spent_rep] Rep) "
		result += contractor_item_icons
	result += "<br>"

	return result

// USED FOR THE MIDROUND ANTAGONIST
/datum/antagonist/traitor/contractor
	name = "Drifting Contractor"
	antagpanel_category = "Drifting Contractor"
	preview_outfit = /datum/outfit/contractor_preview
	job_rank = ROLE_DRIFTING_CONTRACTOR
	antag_hud_name = "contractor"
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	give_uplink = FALSE
	suicide_cry = "FOR THE CONTRACTS!!"
	/// The outfit the contractor is equipped with
	var/contractor_outfit = /datum/outfit/contractor

/datum/antagonist/traitor/contractor/proc/equip_guy()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/person = owner.current
	person.equipOutfit(contractor_outfit)
	return TRUE

/datum/antagonist/traitor/contractor/on_gain()
	equip_guy()
	. = ..()

	var/datum/component/uplink/found_uplink = owner.find_syndicate_uplink()
	if(!found_uplink)
		CRASH("Unable to find uplink for contractor [owner].")

	found_uplink.become_contractor()

/datum/antagonist/traitor/contractor/forge_traitor_objectives()
	var/datum/objective/contractor_total/contract_objective = new
	contract_objective.owner = owner
	objectives += contract_objective
	objectives += forge_single_generic_objective()

/// Used by drifting contractors
/datum/objective/contractor_total
	name = "contractor"
	martyr_compatible = TRUE
	/// How many contracts are needed, rand(1, 3)
	var/contracts_needed

/datum/objective/contractor_total/New(text)
	. = ..()
	contracts_needed = rand(1, 3)
	explanation_text = "Complete at least [contracts_needed] contract\s."

/datum/objective/contractor_total/check_completion()
	var/datum/antagonist/traitor/antag_datum = owner.has_antag_datum(/datum/antagonist/traitor)
	var/datum/uplink_handler/handler = antag_datum?.uplink_handler
	var/completed_contracts = 0
	for(var/datum/traitor_objective/objective in handler?.completed_objectives)
		if(objective.objective_state != OBJECTIVE_STATE_COMPLETED)
			continue

		completed_contracts++

	return completed_contracts >= contracts_needed || completed //only given to contractors so we can assume any completed objectives are contracts

/datum/job/drifting_contractor
	title = ROLE_DRIFTING_CONTRACTOR
