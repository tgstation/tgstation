/// A list of all girder wall recipes in the format: list(stack_type = list(girder_state = recipe))
GLOBAL_LIST_INIT(girder_wall_recipes, init_girder_wall_recipes())

/proc/init_girder_wall_recipes()
	var/list/recipes = list()

	for (var/turf/closed/wall/wall_type in valid_typesof(/turf/closed/wall))
		if (!wall_type::can_make)
			continue
		add_girder_wall_recipe(
			recipes = recipes,
			wall_type = wall_type,
			stack_type = wall_type::sheet_type,
			stack_amount = wall_type::sheet_amount,
			girder_state = wall_type::girder_state,
			make_delay = wall_type::make_delay,
			alert = "adding plating..."
		)

	return recipes

/proc/add_girder_wall_recipe(list/recipes, wall_type, stack_type, stack_amount, girder_state, make_delay, alert)
	if (!ispath(stack_type, /obj/item/stack))
		CRASH("Attempted to create a girder wall recipe for a wall type with an invalid stack type: [wall_type]")

	if (!recipes[stack_type])
		recipes[stack_type] = list()
	else if (recipes[stack_type][girder_state])
		CRASH("Attempted to create a girder wall recipe that has the same stack type and girder state as another: [wall_type]")

	recipes[stack_type][girder_state] = new /datum/girder_wall_recipe(stack_amount, make_delay, wall_type, alert)
