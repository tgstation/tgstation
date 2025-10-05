///all the employers that are syndicate
#define FLAVOR_FACTION_SYNDICATE "syndicate"
///all the employers that are Nanotrasen
#define FLAVOR_FACTION_NANOTRASEN "nanotrasen"

/datum/antagonist/traitor
	name = "\improper Traitor"
	roundend_category = "traitors"
	antagpanel_category = "Traitor"
	pref_flag = ROLE_TRAITOR
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "traitor"
	hijack_speed = 0.5 //10 seconds per hijack stage by default
	ui_name = "AntagInfoTraitor"
	suicide_cry = "FOR THE SYNDICATE!!"
	preview_outfit = /datum/outfit/traitor
	can_assign_self_objectives = TRUE
	default_custom_objective = "Perform an overcomplicated heist on valuable Nanotrasen assets."
	hardcore_random_bonus = TRUE
	stinger_sound = 'sound/music/antag/traitor/tatoralert.ogg'

	///The flag of uplink that this traitor is supposed to have.
	var/uplink_flag_given = UPLINK_TRAITORS

	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	///give this traitor an uplink?
	var/give_uplink = TRUE
	///if TRUE, this traitor will always get hijacking as their final objective
	var/is_hijacker = FALSE

	///the name of the antag flavor this traitor has, set in Traitor's setup if not preset.
	var/employer

	///assoc list of strings set up after employer is given
	var/list/traitor_flavor

	///reference to the uplink this traitor was given, if they were.
	var/datum/weakref/uplink_ref

	/// The uplink handler that this traitor belongs to.
	var/datum/uplink_handler/uplink_handler

	var/uplink_sales_min = 4
	var/uplink_sales_max = 6

	///the final objective the traitor has to accomplish, be it escaping, hijacking, or just martyrdom.
	var/datum/objective/ending_objective

/datum/antagonist/traitor/New(give_objectives = TRUE)
	. = ..()
	src.give_objectives = give_objectives

/datum/antagonist/traitor/on_gain()
	if(give_uplink)
		owner.give_uplink(silent = TRUE, antag_datum = src)

	var/datum/component/uplink/uplink = owner.find_syndicate_uplink()
	uplink_ref = WEAKREF(uplink)
	if(uplink)
		if(uplink_handler)
			uplink.uplink_handler = uplink_handler
		else
			uplink_handler = uplink.uplink_handler
		uplink_handler.uplink_flag = uplink_flag_given
		uplink_handler.primary_objectives = objectives
		uplink_handler.has_progression = TRUE
		SStraitor.register_uplink_handler(uplink_handler)

		uplink_handler.can_replace_objectives = CALLBACK(src, PROC_REF(can_change_objectives))
		uplink_handler.replace_objectives = CALLBACK(src, PROC_REF(submit_player_objective))

		if(uplink_handler.progression_points < SStraitor.current_global_progression)
			uplink_handler.progression_points = SStraitor.current_global_progression * SStraitor.newjoin_progression_coeff

		var/list/uplink_items = list()
		for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
			if(item.item && !item.cant_discount && (item.purchasable_from & uplink_handler.uplink_flag) && item.cost >= TRAITOR_DISCOUNT_MIN_PRICE)
				if(!length(item.restricted_roles) && !length(item.restricted_species))
					uplink_items += item
					continue
				if((uplink_handler.assigned_role in item.restricted_roles) || (uplink_handler.assigned_species in item.restricted_species))
					uplink_items += item
					continue
		uplink_handler.extra_purchasable += create_uplink_sales(rand(uplink_sales_min, uplink_sales_max), /datum/uplink_category/discounts, -1, uplink_items)

	if(give_objectives)
		forge_traitor_objectives()
		forge_ending_objective()

	pick_employer()

	return ..()

/datum/antagonist/traitor/on_removal()
	if(!isnull(uplink_handler))
		uplink_handler.can_replace_objectives = null
		uplink_handler.replace_objectives = null
	owner.take_uplink()
	return ..()

/// Returns true if we're allowed to assign ourselves a new objective
/datum/antagonist/traitor/proc/can_change_objectives()
	return can_assign_self_objectives

/datum/antagonist/traitor/proc/pick_employer()
	if(!employer)
		var/faction = prob(75) ? FLAVOR_FACTION_SYNDICATE : FLAVOR_FACTION_NANOTRASEN
		var/list/possible_employers = list()

		possible_employers.Add(GLOB.syndicate_employers, GLOB.nanotrasen_employers)

		if(istype(ending_objective, /datum/objective/hijack))
			possible_employers -= GLOB.normal_employers
		else //escape or martyrdom
			possible_employers -= GLOB.hijack_employers

		switch(faction)
			if(FLAVOR_FACTION_SYNDICATE)
				possible_employers -= GLOB.nanotrasen_employers
			if(FLAVOR_FACTION_NANOTRASEN)
				possible_employers -= GLOB.syndicate_employers
		employer = pick(possible_employers)
	traitor_flavor = strings(TRAITOR_FLAVOR_FILE, employer)

/// Generates a complete set of traitor objectives up to the traitor objective limit, including non-generic objectives such as martyr and hijack.
/datum/antagonist/traitor/proc/forge_traitor_objectives()
	var/objective_count = 0

	if((GLOB.joined_player_list.len >= HIJACK_MIN_PLAYERS) && prob(HIJACK_PROB))
		is_hijacker = TRUE
		objective_count++

	var/objective_limit = CONFIG_GET(number/traitor_objectives_amount)
	var/datum/objective/job_objective = forge_job_objective()
	// for(in...to) loops iterate inclusively, so to reach objective_limit we need to loop to objective_limit - 1
	// This does not give them 1 fewer objectives than intended.
	for(var/i in objective_count to objective_limit - 1)
		var/generated = forge_single_generic_objective(job_objective)
		if(generated == job_objective)
			job_objective = null
		objectives += generated

/**
 * ## forge_ending_objective
 *
 * Forges the endgame objective and adds it to this datum's objective list.
 */
/datum/antagonist/traitor/proc/forge_ending_objective()
	if(is_hijacker)
		ending_objective = new /datum/objective/hijack
		ending_objective.owner = owner
		return

	var/martyr_compatibility = TRUE

	for(var/datum/objective/traitor_objective in objectives)
		if(!traitor_objective.martyr_compatible)
			martyr_compatibility = FALSE
			break

	if(martyr_compatibility && prob(MARTYR_PROB))
		ending_objective = new /datum/objective/martyr
		ending_objective.owner = owner
		objectives += ending_objective
		return

	ending_objective = new /datum/objective/escape
	ending_objective.owner = owner
	objectives += ending_objective

/datum/antagonist/traitor/proc/forge_single_generic_objective(job_objective)
	if(prob(JOB_PROB) && job_objective)
		return job_objective

	if(prob(KILL_PROB))
		var/list/active_ais = active_ais(skip_syndicate = TRUE)
		if(active_ais.len && prob(DESTROY_AI_PROB(GLOB.joined_player_list.len)))
			var/datum/objective/destroy/destroy_objective = new()
			destroy_objective.owner = owner
			destroy_objective.find_target()
			return destroy_objective

		if(prob(MAROON_PROB))
			var/datum/objective/maroon/maroon_objective = new()
			maroon_objective.owner = owner
			maroon_objective.find_target()
			return maroon_objective

		var/datum/objective/assassinate/kill_objective = new()
		kill_objective.owner = owner
		kill_objective.find_target()
		return kill_objective

	var/datum/objective/steal/steal_objective = new()
	steal_objective.owner = owner
	steal_objective.find_target()
	return steal_objective

/datum/antagonist/traitor/proc/forge_job_objective()
	var/datum/objective/job_objective = owner.assigned_role.generate_traitor_objective() // can return null
	job_objective?.owner = owner
	return job_objective

/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current

	handle_clown_mutation(datum_owner, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	if(should_give_codewords)
		datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
		datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	var/mob/living/datum_owner = mob_override || owner.current
	handle_clown_mutation(datum_owner, removing = FALSE)

	for(var/datum/component/codeword_hearing/component as anything in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

/datum/antagonist/traitor/submit_player_objective(retain_existing, retain_escape, force)
	. = ..()
	if (!.)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/antag/traitor/final_objective.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/traitor/ui_static_data(mob/user)
	var/datum/component/uplink/uplink = uplink_ref?.resolve()
	var/list/data = list()
	data["has_codewords"] = should_give_codewords
	if(should_give_codewords)
		data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
		data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["theme"] = traitor_flavor["ui_theme"]
	data["code"] = uplink?.unlock_code
	data["failsafe_code"] = uplink?.failsafe_code
	data["intro"] = traitor_flavor["introduction"]
	data["allies"] = traitor_flavor["allies"]
	data["goal"] = traitor_flavor["goal"]
	data["has_uplink"] = uplink ? TRUE : FALSE
	data["given_uplink"] = give_uplink
	if(uplink)
		data["uplink_intro"] = traitor_flavor["uplink"]
		data["uplink_unlock_info"] = uplink.unlock_text
	data["objectives"] = get_objectives()
	return data

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
			if(!objective.check_completion())
				traitor_won = FALSE
			objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			count++

	result += "<br>[owner.name] <B>[traitor_flavor["roundend_report"]]</B>"

	if(uplink_owned)
		var/uplink_text = "(used [used_telecrystals] TC) [purchases]"
		if((used_telecrystals == 0) && traitor_won)
			var/static/icon/badass = icon('icons/ui/antags/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	if(uplink_handler && uplink_handler.contractor_hub)
		result += contractor_round_end()

	var/special_role_text = LOWER_TEXT(name)

	if(traitor_won)
		result += span_greentext("The [special_role_text] was successful!")
	else
		result += span_redtext("The [special_role_text] has failed!")
		SEND_SOUND(owner.current, 'sound/ambience/misc/ambifailure.ogg')

	return result.Join("<br>")

///Tells how many contracts have been completed.
/datum/antagonist/traitor/proc/contractor_round_end()
	var/completed_contracts = uplink_handler.contractor_hub.contracts_completed
	var/tc_total = uplink_handler.contractor_hub.contract_TC_payed_out + uplink_handler.contractor_hub.contract_TC_to_redeem

	var/datum/antagonist/traitor/contractor_support/contractor_support_unit = uplink_handler.contractor_hub.contractor_teammate

	if(completed_contracts <= 0)
		return
	var/plural_check = "contract"
	if (completed_contracts > 1)
		plural_check = "contracts"
	var/sent_data = "Completed [span_greentext("[completed_contracts]")] [plural_check] for a total of [span_greentext("[tc_total] TC")]!<br>"
	if(contractor_support_unit)
		sent_data += "<b>[contractor_support_unit.owner.key]</b> played <b>[contractor_support_unit.owner.current.name]</b>, their contractor support unit.<br>"
	return sent_data

/datum/antagonist/traitor/roundend_report_footer()
	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	var/message = "<br><b>The code phrases were:</b> <span class='bluetext'>[phrases]</span><br>\
					<b>The code responses were:</b> [span_redtext("[responses]")]<br>"

	return message

/datum/outfit/traitor
	name = "Traitor (Preview only)"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/ablative
	head = /obj/item/clothing/head/hooded/ablative
	gloves = /obj/item/clothing/gloves/color/yellow
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/energy/sword
	r_hand = /obj/item/gun/energy/recharge/ebow
	shoes = /obj/item/clothing/shoes/magboots/advance

/datum/outfit/traitor/post_equip(mob/living/carbon/human/H, visuals_only)
	var/obj/item/melee/energy/sword/sword = locate() in H.held_items
	if(sword.flags_1 & INITIALIZED_1)
		sword.attack_self()
	else //Atoms aren't initialized during the screenshots unit test, so we can't call attack_self for it as the sword doesn't have the transforming weapon component to handle the icon changes. The below part is ONLY for the antag screenshots unit test.
		sword.icon_state = "e_sword_on_red"
		sword.inhand_icon_state = "e_sword_on_red"
		sword.worn_icon_state = "e_sword_on_red"

		H.update_held_items()

#undef FLAVOR_FACTION_SYNDICATE
#undef FLAVOR_FACTION_NANOTRASEN

/datum/antagonist/traitor/on_respawn(mob/new_character)
	SSjob.equip_rank(new_character, new_character.mind.assigned_role, new_character.client)
	new_character.mind.give_uplink(silent = TRUE, antag_datum = src)
	return TRUE
