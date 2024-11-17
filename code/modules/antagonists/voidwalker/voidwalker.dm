/// Space antagonist that harasses people near space and cursed them if they get the chance
/datum/antagonist/voidwalker
	name = "\improper Voidwalker"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	job_rank = ROLE_VOIDWALKER
	show_in_antagpanel = TRUE
	antagpanel_category = "Voidwalker"
	roundend_category = "Voidwalkers"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoVoidwalker"
	suicide_cry = "FOR THE VOID!!"
	preview_outfit = /datum/outfit/voidwalker
	/// All researched spells. Used on roundend report.
	var/list/researched_spells = list()
	/// All upgrades trees in our upgrades ui.
	var/list/all_upgrades = list()
	/// Upgrades that we bougth.
	var/list/upgrades_we_have = list()
	/// Points that we gain by sending people into the void and spend on upgrades. 1 is given at the beginning.
	var/points = 1
	/// How many points did we recived for the round.
	var/total_points = 0
	/// How many points we gain when void blessed kidnap target.
	var/points_recieved_from_void_blessed = 1
	/// Give unsettle to void blessed.
	var/unsettle_to_blessed = FALSE

/datum/antagonist/voidwalker/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/voidwalker/on_gain()
	. = ..()

	var/mob/living/carbon/human/body = owner.current
	if(ishuman(body))
		body.set_species(/datum/species/voidwalker)
		body.faction |= FACTION_VOIDWALKER
		RegisterSignal(body, COMSIG_VOIDWALKER_SUCCESFUL_KIDNAP, PROC_REF(gain_point))

	generate_voidwalker_upgrades()

	forge_objectives()

/datum/antagonist/voidwalker/on_removal()
	var/mob/living/carbon/human/body = owner.current
	if(ishuman(body))
		body.faction &= ~FACTION_VOIDWALKER
		body.set_species(/datum/species/human)
		UnregisterSignal(body, COMSIG_VOIDWALKER_SUCCESFUL_KIDNAP)

	return ..()

/datum/antagonist/voidwalker/forge_objectives()
	var/datum/objective/voidwalker_objective/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/voidwalker/roundend_report()
	var/list/report = list()

	report += printplayer(owner)
	if(total_points > 0)
		report += span_green("<b>Voidwalker kidnapped [total_points] crewmember[total_points > 1 ? "s" : ""].</b>")
	else
		report += span_redtext("<b>Voidwalker didn't kidnapped anyone!</b>")
	if(length(researched_spells))
		report += "<b>Researched Spells:</b>"

		var/list/spells_list = list()

		for(var/datum/action/cooldown/spell/unlocked_spell in researched_spells)
			spells_list += unlocked_spell

		report += english_list(spells_list)
	else
		report += "<b>Voidwalker didn't learned any new spells.</b>"

	if(length(upgrades_we_have))
		report += "<b>Researched Upgrades:</b>"
		var/list/branches_list = list()

		for(var/datum/voidwalker_upgrade_branch/branch in upgrades_we_have)
			var/name_to_report = branch.name
			if(branch.for_free)
				name_to_report += " (free)"
			branches_list += name_to_report

		report += english_list(branches_list)

	else
		report += span_red("<b>Voidwaleker didn't upgraded anything!</b>")

	return report.Join("<br>")

/datum/antagonist/voidwalker/get_admin_commands()
	. = ..()

	.["Adjust Upgrade Points"] = CALLBACK(src, PROC_REF(admin_change_points))

/// Recive 1 point when we kidnap someone.
/datum/antagonist/voidwalker/proc/gain_point()
	SIGNAL_HANDLER
	points++
	total_points++

/// Admin verb in TP to change points counter.
/datum/antagonist/voidwalker/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/change_num = tgui_input_number(admin, "Add or remove upgrade points", "Points", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	points += change_num

/datum/outfit/voidwalker
	name = "Voidwalker (Preview only)"

/datum/outfit/voidwalker/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/voidwalker)

/datum/objective/voidwalker_objective

/datum/objective/voidwalker_objective/New()
	var/list/explanation_texts = list(
		"Show them the beauty of the void. Drag them into the cosmic abyss, then impart the truth of the void unto them. Seek to enlighten, not destroy.",
		"They must see what you have seen. They must walk where you have walked. Bring them to the void and show them the truth. The dead cannot know what you know.",
		"Recover what you have lost. Bring your children into the inky black and return them to your flock.",
	)
	explanation_text = pick(explanation_texts)

	if(prob(5))
		explanation_text = "Man I fucking love glass."
	..()

/datum/objective/voidwalker_objective/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/void_blessed
	name = "\improper Void Blessed"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_in_antagpanel = TRUE
	antagpanel_category = "Voidwalker"
	roundend_category = "Voidwalkers"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE VOID!!"
	var/static/list/traits_to_add = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_FREE_HYPERSPACE_MOVEMENT,
	)
	/// Weak version of void eater.
	var/obj/item/void_eater/glass_breaker_for_blessed
	/// Voidwalker who made us his friend.
	var/mob/our_friend

/datum/antagonist/void_blessed/on_gain()
	if(!ishuman(owner.current))
		return ..()
	var/mob/living/carbon/human/my_blessed_friend = owner.current
	my_blessed_friend.faction |= FACTION_VOIDWALKER

	var/datum/brain_trauma/voided/void_brain = locate() in my_blessed_friend.get_traumas()
	if(void_brain)
		REMOVE_TRAIT(my_blessed_friend, TRAIT_PACIFISM, REF(void_brain))
		qdel(my_blessed_friend.GetComponent(/datum/component/banned_from_space))
	my_blessed_friend.AddComponent(/datum/component/space_kidnap/junior)
	my_blessed_friend.add_traits(traits_to_add, REF(src))
	my_blessed_friend.AddElement(/datum/element/no_crit_hitting)
	RegisterSignal(my_blessed_friend, COMSIG_VOIDWALKER_SUCCESFUL_KIDNAP, PROC_REF(successful_kidnap))
	var/datum/antagonist/voidwalker/voidwalker_datum = locate() in our_friend.mind.antag_datums
	if(voidwalker_datum)
		if(voidwalker_datum.unsettle_to_blessed)
			var/datum/action/cooldown/spell/pointed/unsettle/unsettle_spell = new /datum/action/cooldown/spell/pointed/unsettle (my_blessed_friend)
			unsettle_spell.Grant(my_blessed_friend)
	glass_breaker_for_blessed = new/obj/item/void_eater
	my_blessed_friend.put_in_hands(glass_breaker_for_blessed)

	forge_objectives()

	return ..()

/datum/antagonist/void_blessed/on_removal()
	if(!ishuman(owner.current))
		return ..()
	var/mob/living/carbon/human/my_blessed_friend = owner.current
	var/datum/brain_trauma/voided/void_brain = locate() in my_blessed_friend.get_traumas()
	if(void_brain)
		ADD_TRAIT(my_blessed_friend, TRAIT_PACIFISM, REF(void_brain))
		my_blessed_friend.AddComponent(/datum/component/banned_from_space)
	qdel(my_blessed_friend.GetComponent(/datum/component/space_kidnap/junior))
	my_blessed_friend.remove_traits(traits_to_add, REF(src))
	my_blessed_friend.RemoveElement(/datum/element/no_crit_hitting)
	UnregisterSignal(my_blessed_friend, COMSIG_VOIDWALKER_SUCCESFUL_KIDNAP)
	var/datum/action/cooldown/spell/pointed/unsettle/unsettle_spell = locate() in my_blessed_friend.actions
	if(!isnull(unsettle_spell))
		unsettle_spell.Remove(my_blessed_friend)
	my_blessed_friend.faction &= ~FACTION_VOIDWALKER
	QDEL_NULL(glass_breaker_for_blessed)
	return ..()

/datum/antagonist/void_blessed/forge_objectives()
	var/datum/objective/void_blessed_serve_objective/objective = new
	objective.owner = owner
	objective.our_friend = our_friend
	objective.explanation_text = "Serve your master [our_friend.name] and don't let him die."
	objectives += objective

/datum/antagonist/void_blessed/proc/successful_kidnap()
	var/datum/antagonist/voidwalker/voidwalker_datum = locate() in our_friend.mind.antag_datums
	if(isnull(voidwalker_datum))
		return
	var/point_to_gain = voidwalker_datum.points_recieved_from_void_blessed
	voidwalker_datum.points += point_to_gain
	voidwalker_datum.total_points++
	our_friend.balloon_alert(our_friend, "recived [point_to_gain] point[point_to_gain > 1 ? "s" : ""] from void blessed!")
	to_chat(our_friend, span_purple("Void blessed followers kidnapped the target. You recived [point_to_gain] point[point_to_gain > 1 ? "s" : ""]."))

/datum/objective/void_blessed_serve_objective
 	/// Voidwalker who made us his friend.
	var/mob/our_friend

/datum/objective/void_blessed_serve_objective/check_completion()
	return our_friend.stat != DEAD

/datum/objective/void_blessed_kidnap_objective
	/// Target that we need to kill.
	var/mob/my_target
	/// Is target kidanpped?
	var/kidnapped = FALSE

/datum/objective/void_blessed_kidnap_objective/check_completion()
	return kidnapped
