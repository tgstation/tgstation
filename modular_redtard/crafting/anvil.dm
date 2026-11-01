#define ANVIL_HOT_FILTER list(3,0,0,1, 0,2.7,0,0.4, 0,0,1,0, 0,0,0,1)

/// Ratwood anvil (roguejobs/blacksmith/anvil.dm): a bar is laid on with tongs or by hand, a recipe is chosen in the anvil
/// window with a hammer, and every hammer strike (2 seconds) works the hot bar through the recipe's stages.
/obj/machinery/anvil
	max_integrity = 500
	interaction_flags_atom = NONE
	/// The bar on the anvil (Ratwood current_workpiece).
	var/obj/item/workpiece
	/// world.time the bar on the anvil cools at (Ratwood hott + 20 seconds).
	var/hot_until = 0
	var/cool_timer
	/// The first strike of a run counts in full, the rest at half (Ratwood advance_multiplier).
	var/strike_multiplier = 1

/obj/machinery/anvil/Destroy()
	if(workpiece)
		workpiece.forceMove(drop_location())
	deltimer(cool_timer)
	return ..()

/obj/machinery/anvil/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != workpiece)
		return
	workpiece = null
	cool()

/obj/machinery/anvil/examine(mob/user)
	. = ..()
	if(!workpiece)
		. += span_info("Lay a bar on it with tongs, or a cast blade by hand, then strike it with a hammer to choose what to forge.")
		return
	. += span_info("\A [workpiece] lies on it.")
	if(is_hot())
		. += span_warning("[workpiece] is too hot to touch.")
	var/datum/component/rogue_forging/forging = workpiece.GetComponent(/datum/component/rogue_forging)
	if(forging?.needed_item)
		. += span_notice("It needs \a [initial(forging.needed_item.name)] to continue.")
	else if(forging?.stage == ROGUE_FORGING_COMPLETE)
		. += span_notice("It is ready to be quenched.")

/obj/machinery/anvil/update_overlays()
	. = ..()
	if(!workpiece)
		return
	var/mutable_appearance/shown = new(workpiece)
	shown.plane = FLOAT_PLANE
	shown.layer = FLOAT_LAYER
	shown.pixel_w = 3
	shown.pixel_z = 5
	shown.transform = matrix() * 0.5
	if(is_hot())
		shown.filters += filter(type = "color", color = ANVIL_HOT_FILTER)
	. += shown

/obj/machinery/anvil/proc/is_hot()
	return workpiece && hot_until > world.time

/obj/machinery/anvil/proc/heat_left()
	return is_hot() ? hot_until - world.time : 0

/obj/machinery/anvil/proc/heat(duration)
	hot_until = world.time + duration
	deltimer(cool_timer)
	cool_timer = addtimer(CALLBACK(src, PROC_REF(cool)), duration, TIMER_STOPPABLE | TIMER_DELETE_ME)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/anvil/proc/cool()
	hot_until = 0
	deltimer(cool_timer)
	cool_timer = null
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/anvil/proc/lay(obj/item/bar, heat_left = 0)
	bar.forceMove(src)
	workpiece = bar
	if(heat_left > 0)
		heat(heat_left)
	else
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/anvil/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/rogueweapon/tongs))
		return tongs_interaction(user, tool)
	if(istype(tool, /obj/item/rogueweapon/hammer))
		return hammer_interaction(user, tool)
	// Ratwood: bars and cast blades are laid on by hand; a blade is never hot.
	if((istype(tool, /obj/item/ingot) || istype(tool, /obj/item/blade)) && !workpiece)
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		lay(tool)
		return ITEM_INTERACT_SUCCESS
	var/datum/component/rogue_forging/forging = workpiece?.GetComponent(/datum/component/rogue_forging)
	if(forging?.add_material(tool, user))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	if(tool.anvilrepair && !user.combat_mode)
		if(!user.transferItemToLoc(tool, drop_location()))
			return ITEM_INTERACT_BLOCKING
		user.visible_message(span_info("[user] places [tool] on the anvil."))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/anvil/proc/tongs_interaction(mob/living/user, obj/item/rogueweapon/tongs/tongs)
	if(!workpiece)
		if(!istype(tongs.held_bar, /obj/item/ingot))
			return ITEM_INTERACT_BLOCKING
		var/heat_left = tongs.heat_left()
		lay(tongs.release_bar(), heat_left)
		return ITEM_INTERACT_SUCCESS
	var/datum/component/rogue_forging/forging = workpiece.GetComponent(/datum/component/rogue_forging)
	if(forging?.needed_item && istype(tongs.held_bar, forging.needed_item))
		forging.add_material(tongs.release_bar(), user)
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	if(!istype(workpiece, /obj/item/ingot))
		return ITEM_INTERACT_BLOCKING
	if(tongs.held_bar)
		to_chat(user, span_warning("You're already holding something with your tongs!"))
		return ITEM_INTERACT_BLOCKING
	var/heat_left = heat_left()
	tongs.grab_bar(workpiece, heat_left > 0, heat_left)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/anvil/proc/hammer_interaction(mob/living/user, obj/item/rogueweapon/hammer/hammer)
	if(!workpiece)
		return ITEM_INTERACT_BLOCKING
	var/datum/component/rogue_forging/forging = workpiece.GetComponent(/datum/component/rogue_forging)
	if(!forging)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	if(forging.stage == ROGUE_FORGING_COMPLETE)
		to_chat(user, span_info("It's ready. It needs quenching in a water bin."))
		return ITEM_INTERACT_BLOCKING
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	strike_multiplier = 1
	INVOKE_ASYNC(src, PROC_REF(forging_loop), user, hammer, forging)
	return ITEM_INTERACT_SUCCESS

/// Ratwood forging_loop(): strikes until the stage is done, the bar cools, breaks or the smith stops.
/obj/machinery/anvil/proc/forging_loop(mob/living/user, obj/item/rogueweapon/hammer/hammer, datum/component/rogue_forging/forging)
	while(workpiece && !QDELETED(forging) && forging.parent == workpiece && forging.stage == ROGUE_FORGING_ACTIVE)
		if(!is_hot() && istype(workpiece, /obj/item/ingot))
			to_chat(user, span_warning("It's too cold."))
			return
		var/strength = user.rogue_stat(ROGUE_STAT_STRENGTH)
		user.adjust_stamina_loss(max((HAS_TRAIT(user, TRAIT_FORGEBLESSED) ? 21 : 40) - strength * 3, 0) * strike_multiplier)
		var/rank = user.rogue_skill_rank(forging.recipe.appro_skill)
		var/breakthrough = prob((1 + 7 * rank * user.rogue_stat(ROGUE_STAT_PERCEPTION) / 10 * hammer.smith_quality) * strike_multiplier)
		if(breakthrough)
			forging.breakthroughs++
			do_sparks(1, TRUE, src)
		var/done = forging.strike(user, breakthrough)
		playsound(src, pick(ROGUE_SMITH_SOUNDS), 100, FALSE)
		update_appearance(UPDATE_OVERLAYS)
		// Ratwood keeps striking while a material is missing; here the run stops until it is added.
		if(done || QDELETED(forging) || forging.needed_item)
			return
		if(!do_after(user, rogue_value("anvil_strike_time"), target = src))
			return
		strike_multiplier = 0.5

/// The smith's hand takes the bar once it has cooled (Ratwood attack_hand()).
/obj/machinery/anvil/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !workpiece)
		return
	if(is_hot() && istype(workpiece, /obj/item/ingot))
		to_chat(user, span_warning("It's too hot."))
		return TRUE
	var/obj/item/taken = workpiece
	taken.forceMove(drop_location())
	user.put_in_active_hand(taken)
	return TRUE

/obj/machinery/anvil/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueAnvil", name)
		ui.open()

/obj/machinery/anvil/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet_batched/rogue_anvil))

/// Ratwood's guarded recipes (anvil ui_static_data(), ui_act()): a recipe with req_trait shows to and is forged only by a
/// smith who has the trait (Dwarvish Knowledge for the dwarven armor and mauls).
/datum/anvil_recipe/proc/known_to(mob/user)
	return !req_trait || HAS_TRAIT(user, req_trait)

/obj/machinery/anvil/ui_static_data(mob/user)
	var/list/recipes = list()
	for(var/datum/anvil_recipe/recipe as anything in GLOB.rogue_anvil_recipes)
		if(workpiece && !recipe.accepts(workpiece))
			continue
		if(!recipe.known_to(user))
			continue
		recipes += list(recipe.get_ui_entry())
	return list("recipes" = recipes)

/obj/machinery/anvil/ui_data(mob/user)
	var/datum/component/rogue_forging/forging = workpiece?.GetComponent(/datum/component/rogue_forging)
	return list(
		"workpiece" = workpiece?.name,
		"current" = forging?.recipe.name,
	)

/obj/machinery/anvil/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "choose_recipe")
		return
	var/datum/anvil_recipe/recipe = locate(params["ref"])
	if(!(recipe in GLOB.rogue_anvil_recipes) || !recipe.accepts(workpiece) || !recipe.known_to(ui.user))
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(choose_recipe), ui.user, recipe)
	ui.close()
	return TRUE

/// Ratwood ui_act("choose_recipe"): the difficulty warning, a recipe change, then straight to work if a hammer is in hand.
/obj/machinery/anvil/proc/choose_recipe(mob/living/user, datum/anvil_recipe/recipe)
	if(user.rogue_skill_rank(recipe.appro_skill) < recipe.craftdiff)
		var/datum/attribute/skill/skill = GET_ROGUE_ATTRIBUTE(recipe.appro_skill)
		if(tgui_alert(user, "This recipe needs [skill.description_from_level(recipe.craftdiff * ROGUE_SKILL_PER_RANK)] skill.", "IT'S TOO DIFFICULT!", list("CONFIRM", "CANCEL")) != "CONFIRM")
			return
	if(!recipe.accepts(workpiece) || !user.Adjacent(src))
		return
	var/datum/component/rogue_forging/existing = workpiece.GetComponent(/datum/component/rogue_forging)
	if(existing)
		if(tgui_alert(user, "This item already has an active recipe ([existing.recipe.name]). Change to [recipe.name]?", "CHANGE RECIPE?", list("CONFIRM", "CANCEL")) != "CONFIRM")
			return
		if(QDELETED(existing) || existing.parent != workpiece)
			return
		qdel(existing)
	var/datum/component/rogue_forging/forging = workpiece.AddComponent(/datum/component/rogue_forging, recipe)
	if(!forging)
		return
	var/obj/item/rogueweapon/hammer/hammer = user.get_active_held_item()
	if(istype(hammer) && user.Adjacent(src))
		hammer_interaction(user, hammer)

/// Ratwood /datum/asset/spritesheet/anvil_recipes: what each anvil recipe makes, for the anvil window. One sprite per made type
/// (the CSS class is its sanitized path), larger sprites shrunk to 32x32 so the window has a single size class.
/datum/asset/spritesheet_batched/rogue_anvil
	name = "rogue_anvil"

/datum/asset/spritesheet_batched/rogue_anvil/create_spritesheets()
	var/list/added = list()
	for(var/datum/anvil_recipe/recipe as anything in GLOB.rogue_anvil_recipes)
		var/obj/item/made = recipe.created_item
		var/id = sanitize_css_class_name("[made]")
		if(added[id])
			continue
		added[id] = TRUE
		var/icon_file = initial(made.icon)
		var/icon_state = initial(made.icon_state)
		if(!icon_file || !icon_exists(icon_file, icon_state))
			continue
		var/made_color = initial(made.color)
		var/datum/universal_icon/sprite = uni_icon(icon_file, icon_state, SOUTH, null, null, istext(made_color) ? made_color : null)
		var/list/size = get_icon_dimensions(icon_file)
		if(size["width"] != ICON_SIZE_X || size["height"] != ICON_SIZE_Y)
			sprite.scale(ICON_SIZE_X, ICON_SIZE_Y)
		insert_icon(id, sprite)

#undef ANVIL_HOT_FILTER
