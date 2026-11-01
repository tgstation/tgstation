// Ratwood's brewing (roguecrafting/alchemy/cauldron.dm, mortarpestle.dm, ingredients.dm, alch_cauldron_recipe*.dm,
// alch_grind_recipe*.dm): the cauldron boils up to four ingredients in water into a potion, the mortar and pestle grind things
// into ingredients. The recipes and what each ingredient leans toward are Ratwood's, written under its paths by the porter
// (alchemy/ported/alchemy.dm, rockhill/config.json "alchemy").

/// A cauldron recipe (Ratwood /datum/alch_cauldron_recipe): what it makes, the smell it leaves, the Alchemy it takes.
/datum/alch_cauldron_recipe
	abstract_type = /datum/alch_cauldron_recipe
	var/name = ""
	/// What the cauldron smells of when the brew is done, and what an ingredient leaning toward it smells of.
	var/smells_like = "nothing"
	/// Least learned rank of Alchemy that brews it (Ratwood Apprentice); below it the brew turns to slurry.
	var/skill_required = ROGUE_RANK_APPRENTICE
	/// Reagents it leaves in the cauldron, list(path = units); items it leaves beside it, one of each.
	var/list/output_reagents = list()
	var/list/output_items = list()

/// A mortar recipe (Ratwood /datum/alch_grind_recipe): what grinds so and what that gives, always and by chance.
/datum/alch_grind_recipe
	abstract_type = /datum/alch_grind_recipe
	var/name = "generic grind recipe"
	/// Only the very type grinds so; FALSE - its subtypes too.
	var/picky = TRUE
	var/obj/item/valid_input
	/// Items it always gives, list(path = count), and may give, list(path = percent).
	var/list/valid_outputs = list()
	var/list/bonus_chance_outputs = list()

/// The chance of a bonus output.
/datum/alch_grind_recipe/proc/get_bonus_output_chance(output_path, mob/living/user, base_chance)
	return base_chance

/// Ratwood's natural bone gives bone meal more often to a better alchemist.
/datum/alch_grind_recipe/natural_bone/get_bonus_output_chance(output_path, mob/living/user, base_chance)
	if(output_path != /obj/item/alch/bonemeal || !user)
		return base_chance
	return user.rogue_learned_rank(ROGUE_ALCHEMY_SKILL) <= ROGUE_RANK_APPRENTICE ? ROGUE_GRIND_BONEMEAL_CHANCE_LOW : ROGUE_GRIND_BONEMEAL_CHANCE_HIGH

/// The recipes of each kind, one of each, by type.
GLOBAL_LIST_INIT(alch_cauldron_recipes, rogue_alchemy_recipes(/datum/alch_cauldron_recipe))
GLOBAL_LIST_INIT(alch_grind_recipes, rogue_alchemy_recipes(/datum/alch_grind_recipe))

/proc/rogue_alchemy_recipes(root)
	. = list()
	for(var/recipe_type in valid_subtypesof(root))
		.[recipe_type] = new recipe_type

/// The mortar recipe that grinds the item (Ratwood find_recipe()), or null.
/proc/rogue_grind_recipe(obj/item/ground)
	for(var/recipe_type in GLOB.alch_grind_recipes)
		var/datum/alch_grind_recipe/recipe = GLOB.alch_grind_recipes[recipe_type]
		if(recipe.picky ? ground.type == recipe.valid_input : istype(ground, recipe.valid_input))
			return recipe

/obj/item/alch
	/// The cauldron recipes it leans toward, strongly, moderately and slightly (Ratwood major_pot, med_pot, minor_pot).
	var/major_pot
	var/med_pot
	var/minor_pot

/// Ratwood's sniffing: Alchemy, or a keen nose and mind, tells what an ingredient leans toward by its smell; the strongest
/// leaning is the easiest to smell. A legendary herb finder knows the recipes by name.
/obj/item/alch/examine(mob/user)
	. = ..()
	if(!isliving(user) || !user.mind)
		return
	var/mob/living/sniffer = user
	var/rank = sniffer.rogue_learned_rank(ROGUE_ALCHEMY_SKILL)
	var/keen = floor((sniffer.rogue_stat(ROGUE_STAT_PERCEPTION) + sniffer.rogue_stat(ROGUE_STAT_INTELLIGENCE)) / 2)
	var/knows = HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST)
	. += rogue_leaning_line(major_pot, knows, "Strongly", "strongly", rank >= ROGUE_RANK_NOVICE || keen >= ROGUE_SNIFF_MAJOR_KEEN)
	. += rogue_leaning_line(med_pot, knows, "Moderately", "slightly", rank >= ROGUE_RANK_APPRENTICE || keen >= ROGUE_SNIFF_MED_KEEN)
	. += rogue_leaning_line(minor_pot, knows, "Minorly", "weakly", rank >= ROGUE_RANK_EXPERT || keen >= ROGUE_SNIFF_MINOR_KEEN)

/obj/item/alch/proc/rogue_leaning_line(recipe_type, knows, attuned, smelt, smells)
	var/datum/alch_cauldron_recipe/recipe = recipe_type && GLOB.alch_cauldron_recipes[recipe_type]
	if(!recipe)
		return list()
	if(knows)
		return list(span_notice("[attuned] attuned to making [recipe.name]."))
	return smells ? list(span_notice("Smells [smelt] of [recipe.smells_like].")) : list()

// The cauldron (Ratwood /obj/machinery/light/rogue/cauldron): a fire under a pot of 500 units (rockhill/fires.dm). Ingredients
// go in; while it burns and holds the water a brew needs, they boil for cauldron_brew_ticks, then the recipe the ingredients
// lean toward the most is brewed, if it has cauldron_min_points. Below the recipe's Alchemy the brew is slurry. The water is
// spent and the potion is left in the cauldron, to be drawn out with a vessel.

/obj/machinery/light/rogue/cauldron
	/// What boils in it (Ratwood ingredients): no more than rogue_max_ingredients, no two of a kind.
	var/list/rogue_ingredients
	var/rogue_max_ingredients = 4
	/// Water a brew needs (Ratwood waterneed: 30 ounces), and what the cauldron holds.
	var/rogue_water_need = 90
	var/rogue_volume = 500
	/// Ratwood ticks the brew has boiled (Ratwood brewing); cauldron_brew_ticks and over once it is done.
	var/rogue_brewing = 0
	/// Who put the last ingredient in: the brew answers to their Alchemy and teaches them (Ratwood lastuser).
	var/datum/weakref/rogue_brewer

/obj/machinery/light/rogue/cauldron/Initialize(mapload)
	create_reagents(rogue_volume, DRAINABLE | AMOUNT_VISIBLE | REFILLABLE)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagents_changed))
	return ..()

/obj/machinery/light/rogue/cauldron/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(reagents?.total_volume)
		chem_splash(get_turf(src), null, 2, list(reagents))
	rogue_ingredients = null
	return ..()

/obj/machinery/light/rogue/cauldron/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(rogue_ingredients, gone)

/obj/machinery/light/rogue/cauldron/ignite(silent = FALSE)
	. = ..()
	if(.)
		rogue_stir()

/// Ratwood's burn_out(): the brew stops and starts over when lit again.
/obj/machinery/light/rogue/cauldron/burn_out(silent = FALSE)
	. = ..()
	if(.)
		rogue_brewing = 0
		update_appearance(UPDATE_OVERLAYS)

/// Puts the brew on to boil if there is one to boil.
/obj/machinery/light/rogue/cauldron/proc/rogue_stir()
	if(lit && length(rogue_ingredients) && rogue_brewing < ROGUE_CAULDRON_BREW_TICKS)
		START_PROCESSING(SSobj, src)

/obj/machinery/light/rogue/cauldron/process(seconds_per_tick)
	if(!lit || !length(rogue_ingredients) || rogue_brewing >= ROGUE_CAULDRON_BREW_TICKS)
		return PROCESS_KILL
	if(!reagents.has_reagent(/datum/reagent/water, rogue_water_need))
		return
	var/was_boiling = rogue_brewing > 0
	rogue_brewing += seconds_per_tick / ROGUE_REAGENT_TICK
	if(!was_boiling)
		update_appearance(UPDATE_OVERLAYS)
	if(prob(ROGUE_CAULDRON_BUBBLE_CHANCE * seconds_per_tick / ROGUE_REAGENT_TICK))
		playsound(src, ROGUE_CAULDRON_BUBBLE_SOUND, 100, FALSE)
	if(rogue_brewing >= ROGUE_CAULDRON_BREW_TICKS)
		rogue_finish_brew()
		return PROCESS_KILL

/// The brew is done: each ingredient gives its leanings their points, and the recipe with the most is brewed (the first of
/// equals), if it has enough and an alchemist to guide it.
/obj/machinery/light/rogue/cauldron/proc/rogue_finish_brew()
	var/list/points = list()
	for(var/obj/item/alch/ingredient in rogue_ingredients)
		if(ingredient.major_pot)
			points[ingredient.major_pot] += ROGUE_CAULDRON_MAJOR_POINTS
		if(ingredient.med_pot)
			points[ingredient.med_pot] += ROGUE_CAULDRON_MED_POINTS
		if(ingredient.minor_pot)
			points[ingredient.minor_pot] += ROGUE_CAULDRON_MINOR_POINTS
	var/best
	for(var/recipe_type in points)
		if(!best || points[recipe_type] > points[best])
			best = recipe_type
	var/datum/alch_cauldron_recipe/recipe = best && points[best] >= ROGUE_CAULDRON_MIN_POINTS ? GLOB.alch_cauldron_recipes[best] : null
	if(!recipe)
		visible_message(span_info("The ingredients in [src] fail to meld together at all..."))
		playsound(src, ROGUE_CAULDRON_DONE_SOUND, 30, FALSE)
		return
	var/mob/living/brewer = rogue_brewer?.resolve()
	if(!brewer)
		visible_message(span_info("[src] can't brew anything without an alchemist to guide it."))
		return
	var/water = reagents.get_reagent_amount(/datum/reagent/water)
	var/experience = brewer.rogue_stat(ROGUE_STAT_INTELLIGENCE) * ROGUE_CAULDRON_XP_PER_INT
	for(var/obj/item/ingredient as anything in rogue_ingredients.Copy())
		qdel(ingredient)
	rogue_ingredients = null
	reagents.remove_reagent(/datum/reagent/water, water)
	if(recipe.skill_required > brewer.rogue_learned_rank(ROGUE_ALCHEMY_SKILL))
		visible_message(span_warning("The ingredients in [src] meld together into a disgusting mess! Perhaps a more skilled alchemist is needed for this recipe."))
		reagents.add_reagent(/datum/reagent/yuck, water)
		brewer.rogue_adjust_experience(ROGUE_ALCHEMY_SKILL, experience)
		update_appearance(UPDATE_OVERLAYS)
		return
	if(length(recipe.output_reagents))
		reagents.add_reagent_list(recipe.output_reagents)
	for(var/item_type in recipe.output_items)
		new item_type(drop_location())
	visible_message(span_info("[src] finishes boiling with a faint [recipe.smells_like] smell."))
	brewer.log_message("brewed [recipe.type] in [src] (REAGENTS: [english_list(recipe.output_reagents, "none")]) (ITEMS: [english_list(recipe.output_items, "none")])", LOG_GAME)
	brewer.rogue_adjust_experience(ROGUE_ALCHEMY_SKILL, experience)
	playsound(src, ROGUE_CAULDRON_BUBBLE_SOUND, 100, TRUE)
	playsound(src, ROGUE_CAULDRON_DONE_SOUND, 30, FALSE)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/light/rogue/cauldron/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance(icon, rogue_brewing > 0 ? "cauldron_boiling" : "cauldron_full")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/machinery/light/rogue/cauldron/proc/on_reagents_changed(datum/reagents/holder)
	SIGNAL_HANDLER
	update_appearance(UPDATE_OVERLAYS)

/// An ingredient goes in (Ratwood attackby()); the brew starts over.
/obj/machinery/light/rogue/cauldron/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/alch))
		return ..()
	if(length(rogue_ingredients) >= rogue_max_ingredients)
		to_chat(user, span_warning("Nothing else can fit."))
		return ITEM_INTERACT_BLOCKING
	if(length(rogue_ingredients) && (locate(tool.type) in rogue_ingredients))
		to_chat(user, span_warning("There is already \a [tool] in [src]! That would ruin the mixture!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] is stuck to my hand!"))
		return ITEM_INTERACT_BLOCKING
	LAZYADD(rogue_ingredients, tool)
	rogue_brewing = 0
	rogue_brewer = WEAKREF(user)
	to_chat(user, span_info("I add [tool] to [src]."))
	playsound(src, ROGUE_CAULDRON_BUBBLE_SOUND, 100, TRUE)
	update_appearance(UPDATE_OVERLAYS)
	rogue_stir()
	return ITEM_INTERACT_SUCCESS

/// Ratwood's attack_hand(): an unlit cauldron gives back the last ingredient put in.
/obj/machinery/light/rogue/cauldron/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(lit)
		if(length(rogue_ingredients))
			to_chat(user, span_warning("Something's brewing."))
		else
			to_chat(user, span_info("Nothing's brewing."))
		return TRUE
	if(!length(rogue_ingredients))
		to_chat(user, span_info("It's empty."))
		return TRUE
	var/obj/item/ingredient = rogue_ingredients[length(rogue_ingredients)]
	ingredient.forceMove(drop_location())
	user.put_in_active_hand(ingredient)
	user.visible_message(span_info("[user] pulls [ingredient] from [src]."))
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Ratwood's onkick(): a kick spills the cauldron and its ingredients.
/obj/machinery/light/rogue/cauldron/rogue_onkick(mob/living/carbon/human/kicker)
	for(var/obj/item/ingredient as anything in rogue_ingredients?.Copy())
		ingredient.forceMove(get_turf(kicker))
	if(reagents?.total_volume)
		chem_splash(get_turf(src), null, 2, list(reagents))
		kicker.visible_message(span_info("[kicker] kicks [src], spilling its contents!"))
	playsound(src, 'modular_redtard/rockhill/sound/items/beartrap2.ogg', 100, FALSE)
	rogue_brewing = 0
	update_appearance(UPDATE_OVERLAYS)

// The mortar (Ratwood /obj/item/reagent_containers/glass/mortar): a thing put in is ground with a pestle into ingredients by a
// mortar recipe, or into reagents (a right click with the pestle: juiced first, else ground). Vessels still pour in and out.

/// Ratwood's stone pestle (mortarpestle.dm): TG's pestle with Ratwood's look, so it grinds in this mortar and in TG's as TG's
/// pestle does, while modern maps keep TG's. The porter hands out Ratwood's pestles as this one.
/obj/item/pestle/rogue
	desc = "A small, round-end stone tool oft used by physicians to crush and mix medicine."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/alchemy.dmi'
	icon_state = "pestle"
	custom_materials = null
	rogue_grid_width = 64
	rogue_grid_height = 32

/obj/item/reagent_containers/glass/mortar
	/// What lies in it to be ground (Ratwood to_grind).
	var/obj/item/rogue_to_grind

/obj/item/reagent_containers/glass/mortar/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rogue_to_grind)
		rogue_to_grind = null

/obj/item/reagent_containers/glass/mortar/examine(mob/user)
	. = ..()
	if(rogue_to_grind)
		. += span_info("[rogue_to_grind] is inside the mortar.")
	. += span_notice("Click it with a pestle to grind what is inside into alchemical ingredients; right-click it with a pestle to grind or juice it. Right-click it with an empty hand to take it out.")

/obj/item/reagent_containers/glass/mortar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/pestle))
		INVOKE_ASYNC(src, PROC_REF(rogue_grind), user)
		return ITEM_INTERACT_SUCCESS
	if(!rogue_grind_recipe(tool) && istype(tool, /obj/item/reagent_containers/glass))
		return ..()
	if(rogue_to_grind)
		to_chat(user, span_warning("[src] is full!"))
		return ITEM_INTERACT_BLOCKING
	if(!rogue_grind_recipe(tool) && !length(tool.grind_results()) && !tool.juice_typepath() && !tool.reagents?.total_volume)
		to_chat(user, span_warning("[tool] can't be ground!"))
		return ITEM_INTERACT_BLOCKING
	if(!tool.blend_requirements(src, user) || !user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	rogue_to_grind = tool
	to_chat(user, span_info("I add [tool] to [src]."))
	return ITEM_INTERACT_SUCCESS

/// Ratwood's MiddleClick() with a pestle: what is inside is juiced, or else ground, into the mortar's reagents.
/obj/item/reagent_containers/glass/mortar/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/pestle))
		return ..()
	var/obj/item/ground = rogue_to_grind
	if(!ground)
		to_chat(user, span_warning("There's nothing to grind."))
		return ITEM_INTERACT_BLOCKING
	if(ground.juice(reagents, user))
		to_chat(user, span_notice("I juice [ground] into a fine liquid."))
	else if(ground.grind(reagents, user))
		to_chat(user, span_notice("I break [ground] into powder."))
	else
		to_chat(user, span_warning("I don't think that will work!"))
		return ITEM_INTERACT_BLOCKING
	playsound(src, ROGUE_GRIND_SOUND, 100, FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/glass/mortar/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !rogue_to_grind)
		return
	var/obj/item/ground = rogue_to_grind
	ground.forceMove(drop_location())
	if(!user.put_in_hands(ground))
		to_chat(user, span_warning("My hands are full! I drop [ground] on the ground."))
	else
		to_chat(user, span_notice("I remove [ground] from the mortar."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/glass/mortar/blended(obj/item/blended_item, grinded)
	if(blended_item == rogue_to_grind)
		rogue_to_grind = null
	return ..()

/// Ratwood's attackby() with a pestle: the mortar recipe of what is inside gives its ingredients (ores and bars spark); tree sap
/// seeds over blessed water give a druid Dendor's blessed seed powder.
/obj/item/reagent_containers/glass/mortar/proc/rogue_grind(mob/living/user)
	var/obj/item/ground = rogue_to_grind
	if(!ground)
		to_chat(user, span_warning("There's nothing to grind."))
		return
	if(istype(ground, /obj/item/seeds/treesap) && reagents.get_reagent_amount(/datum/reagent/water/blessed) >= ROGUE_SEED_BLESSING_WATER)
		rogue_bless_seeds(user)
		return
	var/datum/alch_grind_recipe/recipe = rogue_grind_recipe(ground)
	if(!recipe)
		to_chat(user, span_warning("I don't think that will work!"))
		return
	user.visible_message(span_info("[user] begins grinding up [ground]."))
	playsound(src, ROGUE_GRIND_SOUND, 100, FALSE)
	if(!do_after(user, ROGUE_GRIND_TIME, target = src) || ground != rogue_to_grind)
		return
	var/turf/here = get_turf(src)
	user.log_message("ground [ground] into [english_list(recipe.valid_outputs, "nothing")] with [src]", LOG_GAME)
	for(var/output in recipe.valid_outputs)
		for(var/i in 1 to recipe.valid_outputs[output])
			new output(here)
	for(var/bonus in recipe.bonus_chance_outputs)
		if(prob(recipe.get_bonus_output_chance(bonus, user, recipe.bonus_chance_outputs[bonus])))
			new bonus(get_turf(user))
	if(istype(ground, /obj/item/rogueore) || istype(ground, /obj/item/ingot))
		do_sparks(1, TRUE, here)
	QDEL_NULL(rogue_to_grind)
	user.rogue_adjust_experience(ROGUE_ALCHEMY_SKILL, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * ROGUE_GRIND_XP_PER_INT)

/obj/item/reagent_containers/glass/mortar/proc/rogue_bless_seeds(mob/living/user)
	if(user.rogue_learned_rank(/datum/attribute/skill/magic/druidic) < ROGUE_RANK_NOVICE)
		to_chat(user, span_warning("I lack the druidic knowledge to draw Dendor's blessing from these seeds."))
		return
	user.visible_message(span_info("[user] grinds [rogue_to_grind] into the blessed water, drawing out Dendor's blessing."))
	playsound(src, ROGUE_GRIND_SOUND, 100, FALSE)
	if(!do_after(user, ROGUE_GRIND_TIME, target = src) || !istype(rogue_to_grind, /obj/item/seeds/treesap))
		return
	reagents.remove_reagent(/datum/reagent/water/blessed, ROGUE_SEED_BLESSING_WATER)
	new /obj/item/alch/blessedseedpowder(get_turf(src))
	QDEL_NULL(rogue_to_grind)
	to_chat(user, span_notice("The seeds absorb Dendor's blessing, forming luminous powder."))
	user.rogue_craft_experience(/datum/attribute/skill/magic/druidic, ROGUE_SEED_BLESSING_XP)
