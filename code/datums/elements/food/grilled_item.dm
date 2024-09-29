/// Items grilled through the grill.
/datum/element/grilled_item

/datum/element/grilled_item/Attach(datum/target, grill_time)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/this_food = target

	switch(grill_time) //no 0-20 to prevent spam
		if(20 SECONDS to 30 SECONDS)
			this_food.name = "lightly-grilled [this_food.name]"
			this_food.desc += " It's been lightly grilled."

		if(30 SECONDS to 80 SECONDS)
			this_food.name = "grilled [this_food.name]"
			this_food.desc += " It's been grilled."

		if(80 SECONDS to 100 SECONDS)
			this_food.name = "heavily grilled [this_food.name]"
			this_food.desc += " It's been heavily grilled."

		if(100 SECONDS to INFINITY) //grill marks reach max alpha
			this_food.name = "Powerfully Grilled [this_food.name]"
			this_food.desc = "A [this_food.name]. Reminds you of your wife, wait, no, it's prettier!"

	if(grill_time > 30 SECONDS && isnull(this_food.GetComponent(/datum/component/edible)))
		this_food.AddComponent(/datum/component/edible, foodtypes = FRIED)

	SEND_SIGNAL(this_food, COMSIG_ITEM_BARBEQUE_GRILLED, grill_time)
	ADD_TRAIT(this_food, TRAIT_FOOD_BBQ_GRILLED, ELEMENT_TRAIT(type))

/datum/element/grilled_item/Detach(atom/source, ...)
	source.name = initial(source.name)
	source.desc = initial(source.desc)
	qdel(source.GetComponent(/datum/component/edible)) // Don't care if it was initially edible
	REMOVE_TRAIT(src, TRAIT_FOOD_BBQ_GRILLED, ELEMENT_TRAIT(type))
	return ..()
