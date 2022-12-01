/// Items fried through the deep fryer.
/datum/element/fried_item
	/// List of colors to apply the element target.
	/// Each index corresponds to a different level.
	var/static/list/fried_colors = list(
		COLOR_LIGHT_BROWN,
		COLOR_BROWNER_BROWN,
		COLOR_DARKER_BROWN,
		COLOR_BLACK,
	)

/datum/element/fried_item/Attach(datum/target, fry_time)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/this_food = target

	switch(fry_time)
		if(0 to 15)
			this_food.add_atom_colour(fried_colors[1], FIXED_COLOUR_PRIORITY)
			this_food.name = "lightly-fried [this_food.name]"
			this_food.desc += " It's been lightly fried in a deep fryer."

		if(15 to 50)
			this_food.add_atom_colour(fried_colors[2], FIXED_COLOUR_PRIORITY)
			this_food.name = "fried [this_food.name]"
			this_food.desc += " It's been fried, increasing its tastiness value by [rand(1, 75)]%."

		if(50 to 85)
			this_food.add_atom_colour(fried_colors[3], FIXED_COLOUR_PRIORITY)
			this_food.name = "deep-fried [this_food.name]"
			this_food.desc += " Deep-fried to perfection."

		if(85 to INFINITY)
			this_food.add_atom_colour(fried_colors[4], FIXED_COLOUR_PRIORITY)
			this_food.name = "\proper the physical manifestation of the very concept of fried foods"
			this_food.desc = "A heavily-fried... something. Who can tell anymore?"

	ADD_TRAIT(this_food, TRAIT_FOOD_FRIED, ELEMENT_TRAIT(type))
	SEND_SIGNAL(this_food, COMSIG_ITEM_FRIED, fry_time)
	// Already edible items will inherent these parameters
	// Otherwise, we will become edible.
	this_food.AddComponent( \
		/datum/component/edible, \
		bite_consumption = 2, \
		food_flags = FOOD_FINGER_FOOD, \
		junkiness = 10, \
		foodtypes = FRIED, \
	)

/datum/element/fried_item/Detach(atom/source, ...)
	for(var/color in fried_colors)
		source.remove_atom_colour(FIXED_COLOUR_PRIORITY, color)
	source.name = initial(source.name)
	source.desc = initial(source.desc)
	REMOVE_TRAIT(source, TRAIT_FOOD_FRIED, ELEMENT_TRAIT(type))
	qdel(source.GetComponent(/datum/component/edible)) // Don't care if it was initially edible
	return ..()
