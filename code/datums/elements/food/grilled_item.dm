/// Items grilled through the grill.
/datum/element/grilled_item

/datum/element/grilled_item/Attach(datum/target, grill_time)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/this_food = target

	switch(grill_time) //no 0-20 to prevent spam
		if(20 to 30)
			this_food.name = "lightly-grilled [this_food.name]"
			this_food.desc += " It's been lightly grilled."

		if(30 to 80)
			this_food.name = "grilled [this_food.name]"
			this_food.desc += " It's been grilled."

		if(80 to 100)
			this_food.name = "heavily grilled [this_food.name]"
			this_food.desc += " It's been heavily grilled."

		if(100 to INFINITY) //grill marks reach max alpha
			this_food.name = "Powerfully Grilled [this_food.name]"
			this_food.desc = "A [this_food.name]. Reminds you of your wife, wait, no, it's prettier!"

	if(grill_time > 20)
		ADD_TRAIT(this_food, TRAIT_FOOD_GRILLED, ELEMENT_TRAIT(type))
	if(grill_time > 30)
		this_food.AddComponent(/datum/component/edible, foodtypes = FRIED)

/datum/element/grilled_item/Detach(atom/source, ...)
	source.name = initial(source.name)
	source.desc = initial(source.desc)
	REMOVE_TRAIT(source, TRAIT_FOOD_GRILLED, ELEMENT_TRAIT(type))
	qdel(source.GetComponent(/datum/component/edible)) // Don't care if it was initially edible
	return ..()
