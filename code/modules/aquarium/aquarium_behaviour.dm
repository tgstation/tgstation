/*
	// Default size of the "greyscale_fish" icon_state
	sprite_height = 3
	sprite_width = 3

/// This path exists mostly for admin abuse.
/datum/aquarium_behaviour/fish/auto
	name = "automatic fish"
	desc = "generates fish appearance automatically from component parent appearance"
	available_in_random_cases = FALSE
	sprite_width = 8
	sprite_height = 8
	show_in_catalog = FALSE

/datum/aquarium_behaviour/fish/auto/apply_appearance(obj/effect/holder)
	holder.appearance = parent.parent
	holder.transform = base_transform()
	holder.dir = WEST
*/
