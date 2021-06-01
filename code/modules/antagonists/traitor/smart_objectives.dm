

/**
 * ## smart objectives
 *
 * Smart objectives are objectives for traitors that signal into their targets to confirm when the target dies
 * This means they know when they are complete before roundend, and let an attached antag datum know
 * (antag datums that care for smart objectives need to listen into them!)
 */
/datum/objective/smart
	///the payout for completing this objective
	var/black_telecrystal_reward = 0

/datum/objective/smart/proc/complete_objective()
	if(completed)
		return
	completed = TRUE
	SEND_SIGNAL(src, COMSIG_SMART_OBJECTIVE_ACHIEVED)

/datum/objective/smart/proc/uncomplete_objective()
	if(!completed)
		return
	completed = TRUE
	SEND_SIGNAL(src, COMSIG_SMART_OBJECTIVE_UNACHIEVED)

/**
 * ## Smart destroy AI
 *
 * It achieves when the AI is sent into deep space, or killed.
 * It unachieved when the AI is back into local space, or revived.
 */
/datum/objective/smart/destroy_ai
	name = "destroy AI"
	martyr_compatible = TRUE
	black_telecrystal_reward = 8

/datum/objective/destroy/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free Objective"

/datum/objective/smart/destroy_ai/find_target(dupe_search_range)
	var/list/possible_targets = active_ais(check_mind = TRUE)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/smart/destroy_ai/post_find_target()
	if(!target || !target.current)
		return
	RegisterSignal(target.current, COMSIG_LIVING_DEATH, .proc/on_death)
	RegisterSignal(target.current, COMSIG_LIVING_REVIVE, .proc/on_revive)
	RegisterSignal(target.current, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_level_changed)

/datum/objective/smart/destroy_ai/Destroy(force)
	. = ..()
	UnregisterSignal(target.current, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_MOVABLE_Z_CHANGED))

/datum/objective/smart/destroy_ai/proc/on_revive(datum/target, full_heal)
	SIGNAL_HANDLER

	uncomplete_objective()

/datum/objective/smart/destroy_ai/proc/on_death(datum/target, gibbed)
	SIGNAL_HANDLER

	complete_objective()

/datum/objective/smart/destroy_ai/proc/on_z_level_changed(datum/target, old_z, new_z)
	SIGNAL_HANDLER

	if(new_z > 6)
		complete_objective()
	else
		uncomplete_objective()

/datum/objective/smart/maroon
	name = "maroon"
	var/target_role_type=FALSE
	martyr_compatible = TRUE
	black_telecrystal_reward = 5

/datum/objective/smart/maroon/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/smart/maroon/check_completion()
	return !target || !considered_alive(target) || (!target.current.onCentCom() && !target.current.onSyndieBase())

/datum/objective/smart/maroon/update_explanation_text()
	if(target?.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive.<br>\
		for the purposes of getting rewarded, at least make sure they are dead or off the local station area, as to give the best chance of not escaping."
	else
		explanation_text = "Free Objective"

/datum/objective/smart/maroon/post_find_target()
	if(!target || !target.current)
		return
	RegisterSignal(target.current, COMSIG_LIVING_DEATH, .proc/on_death)
	RegisterSignal(target.current, COMSIG_LIVING_REVIVE, .proc/on_revive)
	RegisterSignal(target.current, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_level_changed)

/datum/objective/smart/maroon/Destroy(force)
	. = ..()
	UnregisterSignal(target.current, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_MOVABLE_Z_CHANGED))

/datum/objective/smart/maroon/proc/on_revive(datum/target, full_heal)
	SIGNAL_HANDLER

	uncomplete_objective()

/datum/objective/smart/maroon/proc/on_death(datum/target, gibbed)
	SIGNAL_HANDLER

	complete_objective()

/datum/objective/smart/maroon/proc/on_z_level_changed(datum/target, old_z, new_z)
	SIGNAL_HANDLER

	if(!is_station_level(new_z) && !is_centcom_level(new_z))
		complete_objective()
	else
		uncomplete_objective()

/datum/objective/smart/assassinate
	name = "assasinate"
	var/target_role_type=FALSE
	martyr_compatible = TRUE
	black_telecrystal_reward = 6

/datum/objective/smart/assassinate/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/smart/assassinate/check_completion()
	return completed || (!considered_alive(target) || considered_afk(target) || considered_exiled(target))

/datum/objective/smart/assassinate/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/smart/assassinate/post_find_target()
	if(!target || !target.current)
		return
	RegisterSignal(target.current, COMSIG_LIVING_DEATH, .proc/on_death)
	RegisterSignal(target.current, COMSIG_LIVING_REVIVE, .proc/on_revive)

/datum/objective/smart/assassinate/Destroy(force)
	. = ..()
	UnregisterSignal(target.current, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))

/datum/objective/smart/assassinate/proc/on_revive(datum/target, full_heal)
	SIGNAL_HANDLER

	uncomplete_objective()

/datum/objective/smart/assassinate/proc/on_death(datum/target, gibbed)
	SIGNAL_HANDLER

	complete_objective()

/datum/objective/smart/download
	name = "download"
	black_telecrystal_reward = 4

/datum/objective/steal/special/find_target()
	target_amount = rand(20,40)
	update_explanation_text()
	return target_amount

/datum/objective/smart/download/update_explanation_text()
	..()
	explanation_text = "Download [target_amount] research node\s."

/datum/objective/smart/download/check_completion()
	var/datum/techweb/checking = new
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/owner in owners)
		if(ismob(owner.current))
			var/mob/M = owner.current //Yeah if you get morphed and you eat a quantum tech disk with the RD's latest backup good on you soldier.
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H && (H.stat != DEAD) && istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
					var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
					S.stored_research.copy_research_to(checking)
			var/list/otherwise = M.GetAllContents()
			for(var/obj/item/disk/tech_disk/TD in otherwise)
				TD.stored_research.copy_research_to(checking)
	return checking.researched_nodes.len >= target_amount

/datum/objective/smart/download/post_find_target()
	if(!target || !target.current)
		return
	RegisterSignal(SSdcs, COMSIG_GLOB_TECHDISK_EJECTED, .proc/on_techdisk_ejected)

/datum/objective/smart/download/Destroy(force)
	. = ..()
	UnregisterSignal(target.current, list(COMSIG_GLOB_TECHDISK_EJECTED))

/datum/objective/smart/download/proc/on_techdisk_ejected(datum/target, obj/item/disk/tech_disk/tech_disk)
	SIGNAL_HANDLER

	///hey this would complete our objective if we held it
	if(tech_disk.stored_research.researched_nodes.len >= target_amount)
		RegisterSignal(tech_disk, COMSIG_ITEM_PICKUP, .proc/on_objective_techdisk_pickup)
	else
		UnregisterSignal(tech_disk, COMSIG_ITEM_PICKUP)

/datum/objective/smart/download/proc/on_objective_techdisk_pickup(datum/tech_disk, mob/taker)
	SIGNAL_HANDLER

	if(taker == owner.current)
		complete_objective()
		UnregisterSignal(tech_disk, COMSIG_ITEM_PICKUP)
		RegisterSignal(tech_disk, COMSIG_ITEM_DROPPED, .proc/on_objective_techdisk_dropped)
	else
		uncomplete_objective()

/datum/objective/smart/download/proc/on_objective_techdisk_dropped(obj/item/disk/tech_disk/tech_disk, mob/dropper)
	SIGNAL_HANDLER

	uncomplete_objective()
	UnregisterSignal(tech_disk, COMSIG_ITEM_DROPPED)
	if(tech_disk.stored_research.researched_nodes.len >= target_amount)
		RegisterSignal(tech_disk, COMSIG_ITEM_PICKUP, .proc/on_objective_techdisk_pickup)

/datum/objective/smart/steal
	name = "steal"
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).
	martyr_compatible = FALSE
	black_telecrystal_reward = 4

/datum/objective/smart/steal/get_target()
	return steal_target

/datum/objective/smart/steal/New()
	..()
	if(!GLOB.possible_items.len)//Only need to fill the list when it's needed.
		for(var/type in subtypesof(/datum/objective_item/steal))
			new type

/datum/objective/smart/steal/find_target(dupe_search_range)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	check_items:
		for(var/datum/objective_item/possible_item in GLOB.possible_items)
			if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
				continue
			for(var/datum/mind/M in owners)
				if(M.current.mind.assigned_role in possible_item.excludefromjob)
					continue check_items
			approved_targets += possible_item
	if (length(approved_targets))
		return set_target(pick(approved_targets))
	return set_target(null)

/datum/objective/smart/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item
		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]"
		give_special_equipment(targetinfo.special_equipment)
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/smart/steal/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!steal_target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents() //this should get things in cheesewheels, books, etc.

		for(var/obj/I in all_items) //Check for items
			if(istype(I, steal_target))
				if(!targetinfo) //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
					return TRUE
				else if(targetinfo.check_special_completion(I))//Returns 1 by default. Items with special checks will return 1 if the conditions are fulfilled.
					return TRUE

			if(targetinfo && (I.type in targetinfo.altitems)) //Ok, so you don't have the item. Do you have an alternative, at least?
				if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
					return TRUE
	return FALSE

/datum/objective/smart/steal/post_find_target()
	if(!steal_target)
		return
	RegisterSignal(steal_target, COMSIG_ITEM_PICKUP, .proc/on_pickup)
	RegisterSignal(steal_target, COMSIG_ITEM_DROPPED, .proc/on_dropped)

/datum/objective/smart/steal/Destroy(force)
	. = ..()
	UnregisterSignal(steal_target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, ))

/datum/objective/smart/steal/proc/on_pickup(datum/tech_disk, mob/taker)
	SIGNAL_HANDLER

	complete_objective()

/datum/objective/smart/steal/proc/on_dropped(obj/item/disk/tech_disk/tech_disk, mob/dropper)
	SIGNAL_HANDLER

	uncomplete_objective()
