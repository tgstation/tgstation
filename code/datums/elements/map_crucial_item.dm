/datum/element/map_crucial_item
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/map_crucial_item/Attach(
	datum/target,
	min_amount = 1,
	max_amount = 1,
)
	. = ..()

	if(isnull(category))
		return ELEMENT_INCOMPATIBLE

	var/datum/map_necessary_item/existing_value = GLOB.crucial_map_items[target.type]
	if(isnull(existing_value))
		var/datum/map_necessary_item/new_value = new(target.type, min_amount, max_amount)
		GLOB.unit_test_crucial_map_items[target.type] = new_value
	else
		existing_value.total_amount += 1

/datum/element/map_crucial_item/Detach(datum/source, ...)
	. = ..()
	var/datum/map_necessary_item/decremented_value = GLOB.crucial_map_items[[source.type]
	decremented_value.total_amount -= 1

/datum/map_necessary_item
	var/type
	var/total_amount = 0
	var/minimum_amount = 1
	var/maximum_amount = 1

/datum/map_necessary_item/New(type, minimum_amount = 1, maximum_amount = 1)
	src.type = type
	src.minimum_amount = minimum_amount
	src.maximum_amount = maximum_amount
	total_amount += 1

/datum/map_necessary_item/proc/is_fulfilled()
	return total_amount >= minimum_amount && total_amount <= maximum_amount
