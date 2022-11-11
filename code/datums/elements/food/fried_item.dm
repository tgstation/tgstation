/// Items fried through the deep fryer.
/datum/element/fried_item

/datum/element/fried_item/Attach(datum/target, fry_time)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/this_food = target

	switch(fry_time)
		if(0 to 15)
			this_food.add_atom_colour(rgb(166, 103, 54), FIXED_COLOUR_PRIORITY)
			this_food.name = "lightly-fried [this_food.name]"
			this_food.desc += " It's been lightly fried in a deep fryer."

		if(16 to 49)
			this_food.add_atom_colour(rgb(103, 63, 24), FIXED_COLOUR_PRIORITY)
			this_food.name = "fried [this_food.name]"
			this_food.desc += " It's been fried, increasing its tastiness value by [rand(1, 75)]%."

		if(50 to 59)
			this_food.add_atom_colour(rgb(63, 23, 4), FIXED_COLOUR_PRIORITY)
			this_food.name = "deep-fried [this_food.name]"
			this_food.desc += " Deep-fried to perfection."

		if(60 to INFINITY)
			this_food.add_atom_colour(rgb(33, 19, 9), FIXED_COLOUR_PRIORITY)
			this_food.name = "\proper the physical manifestation of the very concept of fried foods"
			this_food.desc = "A heavily-fried... something. Who can tell anymore?"

	ADD_TRAIT(this_food, TRAIT_FOOD_FRIED, "kfc")
	// Already edible items will inherent these parameters
	// Otherwise, we will become edible.
	this_food.AddComponent(/datum/component/edible, \
		bite_consumption = 2, \
		food_flags = FOOD_FINGER_FOOD, \
		junkiness = 10, \
		foodtypes = FRIED)
