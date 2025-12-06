/// Contains recipe data for constructing a specific type of wall on a girder.
/// The required stack type and girder state are in [GLOB.girder_wall_recipes].
/// Only the [/obj/structure/girder] type should directly interface with this.
/datum/girder_wall_recipe
	/// The amount of items in the stack required for this recipe.
	var/amount
	/// The amount of time it takes to make this recipe in deciseconds.
	var/delay
	/// The wall type this recipe is for. Can be a turf or an object.
	var/wall
	/// The starting balloon alert text for this recipe.
	var/alert

/datum/girder_wall_recipe/New(amount, delay, wall, alert)
	src.amount = amount
	src.delay = delay
	src.wall = wall
	src.alert = alert
