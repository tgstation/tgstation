/// Contains recipe data for constructing a specific type of wall on a girder.
/// Only the [/datum/element/uses_girder_wall_recipes] should be using these.
/datum/girder_wall_recipe
	/// The wall type this recipe is for. Can be a turf or an object.
	var/wall_type
	/// The type of stack required for this recipe.
	var/stack_type
	/// The amount of stack items required for this recipe.
	var/stack_amount
	/// The [/obj/structure] type required for this recipe.
	var/girder_type
	/// The [/obj/structure/girder/var/state] required for this recipe.
	/// Ignored if [var/girder] is not of type [/obj/structure/girder].
	var/girder_state
	/// The amount of time it takes to make this recipe in deciseconds.
	var/make_delay
	/// The starting balloon alert text for this recipe.
	var/start_alert

/datum/girder_wall_recipe/New(wall_type, stack_type, stack_amount, girder_type, girder_state, make_delay, start_alert)
	src.wall_type = wall_type
	src.stack_type = stack_type
	src.stack_amount = stack_amount
	src.girder_type = girder_type
	src.girder_state = girder_state
	src.make_delay = make_delay
	src.start_alert = start_alert
