
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
	///and in where do we want it roundend (this is a type, not a ref)
	var/area/target_area

/datum/objective/hoarder/find_target(dupe_search_range, blacklist)
	amount = rand(amount - 2, amount + 2)
	target_type = pick(GLOB.hoarder_targets)
	target_area = pick(get_areas(/area/maintenance, TRUE))
	target_area = target_area.type //we don't want a ref anyways

/datum/objective/hoarder/update_explanation_text()
	var/obj/item/target_item = target_type
	var/explanation_name = initial(target_item.name)
	if(copytext(explanation_name, ))
	explanation_text = "Hoard as many [explanation_name]\s as you can in [initial(target_area.name)]! At least [amount] will do."

/datum/objective/hoarder/check_completion()
	. = ..()
	var/stolen_amount = 0
	var/area/area_instance = GLOB.areas_by_type[target_area]
	var/list/contents = area_instance.get_all_contents()
	for(var/atom/movable/in_target_area in contents)
		if(istype(in_target_area, target_type))
			if(!valid_target(in_target_area))
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
	target_area = pick(subtypesof(/area/maintenance))

/datum/objective/hoarder/bodies/valid_target(mob/living/carbon/human/target)
	if(target.stat != DEAD)
		return FALSE
	return TRUE

/datum/objective/hoarder/bodies/update_explanation_text()
	explanation_text = "Hoard as many dead bodies as you can in [initial(target_area.name)]! At least [amount] will do."

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
