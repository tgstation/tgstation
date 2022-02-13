///a type that will turn into a fish on spawn.
/obj/item/instafish
	var/behaviour_type = /datum/aquarium_behaviour/fish

/obj/item/instafish/Initialize(mapload)
	. = ..()
	generate_fish(loc, behaviour_type)
	return INITIALIZE_HINT_QDEL

/obj/item/instafish/ratfish
	behaviour_type = /datum/aquarium_behaviour/fish/ratfish
