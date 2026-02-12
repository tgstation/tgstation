GLOBAL_LIST_INIT(main_girder_wall_recipes, init_main_girder_wall_recipes())
GLOBAL_LIST_INIT(material_girder_wall_recipes, init_material_girder_wall_recipes())

/// Initializes the main, false and tram wall types using three lists of wall types.
/proc/init_main_girder_wall_recipes()
	return create_girder_wall_recipes(
		wall_types = list(
			/turf/closed/wall,
			/turf/closed/wall/metal_foam_base,
			/turf/closed/wall/r_wall,
			/turf/closed/wall/r_wall/plastitanium,
			/turf/closed/wall/mineral/gold,
			/turf/closed/wall/mineral/silver,
			/turf/closed/wall/mineral/diamond,
			/turf/closed/wall/mineral/bananium,
			/turf/closed/wall/mineral/sandstone,
			/turf/closed/wall/mineral/uranium,
			/turf/closed/wall/mineral/plasma,
			/turf/closed/wall/mineral/wood,
			/turf/closed/wall/mineral/wood/nonmetal,
			/turf/closed/wall/mineral/bamboo,
			/turf/closed/wall/mineral/iron,
			/turf/closed/wall/mineral/snow,
			/turf/closed/wall/mineral/abductor,
			/turf/closed/wall/mineral/titanium,
			/turf/closed/wall/mineral/plastitanium,
			/turf/closed/wall/mineral/cult,
			/turf/closed/wall/mineral/bronze,
			/turf/closed/wall/material,
		),
		falsewall_types = list(
			/obj/structure/falsewall,
			/obj/structure/falsewall/reinforced,
			/obj/structure/falsewall/gold,
			/obj/structure/falsewall/silver,
			/obj/structure/falsewall/diamond,
			/obj/structure/falsewall/bananium,
			/obj/structure/falsewall/sandstone,
			/obj/structure/falsewall/uranium,
			/obj/structure/falsewall/plasma,
			/obj/structure/falsewall/wood,
			/obj/structure/falsewall/bamboo,
			/obj/structure/falsewall/iron,
			/obj/structure/falsewall/abductor,
			/obj/structure/falsewall/titanium,
			/obj/structure/falsewall/plastitanium,
			/obj/structure/falsewall/material,
		),
		tram_types = list(
			/obj/structure/tram,
			/obj/structure/tram/alt/gold,
			/obj/structure/tram/alt/silver,
			/obj/structure/tram/alt/diamond,
			/obj/structure/tram/alt/bananium,
			/obj/structure/tram/alt/sandstone,
			/obj/structure/tram/alt/uranium,
			/obj/structure/tram/alt/plasma,
			/obj/structure/tram/alt/wood,
			/obj/structure/tram/alt/bamboo,
			/obj/structure/tram/alt/iron,
			/obj/structure/tram/alt/abductor,
			/obj/structure/tram/alt/titanium,
			/obj/structure/tram/alt/plastitanium,
		)
	)

/// Initializes the normal and false girder material wall recipes using two lists of material wall types.
/proc/init_material_girder_wall_recipes()
	return create_girder_wall_recipes(
		wall_types = list(/turf/closed/wall/material),
		falsewall_types = list(/obj/structure/falsewall/material)
	)

/// Returns a list of newly created [/datum/girder_wall_recipe] instances from the given wall type lists.
/proc/create_girder_wall_recipes(list/wall_types, list/falsewall_types, list/tram_types)
	var/list/recipes = list()

	for (var/turf/closed/wall/wall_type as anything in wall_types)
		add_girder_wall_recipe(
			recipes = recipes,
			wall_type = wall_type,
			stack_type = wall_type::sheet_type,
			stack_amount = wall_type::sheet_amount,
			girder_type = wall_type::girder_type,
			girder_state = wall_type::girder_state,
			make_delay = wall_type::make_delay,
			start_alert = "adding plating..."
		)

	for (var/obj/structure/falsewall/falsewall_type as anything in falsewall_types)
		add_girder_wall_recipe(
			recipes = recipes,
			wall_type = falsewall_type,
			stack_type = falsewall_type::mineral,
			stack_amount = falsewall_type::mineral_amount,
			girder_type = falsewall_type::girder_type,
			girder_state = GIRDER_DISPLACED,
			make_delay = 2 SECONDS,
			start_alert = "concealing entrance..."
		)

	for (var/obj/structure/tram/tram_type as anything in tram_types)
		add_girder_wall_recipe(
			recipes = recipes,
			wall_type = tram_type,
			stack_type = tram_type::mineral,
			stack_amount = tram_type::mineral_amount,
			girder_type = tram_type::girder_type,
			girder_state = GIRDER_TRAM,
			make_delay = 4 SECONDS,
			start_alert = "adding plating..."
		)

	return recipes

/// Adds a new [/datum/girder_wall_recipe] instance to the given recipe list from the given recipe arguments.
/proc/add_girder_wall_recipe(list/recipes, wall_type, stack_type, stack_amount, girder_type, girder_state, make_delay, start_alert)
	if (!ispath(stack_type, /obj/item/stack))
		CRASH("Attempted to create a girder wall recipe for wall type ([wall_type]) with an invalid stack type ([stack_type])")

	recipes += new /datum/girder_wall_recipe(wall_type, stack_type, stack_amount, girder_type, girder_state, make_delay, start_alert)
