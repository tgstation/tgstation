/obj/machinery/power/manufacturing/crafter
	name = "manufacturing assembling machine"
	desc = "Assembles (crafts) the set recipe until it runs out of resources. Inputs irrelevant to the recipe are ignored."
	icon_state = "crafter"
	circuit = /obj/item/circuitboard/machine/manucrafter
	/// power used per process() spent crafting
	var/power_cost = 5 KILO WATTS
	/// our output, if the way out was blocked is held here
	var/atom/movable/withheld
	/// current recipe
	var/datum/crafting_recipe/recipe
	/// crafting component
	var/datum/component/personal_crafting/machine/craftsman
	/// current timer for our crafting
	var/craft_timer
	/// do we use cooking recipes instead
	var/cooking = FALSE

/obj/machinery/power/manufacturing/crafter/Initialize(mapload)
	. = ..()
	craftsman = AddComponent(/datum/component/personal_crafting/machine)

/obj/machinery/power/manufacturing/crafter/examine(mob/user)
	. = ..()
	. += span_notice("It is currently manufacturing <b>[isnull(recipe) ? "nothing. Use a multitool to set it" : recipe.name]</b>.")
	if(isnull(recipe))
		return
	. += span_notice("It needs:")
	for(var/valid_type in recipe.reqs)
		// Check if they're datums, specifically reagents.
		var/datum/reagent/reagent_ingredient = valid_type
		if(istype(reagent_ingredient))
			var/amount = recipe.reqs[reagent_ingredient]
			. += "[amount] unit[amount > 1 ? "s" : ""] of [initial(reagent_ingredient.name)]"

		var/atom/ingredient = valid_type
		var/amount = recipe.reqs[ingredient]

		. += "[amount > 1 ? ("[amount]" + " of") : "a"] [initial(ingredient.name)]"

/obj/machinery/power/manufacturing/crafter/update_overlays()
	. = ..()
	. += generate_io_overlays(dir, COLOR_ORANGE)
	for(var/target_dir in GLOB.cardinals - dir)
		. += generate_io_overlays(target_dir, COLOR_MODERATE_BLUE)

/obj/machinery/power/manufacturing/crafter/proc/valid_for_recipe(obj/item/checking)
	. = FALSE
	for(var/requirement_path in recipe.reqs)
		if(!ispath(checking.type, requirement_path) || recipe.blacklist.Find(checking.type))
			continue
		return TRUE

/obj/machinery/power/manufacturing/crafter/proc/contains_type(path)
	. = FALSE
	for(var/content in contents - circuit)
		if(!istype(content, path))
			continue
		return TRUE

/obj/machinery/power/manufacturing/crafter/receive_resource(obj/receiving, atom/from, receive_dir)
	if(isnull(recipe) || !isitem(receiving) || surplus() < power_cost)
		return MANUFACTURING_FAIL
	if(receive_dir == dir || !valid_for_recipe(receiving))
		return MANUFACTURING_FAIL
	if(!may_merge_in_contents(receiving) && contains_type(receiving.type))
		return MANUFACTURING_FAIL_FULL
	receiving.Move(src, get_dir(receiving, src))
	START_PROCESSING(SSmanufacturing, src)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/crafter/multitool_act(mob/living/user, obj/item/tool)
	. = NONE
	var/list/unavailable = list()
	for(var/datum/crafting_recipe/potential_recipe as anything in cooking ? GLOB.cooking_recipes : GLOB.crafting_recipes)
		if(craftsman.is_recipe_available(potential_recipe, user))
			continue
		var/obj/result = initial(potential_recipe.result)
		if(istype(result) && initial(result.anchored))
			continue
		unavailable += potential_recipe
	var/result = tgui_input_list(usr, "Recipe", "Select Recipe", (cooking ? GLOB.cooking_recipes : GLOB.crafting_recipes) - unavailable)
	if(isnull(result) || result == recipe || !user.can_perform_action(src))
		return ITEM_INTERACT_FAILURE
	var/dump_target = get_step(src, get_dir(src, user))
	for(var/atom/movable/thing as anything in contents - circuit)
		thing.Move(dump_target)
	recipe = result
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/crafter/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == withheld)
		withheld = null

/obj/machinery/power/manufacturing/crafter/atom_destruction(damage_flag)
	. = ..()
	withheld?.Move(drop_location(src))

/obj/machinery/power/manufacturing/crafter/Destroy()
	. = ..()
	recipe = null
	craftsman = null
	QDEL_NULL(withheld)

/obj/machinery/power/manufacturing/crafter/process(seconds_per_tick)
	if(!isnull(withheld) && !send_resource(withheld, dir))
		return
	if(!isnull(craft_timer))
		if(surplus() >= power_cost)
			add_load()
		else
			deltimer(craft_timer)
			craft_timer = null
			say("Power failure!")
		return
	if(isnull(recipe) || !craftsman.check_contents(src, recipe, craftsman.get_surroundings(src)))
		return
	flick_overlay_view(mutable_appearance(icon, "crafter_printing"), recipe.time)
	craft_timer = addtimer(CALLBACK(src, PROC_REF(craft), recipe), recipe.time, TIMER_STOPPABLE)

/obj/machinery/power/manufacturing/crafter/proc/craft(datum/crafting_recipe/recipe)
	if(QDELETED(src))
		return
	craft_timer = null
	var/atom/movable/result = craftsman.construct_item(src, recipe)
	if(istype(result))
		if(isitem(result))
			result.pixel_x += rand(-4, 4)
			result.pixel_y += rand(-4, 4)
		result.Move(src)
		send_resource(result, dir)
	else
		say(result)

/obj/machinery/power/manufacturing/crafter/cooker
	name = "manufacturing cooking machine" // maybe this shouldnt be available dont wanna make chef useless, though otherwise it would need a sprite
	desc = "Cooks the set recipe until it runs out of resources. Inputs irrelevant to the recipe are ignored."
	cooking = TRUE
