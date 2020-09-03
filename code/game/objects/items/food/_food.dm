///Abstract class to allow us to easily create all the generic "normal" food without too much copy pasta of adding more components
/obj/item/food
	name = "food"
	desc = "you eat this"
	///List of reagents this food gets on creation
	var/list/food_reagents
	///Extra flags for things such as if the food is in a container or not
	var/food_flags
	///Bitflag of the types of food this food is
	var/foodtypes
	///Amount of volume the food can contain
	var/max_volume
	///How long it will take to eat this food without any other modifiers
	var/eat_time
	///Tastes to describe this food
	var/list/tastes
	///Verbs used when eating this food in the to_chat messages
	var/list/eatverbs
	///How much reagents per bite
	var/bite_consumption


/obj/item/food/Initialize()
	. = ..()
	MakeEdible()

///This proc adds the edible component, overwrite this if you for some reason want to change some specific args like callbacks.
/obj/item/food/proc/MakeEdible()
	AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				eatverbs = eatverbs,\
				bite_consumption = bite_consumption)




