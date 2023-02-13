
/*
 * Recipe datum
 */
/datum/stack_recipe
	/// The title of the recipe
	var/title = "ERROR"
	/// What atom the recipe makes, typepath
	var/atom/result_type
	/// Amount of stack required to make
	var/req_amount = 1
	/// Amount of resulting atoms made
	var/res_amount = 1
	/// Max amount of resulting atoms made
	var/max_res_amount = 1
	/// How long it takes to make
	var/time = 0
	/// If only one of the resulting atom is allowed per turf
	var/one_per_turf = FALSE
	/// If the atom requires a floor below
	var/on_solid_ground = FALSE
	/// If the atom requires a tram floor below
	var/on_tram = FALSE
	/// Bitflag of additional placement checks required to place. (STACK_CHECK_CARDINALS|STACK_CHECK_ADJACENT)
	var/placement_checks = NONE
	/// If TRUE, the created atom will gain custom mat datums
	var/applies_mats = FALSE
	/// What trait, if any, boosts the construction speed of this item
	var/trait_booster
	/// How much the trait above, if supplied, boosts the construct speed of this item
	var/trait_modifier = 1
	/// Category for general crafting menu
	var/category

/datum/stack_recipe/New(
	title,
	result_type,
	req_amount = 1,
	res_amount = 1,
	max_res_amount = 1,
	time = 0,
	one_per_turf = FALSE,
	on_solid_ground = FALSE,
	on_tram = FALSE,
	window_checks = FALSE,
	placement_checks = NONE,
	applies_mats = FALSE,
	trait_booster,
	trait_modifier = 1,
	category,
)

	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_solid_ground = on_solid_ground
	src.on_tram = on_tram
	src.placement_checks = placement_checks
	src.applies_mats = applies_mats
	src.trait_booster = trait_booster
	src.trait_modifier = trait_modifier
	src.category = src.category || category || CAT_MISC

/datum/stack_recipe/radial
	/// Optional info to be shown on the radial option for this item
	var/desc

/datum/stack_recipe/radial/New(
	title,
	result_type,
	req_amount = 1,
	res_amount = 1,
	max_res_amount = 1,
	time = 0,
	one_per_turf = FALSE,
	on_solid_ground = FALSE,
	on_tram = FALSE,
	window_checks = FALSE,
	placement_checks = NONE,
	applies_mats = FALSE,
	trait_booster,
	trait_modifier = 1,
	desc,
	required_noun,
	category,
)
	if(category)
		src.category = category
	if(desc)
		src.desc = desc
	if(required_noun)
		src.desc += span_boldnotice("[desc ? " - ":""]Requires: [req_amount] [required_noun]\s.")

	return ..()


/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes
