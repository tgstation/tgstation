
GLOBAL_LIST_INIT(hoarder_targets, list(
	/obj/item/clothing/gloves/color/yellow,
	/obj/item/mod/control,
	/obj/item/melee/baton/security,
))

/datum/objective/hoarder
	name = "hoarding"
	explanation_text = "Hoard as many items as you can in one area!"
	///what item we want to get many of
	var/atom/movable/target_type
	///how many we want for greentext
	var/amount = 7
	///and where do we want it roundend (this is a type, not a ref)
	var/turf/hoarder_turf

/datum/objective/hoarder/find_target(dupe_search_range, blacklist)
	amount = rand(amount - 2, amount + 2)
	target_type = pick(GLOB.hoarder_targets)
	add_action()

/datum/objective/hoarder/proc/add_action()
	var/list/owners = get_owners()
	var/datum/mind/hoardpicker = owners[1]
	var/datum/action/declare_hoard/declare = new /datum/action/declare_hoard(hoardpicker.current)
	declare.weak_objective = WEAKREF(src)
	declare.Grant(hoardpicker.current)

/datum/objective/hoarder/update_explanation_text()
	var/obj/item/target_item = target_type
	explanation_text = "Hoard as many [initial(target_item.name)]\s as you can in maintenance (after declaring a spot)! At least [amount] will do."

/datum/objective/hoarder/check_completion()
	. = ..()
	if(.)
		return TRUE
	var/stolen_amount = 0
	if(!hoarder_turf)
		return FALSE //they never set up their hoard spot, so they couldn't have done their objective
	for(var/atom/movable/in_target_turf in hoarder_turf.get_all_contents())
		if(istype(in_target_turf, target_type))
			if(!valid_target(in_target_turf))
				continue
			stolen_amount++
	return stolen_amount >= amount

/datum/objective/hoarder/proc/valid_target(atom/movable/target)
	return TRUE

///for the deranged flavor
/datum/objective/hoarder/bodies
	name = "corpse hoarding"
	explanation_text = "Hoard as many dead bodies as you can in one area!"
	amount = 5 //little less, bodies are hard when you can't kill like antags

/datum/objective/hoarder/bodies/find_target(dupe_search_range, blacklist)
	amount = rand(amount - 2, amount + 2)
	target_type = /mob/living/carbon/human
	add_action()

/datum/objective/hoarder/bodies/valid_target(mob/living/carbon/human/target)
	if(target.stat != DEAD)
		return FALSE
	return TRUE

/datum/objective/hoarder/bodies/update_explanation_text()
	explanation_text = "Hoard as many dead bodies as you can in maintenance (after declaring a spot)! At least [amount] will do."

/datum/action/declare_hoard
	name = "Declare Hoard"
	desc = "Declare a new hoarding spot on the ground you're standing on. Items on this floor will count for your objective."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "hoard"
	///weak reference to the objective this action targets, set by hoarder objective
	var/datum/weakref/weak_objective

/datum/action/declare_hoard/Trigger(trigger_flags)
	if(owner.incapacitated())
		owner.balloon_alert(owner, "not while incapacitated!")
		return
	var/area/owner_area = get_area(owner)
	if(!istype(owner_area, /area/maintenance))
		owner.balloon_alert(owner, "hoard must be in maintenance!")
		return
	var/datum/objective/hoarder/objective = weak_objective.resolve()
	if(objective)
		owner.balloon_alert(owner, "hoard position set")
		objective.hoarder_turf = get_turf(owner)
		var/image/hoarder_marker = image('icons/mob/telegraphing/telegraph.dmi', objective.hoarder_turf, "hoarder_circle", layer = ABOVE_OPEN_TURF_LAYER)
		owner.client.images |= hoarder_marker
	qdel(src)

/datum/objective/chronicle //exactly what it sounds like, steal someone's heirloom.
	name = "chronicle"
	explanation_text = "Steal any family heirloom, for chronicling of course."

/datum/objective/chronicle/check_completion()
	. = ..()
	if(.)
		return TRUE
	var/list/owners = get_owners()
	for(var/datum/mind/owner in owners)
		if(!isliving(owner.current))
			continue
		var/list/all_items = owner.current.get_all_contents() //this should get things in cheesewheels, books, etc.
		for(var/obj/possible_heirloom in all_items) //Check for wanted items
			var/datum/component/heirloom/found = possible_heirloom.GetComponent(/datum/component/heirloom)
			if(found && !(found.owner in owners)) //it exists, and its not yours.
				return TRUE
	return FALSE
