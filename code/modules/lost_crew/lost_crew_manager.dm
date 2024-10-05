GLOBAL_DATUM_INIT(lost_crew_manager, /datum/lost_crew_manager, new)

/// Handles procs and timers for the lost
/datum/lost_crew_manager
	/// How many credits we reward the medical budget on a succesful revive
	var/credits_on_succes = CARGO_CRATE_VALUE * 10
	/// How long after succesful revival we check to see if theyre still alive, and give rewards
	var/succes_check_time = 3 SECONDS //set to 3 minutes when done testing

/**
 * Creates a body with random background and injuries
 *
 * Arguments:
 * * revivable - Whether or not we can be revived to grand a ghost controle
 * * forced_class - To force a specific damage class for some specific lore reason
 * * recovered_items - Items recovered, such as some organs, dropped directly with the body
 * * body_data - Debug data we can use to get a readout of what has been done
 */
/datum/lost_crew_manager/proc/create_lost_crew(revivable = TRUE, datum/corpse_damage_class/forced_class, list/recovered_items = list(), list/body_data = list())
	var/mob/living/carbon/human/new_body = new(null)
	new_body.death()

	var/static/list/scenarios = list()
	if(!scenarios.len)
		var/list/types = subtypesof(/datum/corpse_damage_class)
		for(var/datum/corpse_damage_class/scenario as anything in types)
			scenarios[scenario] = initial(scenario.weight)

	var/datum/corpse_damage_class/scenario = forced_class || pick_weight(scenarios)
	scenario = new scenario ()

	scenario.apply_character(new_body, recovered_items, body_data)
	scenario.apply_injuries(new_body, recovered_items, body_data)

	// so bodies can also be used for runes, morgue, etc
	if(revivable)
		//it's not necessary since we dont spawn the body until we open the bodybag, but why not be nice for once
		new_body.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 5)

		var/obj/item/organ/internal/brain/hersens = new_body.get_organ_by_type(/obj/item/organ/internal/brain)
		hersens.AddComponent(/datum/component/ghostrole_on_revive, /* refuse_revival_if_failed = */ TRUE, /*on_revival = */ CALLBACK(src, PROC_REF(start_countdown), hersens))

	return new_body

/datum/lost_crew_manager/proc/start_countdown(obj/item/organ/internal/brain/brain)
	var/mob/living/carbon/owner = brain.owner

	addtimer(CALLBACK(src, PROC_REF(award_succes), owner.mind), succes_check_time)

/// Give medbay a happy announcement and put some money into their budget
/datum/lost_crew_manager/proc/award_succes(datum/mind/revived_mind)
	var/obj/item/radio/headset/radio = new /obj/item/radio/headset/silicon/ai(revived_mind.current) //radio cant be in nullspace or brit shakes
	radio.set_frequency(FREQ_MEDICAL)
	radio.name = "Medical Announcer"

	// i am incredibly disappointed in you
	if(revived_mind.current.stat == DEAD)
		radio.talk_into(radio, "Sensors indicate lifesigns of [revived_mind.name] have seized. Please inform their family of your failure.", FREQ_MEDICAL)
		return

	// You are a credit to society
	radio.talk_into(radio, "Sensors indicate continued survival of [revived_mind.name]. Well done, [credits_on_succes]cr has been transferred to the medical budget.", FREQ_MEDICAL)

	var/datum/bank_account/medical_budget = SSeconomy.get_dep_account(ACCOUNT_MED)
	medical_budget.adjust_money(credits_on_succes)
	qdel(radio)
