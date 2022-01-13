/datum/antagonist/traitor
	name = "\improper Traitor"
	roundend_category = "traitors"
	antagpanel_category = "Traitor"
	job_rank = ROLE_TRAITOR
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "traitor"
	hijack_speed = 0.5 //10 seconds per hijack stage by default
	ui_name = "AntagInfoTraitor"
	suicide_cry = "FOR THE SYNDICATE!!"
	preview_outfit = /datum/outfit/traitor
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	///give this traitor an uplink?
	var/give_uplink = TRUE
	///if TRUE, this traitor will always get hijacking as their final objective
	var/is_hijacker = FALSE

	///the name of the antag flavor this traitor has.
	var/employer

	///assoc list of strings set up after employer is given
	var/list/traitor_flavor

	///reference to the uplink this traitor was given, if they were.
	var/datum/weakref/uplink_ref

	/// The uplink handler that this traitor belongs to.
	var/datum/uplink_handler/uplink_handler

	var/uplink_sale_count = 3

/datum/antagonist/traitor/New(give_objectives = TRUE)
	. = ..()
	src.give_objectives = give_objectives

/datum/antagonist/traitor/on_gain()
	owner.special_role = job_rank

	if(give_uplink)
		owner.give_uplink(silent = TRUE, antag_datum = src)

	var/datum/component/uplink/uplink = owner.find_syndicate_uplink()
	uplink_ref = WEAKREF(uplink)
	if(uplink)
		if(uplink_handler)
			uplink.uplink_handler = uplink_handler
		else
			uplink_handler = uplink.uplink_handler
		uplink_handler.has_progression = TRUE
		SStraitor.register_uplink_handler(uplink_handler)

		uplink_handler.has_objectives = TRUE
		uplink_handler.owner = owner
		uplink_handler.assigned_role = owner.assigned_role.title
		uplink_handler.generate_objectives()

		if(uplink_handler.progression_points < SStraitor.current_global_progression)
			uplink_handler.progression_points = SStraitor.current_global_progression * SStraitor.newjoin_progression_coeff
		var/list/uplink_items = list()
		for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
			if(item.item && (!length(item.restricted_roles) || (uplink_handler.assigned_role in item.restricted_roles)) \
				&&  !item.cant_discount && (item.purchasable_from & uplink_handler.uplink_flag) && item.cost > 1)
				uplink_items += item
		uplink_handler.extra_purchasable += create_uplink_sales(uplink_sale_count, /datum/uplink_category/discounts, -1, uplink_items)

	if(give_objectives)
		forge_traitor_objectives()

	var/faction = prob(75) ? FACTION_SYNDICATE : FACTION_NANOTRASEN

	pick_employer(faction)

	traitor_flavor = strings(TRAITOR_FLAVOR_FILE, employer)

	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	return ..()

/datum/antagonist/traitor/proc/traitor_objective_to_html(datum/traitor_objective/to_display)
	var/string = "[to_display.name]"
	if(to_display.objective_state == OBJECTIVE_STATE_ACTIVE || to_display.objective_state == OBJECTIVE_STATE_INACTIVE)
		string += " <a href='?src=[REF(owner)];edit_obj_tc=[REF(to_display)]'>[to_display.telecrystal_reward] TC</a>"
		string += " <a href='?src=[REF(owner)];edit_obj_pr=[REF(to_display)]'>[to_display.progression_reward] PR</a>"
	else
		string += ", [to_display.telecrystal_reward] TC"
		string += ", [to_display.progression_reward] PR"
	if(to_display.objective_state == OBJECTIVE_STATE_ACTIVE)
		string += " <a href='?src=[REF(owner)];fail_objective=[REF(to_display)]'>Fail this objective</a>"
		string += " <a href='?src=[REF(owner)];succeed_objective=[REF(to_display)]'>Succeed this objective</a>"
	if(to_display.objective_state == OBJECTIVE_STATE_INACTIVE)
		string += " <a href='?src=[REF(owner)];fail_objective=[REF(to_display)]'>Dispose of this objective</a>"

	if(to_display.skipped)
		string += " - <b>Skipped</b>"
	else if(to_display.objective_state == OBJECTIVE_STATE_FAILED)
		string += " - <b><font color='red'>Failed</font></b>"
	else if(to_display.objective_state == OBJECTIVE_STATE_INVALID)
		string += " - <b>Invalidated</b>"
	else if(to_display.objective_state == OBJECTIVE_STATE_COMPLETED)
		string += " - <b><font color='green'>Succeeded</font></b>"

	return string

/datum/antagonist/traitor/antag_panel_objectives()
	var/result = ..()
	if(!uplink_handler)
		return result
	result += "<i><b>Traitor specific objectives</b></i><br>"
	result += "<i><b>Concluded Objectives</b></i>:<br>"
	for(var/datum/traitor_objective/objective as anything in uplink_handler.completed_objectives)
		result += "[traitor_objective_to_html(objective)]<br>"
	if(!length(uplink_handler.completed_objectives))
		result += "EMPTY<br>"
	result += "<i><b>Ongoing Objectives</b></i>:<br>"
	for(var/datum/traitor_objective/objective as anything in uplink_handler.active_objectives)
		result += "[traitor_objective_to_html(objective)]<br>"
	if(!length(uplink_handler.active_objectives))
		result += "EMPTY<br>"
	result += "<i><b>Potential Objectives</b></i>:<br>"
	for(var/datum/traitor_objective/objective as anything in uplink_handler.potential_objectives)
		result += "[traitor_objective_to_html(objective)]<br>"
	if(!length(uplink_handler.potential_objectives))
		result += "EMPTY<br>"
	result += "<a href='?src=[REF(owner)];common=1;give_objective=1'>Force add objective</a><br>"
	return result

/datum/antagonist/traitor/on_removal()
	owner.special_role = null
	return ..()

/datum/antagonist/traitor/proc/pick_employer(faction)
	var/list/possible_employers = list()
	possible_employers.Add(GLOB.syndicate_employers, GLOB.nanotrasen_employers)

	switch(faction)
		if(FACTION_SYNDICATE)
			possible_employers -= GLOB.nanotrasen_employers
		if(FACTION_NANOTRASEN)
			possible_employers -= GLOB.syndicate_employers
	employer = pick(possible_employers)

/datum/objective/traitor_progression
	name = "traitor progression"
	explanation_text = "Become a living legend by getting a total of %REPUTATION% reputation points"

	var/possible_range = list(40 MINUTES, 90 MINUTES)
	var/required_total_progression_points

/datum/objective/traitor_progression/New(text)
	. = ..()
	required_total_progression_points = round(rand(possible_range[1], possible_range[2]) / 60)
	explanation_text = replacetext(explanation_text, "%REPUTATION%", required_total_progression_points)

/datum/objective/traitor_progression/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return FALSE
	if(!traitor.uplink_handler)
		return FALSE
	if(traitor.uplink_handler.progression_points < required_total_progression_points)
		return FALSE
	return TRUE

/datum/objective/traitor_objectives
	name = "traitor objective"
	explanation_text = "Complete objectives colletively worth more than %REPUTATION% reputation points"

	var/possible_range = list(20 MINUTES, 30 MINUTES)
	var/required_progression_in_objectives

/datum/objective/traitor_objectives/New(text)
	. = ..()
	required_progression_in_objectives = round(rand(possible_range[1], possible_range[2]) / 60)
	explanation_text = replacetext(explanation_text, "%REPUTATION%", required_progression_in_objectives)

/datum/objective/traitor_objectives/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return FALSE
	if(!traitor.uplink_handler)
		return FALSE
	var/total_points = 0
	for(var/datum/traitor_objective/objective as anything in traitor.uplink_handler.completed_objectives)
		if(objective.objective_state != OBJECTIVE_STATE_COMPLETED)
			continue
		total_points += objective.progression_reward
	if(total_points < required_progression_in_objectives)
		return FALSE
	return TRUE

/// Generates a complete set of traitor objectives up to the traitor objective limit, including non-generic objectives such as martyr and hijack.
/datum/antagonist/traitor/proc/forge_traitor_objectives()
	objectives.Cut()

	var/datum/objective/traitor_progression/final_objective = new /datum/objective/traitor_progression()
	final_objective.owner = owner
	objectives += final_objective

	var/datum/objective/traitor_objectives/objective_completion = new /datum/objective/traitor_objectives()
	objective_completion.owner = owner
	objectives += objective_completion


/datum/antagonist/traitor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current

	handle_clown_mutation(datum_owner, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	if(should_give_codewords)
		datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
		datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)

/datum/antagonist/traitor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	handle_clown_mutation(datum_owner, removing = FALSE)

	for(var/datum/component/codeword_hearing/component as anything in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)

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
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
				traitor_won = FALSE
			count++

	result += "<br>[owner.name] <B>[traitor_flavor["roundend_report"]]</B>"

	if(uplink_owned)
		var/uplink_text = "(used [used_telecrystals] TC) [purchases]"
		if((used_telecrystals == 0) && traitor_won)
			var/static/icon/badass = icon('icons/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	if(uplink_handler)
		var/completed_objectives_text = "Completed Uplink Objectives: "
		for(var/datum/traitor_objective/objective as anything in uplink_handler.completed_objectives)
			if(objective.objective_state == OBJECTIVE_STATE_COMPLETED)
				completed_objectives_text += "<br><B>[objective.name]</B> - ([objective.telecrystal_reward] TC, [round(objective.progression_reward/600, 0.1)] Reputation)"
		result += completed_objectives_text

	var/special_role_text = lowertext(name)

	if(traitor_won)
		result += span_greentext("The [special_role_text] was successful!")
	else
		result += span_redtext("The [special_role_text] has failed!")
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

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
	gloves = /obj/item/clothing/gloves/color/yellow
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/energy/sword
	r_hand = /obj/item/gun/energy/kinetic_accelerator/crossbow

/datum/outfit/traitor/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/melee/energy/sword/sword = locate() in H.held_items
	sword.icon_state = "e_sword_on_red"
	sword.worn_icon_state = "e_sword_on_red"

	H.update_inv_hands()
