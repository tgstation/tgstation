
GLOBAL_LIST_INIT(hoarder_targets, list(
	/obj/item/clothing/gloves/color/yellow,
	/obj/item/mod/core
))

/datum/objective/hoarder
	name = "hoarding"
	explanation_text = "Hoard as many items as you can in one area!"
	///what item we want to get many of
	var/target_item_type
	///how many we want for greentext
	var/amount = 7
	///and in where do we want it roundend (this is a type, not a ref)
	var/area/target_area

/datum/objective/hoarder/find_target(dupe_search_range, blacklist)
	. = ..()
	amount = rand(amount - 2, amount + 2)
	target_item_type = pick(GLOB.hoarder_targets)
	target_area = pick(subtypesof(/area/maintenance))

/datum/objective/hoarder/update_explanation_text()
	. = ..()
	var/obj/item/target_item = target_item_type
	explanation_text = "Hoard as many [initial(target_item.name)]s as you can in [initial(target_area.name)]! At least [amount] will do."

/datum/objective/hoarder/check_completion()
	. = ..()
	var/stolen_amount = 0
	var/area/area_instance = GLOB.areas_by_type[target_area]
	var/list/contents = area_instance.get_all_contents()
	for(var/obj/item/in_target_area in contents)
		if(istype(in_target_area, target_item_type))
			stolen_amount++
	return stolen_amount >= amount
