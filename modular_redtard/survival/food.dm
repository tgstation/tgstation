/// Ratwood food (code/modules/food_and_drinks/food/snacks.dm, modular/Neu_Food) is TG food: the Ratwood root grafts onto
/// /obj/item/food, so eating, bites, tastes, likes and dislikes are TG's edible component, frying on a pan or over a fire is TG
/// grilling (/datum/component/grillable) and the oven is TG baking (/datum/component/bakeable). The Ratwood numbers of each food
/// come from the porter (survival/ported/food.dm): reagents, food types, bites, eat effect, what it cooks, fries, slices or rots
/// into and when.
/obj/item/reagent_containers/food
	parent_type = /obj/item/food
	abstract_type = /obj/item/reagent_containers/food
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	/// Ratwood bitesize: how many bites the food lasts; TG bite_consumption follows from it.
	var/bitesize = 3
	/// What every bite does to the eater (Ratwood eat_effect: raw, burned, rotten food, snack and meal buffs).
	var/datum/status_effect/eat_effect
	/// Reagents the food gains when something cooks into it (Ratwood bonus_reagents, initialize_cooked_food()).
	var/list/bonus_reagents
	/// What an oven bakes it into (Ratwood cooked_type).
	var/cooked_type
	/// What a pan or an open fire fries it into (Ratwood fried_type).
	var/fried_type
	/// Deciseconds of heat until it is done, or burnt when nothing fits the heat (Ratwood cooktime); 0 - it only burns.
	var/cooktime = 0
	/// Deciseconds of heat until food that does not cook burns (Ratwood burntime); 0 - it never burns.
	var/burntime = 5 MINUTES
	/// Shelf life after its warm time, in deciseconds (Ratwood rotprocess); 0 - it does not rot.
	var/rotprocess = 0
	/// Warm time before the shelf life starts (Ratwood warming).
	var/warming = 5 MINUTES
	/// What it turns into when rotten; without one the food itself goes bad (Ratwood become_rot_type).
	var/become_rot_type
	/// Ratwood slicing: what a short blade cuts it into on a table, how many, and the blade class it takes.
	var/slice_path
	var/slices_num = 0
	var/slice_bclass = BCLASS_CUT
	/// All slices at once, or one per cut (Ratwood slice_batch).
	var/slice_batch = TRUE
	/// Slapcraft recipe in progress and its step (Ratwood active_recipe, current_step).
	var/datum/rogue_food_recipe/active_recipe
	var/current_step = 1
	/// Looks of the ingredients added so far (Ratwood do_cooking_step() overlays).
	var/list/recipe_overlays
	/// A recipe made this ready to cook or to deep fry; it takes no other recipe (a roofed pie takes no more filling).
	var/rogue_recipe_done = FALSE
	/// Gone bad in place (Ratwood become_rotten() without a rotten form).
	var/rotten = FALSE
	/// What heat turned this food into, for whoever held it over the fire or in the pan.
	var/datum/weakref/cooked_into

/obj/item/reagent_containers/food/snacks
	abstract_type = /obj/item/reagent_containers/food/snacks

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FOOD_EATEN, PROC_REF(on_bite))
	RegisterSignals(src, list(COMSIG_ITEM_GRILLED_RESULT, COMSIG_ITEM_BAKED_RESULT), PROC_REF(on_cooked_into))

/obj/item/reagent_containers/food/Destroy(force)
	active_recipe = null
	return ..()

/// Ratwood eats a food in bitesize bites, each a share of what is left; TG bites a fixed amount, so the bite is the whole split
/// into bitesize parts.
/obj/item/reagent_containers/food/make_edible()
	var/total = 0
	for(var/reagent in food_reagents)
		total += food_reagents[reagent]
	bite_consumption = max(CEILING(total / max(bitesize, 1), 0.01), 0.01)
	return ..()

/// Ratwood cooking() on a pan or over a fire: food with a cook time turns into its fried form, or into a burnt mess if it has
/// none; food without one burns after its burn time.
/obj/item/reagent_containers/food/make_grillable()
	if(cooktime)
		AddComponent(/datum/component/grillable, fried_type || ROGUE_BURNT_FOOD, cooktime, !!fried_type)
	else if(burntime)
		AddComponent(/datum/component/grillable, ROGUE_BURNT_FOOD, burntime, FALSE)

/// The same in an oven, with the baked form (Ratwood heating_act() of the oven).
/obj/item/reagent_containers/food/make_bakeable()
	if(cooktime)
		AddComponent(/datum/component/bakeable, cooked_type || ROGUE_BURNT_FOOD, cooktime, !!cooked_type)
	else if(burntime)
		AddComponent(/datum/component/bakeable, ROGUE_BURNT_FOOD, burntime, FALSE)

/// Ratwood food does not catch TG germs on the floor and mould; it rots by its own shelf life instead.
/obj/item/reagent_containers/food/make_germ_sensitive(mapload)
	if(rotprocess > 0 && !rotten && CONFIG_GET(flag/rogue_food_rot))
		AddComponent(/datum/component/rogue_rot, rotprocess, warming)

/// Cooking results changed (a recipe made the food ready to cook, or it rotted): the grill and the oven learn it anew.
/obj/item/reagent_containers/food/proc/refresh_cooking()
	qdel(GetComponent(/datum/component/grillable))
	qdel(GetComponent(/datum/component/bakeable))
	make_grillable()
	make_bakeable()

/obj/item/reagent_containers/food/proc/on_bite(datum/source, mob/living/eater, mob/living/feeder, bitecount, bite_size)
	SIGNAL_HANDLER
	if(!isliving(eater))
		return
	// Ratwood On_Consume(): favourites and the noble palate (survival/appetite.dm) may spoil the good effect of the bite.
	if(rogue_taste_for(eater) && eat_effect)
		eater.apply_status_effect(eat_effect)

/obj/item/reagent_containers/food/proc/on_cooked_into(datum/source, atom/original)
	SIGNAL_HANDLER
	if(length(bonus_reagents))
		reagents?.add_reagent_list(bonus_reagents)
	var/obj/item/reagent_containers/food/raw = original
	if(istype(raw))
		raw.cooked_into = WEAKREF(src)
		rogue_cooking_smell(raw)

/obj/item/reagent_containers/food/update_overlays()
	. = ..()
	for(var/mutable_appearance/ingredient as anything in recipe_overlays)
		. += ingredient
	if(rotten)
		. += mutable_appearance('modular_redtard/survival/icons/rotten.dmi', "rotten")

/obj/item/reagent_containers/food/examine(mob/user)
	. = ..()
	if(active_recipe && current_step <= length(active_recipe.ingredients))
		. += span_smallnotice("Recipe: <b>[active_recipe.name]</b>. Next step: add [active_recipe.step_name(current_step)]. Alt-click to start over.")
	var/list/recipes = GLOB.rogue_food_recipes[type]
	if(length(recipes) && !rotten)
		var/list/names = list()
		for(var/datum/rogue_food_recipe/recipe as anything in recipes)
			names += "[recipe.name] (starts with [recipe.step_name(1)])"
		. += span_smallnotice("This could be used to prepare: [names.Join(", ")].")
	if(slice_path && slices_num > 0)
		var/obj/item/slice = slice_path
		. += span_smallnotice("It can be <b>[slice_bclass == BCLASS_CHOP ? "chopped" : "sliced"]</b> into [initial(slice.name)] on a table with a short blade.")
	switch(eat_effect)
		if(/datum/status_effect/rogue_food/uncooked)
			. += span_warning("It is raw!")
		if(/datum/status_effect/rogue_food/rotten)
			. += span_warning("It is rotten!")
		if(/datum/status_effect/rogue_food/burned)
			. += span_warning("It is burned!")
		if(/datum/status_effect/rogue_food_buff/snack, /datum/status_effect/rogue_food_buff/meal)
			. += span_smallnotice("It looks good!")
		if(/datum/status_effect/rogue_food_buff/great_snack, /datum/status_effect/rogue_food_buff/great_meal)
			. += span_smallnotice("It looks great!!")
	. += rogue_fryer_examine()
	. += rogue_palate_examine()

/obj/item/reagent_containers/food/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = rogue_combo_interaction(user, tool)
	if(.)
		return .
	. = recipe_interaction(user, tool)
	if(.)
		return .
	. = slice_interaction(user, tool)
	if(.)
		return .
	return ..()

/// Ratwood slice(): a short blade of the right class cuts the food on a table into its slices, all at once or one by one.
/obj/item/reagent_containers/food/proc/slice_interaction(mob/living/user, obj/item/tool)
	if(!slice_path || slices_num <= 0 || rotten || tool.wlength != WLENGTH_SHORT)
		return NONE
	var/datum/intent/intent = user.rogue_active_intent()
	if(intent?.blade_class != slice_bclass)
		return NONE
	if(!isturf(loc) || !(locate(/obj/structure/table) in loc))
		to_chat(user, span_warning("I need to use a table."))
		return ITEM_INTERACT_BLOCKING
	playsound(src, slice_bclass == BCLASS_CHOP ? 'modular_redtard/survival/sound/chopping_block.ogg' : 'modular_redtard/survival/sound/slicing.ogg', 60, TRUE, -1)
	if(slice_bclass == BCLASS_CHOP)
		user.visible_message(span_notice("[user] chops [src]!"))
	if(!slice_batch)
		make_slice(reagents.total_volume / slices_num)
		slices_num--
		if(slices_num <= 1)
			if(slices_num == 1)
				make_slice(reagents.total_volume)
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	if(!do_after(user, 1 SECONDS / rogue_cook_divisor(user), target = src))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src))
		return ITEM_INTERACT_BLOCKING
	var/share = reagents.total_volume / slices_num
	for(var/i in 1 to slices_num)
		make_slice(share)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Ratwood initialize_slice(): a slice takes its share of the reagents.
/obj/item/reagent_containers/food/proc/make_slice(share)
	var/obj/item/slice = new slice_path(loc)
	if(slice.reagents && reagents)
		slice.reagents.clear_reagents()
		reagents.trans_to(slice, share)
	return slice

/// Ratwood snacks/rogue attackby(), do_cooking_step(): an ingredient (or a reagent from a container) for the next step of a
/// slapcraft recipe, on a table.
/obj/item/reagent_containers/food/proc/recipe_interaction(mob/living/user, obj/item/tool)
	if(rotten || rogue_recipe_done)
		return NONE
	var/datum/rogue_food_recipe/recipe = active_recipe || rogue_food_recipe_for(src, tool)
	if(!recipe)
		return NONE
	var/requirement = recipe.ingredients[current_step]
	var/amount = 0
	if(ispath(requirement, /datum/reagent))
		amount = recipe.ingredients[requirement]
		if(!recipe.step_accepts(current_step, tool))
			if(active_recipe)
				to_chat(user, span_warning("I need at least [amount] units of [recipe.step_name(current_step)]!"))
				return ITEM_INTERACT_BLOCKING
			return NONE
	else if(!recipe.step_accepts(current_step, tool))
		return NONE
	else if(istype(tool, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/ingredient = tool
		if(ingredient.rotten)
			return NONE
	if(!(locate(/obj/structure/table) in loc))
		to_chat(user, span_warning("I need a table to prepare [src]."))
		return ITEM_INTERACT_BLOCKING
	if(!recipe.can_prepare(user))
		to_chat(user, span_warning(recipe.refusal))
		return ITEM_INTERACT_BLOCKING
	active_recipe = recipe
	if(!do_after(user, recipe.time_per_step / rogue_cook_divisor(user), target = src))
		if(current_step == 1)
			active_recipe = null
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || QDELETED(tool) || active_recipe != recipe)
		return ITEM_INTERACT_BLOCKING
	if(amount)
		if(!tool.reagents?.has_reagent(requirement, amount))
			return ITEM_INTERACT_BLOCKING
		tool.reagents.remove_reagent(requirement, amount)
	else
		if(ismob(tool.loc) && !user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_BLOCKING
		if(current_step < length(recipe.ingredients) || recipe.needs_cooking)
			add_recipe_look(recipe, current_step, tool)
		qdel(tool)
	playsound(src, 'modular_redtard/survival/sound/gen_drop.ogg', 30, TRUE)
	user.rogue_cooking_experience(recipe.experience_per_step)
	if(current_step == 1 && recipe.started_name)
		name = recipe.started_name
	current_step++
	if(current_step <= length(recipe.ingredients))
		return ITEM_INTERACT_SUCCESS
	active_recipe = null
	current_step = 1
	if(!recipe.needs_cooking)
		new recipe.result_type(drop_location())
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	rogue_recipe_done = TRUE
	if(recipe.ready_name)
		name = recipe.ready_name
	if(recipe.ready_smell)
		rogue_cooked_smell = recipe.ready_smell
	if(recipe.deep_fry)
		to_chat(user, span_nicegreen("[src] is ready to be deep fried."))
		rogue_deep_fried_type = recipe.result_type
		return ITEM_INTERACT_SUCCESS
	to_chat(user, span_nicegreen("[src] is ready to be cooked."))
	cooked_type = recipe.result_type
	fried_type = recipe.result_type
	if(!cooktime)
		cooktime = 30 SECONDS
	refresh_cooking()
	return ITEM_INTERACT_SUCCESS

/// How a step shows on the dish: Ratwood's own sprite of the step if the recipe has one, else the ingredient drawn small.
/obj/item/reagent_containers/food/proc/add_recipe_look(datum/rogue_food_recipe/recipe, step, obj/item/ingredient)
	if(LAZYLEN(recipe.step_icon_states) >= step && recipe.step_icon_states[step])
		icon_state = recipe.step_icon_states[step]
		update_appearance()
		return
	if(LAZYLEN(recipe.step_overlays) >= step && recipe.step_overlays[step])
		LAZYADD(recipe_overlays, mutable_appearance(recipe.overlay_icon || icon, recipe.step_overlays[step]))
		update_appearance(UPDATE_OVERLAYS)
		return
	add_ingredient_look(ingredient)

/// Ratwood draws each added ingredient small in a corner of the dish.
/obj/item/reagent_containers/food/proc/add_ingredient_look(obj/item/ingredient)
	var/static/list/corners = list(list(-7, 7), list(7, 7), list(7, -7), list(-7, -7))
	var/mutable_appearance/look = mutable_appearance(ingredient.icon, ingredient.icon_state)
	look.transform = matrix() * 0.7
	var/list/corner = corners[((length(recipe_overlays)) % length(corners)) + 1]
	look.pixel_x = corner[1]
	look.pixel_y = corner[2]
	LAZYADD(recipe_overlays, look)
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood MiddleClick(): start the recipe over (middle click is TG's hand swap, so Alt+click).
/obj/item/reagent_containers/food/click_alt(mob/user)
	if(!active_recipe)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(confirm_recipe_reset), user)
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/food/proc/confirm_recipe_reset(mob/user)
	var/datum/rogue_food_recipe/recipe = active_recipe
	if(tgui_alert(user, "Are you sure you want to reset the preparation for [recipe.name]?", "Reset Recipe", list("Yes", "No")) != "Yes" || active_recipe != recipe)
		return
	to_chat(user, span_notice("I clear the preparation progress for [recipe.name] from [src]."))
	active_recipe = null
	current_step = 1
	recipe_overlays = null
	name = initial(name)
	icon_state = initial(icon_state)
	update_appearance()

/// Ratwood become_rotten(): the food turns into its rotten form (not in someone's hands), or goes bad in place - flies,
/// a bluish tint, the rotten bite, no slicing and no cooking but burning. Food left to rot on the floor of the town's sewers
/// becomes a rat instead. FALSE when it has to wait.
/obj/item/reagent_containers/food/proc/become_rotten()
	if(QDELETED(src) || !loc)
		return FALSE
	if(isturf(loc) && istype(get_area(src), /area/rogue/under/town/sewer) && !istype(src, /obj/item/reagent_containers/food/snacks/smallrat))
		new /obj/item/reagent_containers/food/snacks/smallrat(loc)
		qdel(src)
		return TRUE
	if(become_rot_type)
		if(ismob(loc))
			return FALSE
		var/obj/item/rotten_form = new become_rot_type(loc)
		if(rotten_form.reagents && reagents)
			rotten_form.reagents.clear_reagents()
			reagents.trans_to(rotten_form, reagents.total_volume)
		qdel(src)
		return TRUE
	rotten = TRUE
	name = "rotten [initial(name)]"
	add_atom_colour("#6c6897", FIXED_COLOUR_PRIORITY)
	eat_effect = /datum/status_effect/rogue_food/rotten
	slice_path = null
	slices_num = 0
	cooked_type = null
	fried_type = null
	cooktime = 0
	active_recipe = null
	refresh_cooking()
	update_appearance()
	loc.update_appearance()
	return TRUE

/// Ratwood keeps eggs off the open fire; they need a pan.
/obj/item/reagent_containers/food/proc/can_spit_roast()
	var/static/egg_type = text2path("/obj/item/reagent_containers/food/snacks/egg")
	return !(egg_type && istype(src, egg_type))
