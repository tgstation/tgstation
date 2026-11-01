// Ratwood's brewing (code/modules/farming/fermentation_keg.dm, bottle_kit.dm, big_liquid_containers.dm,
// code/datums/brewing_recipes/), on the kegs, the copper distiller and the bottling kit the porter brings as data
// (rockhill/ported/structures.dm, items.dm). A keg holds 900 units and is moved by hand. A cook of keg_brew_cooking_rank
// picks a recipe with a right click; its crops and items go in by hand or out of a bag, its water is poured in with a vessel;
// a click starts the brew, which spends all the keg holds and bubbles for the recipe's time. The brew is then bottled with a
// bottling kit, or the keg is tapped (Alt+click, Ratwood's middle click) and vessels are filled from it with the fill intent; a
// fruit wine ages in the keg. A finished brew may be brewed on (cider into brandy, brandy into aqua vitae): a right click picks
// the next recipe. The distiller, fired with coal or logs, brews what needs heat and brews the rest twice as fast. A keg dragged
// onto another pours into it what the other's recipe needs, or all its tapped brew into one without a recipe. The kegs of the
// map come full of water or of a brew. Ratwood's recipe pages and its brewed items (no recipe of it makes one) are not ported.

/// The keg's numbers (config/redtard/mechanics/values/alchemy.txt): who may brew, how long its handling takes, the distiller.
#define ROGUE_KEG_BREW_RANK rogue_value("keg_brew_cooking_rank")
#define ROGUE_KEG_EMPTY_TIME rogue_value("keg_empty_time")
#define ROGUE_KEG_TAP_TIME rogue_value("keg_tap_time")
#define ROGUE_KEG_POUR_TIME rogue_value("keg_pour_time")
#define ROGUE_KEG_DRAG_POUR_TIME rogue_value("keg_drag_pour_time")
#define ROGUE_KEG_REFUEL_TIME rogue_value("keg_refuel_time")
#define ROGUE_KEG_BURN_TIME rogue_value("keg_burn_time")
#define ROGUE_KEG_FUEL_HEAT rogue_value("keg_fuel_heat")
#define ROGUE_KEG_COAL_MULTIPLIER rogue_value("keg_coal_multiplier")
#define ROGUE_KEG_MAX_HEAT rogue_value("keg_max_heat")
#define ROGUE_KEG_ROOM_HEAT rogue_value("keg_room_heat")
#define ROGUE_KEG_HEAT_DECAY rogue_value("keg_heat_decay")
#define ROGUE_KEG_DISTILLER_SPEED rogue_value("keg_distiller_speed")
/// The skill that brews (Ratwood's cooking), and Ratwood's units in an ounce for the keg's examine.
#define ROGUE_KEG_SKILL /datum/attribute/skill/craft/cooking
#define ROGUE_KEG_UNITS_PER_OUNCE 3

/// A recipe of the keg (Ratwood /datum/brewing_recipe), under Ratwood's paths.
/datum/brewing_recipe
	abstract_type = /datum/brewing_recipe
	var/name = "Alcohols"
	var/category = "Other"
	/// What it brews, and the brew the keg must hold, finished, to brew it on (Ratwood pre_reqs).
	var/datum/reagent/reagent_to_brew = /datum/reagent/consumable/ethanol
	var/datum/reagent/pre_reqs
	/// Crops and other things it takes, by exact type and count, and reagents, by type and units.
	var/list/needed_crops = list()
	var/list/needed_items = list()
	var/list/needed_reagents = list()
	/// Only a dwarf may pick it (Ratwood req_species /datum/species/dwarf).
	var/dwarven = FALSE
	/// How long it brews, and what a keg of it sells for.
	var/brew_time = 1 SECONDS
	var/sell_value = 0
	/// Bottles it fills, and the units in each.
	var/brewed_amount = 1
	var/per_brew_amount = 50
	var/helpful_hints
	/// It ages in the keg: what it becomes, by the time it has aged (reagent = deciseconds).
	var/ages = FALSE
	var/list/age_times = list()
	/// The heat in kelvin a distiller must hold for it to brew; a recipe without it brews in any keg.
	var/heat_required
	/// The name and the description of its bottles, and the bottle.
	var/bottle_name = "generic brew"
	var/bottle_desc
	var/obj/item/reagent_containers/glass/bottle/brewing_bottle/output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle

/// The keg: holds water and brews, brews, ages, bottles and pours (Ratwood /obj/structure/fermentation_keg).
/obj/structure/fermentation_keg
	anchored = FALSE
	sellprice = 15
	/// Units it holds.
	var/rogue_volume = 900
	/// Its look while a recipe is set, once a brew is ready, once tapped; none keeps the look it has (the distiller, the pots).
	var/open_icon_state = "barrel_tapless_open"
	var/ready_icon_state = "barrel_tapless_ready"
	var/tapped_icon_state = "barrel_tapped_ready"
	/// Its look at rest (Ratwood initial(icon_state); a pot picks its own at random).
	var/rogue_rest_icon_state
	/// A distiller: fired with coal and logs, it brews what needs heat.
	var/heated = FALSE
	/// The recipe set (Ratwood selected_recipe), the crops and items put in toward it by type, the name of what it brewed.
	var/datum/brewing_recipe/selected_recipe
	var/list/recipe_crop_stocks
	var/made_item
	var/brewing = FALSE
	var/ready_to_bottle = FALSE
	var/tapped = FALSE
	/// Units of the brew left to draw from the tap.
	var/beer_left = 0
	/// When the brew began to age.
	var/age_start_time = 0
	/// Someone is picking a recipe.
	var/selecting_recipe = FALSE
	/// Its heat in kelvin, when its fuel burns out, how long the brew has had its heat and when that was last counted.
	var/heat = 0
	var/heat_decay = 0
	var/heated_progress_time = 0
	var/start_time = 0
	/// What fills it when it is made (Ratwood's kegs of water and of brews), and whether a random share of it.
	var/datum/reagent/rogue_fill_reagent
	var/rogue_fill_random = FALSE
	var/datum/looping_sound/boiling/soundloop
	var/brew_timer

/obj/structure/fermentation_keg/Initialize(mapload)
	. = ..()
	rogue_rest_icon_state = icon_state
	heat = ROGUE_KEG_ROOM_HEAT
	recipe_crop_stocks = list()
	create_reagents(rogue_volume, OPENCONTAINER | NO_REACT | AMOUNT_VISIBLE)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagents_changed))
	soundloop = new(src, FALSE)
	AddElement(/datum/element/rogue_reagent_sight)
	if(rogue_fill_reagent)
		reagents.add_reagent(rogue_fill_reagent, rogue_fill_random ? rand(0, rogue_volume) : rogue_volume)

/obj/structure/fermentation_keg/Destroy()
	STOP_PROCESSING(SSobj, src)
	deltimer(brew_timer)
	QDEL_NULL(soundloop)
	QDEL_NULL(selected_recipe)
	recipe_crop_stocks = null
	return ..()

/obj/structure/fermentation_keg/update_overlays()
	. = ..()
	if(!open_icon_state || icon_state != open_icon_state || !reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance(icon, "filling")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/structure/fermentation_keg/proc/on_reagents_changed(datum/reagents/holder)
	SIGNAL_HANDLER
	update_appearance(UPDATE_OVERLAYS)

/// Takes the look given, if the keg has one of that kind.
/obj/structure/fermentation_keg/proc/rogue_set_look(state)
	if(state)
		icon_state = state
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/fermentation_keg/examine(mob/user)
	. = ..()
	if(heated)
		. += "Internal Temperature of around [round(heat - T0C)]C."
	if(ready_to_bottle)
		. += span_boldnotice("[made_item]")
		if(age_start_time)
			. += "Aged for [round((world.time - age_start_time) / (1 SECONDS))] Seconds."
		if(beer_left)
			. += "[round(beer_left / (selected_recipe.brewed_amount * selected_recipe.per_brew_amount) * 100)]% Full"
		if(!tapped)
			. += span_blue("Alt-click the barrel to tap it. It will lose its sale value.")
		. += span_blue("Use a bottling kit on it to bottle the brew; right-click it to brew it on into something else.")
		return
	if(!selected_recipe)
		. += span_blue("Right-click the barrel to select a recipe.")
		return
	if(brewing)
		. += span_notice("It is brewing [selected_recipe.name].")
		return
	. += span_blue("Right-click the barrel to clear it. Left-click to start brewing. Brewing will remove all existing reagents in the barrel!")
	. += "Currently making: [selected_recipe.name]."
	var/brew_time = selected_recipe.brew_time * ((heated && !selected_recipe.heat_required) ? ROGUE_KEG_DISTILLER_SPEED : 1)
	. += brew_time >= 1 MINUTES ? "Once set, will take [brew_time / (1 MINUTES)] Minutes." : "Once set, will take [brew_time / (1 SECONDS)] Seconds."
	. += "Will produce [selected_recipe.brewed_amount] bottles when finished or [FLOOR(selected_recipe.brewed_amount * selected_recipe.per_brew_amount / ROGUE_KEG_UNITS_PER_OUNCE, 1)] oz."
	if(selected_recipe.helpful_hints)
		. += "[selected_recipe.helpful_hints]."
	var/list/missing = rogue_missing()
	if(length(missing))
		. += span_notice("It still needs [english_list(missing)].")

/// What the recipe still needs, as words.
/obj/structure/fermentation_keg/proc/rogue_missing()
	. = list()
	for(var/list/needed as anything in list(selected_recipe.needed_crops, selected_recipe.needed_items))
		for(var/obj/item/needed_type as anything in needed)
			var/lacking = needed[needed_type] - recipe_crop_stocks[needed_type]
			if(lacking > 0)
				. += "[lacking] [initial(needed_type.name)]"
	for(var/datum/reagent/needed_type as anything in selected_recipe.needed_reagents)
		var/lacking = selected_recipe.needed_reagents[needed_type] - reagents.get_reagent_amount(needed_type)
		if(lacking > 0)
			. += "[CEILING(lacking, 1)] drams of [initial(needed_type.name)]"

/// A click starts the brew (Ratwood attack_hand()); a finished brew waits to be bottled, tapped or brewed on.
/obj/structure/fermentation_keg/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || user.combat_mode)
		return
	if(!selected_recipe)
		to_chat(user, span_warning("No recipe has been set yet!"))
		return TRUE
	if(ready_to_bottle)
		to_chat(user, span_notice("[made_item] is ready: bottle it, tap it, or pick a recipe to brew it on."))
		return TRUE
	if(try_n_brew(user))
		start_brew()
		to_chat(user, span_info("[src] begins brewing [selected_recipe.name]."))
	return TRUE

/// A right click picks a recipe, or empties the keg of a recipe not yet brewed (Ratwood attack_right()).
/obj/structure/fermentation_keg/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !isliving(user))
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_right_click), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fermentation_keg/proc/rogue_right_click(mob/living/user)
	if(!ready_to_bottle && selected_recipe && !brewing)
		user.visible_message(span_notice("[user] starts emptying out [src]."), span_notice("I start emptying out [src]."))
		if(do_after(user, ROGUE_KEG_EMPTY_TIME, target = src))
			clear_keg(TRUE)
		return
	if(!brewing && (!selected_recipe || ready_to_bottle))
		shopping_run(user)

/// Alt+click taps a finished keg (Ratwood MiddleClick(); the middle click is the module's kick).
/obj/structure/fermentation_keg/click_alt(mob/user)
	if(brewing || !ready_to_bottle || tapped || !isliving(user))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(try_tapping), user)
	return CLICK_ACTION_SUCCESS

/// What a tool does to the keg (Ratwood attackby()): a vessel with the fill intent draws from the tap, fuel fires a distiller,
/// a bottling kit bottles the brew, and the crops and items of the recipe go in. Anything else is a vessel's own pouring.
/obj/structure/fermentation_keg/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tapped && rogue_vessel_draws(user, tool))
		INVOKE_ASYNC(src, PROC_REF(try_filling), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(heated && (istype(tool, /obj/item/rogueore/coal) || istype(tool, /obj/item/grown/log/tree)))
		INVOKE_ASYNC(src, PROC_REF(refuel), tool, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/bottle_kit))
		var/obj/item/bottle_kit/kit = tool
		if(bottle(user, kit.glass_colour))
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("There is nothing finished in [src] to bottle."))
		return ITEM_INTERACT_BLOCKING
	if(rogue_stock(user, tool))
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Whether the recipe set takes things of this type.
/obj/structure/fermentation_keg/proc/rogue_needs(item_type)
	return selected_recipe && (LAZYACCESS(selected_recipe.needed_crops, item_type) || LAZYACCESS(selected_recipe.needed_items, item_type))

/// Puts the crop or the item the recipe needs into the keg, or all of them a bag holds; TRUE when the tool was one of them.
/obj/structure/fermentation_keg/proc/rogue_stock(mob/living/user, obj/item/tool)
	if(!selected_recipe || brewing || ready_to_bottle)
		return FALSE
	var/list/produce = list()
	var/from_bag = FALSE
	if(rogue_needs(tool.type))
		produce += tool
	else if(tool.atom_storage)
		for(var/obj/item/stored in tool.contents)
			if(rogue_needs(stored.type))
				produce += stored
		from_bag = TRUE
	if(!length(produce))
		return FALSE
	var/tool_name = "[tool]"
	var/added = 0
	for(var/obj/item/thing as anything in produce)
		var/needed = LAZYACCESS(selected_recipe.needed_crops, thing.type) || LAZYACCESS(selected_recipe.needed_items, thing.type)
		if(recipe_crop_stocks[thing.type] >= needed)
			continue
		recipe_crop_stocks[thing.type] += 1
		qdel(thing)
		added++
	if(!added)
		to_chat(user, span_warning("[src] has enough of that."))
	else if(from_bag)
		user.visible_message(span_notice("[user] dumps some things into [src]."), span_notice("I dump some things into [src]."))
	else
		to_chat(user, span_info("I put [tool_name] in [src]."))
	return TRUE

/// Whether the recipe has all it needs (Ratwood try_n_brew()), saying what it lacks.
/obj/structure/fermentation_keg/proc/try_n_brew(mob/living/user)
	if(brewing)
		to_chat(user, span_notice("This keg is already brewing a mix!"))
		return FALSE
	. = TRUE
	for(var/list/needed as anything in list(selected_recipe.needed_crops, selected_recipe.needed_items))
		for(var/obj/item/needed_type as anything in needed)
			if(recipe_crop_stocks[needed_type] < needed[needed_type])
				to_chat(user, span_notice("This keg needs more [initial(needed_type.name)]!"))
				. = FALSE
	for(var/datum/reagent/needed_type as anything in selected_recipe.needed_reagents)
		if(reagents.get_reagent_amount(needed_type) < selected_recipe.needed_reagents[needed_type])
			to_chat(user, span_notice("This keg needs more [initial(needed_type.name)]!"))
			. = FALSE

/// The brew begins: it spends what the recipe takes and all the keg holds, and bubbles for the recipe's time (a distiller, for
/// what needs heat, as long as its heat holds).
/obj/structure/fermentation_keg/proc/start_brew()
	brewing = TRUE
	for(var/list/needed as anything in list(selected_recipe.needed_crops, selected_recipe.needed_items))
		for(var/needed_type in needed)
			recipe_crop_stocks[needed_type] -= needed[needed_type]
	reagents.clear_reagents()
	soundloop.start()
	start_time = world.time
	heated_progress_time = 0
	if(selected_recipe.heat_required)
		START_PROCESSING(SSobj, src)
	else
		brew_timer = addtimer(CALLBACK(src, PROC_REF(end_brew)), selected_recipe.brew_time * (heated ? ROGUE_KEG_DISTILLER_SPEED : 1), TIMER_STOPPABLE | TIMER_DELETE_ME)
	rogue_set_look(rogue_rest_icon_state)

/// The brew is done: it waits to be bottled or tapped, and ages if it ages.
/obj/structure/fermentation_keg/proc/end_brew()
	brew_timer = null
	soundloop.stop()
	brewing = FALSE
	ready_to_bottle = TRUE
	made_item = selected_recipe.name
	sellprice = selected_recipe.sell_value + initial(sellprice)
	start_time = 0
	heated_progress_time = 0
	if(selected_recipe.ages)
		age_start_time = world.time
	rogue_set_look(heated ? null : ready_icon_state)

/// What the keg pours: the recipe's brew, or what it has aged into.
/obj/structure/fermentation_keg/proc/rogue_brewed_reagent()
	. = selected_recipe.reagent_to_brew
	if(!selected_recipe.ages || !age_start_time)
		return
	var/age = world.time - age_start_time
	for(var/aged_type in selected_recipe.age_times)
		if(age > selected_recipe.age_times[aged_type])
			. = aged_type

/// Picks a recipe (Ratwood shopping_run()): a new one into an empty keg, or one that brews on what the keg has finished. What
/// needs heat is for the distiller, a dwarven brew for dwarves, and only a cook may brew.
/obj/structure/fermentation_keg/proc/shopping_run(mob/living/user)
	if(brewing || selecting_recipe)
		return
	var/list/options = list()
	for(var/datum/brewing_recipe/recipe_type as anything in valid_subtypesof(/datum/brewing_recipe))
		if(!heated && initial(recipe_type.heat_required))
			continue
		if(initial(recipe_type.dwarven) && !(iscarbon(user) && rogue_is_dwarf(user)))
			continue
		if(rogue_can_pick(recipe_type))
			options[initial(recipe_type.name)] = recipe_type
	if(!length(options))
		return
	if(user.rogue_learned_rank(ROGUE_KEG_SKILL) < ROGUE_KEG_BREW_RANK)
		to_chat(user, span_notice("I am not knowledgable enough to brew."))
		return
	selecting_recipe = TRUE
	var/choice = tgui_input_list(user, "What brew do you want to make?", name, sort_list(options))
	selecting_recipe = FALSE
	var/datum/brewing_recipe/recipe_type = options[choice]
	if(!recipe_type || QDELETED(src) || brewing || !user.Adjacent(src) || !rogue_can_pick(recipe_type))
		return
	QDEL_NULL(selected_recipe)
	selected_recipe = new recipe_type
	ready_to_bottle = FALSE
	tapped = FALSE
	beer_left = 0
	age_start_time = 0
	sellprice = initial(sellprice)
	rogue_set_look(open_icon_state)

/// Whether the keg may take this recipe now: a new one, or one brewed on what it has finished.
/obj/structure/fermentation_keg/proc/rogue_can_pick(datum/brewing_recipe/recipe_type)
	var/prereq = initial(recipe_type.pre_reqs)
	if(!ready_to_bottle)
		return !prereq && !selected_recipe
	return prereq && selected_recipe?.reagent_to_brew == prereq

/// Empties the keg (Ratwood clear_keg()); force drops a finished brew and the recipe too.
/obj/structure/fermentation_keg/proc/clear_keg(force = FALSE)
	if(brewing || (!force && ready_to_bottle))
		return FALSE
	reagents.clear_reagents()
	ready_to_bottle = FALSE
	made_item = null
	tapped = FALSE
	beer_left = 0
	age_start_time = 0
	start_time = 0
	sellprice = initial(sellprice)
	recipe_crop_stocks.Cut()
	if(force)
		QDEL_NULL(selected_recipe)
	rogue_set_look(selected_recipe ? open_icon_state : rogue_rest_icon_state)
	return TRUE

/// Bottles the finished brew (Ratwood bottle()): brewed_amount bottles of the kit's colour, or what is left in a tapped keg.
/obj/structure/fermentation_keg/proc/bottle(mob/living/user, glass_colour)
	if(!ready_to_bottle || brewing)
		return FALSE
	var/datum/brewing_recipe/recipe = selected_recipe
	var/datum/reagent/brewed = rogue_brewed_reagent()
	var/units_left = tapped ? beer_left : recipe.brewed_amount * recipe.per_brew_amount
	var/turf/spot = get_turf(src)
	while(units_left > 0)
		var/obj/item/reagent_containers/glass/bottle/brewing_bottle/bottle_made = new recipe.output_bottle_type(spot)
		bottle_made.icon_state = glass_colour || initial(bottle_made.icon_state)
		bottle_made.name = "brewer's bottle of [recipe.bottle_name]"
		bottle_made.desc = recipe.bottle_desc || "A bottle of locally-brewed [recipe.bottle_name]."
		bottle_made.sellprice = round(recipe.sell_value / recipe.brewed_amount)
		bottle_made.reagents.add_reagent(brewed, min(recipe.per_brew_amount, units_left))
		bottle_made.update_appearance()
		units_left -= recipe.per_brew_amount
	clear_keg(TRUE)
	user?.visible_message(span_notice("[user] bottles [src]."), span_notice("I bottle [src]."))
	return TRUE

/obj/structure/fermentation_keg/proc/try_tapping(mob/living/user)
	user.visible_message(span_notice("[user] starts tapping [src]."), span_notice("I start tapping [src]."))
	if(!do_after(user, ROGUE_KEG_TAP_TIME, target = src) || tapped || brewing || !ready_to_bottle)
		return
	tapped = TRUE
	sellprice = 0
	beer_left = selected_recipe.brewed_amount * selected_recipe.per_brew_amount
	rogue_set_look(tapped_icon_state)

/// Fills a vessel from the tap (Ratwood try_filling()); a keg drawn dry is emptied.
/obj/structure/fermentation_keg/proc/try_filling(mob/living/user, obj/item/vessel)
	user.visible_message(span_notice("[user] starts pouring from [src]."), span_notice("I start pouring from [src]."))
	if(!do_after(user, ROGUE_KEG_POUR_TIME, target = src) || !tapped || !selected_recipe || QDELETED(vessel) || !user.is_holding(vessel))
		return
	var/taken = min(vessel.reagents.maximum_volume - vessel.reagents.total_volume, beer_left)
	if(taken <= 0)
		to_chat(user, span_warning("[vessel] is full."))
		return
	beer_left -= taken
	vessel.reagents.add_reagent(rogue_brewed_reagent(), taken)
	if(beer_left <= 0)
		clear_keg(TRUE)

/// Fires a distiller (Ratwood refuel()): a log for keg_burn_time, coal for longer and hotter.
/obj/structure/fermentation_keg/proc/refuel(obj/item/fuel, mob/living/user)
	user.visible_message(span_notice("[user] starts refueling [src]."), span_notice("I start refueling [src]."))
	if(!do_after(user, ROGUE_KEG_REFUEL_TIME, target = src) || QDELETED(fuel))
		return
	var/burn_time = ROGUE_KEG_BURN_TIME
	var/burn_heat = ROGUE_KEG_FUEL_HEAT
	if(istype(fuel, /obj/item/rogueore/coal))
		burn_time *= ROGUE_KEG_COAL_MULTIPLIER
		burn_heat *= ROGUE_KEG_COAL_MULTIPLIER
	heat_decay = world.time + burn_time
	heat = min(ROGUE_KEG_MAX_HEAT, heat + burn_heat)
	qdel(fuel)
	START_PROCESSING(SSobj, src)

/// A distiller's heat (Ratwood process()): what needs heat brews while it is hotter than the recipe asks; spent fuel cools.
/obj/structure/fermentation_keg/process(seconds_per_tick)
	if(brewing && selected_recipe?.heat_required)
		if(heat > selected_recipe.heat_required)
			heated_progress_time += world.time - start_time
		start_time = world.time
		if(heated_progress_time >= selected_recipe.brew_time)
			end_brew()
	if(heat_decay < world.time)
		heat = max(ROGUE_KEG_ROOM_HEAT, heat - ROGUE_KEG_HEAT_DECAY * seconds_per_tick / ROGUE_REAGENT_TICK)
	if(!brewing && heat <= ROGUE_KEG_ROOM_HEAT)
		return PROCESS_KILL

/// A keg dragged onto this one pours (Ratwood MouseDrop_T()).
/obj/structure/fermentation_keg/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	var/obj/structure/fermentation_keg/keg = dropped
	if(!istype(keg) || keg == src || !isliving(user) || !Adjacent(keg))
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_pour_from), keg, user)

/// Into a keg with a recipe goes what the recipe needs (the tapped brew of the other, or its liquids); into one without, all
/// the other's tapped brew.
/obj/structure/fermentation_keg/proc/rogue_pour_from(obj/structure/fermentation_keg/keg, mob/living/user)
	if(!selected_recipe)
		if(!keg.tapped || !keg.selected_recipe)
			return
		if(!rogue_drag_pour(keg, user))
			return
		reagents.add_reagent(keg.rogue_brewed_reagent(), keg.beer_left)
		keg.beer_left = 0
		keg.clear_keg(TRUE)
		return
	if(keg.tapped)
		var/datum/reagent/brewed = keg.selected_recipe?.reagent_to_brew
		var/lacking = LAZYACCESS(selected_recipe.needed_reagents, brewed) - reagents.get_reagent_amount(brewed)
		if(lacking <= 0 || !rogue_drag_pour(keg, user))
			return
		var/poured = min(lacking, keg.beer_left)
		reagents.add_reagent(brewed, poured)
		keg.beer_left -= poured
		if(keg.beer_left <= 0)
			keg.clear_keg(TRUE)
		return
	for(var/datum/reagent/liquid as anything in keg.reagents.reagent_list)
		var/lacking = LAZYACCESS(selected_recipe.needed_reagents, liquid.type) - reagents.get_reagent_amount(liquid.type)
		if(lacking <= 0)
			continue
		if(!rogue_drag_pour(keg, user))
			return
		keg.reagents.trans_to(src, min(lacking, liquid.volume), target_id = liquid.type, transferred_by = user)
		return

/// The wait of pouring one keg into another; FALSE if it was broken off.
/obj/structure/fermentation_keg/proc/rogue_drag_pour(obj/structure/fermentation_keg/keg, mob/living/user)
	user.visible_message(span_notice("[user] starts to pour [keg] into [src]."), span_notice("I start to pour [keg] into [src]."))
	return do_after(user, ROGUE_KEG_DRAG_POUR_TIME, target = keg) && !QDELETED(src) && !QDELETED(keg) && Adjacent(keg)

// The kegs of the map and of crafting (Ratwood big_liquid_containers.dm, roguecrafting/structure.dm, modular_deserttown).

/obj/structure/fermentation_keg/water
	rogue_fill_reagent = /datum/reagent/water

/obj/structure/fermentation_keg/beer
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/beer

/obj/structure/fermentation_keg/random/water
	rogue_fill_reagent = /datum/reagent/water
	rogue_fill_random = TRUE

/obj/structure/fermentation_keg/random/beer
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/beer
	rogue_fill_random = TRUE

/obj/structure/fermentation_keg/gronmead
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/gronnmead

/obj/structure/fermentation_keg/sourwine
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/sourwine

/obj/structure/fermentation_keg/whitewine
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/whitewine

/obj/structure/fermentation_keg/redwine
	rogue_fill_reagent = /datum/reagent/consumable/ethanol/redwine

/obj/structure/fermentation_keg/crafted
	sellprice = 6

/obj/structure/fermentation_keg/distiller
	anchored = TRUE
	heated = TRUE
	open_icon_state = null
	ready_icon_state = null
	tapped_icon_state = null

/// Ratwood's pots of the desert keep their look: its barrel states are not in their sheet.
/obj/structure/fermentation_keg/sandpot
	open_icon_state = null
	ready_icon_state = null
	tapped_icon_state = null

/obj/structure/fermentation_keg/fancypot
	open_icon_state = null
	ready_icon_state = null
	tapped_icon_state = null

/// Ratwood's bottling kit: it sets the colour of the bottles the keg fills.
/obj/item/bottle_kit
	/// The bottle's icon state, and its name in the kit.
	var/glass_colour = "brew_bottle"
	var/fake_glass_name = "Kinda Blue"
	var/static/list/rogue_glass_colours = list(
		"Kinda Blue" = "brew_bottle",
		"Reddish" = "brew_red_bottle",
		"Green-Adjacent" = "brew_green_bottle",
		"Scuffed Platinum" = "brew_white_bottle",
		"Sorta Coal" = "brew_coal_bottle",
		"Maybe Bronze" = "brew_fancy_bottle",
		"Off Amethyst" = "brew_funky_bottle",
		"Odd Sky Shade" = "brew_sky_bottle",
		"Washed-Out Brass" = "brew_saint_po_bottle",
		"Faded Caramel" = "brew_gold_bottle",
		"Approximate Sea Shore" = "brew_pianowoman_bottle",
		"Faded Dust" = "brew_noir_bottle",
		"Close Honeycomb" = "brew_bees_bottle",
	)

/obj/item/bottle_kit/examine(mob/user)
	. = ..()
	. += span_info("The kit is set to [fake_glass_name] bottles.")
	. += span_info("You can change the bottle colour by using the kit. Click on a fermentation keg / distiller that has finished brewing to bottle its results.")

/obj/item/bottle_kit/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/choice = tgui_input_list(user, "What colour do you pick?", name, rogue_glass_colours)
	if(!choice || QDELETED(src))
		return TRUE
	fake_glass_name = choice
	glass_colour = rogue_glass_colours[choice]
	return TRUE

/// Ratwood's brewer's bottle: a corked bottle the keg fills in the kit's colour. Sealed, it sells; once uncorked it does not.
/obj/item/reagent_containers/glass/bottle/brewing_bottle
	name = "brewer's bottle"
	desc = "A bottle with a cork."
	icon = 'modular_redtard/survival/icons/bottle.dmi'
	icon_state = "brew_bottle"
	/// Sealed as the keg filled it.
	var/sealed = TRUE

/obj/item/reagent_containers/glass/bottle/brewing_bottle/toggle_cork(mob/user)
	. = ..()
	if(!corked && sealed)
		sealed = FALSE
		sellprice = 0

/obj/item/reagent_containers/glass/bottle/brewing_bottle/examine(mob/user)
	. = ..()
	. += span_notice(sealed ? "The bottle is sealed. It can sell for something." : "The bottle has been unsealed. It cannot be sold anymore.")

/obj/item/reagent_containers/glass/bottle/brewing_bottle/update_overlays()
	. = ..()
	if(corked)
		. += mutable_appearance(icon, "[icon_state]cork")

// Ratwood's bottles of each brew, by which its trade told the brews apart.
/obj/item/reagent_containers/glass/bottle/brewing_bottle/mead
/obj/item/reagent_containers/glass/bottle/brewing_bottle/spidermead
/obj/item/reagent_containers/glass/bottle/brewing_bottle/jack_wine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/plum_wine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/tangerine_wine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/blackberry_wine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/raspberry_wine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/whipwine
/obj/item/reagent_containers/glass/bottle/brewing_bottle/luxintenebre
/obj/item/reagent_containers/glass/bottle/brewing_bottle/voddena
/obj/item/reagent_containers/glass/bottle/brewing_bottle/beer
/obj/item/reagent_containers/glass/bottle/brewing_bottle/beer_oat
/obj/item/reagent_containers/glass/bottle/brewing_bottle/cider
/obj/item/reagent_containers/glass/bottle/brewing_bottle/gin
/obj/item/reagent_containers/glass/bottle/brewing_bottle/ricespirit
/obj/item/reagent_containers/glass/bottle/brewing_bottle/limoncello
/obj/item/reagent_containers/glass/bottle/brewing_bottle/rum
/obj/item/reagent_containers/glass/bottle/brewing_bottle/aqua_vitae
/obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy
/obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy_plum
/obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy_pear
/obj/item/reagent_containers/glass/bottle/brewing_bottle/valerian_tea
/obj/item/reagent_containers/glass/bottle/brewing_bottle/calendula_tea

// The keg's brews that are not alcohol (Ratwood food_reagents.dm, modular/Neu_Food/code/drinks/drinks_reagents.dm).

/// Sugar boiled down in the keg, which the distiller makes rum of. TG's synthesis and random spawns of sugar are not its.
/datum/reagent/consumable/sugar/molasses
	name = "Molasses"
	color = "#835c5c"
	chemical_flags = NONE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM

/// A tea of the distiller (Ratwood's from Vanderlin): it gives energy, blood and mends wounds, and while there is a unit of it
/// heals the flesh, the breath and the brain.
/datum/reagent/consumable/golden_calendula_tea
	name = "Golden Calendula Tea"
	description = "A refreshing tea, great to soothe wounds and relieve fatigue."
	color = "#b38e17AD"
	taste_description = "herbal flavor"
	quality = DRINK_VERYGOOD
	nutriment_factor = 1 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	/// Per Ratwood tick: energy, blood below normal, wound health; and brute and burns, oxygen and the brain healed.
	var/rogue_energy = 5
	var/rogue_blood = 5
	var/rogue_wound_heal = 1
	var/rogue_heal = 0.75 * ROGUE_REAGENT_EFFECT
	var/rogue_oxy_heal = 0.25
	var/rogue_brain_heal = 1 * ROGUE_REAGENT_EFFECT

/datum/reagent/consumable/golden_calendula_tea/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(rogue_reagent_restore(affected_mob, seconds_per_tick, blood = rogue_blood, energy = rogue_energy, wounds = rogue_wound_heal))
		. = UPDATE_MOB_HEALTH
	if(volume < ROGUE_POTION_MIN_VOLUME)
		return
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	if(affected_mob.adjust_brute_loss(-rogue_heal * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH
	if(affected_mob.adjust_fire_loss(-rogue_heal * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH
	if(affected_mob.adjust_oxy_loss(-rogue_oxy_heal * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH
	affected_mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, -rogue_brain_heal * ticks)

/// A tea of the distiller (Ratwood's from Vanderlin): it eases fatigue.
/datum/reagent/consumable/soothing_valerian_tea
	name = "Soothing Valerian Tea"
	description = "A refreshing tea, great to ease fatigue and relieve stress."
	color = "#3b9146AD"
	taste_description = "herbal flavor"
	quality = DRINK_FANTASTIC
	nutriment_factor = 1 * ROGUE_REAGENT_NUTRITION
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	/// Energy per Ratwood tick.
	var/rogue_energy = 3

/datum/reagent/consumable/soothing_valerian_tea/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	rogue_reagent_restore(affected_mob, seconds_per_tick, energy = rogue_energy)

// Ratwood's recipes of the keg (code/datums/brewing_recipes/), under its paths.

/datum/brewing_recipe/aqua_vitae
	name = "Aqua Vitae - Apple"
	category = "Aqua Vitae"
	bottle_name = "aqua vitae"
	bottle_desc = "A bottle of locally-distilled aqua vitae, distilled twice from cider then brandy, suitable for medicinal purposes. Not advised for drinking."
	brewed_amount = 2
	brew_time = 4 MINUTES
	sell_value = 120
	reagent_to_brew = /datum/reagent/consumable/ethanol/aqua_vitae
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/aqua_vitae
	pre_reqs = /datum/reagent/consumable/ethanol/brandy

/// Ratwood names it "Plum" too.
/datum/brewing_recipe/aqua_vitae/pear
	name = "Aqua Vitae - Pear"
	pre_reqs = /datum/reagent/consumable/ethanol/brandy/pear

/datum/brewing_recipe/aqua_vitae/strawberry
	name = "Aqua Vitae - Strawberry"
	pre_reqs = /datum/reagent/consumable/ethanol/brandy/strawberry

/datum/brewing_recipe/aqua_vitae/tangerine
	name = "Aqua Vitae - Tangerine"
	pre_reqs = /datum/reagent/consumable/ethanol/brandy/tangerine

/datum/brewing_recipe/aqua_vitae/plum
	name = "Aqua Vitae - Plum"
	pre_reqs = /datum/reagent/consumable/ethanol/brandy/plum

/datum/brewing_recipe/brandy
	name = "Brandy, Apple"
	category = "Liquor"
	bottle_name = "apple brandy"
	bottle_desc = "A bottle of locally-distilled apple brandy. Has a slight caramel flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/brandy
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy
	pre_reqs = /datum/reagent/consumable/ethanol/cider
	brewed_amount = 6
	brew_time = 4 MINUTES
	sell_value = 90
	heat_required = 360

/datum/brewing_recipe/brandy/pear
	name = "Brandy, Pear"
	bottle_name = "pear brandy"
	bottle_desc = "A bottle of locally-distilled pear brandy. Tastes of ripe pear, and a hint of spice."
	pre_reqs = /datum/reagent/consumable/ethanol/cider/pear
	reagent_to_brew = /datum/reagent/consumable/ethanol/brandy/pear
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy_pear

/datum/brewing_recipe/brandy/strawberry
	name = "Brandy, Strawberry"
	bottle_name = "strawberry brandy"
	bottle_desc = "A bottle of locally-distilled strawberry berry. Tastes of overwhelming sweetness with a smooth finish."
	pre_reqs = /datum/reagent/consumable/ethanol/cider/strawberry
	reagent_to_brew = /datum/reagent/consumable/ethanol/brandy/strawberry
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle

/datum/brewing_recipe/brandy/tangerine
	name = "Brandy, Tangerine"
	bottle_name = "tangerine brandy"
	bottle_desc = "A bottle of locally-distilled tangerine brandy. Has a light, citrusty flavor with a hint of spice."
	pre_reqs = /datum/reagent/consumable/ethanol/tangerine
	reagent_to_brew = /datum/reagent/consumable/ethanol/brandy/tangerine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle

/datum/brewing_recipe/brandy/plum
	name = "Brandy, Plum"
	bottle_name = "plum brandy"
	bottle_desc = "A bottle of locally-distilled plum brandy. Has a sweet, vanilla flavor."
	pre_reqs = /datum/reagent/consumable/ethanol/plum_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/brandy/plum
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/brandy_plum

/datum/brewing_recipe/cabbage
	name = "Fireleaf"
	category = "Other"
	bottle_name = "fireleaf"
	bottle_desc = "A bottle of locally-brewed fireleaf. Brewed from cabbage, it tastes absolutely awful."
	reagent_to_brew = /datum/reagent/consumable/ethanol/fireleaf
	needed_reagents = list(/datum/reagent/water = 198)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/cabbage/rogue = 6)
	brewed_amount = 6
	brew_time = 1 MINUTES
	sell_value = 30

/datum/brewing_recipe/cider
	name = "Cider, Apple"
	category = "Fruit"
	bottle_name = "apple cider"
	bottle_desc = "A bottle of locally-brewed apple cider. Has a sweet, crispy apple flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/cider
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/cider
	needed_reagents = list(/datum/reagent/water = 198)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/apple = 6)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50

/datum/brewing_recipe/cider/pear
	name = "Cider, Pear"
	bottle_name = "pear cider"
	bottle_desc = "A bottle of locally-brewed pear cider. Has a sweet, subtle pear flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/cider/pear
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/fruit/pear = 6)

/datum/brewing_recipe/cider/strawberry
	name = "Cider, Strawberry"
	bottle_name = "strawberry cider"
	bottle_desc = "A bottle of locally-brewed strawberry cider. Has a sweet, subtle strawberry flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/cider/strawberry
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/fruit/strawberry = 6)

/datum/brewing_recipe/butterhairs
	name = "Butterhairs"
	category = "Grain"
	bottle_name = "butterhairs"
	bottle_desc = "A bottle of dwarven butterhairs brew. Rich and smooth with a buttery warmth."
	reagent_to_brew = /datum/reagent/consumable/ethanol/butterhairs
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/butter = 1, /obj/item/reagent_containers/food/snacks/grown/wheat = 2, /obj/item/reagent_containers/food/snacks/grown/oat = 3)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 60
	dwarven = TRUE

/datum/brewing_recipe/stonebeards
	name = "Stonebeard Reserve"
	category = "Grain"
	bottle_name = "stonebeard reserve"
	bottle_desc = "A bottle of dwarven stonebeard reserve. A potent oatlike liquor of dwarven craft."
	reagent_to_brew = /datum/reagent/consumable/ethanol/stonebeards
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced = 4, /obj/item/reagent_containers/food/snacks/grown/wheat = 2, /obj/item/reagent_containers/food/snacks/grown/oat = 3)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 80
	dwarven = TRUE

/datum/brewing_recipe/beer
	name = "Wheat Beer"
	category = "Grain"
	bottle_name = "wheat beer"
	bottle_desc = "A bottle of locally-brewed wheat beer. Has a light flavor. Staple of the west."
	reagent_to_brew = /datum/reagent/consumable/ethanol/beer
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/beer
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/wheat = 6)
	brewed_amount = 6
	brew_time = 2 MINUTES
	sell_value = 30

/datum/brewing_recipe/beer/oat
	name = "Oat Ale"
	bottle_name = "oat ale"
	bottle_desc = "A bottle of locally-brewed oat ale. Has a rich, hearty flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/ale
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/beer_oat
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/oat = 6)

/datum/brewing_recipe/beer/rice
	name = "Rice Wine"
	bottle_name = "rice wine"
	bottle_desc = "A bottle of locally-brewed rice wine. Has a sweet, umami flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/ricewine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/rice = 6)

/datum/brewing_recipe/limoncello
	name = "Limoncello"
	category = "Liquor"
	bottle_name = "limoncello"
	bottle_desc = "A bottle of locally-distilled limoncello. Has a sweet, citrusy and burning flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/limoncello
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/limoncello
	pre_reqs = /datum/reagent/consumable/ethanol/voddena
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/fruit/lemon = 2, /obj/item/reagent_containers/food/snacks/sugar = 1)
	brewed_amount = 4
	brew_time = 4 MINUTES
	sell_value = 90
	heat_required = 360

/datum/brewing_recipe/liquor
	name = "Gin"
	category = "Liquor"
	bottle_name = "gin"
	bottle_desc = "A bottle of locally-distilled gin. Has a strong, piney flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/gin
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/gin
	pre_reqs = /datum/reagent/consumable/ethanol/voddena
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 2)
	brewed_amount = 4
	brew_time = 5 MINUTES
	sell_value = 100
	heat_required = 370

/datum/brewing_recipe/liquor/ricespirit
	name = "Rice Spirit"
	bottle_name = "rice spirit"
	bottle_desc = "A bottle of locally-distilled rice spirit. Has a clean flavor and a dry finish."
	reagent_to_brew = /datum/reagent/consumable/ethanol/ricespirit
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/ricespirit
	pre_reqs = /datum/reagent/consumable/ethanol/ricewine
	needed_items = null
	brewed_amount = 4
	sell_value = 90

/datum/brewing_recipe/spidermead
	name = "Spider Honey Mead"
	category = "Other"
	bottle_name = "spider honey mead"
	bottle_desc = "A bottle of locally-brewed spider honey mead. Taste the same as normal mead with a sweet flavor, but considered better and more refined."
	reagent_to_brew = /datum/reagent/consumable/ethanol/mead/spider
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/spidermead
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/rogue/honey/spider = 6)
	brewed_amount = 6
	brew_time = 3 MINUTES
	sell_value = 75

/datum/brewing_recipe/mead
	name = "Mead"
	category = "Other"
	bottle_name = "mead"
	bottle_desc = "A bottle of locally-brewed mead. Has a sweet, honey-like flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/mead
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/mead
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/rogue/honey = 6)
	brewed_amount = 6
	brew_time = 3 MINUTES
	sell_value = 50

/datum/brewing_recipe/onion
	name = "Onion Cognac"
	category = "Other"
	bottle_name = "onion cognac"
	bottle_desc = "A bottle of locally-brewed onion cognac. Weak, with a strong spicy, sweet and malty overtone."
	reagent_to_brew = /datum/reagent/consumable/ethanol/onion
	needed_reagents = list(/datum/reagent/water = 198)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/onion/rogue = 6)
	brewed_amount = 6
	brew_time = 3 MINUTES
	sell_value = 45

/datum/brewing_recipe/molasses
	name = "Molasses"
	category = "Other"
	bottle_name = "molasses"
	bottle_desc = "A bottle of molasses. A thick, dark syrup made from sugar."
	reagent_to_brew = /datum/reagent/consumable/sugar/molasses
	needed_items = list(/obj/item/reagent_containers/food/snacks/sugar = 6)
	brewed_amount = 6
	brew_time = 3 MINUTES
	sell_value = 30

/datum/brewing_recipe/rum
	name = "Rum"
	category = "Liquor"
	bottle_name = "rum"
	bottle_desc = "A bottle of locally-distilled rum. Has a sweet flavor with a hints of caramel and vanilla."
	reagent_to_brew = /datum/reagent/consumable/ethanol/rum
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/rum
	pre_reqs = /datum/reagent/consumable/sugar/molasses
	brewed_amount = 4
	brew_time = 4 MINUTES
	sell_value = 90
	heat_required = 380

/datum/brewing_recipe/golden_calendula_tea
	name = "Golden Calendula Tea"
	category = "Tea"
	bottle_name = "golden calendula tea"
	bottle_desc = "A bottle of locally-brewed golden calendula tea. Has a herbal flavor."
	reagent_to_brew = /datum/reagent/consumable/golden_calendula_tea
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/calendula_tea
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/alch/calendula = 1, /obj/item/alch/mentha = 1, /obj/item/reagent_containers/food/snacks/rogue/honey = 1)
	brewed_amount = 6
	brew_time = 4 MINUTES
	sell_value = 60
	heat_required = 320

/datum/brewing_recipe/soothing_valerian_tea
	name = "Soothing Valerian Tea"
	category = "Tea"
	bottle_name = "soothing valerian tea"
	bottle_desc = "A bottle of locally-brewed soothing valerian tea. Has a herbal flavor."
	reagent_to_brew = /datum/reagent/consumable/soothing_valerian_tea
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/valerian_tea
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/alch/valeriana = 1, /obj/item/alch/hypericum = 1, /obj/item/reagent_containers/food/snacks/rogue/honey = 1)
	brewed_amount = 6
	brew_time = 4 MINUTES
	sell_value = 60
	heat_required = 310

/datum/brewing_recipe/voddena
	name = "Voddena"
	category = "Grain"
	bottle_name = "voddena"
	bottle_desc = "A bottle of locally-brewed voddena. Brewed from potatoes. It has a clean flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/voddena
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/voddena
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced = 12)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 60

/datum/brewing_recipe/jack_wine
	name = "Wine, Jackberry"
	category = "Fruit"
	bottle_name = "jackberry wine"
	bottle_desc = "A bottle of locally-brewed jackberry wine. Has a sweet, fruity flavor with a hint of tartness."
	reagent_to_brew = /datum/reagent/consumable/ethanol/jackberrywine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/jack_wine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 6)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50
	ages = TRUE
	age_times = list(
		/datum/reagent/consumable/ethanol/jackberrywine/aged = 10 MINUTES,
		/datum/reagent/consumable/ethanol/jackberrywine/delectable = 20 MINUTES,
	)

/datum/brewing_recipe/plum_wine
	name = "Wine, Umeshu (Plum)"
	category = "Fruit"
	bottle_name = "umeshu wine"
	bottle_desc = "A bottle of locally-brewed plum wine. Has a sweet, slightly sour flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/plum_wine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/plum_wine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/fruit/plum = 4, /obj/item/reagent_containers/food/snacks/sugar = 2)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50
	ages = TRUE
	age_times = list(
		/datum/reagent/consumable/ethanol/plum_wine/aged = 10 MINUTES,
		/datum/reagent/consumable/ethanol/plum_wine/delectable = 20 MINUTES,
	)

/datum/brewing_recipe/tangerine_wine
	name = "Wine, Tangerine"
	category = "Fruit"
	bottle_name = "tangerine wine"
	bottle_desc = "A bottle of locally-brewed tangerine wine. Has a bittersweet, citrusy flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/tangerine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/tangerine_wine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine = 4, /obj/item/reagent_containers/food/snacks/sugar = 2)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50
	ages = TRUE
	age_times = list(
		/datum/reagent/consumable/ethanol/tangerine/aged = 10 MINUTES,
		/datum/reagent/consumable/ethanol/tangerine/delectable = 20 MINUTES,
	)

/datum/brewing_recipe/raspberry_wine
	name = "Wine, Raspberry"
	category = "Fruit"
	bottle_name = "raspberry wine"
	bottle_desc = "A bottle of locally-brewed raspberry wine. Has a sweet, tart flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/raspberry
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/raspberry_wine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/fruit/raspberry = 4, /obj/item/reagent_containers/food/snacks/sugar = 2)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50
	ages = TRUE
	age_times = list(
		/datum/reagent/consumable/ethanol/raspberry/aged = 10 MINUTES,
		/datum/reagent/consumable/ethanol/raspberry/delectable = 20 MINUTES,
	)

/datum/brewing_recipe/blackberry_wine
	name = "Wine, Blackberry"
	category = "Fruit"
	bottle_name = "blackberry wine"
	bottle_desc = "A bottle of locally-brewed blackberry wine. Has a bitter, tart flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/blackberry
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/blackberry_wine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry = 4, /obj/item/reagent_containers/food/snacks/sugar = 2)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 50
	ages = TRUE
	age_times = list(
		/datum/reagent/consumable/ethanol/blackberry/aged = 10 MINUTES,
		/datum/reagent/consumable/ethanol/blackberry/delectable = 20 MINUTES,
	)

/// Poisonous herbs, sugar, and an actual whip.
/datum/brewing_recipe/whipwine
	name = "Wine, Whip"
	category = "Other"
	bottle_name = "vale whip-wine"
	bottle_desc = "A bottle of locally-brewed Whipwine. Said to be based off a Kazengun recipe. It has a particularly... leathery flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/whipwine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/whipwine
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(
		/obj/item/alch/atropa = 1,
		/obj/item/reagent_containers/food/snacks/sugar = 1,
		/obj/item/alch/matricaria = 1,
		/obj/item/alch/paris = 1,
		/obj/item/rogueweapon/whip = 1,
	)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 30

/// A single lux, sugar and a healing herb; heretical, and worth much in the black market.
/datum/brewing_recipe/luxintenebre
	name = "Wine, Lux"
	category = "Other"
	bottle_name = "luxintebere"
	bottle_desc = "A potentially heretickal brew, Lux, when fermented, breaks down into Vitae, which can further ferment into a delectable wine."
	reagent_to_brew = /datum/reagent/consumable/ethanol/luxwine
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/luxintenebre
	needed_reagents = list(/datum/reagent/water = 198)
	needed_items = list(
		/obj/item/reagent_containers/lux_impure = 1,
		/obj/item/reagent_containers/food/snacks/sugar = 2,
		/obj/item/alch/calendula = 1,
	)
	brewed_amount = 2
	brew_time = 5 MINUTES
	sell_value = 120

#undef ROGUE_KEG_BREW_RANK
#undef ROGUE_KEG_EMPTY_TIME
#undef ROGUE_KEG_TAP_TIME
#undef ROGUE_KEG_POUR_TIME
#undef ROGUE_KEG_DRAG_POUR_TIME
#undef ROGUE_KEG_REFUEL_TIME
#undef ROGUE_KEG_BURN_TIME
#undef ROGUE_KEG_FUEL_HEAT
#undef ROGUE_KEG_COAL_MULTIPLIER
#undef ROGUE_KEG_MAX_HEAT
#undef ROGUE_KEG_ROOM_HEAT
#undef ROGUE_KEG_HEAT_DECAY
#undef ROGUE_KEG_DISTILLER_SPEED
#undef ROGUE_KEG_SKILL
#undef ROGUE_KEG_UNITS_PER_OUNCE
