/// Chance that the traitor could roll hijack if the pop limit is met.
#define HIJACK_PROB 10
/// Hijack is unavailable as a random objective below this player count.
#define HIJACK_MIN_PLAYERS 30

/// Chance the traitor gets a martyr objective instead of having to escape alive, as long as all the objectives are martyr compatible.
#define MARTYR_PROB 20

/// Chance the traitor gets a kill objective. If this prob fails, they will get a steal objective instead.
#define KILL_PROB 50
/// If a kill objective is rolled, chance that it is to destroy the AI.
#define DESTROY_AI_PROB(denominator) (100 / denominator)
/// If the destroy AI objective doesn't roll, chance that we'll get a maroon instead. If this prob fails, they will get a generic assassinate objective instead.
#define MAROON_PROB 30
/// If it's a steal objective, this is the chance that it'll be a download research notes objective. Science staff can't get this objective. It can only roll once. If any of these fail, they will get a generic steal objective instead.
#define DOWNLOAD_PROB 15

/datum/antagonist/traitor
	name = "Traitor"
	roundend_category = "traitors"
	antagpanel_category = "Traitor"
	job_rank = ROLE_TRAITOR
	antag_moodlet = /datum/mood_event/focused
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"
	hijack_speed = 0.5 //10 seconds per hijack stage by default
	var/employer = "The Syndicate"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE

	var/datum/contractor_hub/contractor_hub

/datum/antagonist/traitor/on_gain()
	owner.special_role = job_rank
	if(give_objectives)
		forge_traitor_objectives()

	equip()

	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	return ..()

/datum/antagonist/traitor/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer the [job_rank]!</span>")

	owner.special_role = null

	return ..()

/// Simple helper proc that handles equipping the traitor if necessary.
/datum/antagonist/traitor/proc/equip()
	if(should_equip)
		owner.equip_traitor(employer, silent, src)

/// Generates a complete set of traitor objectives up to the traitor objective limit, including non-generic objectives such as martyr and hijack.
/datum/antagonist/traitor/proc/forge_traitor_objectives()
	objectives.Cut()

	var/is_hijacker = FALSE
	var/objective_count = 0

	if ((GLOB.joined_player_list.len >= HIJACK_MIN_PLAYERS) && prob(HIJACK_PROB))
		is_hijacker = TRUE
		objective_count++

	var/objective_limit = CONFIG_GET(number/traitor_objectives_amount)

	// for(in...to) loops iterate inclusively, so to reach objective_limit we need to loop to objective_limit - 1
	// This does not give them 1 fewer objectives than intended.
	for(var/i in objective_count to objective_limit - 1)
		forge_single_generic_objective()

	if(is_hijacker)
		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = owner
		objectives += hijack_objective
		return

	forge_escape_objective()

/// Forges a single escape objective and adds it to this datum's objective list.
/datum/antagonist/traitor/proc/forge_escape_objective()
	var/is_martyr = prob(MARTYR_PROB)
	var/martyr_compatibility = TRUE

	for(var/datum/objective/traitor_objective in objectives)
		if(!traitor_objective.martyr_compatible)
			martyr_compatibility = FALSE
			break

	if(martyr_compatibility && is_martyr)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		objectives += martyr_objective
		return

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

/// Adds a generic kill or steal objective to this datum's objective list.
/datum/antagonist/traitor/proc/forge_single_generic_objective()
	if(prob(KILL_PROB))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(DESTROY_AI_PROB(GLOB.joined_player_list.len)))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			objectives += destroy_objective
			return

		if(prob(MAROON_PROB))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			objectives += maroon_objective
			return

		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		objectives += kill_objective
		return

	if(prob(DOWNLOAD_PROB) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist", "Geneticist")))
		var/datum/objective/download/download_objective = new
		download_objective.owner = owner
		download_objective.gen_amount_goal()
		objectives += download_objective
		return

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = owner
	steal_objective.find_target()
	objectives += steal_objective

/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role].</span>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current

	add_antag_hud(antag_hud_type, antag_hud_name, datum_owner)
	handle_clown_mutation(datum_owner, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	remove_antag_hud(antag_hud_type, datum_owner)
	handle_clown_mutation(datum_owner, removing = FALSE)

	for(var/datum/component/codeword_hearing/component as anything in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/// Outputs this shift's codewords and responses to the antag's chat and copies them to their memory.
/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return

	var/mob/traitor_mob = owner.current

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	to_chat(traitor_mob, "<U><B>The Syndicate have provided you with the following codewords to identify fellow agents:</B></U>")
	to_chat(traitor_mob, "<B>Code Phrase</B>: <span class='blue'>[phrases]</span>")
	to_chat(traitor_mob, "<B>Code Response</B>: <span class='red'>[responses]</span>")

	antag_memory += "<b>Code Phrase</b>: <span class='blue'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	to_chat(traitor_mob, "Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	to_chat(traitor_mob, "<span class='alertwarning'>You memorize the codewords, allowing you to recognise them when heard.</span>")

/datum/antagonist/traitor/roundend_report()
	var/list/result = list()

	var/traitor_won = TRUE

	result += printplayer(owner)

	var/used_telecrystals = 0
	var/uplink_owned = FALSE
	var/purchases = ""

	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	// Uplinks add an entry to uplink_purchase_logs_by_key on init.
	var/datum/uplink_purchase_log/purchase_log = GLOB.uplink_purchase_logs_by_key[owner.key]
	if(purchase_log)
		used_telecrystals = purchase_log.total_spent
		uplink_owned = TRUE
		purchases += purchase_log.generate_render(FALSE)

	var/objectives_text = ""
	if(objectives.len) //If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				traitor_won = FALSE
			count++

	if(uplink_owned)
		var/uplink_text = "(used [used_telecrystals] TC) [purchases]"
		if((used_telecrystals == 0) && traitor_won)
			var/static/icon/badass = icon('icons/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	var/special_role_text = lowertext(name)

	if (contractor_hub)
		result += contractor_round_end()

	if(traitor_won)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/// Proc detailing contract kit buys/completed contracts/additional info
/datum/antagonist/traitor/proc/contractor_round_end()
	var/result = ""
	var/total_spent_rep = 0

	var/completed_contracts = contractor_hub.contracts_completed
	var/tc_total = contractor_hub.contract_TC_payed_out + contractor_hub.contract_TC_to_redeem

	var/contractor_item_icons = "" // Icons of purchases
	var/contractor_support_unit = "" // Set if they had a support unit - and shows appended to their contracts completed

	/// Get all the icons/total cost for all our items bought
	for (var/datum/contractor_item/contractor_purchase in contractor_hub.purchased_items)
		contractor_item_icons += "<span class='tooltip_container'>\[ <i class=\"fas [contractor_purchase.item_icon]\"></i><span class='tooltip_hover'><b>[contractor_purchase.name] - [contractor_purchase.cost] Rep</b><br><br>[contractor_purchase.desc]</span> \]</span>"

		total_spent_rep += contractor_purchase.cost

		/// Special case for reinforcements, we want to show their ckey and name on round end.
		if (istype(contractor_purchase, /datum/contractor_item/contractor_partner))
			var/datum/contractor_item/contractor_partner/partner = contractor_purchase
			contractor_support_unit += "<br><b>[partner.partner_mind.key]</b> played <b>[partner.partner_mind.current.name]</b>, their contractor support unit."

	if (contractor_hub.purchased_items.len)
		result += "<br>(used [total_spent_rep] Rep) "
		result += contractor_item_icons
	result += "<br>"
	if (completed_contracts > 0)
		var/pluralCheck = "contract"
		if (completed_contracts > 1)
			pluralCheck = "contracts"

		result += "Completed <span class='greentext'>[completed_contracts]</span> [pluralCheck] for a total of \
					<span class='greentext'>[tc_total] TC</span>![contractor_support_unit]<br>"

	return result

/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var/message = "<br><b>The code phrases were:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='redtext'>[responses]</span><br>"

	return message

#undef HIJACK_PROB
#undef HIJACK_MIN_PLAYERS
#undef MARTYR_PROB
#undef KILL_PROB
#undef DESTROY_AI_PROB
#undef MAROON_PROB
#undef DOWNLOAD_PROB
