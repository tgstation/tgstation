///Juice item, converting nutriments into juice_typepath and transfering to target_holder if specified
/obj/item/proc/juice(datum/reagents/target_holder, mob/user)
	if(on_juice() == -1 || !reagents?.total_volume)
		return FALSE

	for(var/datum/reagent/juice_typepath as anything in juice_results)
		if(ispath(juice_typepath))
			reagents.convert_reagent(/datum/reagent/consumable, juice_typepath, include_source_subtypes = TRUE)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)

	return TRUE

///Grind item, adding grind_results to item's reagents and transfering to target_holder if specified
/obj/item/proc/grind(datum/reagents/target_holder, mob/user)
	. = FALSE
	if(on_grind() == -1)
		return

	if(length(grind_results))
		target_holder.add_reagent_list(grind_results)
		. = TRUE
	if(reagents?.total_volume)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
		. = TRUE

/datum/reagents/proc/convert_reagent(
	datum/reagent/source_reagent_typepath,
	datum/reagent/target_reagent_typepath,
	multiplier = 1,
	include_source_subtypes = FALSE
)
	if(!ispath(source_reagent_typepath))
		stack_trace("invalid reagent path passed to convert reagent [source_reagent_typepath]")
		return FALSE

	var/reagent_amount
	var/reagent_purity
	var/reagent_ph
	if(include_source_subtypes)
		reagent_ph = ph
		var/weighted_purity
		var/list/reagent_type_list = typecacheof(source_reagent_typepath)
		for(var/datum/reagent/reagent as anything in reagent_list)
			if(reagent.type in reagent_type_list)
				weighted_purity += reagent.volume * reagent.purity
				reagent_amount += reagent.volume
				remove_reagent(reagent.type, reagent.volume * multiplier)
		reagent_purity = weighted_purity / reagent_amount
	else
		var/datum/reagent/source_reagent = has_reagent(source_reagent_typepath)
		reagent_amount = source_reagent.volume
		reagent_purity = source_reagent.purity
		reagent_ph = source_reagent.ph
		remove_reagent(source_reagent_typepath, reagent_amount)
	add_reagent(target_reagent_typepath, reagent_amount * multiplier, reagtemp = chem_temp, added_purity = reagent_purity, added_ph = reagent_ph)


/obj/item/stack/sheet/mineral/stone
	name = "stone"
	desc = "Stone brick."
	singular_name = "stone block"
	icon = 'monkestation/code/modules/blueshift/icons/ore.dmi'
	icon_state = "sheet-stone"
	inhand_icon_state = "sheet-metal"
	mats_per_unit = list(/datum/material/stone=SHEET_MATERIAL_AMOUNT)
	force = 10
	throwforce = 15
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/mineral/stone
	grind_results = null
	material_type = /datum/material/stone
	matter_amount = 0
	source = null
	walltype = /turf/closed/wall/mineral/stone
	stairs_type = /obj/structure/stairs/stone

GLOBAL_LIST_INIT(stone_recipes, list ( \
	new/datum/stack_recipe("stone brick wall", /turf/closed/wall/mineral/stone, 5, one_per_turf = 1, on_solid_ground = 1, applies_mats = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("stone brick tile", /obj/item/stack/tile/mineral/stone, 1, 4, 20, check_density = FALSE, category = CAT_TILES),
	new/datum/stack_recipe("millstone", /obj/structure/millstone, 6, one_per_turf = 1, on_solid_ground = 1, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone cauldron", /obj/machinery/cauldron, 5, one_per_turf = 1, on_solid_ground = 1, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone stove", /obj/machinery/primitive_stove, 5, one_per_turf = 1, on_solid_ground = 1, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone oven", /obj/machinery/oven/stone, 5, one_per_turf = 1, on_solid_ground = 1, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone griddle", /obj/machinery/griddle/stone, 5, one_per_turf = 1, on_solid_ground = 1, category = CAT_STRUCTURE),
	))

/obj/item/stack/sheet/mineral/stone/get_main_recipes()
	. = ..()
	. += GLOB.stone_recipes

/datum/material/stone
	name = "stone"
	desc = "It's stone."
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/stone
	value_per_unit = 0.005
	beauty_modifier = 0.01
	color = "#59595a"
	greyscale_colors = "#59595a"
	value_per_unit = 0.0025
	armor_modifiers = list(MELEE = 0.75, BULLET = 0.5, LASER = 1.25, ENERGY = 0.5, BOMB = 0.5, BIO = 0.25, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_PLATING

/obj/item/stack/stone
	name = "rough stone"
	desc = "Large chunks of uncut stone, tough enough to safely build out of... if you could manage to cut them into something usable."
	icon = 'monkestation/code/modules/blueshift/icons/ore.dmi'
	icon_state = "stone_ore"
	singular_name = "rough stone boulder"
	mats_per_unit = list(/datum/material/stone = SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/stone
	force = 10
	throwforce = 15

/obj/item/stack/stone/examine()
	. = ..()
	. += span_notice("With a <b>chisel</b> or even a <b>pickaxe</b> of some kind, you could cut this into <b>blocks</b>.")

/obj/item/stack/stone/attackby(obj/item/attacking_item, mob/user, params)
	if((attacking_item.tool_behaviour != TOOL_MINING) && !(istype(attacking_item, /obj/item/chisel)))
		return ..()
	playsound(src, 'sound/effects/picaxe1.ogg', 50, TRUE)
	balloon_alert_to_viewers("cutting...")
	if(!do_after(user, 5 SECONDS, target = src))
		balloon_alert_to_viewers("stopped cutting")
		return FALSE
	new /obj/item/stack/sheet/mineral/stone(get_turf(src), amount)
	qdel(src)

/obj/item/stack/tile/mineral/stone
	name = "stone tile"
	singular_name = "stone floor tile"
	desc = "A tile made of stone bricks, for that fortress look."
	icon_state = "tile_herringbone"
	inhand_icon_state = "tile"
	turf_type = /turf/open/floor/stone
	mineralType = "stone"
	mats_per_unit = list(/datum/material/stone= HALF_SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/tile/mineral/stone

/turf/open/floor/stone
	desc = "Blocks of stone arranged in a tile-like pattern, odd, really, how it looks like real stone too, because it is!" //A play on the original description for stone tiles
	slowdown = -0.3

/turf/closed/wall/mineral/stone
	name = "stone wall"
	desc = "A wall made of solid stone bricks."
	icon = 'monkestation/code/modules/blueshift/icons/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/stone
	explosive_resistance = 2 // Rock and stone to the bone, or at least a bit longer than walls made of metal sheets!
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS
	custom_materials = list(
		/datum/material/stone = SHEET_MATERIAL_AMOUNT  * 2,
	)

/turf/closed/wall/mineral/stone/try_decon(obj/item/item_used, mob/user) // Lets you break down stone walls with stone breaking tools
	if(item_used.tool_behaviour != TOOL_MINING)
		return ..()

	if(!item_used.tool_start_check(user, amount = 0))
		return FALSE

	balloon_alert_to_viewers("breaking down...")

	if(!item_used.use_tool(src, user, 5 SECONDS))
		return FALSE
	dismantle_wall()
	return TRUE

/turf/closed/indestructible/stone
	name = "stone wall"
	desc = "A wall made of unusually solid stone bricks."
	icon = 'monkestation/code/modules/blueshift/icons/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS
	custom_materials = list(
		/datum/material/stone = SHEET_MATERIAL_AMOUNT  * 2,
	)

/obj/structure/falsewall/stone
	name = "stone wall"
	desc = "A wall made of solid stone bricks."
	icon = 'monkestation/code/modules/blueshift/icons/wall.dmi'
	icon_state = "wall-open"
	base_icon_state = "wall"
	mineral = /obj/item/stack/sheet/mineral/stone
	walltype = /turf/closed/wall/mineral/stone
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS

/turf/closed/mineral/gets_drilled(mob/user, give_exp = FALSE)
	if(prob(5))
		new /obj/item/stack/stone(src)

	return ..()


#define GET_RECIPE(input_thing) LAZYACCESS(processor_inputs[/obj/machinery/processor], input_thing.type)

/obj/item/cutting_board
	name = "cutting board"
	desc = "Processing food before electricity was cool, because you can just do your regular cutting on the table next to this right?"
	icon = 'monkestation/code/modules/blueshift/icons/cooking_structures.dmi'
	icon_state = "cutting_board"
	force = 5
	throwforce = 7 //Imagine someone just throws the entire fucking cutting board at you
	w_class = WEIGHT_CLASS_NORMAL
	pass_flags = PASSTABLE
	layer = BELOW_OBJ_LAYER //So newly spawned food appears on top of the board rather than under it
	resistance_flags = FLAMMABLE
	///List containg list of possible inputs and resulting recipe items, taken from processor.dm and processor_recipes.dm
	var/static/list/processor_inputs

/obj/item/cutting_board/Initialize(mapload)
	. = ..()
	if(processor_inputs)
		return

	processor_inputs = list()
	for(var/datum/food_processor_process/recipe as anything in subtypesof(/datum/food_processor_process)) //this is how tg food processors do it just in case this is digusting
		if(!initial(recipe.input))
			continue

		recipe = new recipe
		var/list/typecache = list()
		var/list/bad_types

		for(var/bad_type in recipe.blacklist)
			LAZYADD(bad_types, typesof(bad_type))

		for(var/input_type in typesof(recipe.input) - bad_types)
			typecache[input_type] = recipe

		for(var/machine_type in typesof(recipe.required_machine))
			LAZYADD(processor_inputs[machine_type], typecache)

/obj/item/cutting_board/update_appearance()
	. = ..()
	cut_overlays()
	if(!length(contents))
		return
	var/image/overlayed_item = image(icon = contents[1].icon, icon_state = contents[1].icon_state, pixel_y = 2)
	add_overlay(overlayed_item)

/obj/item/cutting_board/examine(mob/user)
	. = ..()
	. += span_notice("You can process food similar to a food processor by putting food on this and using a <b>knife</b> on it.")
	. += span_notice("It can be (un)secured with <b>Right Click</b>")
	. += span_notice("You can make it drop its item with <b>Alt Click</b>")
	if(length(contents))
		. += span_notice("It has [contents[1]] sitting on it.")

/obj/item/cutting_board/Destroy()
	drop_everything_contained()
	return ..()

/obj/item/cutting_board/AltClick(mob/user)
	if(!length(contents))
		balloon_alert(user, "nothing on board")
		return

	drop_everything_contained()
	balloon_alert(user, "cleared board")
	return

///Drops all contents at the turf of the item
/obj/item/cutting_board/proc/drop_everything_contained()
	if(!length(contents))
		return

	for(var/obj/target_item as anything in contents)
		target_item.forceMove(get_turf(src))

/obj/item/cutting_board/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src))
		return

	set_anchored(!anchored)
	balloon_alert_to_viewers(anchored ? "secured" : "unsecured")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///Takes the given obj (processed thing) and gets its results from the recipe list, spawning the results and deleting the original obj
/obj/item/cutting_board/proc/process_food(datum/food_processor_process/recipe, obj/processed_thing)
	if(!recipe.output || !loc || QDELETED(src))
		return

	var/food_multiplier = recipe.food_multiplier
	for(var/i in 1 to food_multiplier)
		var/obj/new_food_item = new recipe.output(drop_location())
		new_food_item.pixel_x = rand(-6, 6)
		new_food_item.pixel_y = rand(-6, 6)

		if(!processed_thing.reagents) //backup in case we really fuck up
			continue

		processed_thing.reagents.copy_to(new_food_item, processed_thing.reagents.total_volume, multiplier = 1 / food_multiplier)

	qdel(processed_thing)
	update_appearance()

/obj/item/cutting_board/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.istate & ISTATE_HARM)
		return ..()

	if(attacking_item.tool_behaviour == TOOL_KNIFE)
		if(!length(contents))
			balloon_alert(user, "nothing to process")
			return

		var/datum/food_processor_process/item_process_recipe = GET_RECIPE(contents[1])
		if(!item_process_recipe)
			log_admin("DEBUG: [src] (cutting board item) just tried to process [contents[1]] but wasn't able to get a recipe somehow, this should not be able to happen.")
			return

		playsound(src, 'sound/effects/butcher.ogg', 50, TRUE)
		balloon_alert_to_viewers("cutting...")
		if(!do_after(user, 3 SECONDS, target = src))
			balloon_alert_to_viewers("stopped cutting")
			return

		process_food(item_process_recipe, contents[1])
		return

	var/datum/food_processor_process/gotten_recipe = GET_RECIPE(attacking_item)
	if(gotten_recipe)
		if(length(contents))
			balloon_alert(user, "board is full")
			return

		attacking_item.forceMove(src)
		balloon_alert(user, "placed [attacking_item] on board")
		update_appearance()
		return

	if(IS_EDIBLE(attacking_item)) //We may have failed but the user wants some feedback on why they can't put x food item on the board
		balloon_alert(user, "[attacking_item] can't be processed")
	return ..()

#undef GET_RECIPE

/obj/item/reagent_containers/cup/soup_pot/material
	icon = 'monkestation/code/modules/blueshift/icons/cookware.dmi'
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

// A few random preset types as well

/obj/item/reagent_containers/cup/soup_pot/material/fake_copper


/obj/item/reagent_containers/cup/soup_pot/material/fake_brass


/obj/item/reagent_containers/cup/soup_pot/material/fake_tin


// Oven Trays
/obj/item/plate/oven_tray/material
	desc = "Time to bake hardtack!"
	icon = 'monkestation/code/modules/blueshift/icons/cookware.dmi'
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

// A few random preset types as well

/obj/item/plate/oven_tray/material/fake_copper


/obj/item/plate/oven_tray/material/fake_brass


/obj/item/plate/oven_tray/material/fake_tin

#define LARGE_MORTAR_STAMINA_MINIMUM 50 //What is the amount of stam damage that we prevent mortar use at
#define LARGE_MORTAR_STAMINA_USE 70 //How much stam damage is given to people when the mortar is used

/obj/structure/large_mortar
	name = "large mortar"
	desc = "A large bowl perfect for grinding or juicing a large number of things at once."
	icon = 'monkestation/code/modules/blueshift/icons/cooking_structures.dmi'
	icon_state = "big_mortar"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	pass_flags = PASSTABLE
	resistance_flags = FLAMMABLE
	custom_materials = list(
		/datum/material/wood = SHEET_MATERIAL_AMOUNT  * 10,
	)
	/// The maximum number of items this structure can store
	var/maximum_contained_items = 10

/obj/structure/large_mortar/Initialize(mapload)
	. = ..()
	create_reagents(200, OPENCONTAINER)

	AddElement(/datum/element/falling_hazard, damage = 20, wound_bonus = 5, hardhat_safety = TRUE, crushes = FALSE)

/obj/structure/large_mortar/examine(mob/user)
	. = ..()
	. += span_notice("It currently contains <b>[length(contents)]/[maximum_contained_items]</b> items.")
	. += span_notice("It can be (un)secured with <b>Right Click</b>")
	. += span_notice("You can empty all of the items out of it with <b>Alt Click</b>")

/obj/structure/large_mortar/Destroy()
	drop_everything_contained()
	return ..()

/obj/structure/large_mortar/AltClick(mob/user)
	if(!length(contents))
		balloon_alert(user, "nothing inside")
		return

	drop_everything_contained()
	balloon_alert(user, "removed all items")
	return

/// Drops all contents at the mortar
/obj/structure/large_mortar/proc/drop_everything_contained()
	if(!length(contents))
		return

	for(var/obj/target_item as anything in contents)
		target_item.forceMove(get_turf(src))

/obj/structure/large_mortar/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src))
		return

	set_anchored(!anchored)
	balloon_alert_to_viewers(anchored ? "secured" : "unsecured")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/large_mortar/attackby(obj/item/attacking_item, mob/living/carbon/human/user)
	if(istype(attacking_item, /obj/item/storage/bag))
		if(length(contents) >= maximum_contained_items)
			balloon_alert(user, "already full")
			return TRUE

		if(!length(attacking_item.contents))
			balloon_alert(user, "nothing to transfer!")
			return TRUE

		for(var/obj/item/target_item in attacking_item.contents)
			if(length(contents) >= maximum_contained_items)
				break

			if(target_item.juice_results || target_item.grind_results)
				target_item.forceMove(src)

		if (length(contents) >= maximum_contained_items)
			balloon_alert(user, "filled!")
		else
			balloon_alert(user, "transferred")
		return TRUE

	if(istype(attacking_item, /obj/item/pestle))
		if(!anchored)
			balloon_alert(user, "secure to ground first")
			return

		if(!length(contents))
			balloon_alert(user, "nothing to grind")
			return

		if(user.stamina.loss > LARGE_MORTAR_STAMINA_MINIMUM)
			balloon_alert(user, "too tired")
			return

		var/list/choose_options = list(
			"Grind" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind"),
			"Juice" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice")
		)
		var/picked_option = show_radial_menu(user, src, choose_options, radius = 38, require_near = TRUE)

		if(!length(contents) || !in_range(src, user) || !user.is_holding(attacking_item) && !picked_option)
			return

		balloon_alert_to_viewers("grinding...")
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
		if(!do_after(user, 5 SECONDS * skill_modifier, target = src))
			balloon_alert_to_viewers("stopped grinding")
			return

		var/stamina_use = LARGE_MORTAR_STAMINA_USE
		if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
			stamina_use *= 0.5 //so it uses half the amount of stamina (35 instead of 70)

		user.stamina.adjust(-stamina_use) //This is a bit more tiring than a normal sized mortar and pestle
		user.mind.adjust_experience(/datum/skill/primitive, 5)
		switch(picked_option)
			if("Juice")
				for(var/obj/item/target_item as anything in contents)
					if(target_item.juice_results)
						juice_target_item(target_item, user)
					else
						grind_target_item(target_item, user)

			if("Grind")
				for(var/obj/item/target_item as anything in contents)
					if(target_item.grind_results)
						grind_target_item(target_item, user)
					else
						juice_target_item(target_item, user)
		return

	if(!attacking_item.grind_results && !attacking_item.juice_results)
		balloon_alert(user, "can't grind this")
		return ..()

	if(length(contents) >= maximum_contained_items)
		balloon_alert(user, "already full")
		return

	attacking_item.forceMove(src)
	return ..()

///Juices the passed target item, and transfers any contained chems to the mortar as well
/obj/structure/large_mortar/proc/juice_target_item(obj/item/to_be_juiced, mob/living/carbon/human/user)
	if(to_be_juiced.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to juice [to_be_juiced], but it fades away!"))
		qdel(to_be_juiced)
		return

	if(!to_be_juiced.juice(src.reagents, user))
		to_chat(user, span_danger("You fail to juice [to_be_juiced]."))

	to_chat(user, span_notice("You juice [to_be_juiced] into a liquid."))
	QDEL_NULL(to_be_juiced)

///Grinds the passed target item, and transfers any contained chems to the mortar as well
/obj/structure/large_mortar/proc/grind_target_item(obj/item/to_be_ground, mob/living/carbon/human/user)
	if(to_be_ground.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to grind [to_be_ground], but it fades away!"))
		qdel(to_be_ground)
		return

	if(!to_be_ground.grind(src.reagents, user))
		if(isstack(to_be_ground))
			to_chat(usr, span_notice("[src] attempts to grind as many pieces of [to_be_ground] as possible."))
		else
			to_chat(user, span_danger("You fail to grind [to_be_ground]."))

	to_chat(user, span_notice("You break [to_be_ground] into a fine powder."))
	QDEL_NULL(to_be_ground)

#undef LARGE_MORTAR_STAMINA_MINIMUM
#undef LARGE_MORTAR_STAMINA_USE

#define MILLSTONE_STAMINA_MINIMUM 50 //What is the amount of stam damage that we prevent mill use at
#define MILLSTONE_STAMINA_USE 100 //How much stam damage is given to people when the mill is used

/obj/structure/millstone
	name = "millstone"
	desc = "Two big disks of something heavy and tough. Put a plant between them and spin, and you'll end up with seeds and a really ground up plant."
	icon = 'monkestation/code/modules/blueshift/icons/millstone.dmi'
	icon_state = "millstone"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	pass_flags = PASSTABLE
	custom_materials = list(
		/datum/material/stone = SHEET_MATERIAL_AMOUNT  * 6,
	)
	drag_slowdown = 2
	/// The maximum number of items this structure can store
	var/maximum_contained_items = 10

/obj/structure/millstone/examine(mob/user)
	. = ..()

	. += span_notice("It currently contains <b>[length(contents)]/[maximum_contained_items]</b> items.")
	. += span_notice("You can process [src]'s contents with <b>Right Click</b>")
	. += span_notice("You can empty all of the items out of it with <b>Alt Click</b>")

	if(length(contents))
		. += span_notice("Inside, you can see:")
		var/list/stuff_inside = list()
		for(var/obj/thing as anything in contents)
			stuff_inside[thing.type] += 1

		for(var/obj/thing as anything in stuff_inside)
			. += span_notice("&bull; [stuff_inside[thing]] [initial(thing.name)]\s")

		. += span_notice("And it can fit <b>[maximum_contained_items - length(contents)]</b> more items in it.")
	else
		. += span_notice("It can hold [maximum_contained_items] items, and there is nothing in it presently.")

	. += span_notice("You can [anchored ? "un" : ""]secure [src] with <b>CTRL-Shift-Click</b>.")
	. += span_notice("With a <b>prying tool</b> of some sort, you could take [src] apart.")

/obj/structure/millstone/Destroy()
	drop_everything_contained()
	return ..()

/obj/structure/millstone/deconstruct(disassembled)
	var/obj/item/stack/sheet/mineral/stone = new (drop_location())
	stone.amount = 6
	stone.update_appearance(UPDATE_ICON)
	transfer_fingerprints_to(stone)
	return ..()

/obj/structure/millstone/AltClick(mob/user)
	if(!length(contents))
		balloon_alert(user, "nothing inside!")
		return

	drop_everything_contained()
	balloon_alert(user, "removed all items")
	return

/obj/structure/millstone/CtrlShiftClick(mob/user)
	set_anchored(!anchored)
	balloon_alert(user, "[anchored ? "secured" : "unsecured"]")

/// Drops all contents at the mortar
/obj/structure/millstone/proc/drop_everything_contained()
	if(!length(contents))
		return

	for(var/obj/target_item as anything in contents)
		target_item.forceMove(get_turf(src))

/obj/structure/millstone/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src))
		return

	mill_it_up(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/millstone/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert_to_viewers("disassembling...")
	if(!do_after(user, 2 SECONDS, src))
		return
	deconstruct(TRUE)

/obj/structure/millstone/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/storage/bag))
		if(length(contents) >= maximum_contained_items)
			balloon_alert(user, "already full")
			return TRUE

		if(!length(attacking_item.contents))
			balloon_alert(user, "nothing to transfer!")
			return TRUE

		for(var/obj/item/food/grown/target_item in attacking_item.contents)
			if(length(contents) >= maximum_contained_items)
				break

			target_item.forceMove(src)

		if (length(contents) >= maximum_contained_items)
			balloon_alert(user, "filled!")
		else
			balloon_alert(user, "transferred")

		return TRUE

	if(!((istype(attacking_item, /obj/item/food/grown/)) || (istype(attacking_item, /obj/item/grown))))
		balloon_alert(user, "can only mill plants")
		return ..()

	if(length(contents) >= maximum_contained_items)
		balloon_alert(user, "already full")
		return

	attacking_item.forceMove(src)
	return ..()

/// Takes the content's seeds and spits them out on the turf, as well as grinding whatever the contents may be
/obj/structure/millstone/proc/mill_it_up(mob/living/carbon/human/user)
	if(!length(contents))
		balloon_alert(user, "nothing to mill")
		return

	if(user.stamina.loss > MILLSTONE_STAMINA_MINIMUM)
		balloon_alert(user, "too tired")
		return

	if(!length(contents) || !in_range(src, user))
		return

	balloon_alert_to_viewers("grinding...")

	flick("millstone_spin", src)
	playsound(src, 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)

	var/stamina_use = MILLSTONE_STAMINA_USE
	if(prob(user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_PROBS_MODIFIER)))
		stamina_use *= 0.5 //so it uses half the amount of stamina (50 instead of 100)

	user.stamina.adjust(-stamina_use) // Prevents spamming it

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/primitive, SKILL_SPEED_MODIFIER)
	if(!do_after(user, 5 SECONDS * skill_modifier, target = src))
		balloon_alert_to_viewers("stopped grinding")
		return

	user.mind.adjust_experience(/datum/skill/primitive, 5)

	for(var/target_item as anything in contents)
		seedify(target_item, t_max = 1)

	return

#undef MILLSTONE_STAMINA_MINIMUM
#undef MILLSTONE_STAMINA_USE

#define RESKIN_LINEN "Linen"

/obj/item/storage/bag/plants
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Original" = list(
			RESKIN_ICON = 'icons/obj/hydroponics/equipment.dmi',
			RESKIN_ICON_STATE = "plantbag",
			RESKIN_WORN_ICON = 'icons/mob/clothing/belt.dmi',
			RESKIN_WORN_ICON_STATE = "plantbag",
		),
		RESKIN_LINEN = list(
			RESKIN_ICON = 'monkestation/code/modules/blueshift/icons/plant_bag.dmi',
			RESKIN_ICON_STATE = "plantbag_primitive",
			RESKIN_WORN_ICON = 'monkestation/code/modules/blueshift/icons/plant_bag_worn.dmi',
			RESKIN_WORN_ICON_STATE = "plantbag_primitive",
		),
	)

// This is so the linen reskin shows properly in the suit storage.
/obj/item/storage/bag/plants/build_worn_icon(default_layer, default_icon_file, isinhands, female_uniform, override_state, override_file, mutant_styles)
	if(default_layer == SUIT_STORE_LAYER && current_skin == RESKIN_LINEN)
		override_file = 'monkestation/code/modules/blueshift/icons/plant_bag_worn_mirror.dmi'

	return ..()

/// Simple helper to reskin this item into its primitive variant.
/obj/item/storage/bag/plants/proc/make_primitive()
	current_skin = RESKIN_LINEN

	icon = unique_reskin[current_skin][RESKIN_ICON]
	icon_state = unique_reskin[current_skin][RESKIN_ICON_STATE]
	worn_icon = unique_reskin[current_skin][RESKIN_WORN_ICON]
	worn_icon_state = unique_reskin[current_skin][RESKIN_WORN_ICON_STATE]

	update_appearance()

/// A helper for the primitive variant, for mappers.
/obj/item/storage/bag/plants/primitive
	current_skin = RESKIN_LINEN // Just so it displays properly when in suit storage
	uses_advanced_reskins = FALSE
	unique_reskin = null
	icon = 'monkestation/code/modules/blueshift/icons/plant_bag.dmi'
	icon_state = "plantbag_primitive"
	worn_icon = 'monkestation/code/modules/blueshift/icons/plant_bag_worn.dmi'
	worn_icon_state = "plantbag_primitive"

/obj/item/stack/sheet/cloth/on_item_crafted(mob/builder, atom/created)
	if(!istype(created, /obj/item/storage/bag/plants))
		return

	if(!isashwalker(builder))
		return

	var/obj/item/storage/bag/plants/bag = created

	bag.make_primitive()

/obj/item/storage/bag/plants/portaseeder
	uses_advanced_reskins = FALSE
	unique_reskin = null

#undef RESKIN_LINEN

/obj/machinery/griddle/stone
	name = "stone griddle"
	desc = "You could probably cook an egg on this... the griddle slab looks very unsanitary."
	icon = 'monkestation/code/modules/blueshift/icons/stone_kitchen_machines.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | PASSTABLE| LETPASSTHROW // It's roughly the height of a table.
	layer = BELOW_OBJ_LAYER
	use_power = FALSE
	circuit = null
	resistance_flags = FIRE_PROOF
	processing_flags = START_PROCESSING_MANUALLY
	variant = 1

/obj/machinery/griddle/Initialize(mapload)
	. = ..()
	grill_loop = new(src, FALSE)
	if(isnum(variant))
		variant = 1

/obj/machinery/griddle/stone/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

/obj/machinery/griddle/stone/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)
	deconstruct(TRUE)
	return

#define OVEN_TRAY_Y_OFFSET -12

/obj/machinery/oven/stone
	name = "stone oven"
	desc = "Sorry buddy, all this stone used up the budget that would have normally gone to garfield comic jokes."
	icon = 'monkestation/code/modules/blueshift/icons/stone_kitchen_machines.dmi'
	circuit = null
	use_power = FALSE

	/// A list of the different oven trays we can spawn with
	var/static/list/random_oven_tray_types = list(
		/obj/item/plate/oven_tray/material/fake_copper,
		/obj/item/plate/oven_tray/material/fake_brass,
		/obj/item/plate/oven_tray/material/fake_tin,
	)

/obj/machinery/oven/stone/Initialize(mapload)
	. = ..()

	if(!mapload)
		return

	if(used_tray) // We have to get rid of normal generic tray that normal ovens spawn with
		QDEL_NULL(used_tray)

	var/new_tray_type_to_use = pick(random_oven_tray_types)
	add_tray_to_oven(new new_tray_type_to_use(src))

/obj/machinery/oven/stone/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

// previously NO_DECONSTRUCTION
/obj/machinery/oven/stone/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/oven/stone/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/oven/stone/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/oven/stone/add_tray_to_oven(obj/item/plate/oven_tray, mob/baker)
	used_tray = oven_tray

	if(!open)
		oven_tray.vis_flags |= VIS_HIDE
	vis_contents += oven_tray
	oven_tray.flags_1 |= IS_ONTOP_1
	oven_tray.vis_flags |= VIS_INHERIT_PLANE
	oven_tray.pixel_y = OVEN_TRAY_Y_OFFSET

	RegisterSignal(used_tray, COMSIG_MOVABLE_MOVED, PROC_REF(on_tray_moved))
	update_baking_audio()
	update_appearance()

/obj/machinery/oven/stone/set_smoke_state(new_state)
	. = ..()

	if(particles)
		particles.position = list(0, 10, 0)

/obj/machinery/oven/stone/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)
	deconstruct(TRUE)
	return

#undef OVEN_TRAY_Y_OFFSET

/obj/machinery/primitive_stove
	name = "stone stove"
	desc = "You think you'll stick to just putting pots on this, the grill part looks very unsanitary."
	icon = 'monkestation/code/modules/blueshift/icons/stone_kitchen_machines.dmi'
	icon_state = "stove_off"
	base_icon_state = "stove"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	use_power = FALSE
	circuit = null
	resistance_flags = FIRE_PROOF

/obj/machinery/primitive_stove/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/stove/primitive, container_x = -7, container_y = 7, spawn_container = new /obj/item/reagent_containers/cup/soup_pot)

/obj/machinery/primitive_stove/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

// previously NO_DECONSTRUCTION
/obj/machinery/primitive_stove/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/primitive_stove/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/primitive_stove/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)
	deconstruct(TRUE)
	return

/// Stove component subtype with changed visuals and not much else
/datum/component/stove/primitive
	flame_color = "#ff9900"

/datum/component/stove/primitive/on_overlay_update(obj/machinery/source, list/overlays)
	update_smoke()

	var/obj/real_parent = parent

	if(!on)
		real_parent.icon_state = "[real_parent.base_icon_state]_off" // Not an overlay but do you really want me to override a second proc? I don't
		real_parent.set_light(0, 0)
		return

	real_parent.icon_state = "[real_parent.base_icon_state]_on"
	real_parent.set_light(3, 1, LIGHT_COLOR_FIRE)

	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_fire_emissive", real_parent, alpha = real_parent.alpha)

	if(!container)
		overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_hole_emissive", real_parent, alpha = real_parent.alpha)

	// Flames around the pot
	var/mutable_appearance/flames = mutable_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", alpha = real_parent.alpha)
	flames.color = flame_color
	overlays += flames
	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", real_parent, alpha = real_parent.alpha)

#define DEFAULT_SPIN (4 SECONDS)

/*
 * Clay Bricks
 */

/obj/item/stack/sheet/mineral/clay
	name = "clay brick"
	desc = "A heavy clay brick."
	singular_name = "clay brick"
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "sheet-clay"
	inhand_icon_state = null
	throw_speed = 3
	throw_range = 5
	merge_type = /obj/item/stack/sheet/mineral/clay

GLOBAL_LIST_INIT(clay_recipes, list ( \
	new/datum/stack_recipe("clay range", /obj/machinery/primitive_stove, 10, time = 5 SECONDS,one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("clay oven", /obj/machinery/oven/stone, 10, time = 5 SECONDS,one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_MISC) \
	))

/obj/item/stack/sheet/mineral/clay/get_main_recipes()
	. = ..()
	. += GLOB.clay_recipes

/obj/structure/water_source/puddle/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = O
		if(!glass_item.use(1))
			return
		new /obj/item/stack/clay(get_turf(src))
		user.mind.adjust_experience(/datum/skill/production, 1)
		return
	return ..()

/turf/open/water/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = C
		if(!glass_item.use(1))
			return
		new /obj/item/stack/clay(src)
		user.mind.adjust_experience(/datum/skill/production, 1)
		return
	return ..()

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/stack/ore/glass))
		if(dispensedreagent != /datum/reagent/water)
			return
		if(reagents.total_volume <= 0)
			return
		var/obj/item/stack/ore/glass/glass_item = O
		if(!glass_item.use(1))
			return
		new /obj/item/stack/clay(get_turf(src))
		user.mind.adjust_experience(/datum/skill/production, 1)
		return
	return ..()

/obj/item/ceramic
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	var/forge_item

/obj/item/ceramic/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon_item = attacking_item
		if(!forge_item || !crayon_item.paint_color)
			return
		color = crayon_item.paint_color
		to_chat(user, span_notice("You color [src] with [crayon_item]..."))
		return
	return ..()

/obj/item/stack/clay
	name = "clay"
	desc = "A pile of clay that can be used to create ceramic artwork."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "clay"
	merge_type = /obj/item/stack/clay
	singular_name = "glob of clay"

/datum/export/ceramics
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "ceramic product"
	export_types = list(
		/obj/item/plate/ceramic,
		/obj/item/plate/oven_tray/material/ceramic,
		/obj/item/reagent_containers/cup/bowl/ceramic,
		/obj/item/reagent_containers/cup/beaker/large/ceramic,
	)

/datum/export/ceramics/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/datum/export/ceramics_unfinished
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "unfinished ceramic product"
	export_types = list(/obj/item/ceramic/plate,
						/obj/item/ceramic/bowl,
						/obj/item/ceramic/tray,
						/obj/item/ceramic/cup)

/datum/export/ceramics_unfinished/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/obj/item/ceramic/plate
	name = "ceramic plate"
	desc = "A piece of clay that is flat, in the shape of a plate."
	icon_state = "clay_plate"
	forge_item = /obj/item/plate/ceramic

/obj/item/plate/ceramic
	name = "ceramic plate"
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "clay_plate"

/obj/item/ceramic/tray
	name = "ceramic tray"
	desc = "A piece of clay that is flat, in the shape of a tray."
	icon_state = "clay_tray"
	forge_item = /obj/item/plate/oven_tray/material/ceramic

/obj/item/plate/oven_tray/material/ceramic
	name = "ceramic oven tray"
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "clay_tray"

/obj/item/ceramic/bowl
	name =  "ceramic bowl"
	desc = "A piece of clay with a raised lip, in the shape of a bowl."
	icon_state = "clay_bowl"
	forge_item = /obj/item/reagent_containers/cup/bowl/ceramic

/obj/item/reagent_containers/cup/bowl/ceramic
	name = "ceramic bowl"
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "clay_bowl"
	custom_materials = null

/obj/item/ceramic/cup
	name = "ceramic cup"
	desc = "A piece of clay with high walls, in the shape of a cup. It can hold 120 units."
	icon_state = "clay_cup"
	forge_item = /obj/item/reagent_containers/cup/beaker/large/ceramic

/obj/item/reagent_containers/cup/beaker/large/ceramic
	name = "ceramic cup"
	desc = "A cup that is made from ceramic."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "clay_cup"
	custom_materials = null

/obj/item/ceramic/brick
	name = "ceramic brick"
	desc = "A dense block of clay, ready to be fired into a brick!"
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "sheet-clay"
	forge_item = /obj/item/stack/sheet/mineral/clay

/obj/structure/throwing_wheel
	name = "throwing wheel"
	desc = "A machine that allows you to throw clay."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "throw_wheel_empty"
	density = TRUE
	anchored = TRUE
	///if the structure has clay
	var/has_clay = FALSE
	//if the structure is in use or not
	var/in_use = FALSE
	///the list of messages that are sent whilst "working" the clay
	var/static/list/given_message = list(
		"You slowly start spinning the throwing wheel...",
		"You place your hands on the clay, slowly shaping it...",
		"You start becoming satisfied with what you have made...",
		"You stop the throwing wheel, admiring your new creation...",
	)

/obj/structure/throwing_wheel/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/stack/clay))
		if(has_clay)
			return
		var/obj/item/stack/stack_item = attacking_item
		if(!stack_item.use(1))
			return
		has_clay = TRUE
		icon_state = "throw_wheel_full"
		return
	return ..()

/obj/structure/throwing_wheel/crowbar_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	new /obj/item/stack/sheet/iron/ten(get_turf(src))
	if(has_clay)
		new /obj/item/stack/clay(get_turf(src))
	qdel(src)

/obj/structure/throwing_wheel/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	anchored = !anchored

/obj/structure/throwing_wheel/proc/use_clay(spawn_type, mob/user)
	var/spinning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_SPIN
	for(var/loop_try in 1 to length(given_message))
		if(!do_after(user, spinning_speed, target = src))
			in_use = FALSE
			return
		to_chat(user, span_notice(given_message[loop_try]))
	new spawn_type(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 50)
	has_clay = FALSE
	icon_state = "throw_wheel_empty"

/obj/structure/throwing_wheel/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(in_use)
		return
	use(user)
	in_use = FALSE

/**
 * Prompts user for how they wish to use the throwing wheel
 *
 * To make sure in_use var always gets set back to FALSE no matter what happens, do the actual 'using' in its own proc and do the setting to FALSE in attack_hand
 *
 * Arguments:
 * * user - the mob who is using the throwing wheel
 */
/obj/structure/throwing_wheel/proc/use(mob/living/user)
	in_use = TRUE
	var/spinning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_SPIN
	if(!has_clay)
		balloon_alert(user, "there is no clay!")
		return
	var/user_input = tgui_alert(user, "What would you like to do?", "Choice Selection", list("Create", "Remove"))
	if(!user_input)
		return
	switch(user_input)
		if("Create")
			var/creation_choice = tgui_input_list(user, "What you like to create?", "Creation Choice", list("Cup", "Plate", "Bowl", "Tray", "Brick"))
			if(!creation_choice)
				return
			switch(creation_choice)
				if("Cup")
					use_clay(/obj/item/ceramic/cup, user)
				if("Plate")
					use_clay(/obj/item/ceramic/plate, user)
				if("Bowl")
					use_clay(/obj/item/ceramic/bowl, user)
				if("Tray")
					use_clay(/obj/item/ceramic/tray, user)
				if("Brick")
					use_clay(/obj/item/ceramic/brick, user)
		if("Remove")
			if(!do_after(user, spinning_speed, target = src))
				return
			var/atom/movable/new_clay = new /obj/item/stack/clay(get_turf(src))
			user.put_in_active_hand(new_clay)
			has_clay = FALSE
			icon_state = "throw_wheel_empty"

#undef DEFAULT_SPIN

/datum/skill/construction
	name = "Construction"
	title = "Builder"
	desc = "To be a builder is to enjoy the start and construction of civilization."
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
		SKILL_PROBS_MODIFIER = list(0, 5, 10, 20, 40, 80, 100)
	)
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/construction

/obj/item/clothing/neck/cloak/skill_reward/construction
	name = "legendary builder's cloak"
	desc = "Those who wear this cloak have the knowledge and understanding to start the foundation of a civilization. \
	It is within folklore that there exists people who can create and destroy villages, towns, and cities within minutes."
	icon = 'monkestation/code/modules/blueshift/icons/cloaks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/neck.dmi'
	icon_state = "buildercloak"
	associated_skill_path = /datum/skill/construction

#define DEFAULT_TIMED (4 SECONDS)
#define STEP_BLOW "blow"
#define STEP_SPIN "spin"
#define STEP_PADDLE "paddle"
#define STEP_SHEAR "shear"
#define STEP_JACKS "jacks"

/obj/item/glassblowing
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'

/obj/item/glassblowing/glass_globe
	name = "glass globe"
	desc = "A glass bowl that is capable of carrying things."
	icon_state = "glass_globe"
	material_flags = MATERIAL_COLOR
	custom_materials = list(
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)

/datum/export/glassblowing
	cost = CARGO_CRATE_VALUE * 5
	unit_name = "glassblowing product"
	export_types = list(
		/obj/item/glassblowing/glass_lens,
		/obj/item/glassblowing/glass_globe,
		/obj/item/reagent_containers/cup/bowl/blowing_glass,
		/obj/item/reagent_containers/cup/beaker/large/blowing_glass,
		/obj/item/plate/blowing_glass
	)

/datum/export/glassblowing/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	return ..()

/obj/item/glassblowing/glass_lens
	name = "glass lens"
	desc = "A convex glass lens that would make an excellent magnifying glass if it were attached to a handle."
	icon_state = "glass_lens"

/obj/item/reagent_containers/cup/bowl/blowing_glass
	name = "glass bowl"
	desc = "A glass bowl that is capable of carrying things."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "glass_bowl"
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/reagent_containers/cup/beaker/large/blowing_glass
	name = "glass cup"
	desc = "A glass cup that is capable of carrying liquids."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "glass_cup"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/plate/blowing_glass
	name = "glass plate"
	desc = "A glass plate that is capable of carrying things."
	icon = 'monkestation/code/modules/blueshift/icons/prim_fun.dmi'
	icon_state = "glass_plate"
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR

/obj/item/glassblowing/molten_glass
	name = "molten glass"
	desc = "A glob of molten glass, ready to be shaped into art."
	icon_state = "molten_glass"
	///the cooldown if its still molten / requires heating up
	COOLDOWN_DECLARE(remaining_heat)
	///the typepath of the item that will be produced when the required actions are met
	var/chosen_item
	///the list of steps remaining
	var/list/steps_remaining
	///the amount of time this glass will stay heated, updated each time it gets put in the forge based on the user's skill
	var/total_time
	///whether this glass's chosen item has completed all its steps. So we don't have to keep checking this a million times once it's done.
	var/is_finished = FALSE

/obj/item/glassblowing/molten_glass/examine(mob/user)
	. = ..()
	. += get_examine_message(src)

/obj/item/glassblowing/molten_glass/pickup(mob/living/user)
	if(!istype(user))
		return ..()

	. = ..()

	try_burn_user(user)

/**
 * Tries to burn the user if the glass is still molten hot.
 *
 * Arguments:
 * * mob/living/user - user to burn
 */
/obj/item/glassblowing/molten_glass/proc/try_burn_user(mob/living/user)
	if(!COOLDOWN_FINISHED(src, remaining_heat))
		to_chat(user, span_warning("You burn your hands trying to pick up [src]!"))
		user.emote("scream")
		user.dropItemToGround(src)
		var/obj/item/bodypart/affecting = user.get_active_hand()
		user.investigate_log("was burned their hand on [src] for [15] at [AREACOORD(user)]", INVESTIGATE_CRAFTING)
		return affecting?.receive_damage(0, 15, wound_bonus = CANT_WOUND)

/obj/item/glassblowing/blowing_rod
	name = "blowing rod"
	desc = "A tool that is used to hold the molten glass as well as help shape it."
	icon_state = "blow_pipe_empty"
	tool_behaviour = TOOL_BLOWROD
	/// Whether the rod is in use currently; will try to prevent many other actions on it
	var/in_use = FALSE
	/// A ref to the glass item being blown
	var/datum/weakref/glass_ref

/obj/item/glassblowing/blowing_rod/examine(mob/user)
	. = ..()
	var/obj/item/glassblowing/molten_glass/glass = glass_ref.resolve()
	if(!glass)
		return
	. += get_examine_message(glass)


/**
 * Create the examine message and return it.
 *
 * This will include all the remaining steps and whether the glass has cooled down or not.
 *
 * Arguments:
 * * obj/item/glassblowing/molten_glass/glass - the glass object being examined
 *
 * Returns the examine message.
 */
/obj/item/glassblowing/proc/get_examine_message(obj/item/glassblowing/molten_glass/glass)
	if(COOLDOWN_FINISHED(glass, remaining_heat))
		. += span_warning("The glass has cooled down and will require reheating to modify! ")
	if(glass.steps_remaining[STEP_BLOW])
		. += "The glass requires [glass.steps_remaining[STEP_BLOW]] more blowing actions! "
	if(glass.steps_remaining[STEP_SPIN])
		. += "The glass requires [glass.steps_remaining[STEP_SPIN]] more spinning actions! "
	if(glass.steps_remaining[STEP_PADDLE])
		. += "The glass requires [glass.steps_remaining[STEP_PADDLE]] more paddling actions! "
	if(glass.steps_remaining[STEP_SHEAR])
		. += "The glass requires [glass.steps_remaining[STEP_SHEAR]] more shearing actions! "
	if(glass.steps_remaining[STEP_JACKS])
		. += "The glass requires [glass.steps_remaining[STEP_JACKS]] more jacking actions!"

/obj/item/glassblowing/blowing_rod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
	if(istype(target, /obj/item/glassblowing/molten_glass))
		var/obj/item/glassblowing/molten_glass/attacking_glass = target
		var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()
		if(glass)
			to_chat(user, span_warning("[src] already has some glass on it!"))
			return
		if(!user.transferItemToLoc(attacking_glass, src))
			return
		glass_ref = WEAKREF(attacking_glass)
		to_chat(user, span_notice("[src] picks up [target]."))
		icon_state = "blow_pipe_full"
		return
	return ..()

/obj/item/glassblowing/blowing_rod/attackby(obj/item/attacking_item, mob/living/user, params)
	var/actioning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_TIMED
	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()

	if(istype(attacking_item, /obj/item/glassblowing/molten_glass))
		if(glass)
			to_chat(user, span_warning("[src] already has some glass on it still!"))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return
		glass_ref = WEAKREF(attacking_item)
		to_chat(user, span_notice("[src] picks up [attacking_item]."))
		icon_state = "blow_pipe_full"
		return

	if(istype(attacking_item, /obj/item/glassblowing/paddle))
		do_glass_step(STEP_PADDLE, user, actioning_speed, glass)
		return

	if(istype(attacking_item, /obj/item/glassblowing/shears))
		do_glass_step(STEP_SHEAR, user, actioning_speed, glass)
		return

	if(istype(attacking_item, /obj/item/glassblowing/jacks))
		do_glass_step(STEP_JACKS, user, actioning_speed, glass)
		return

	return ..()

/obj/item/glassblowing/blowing_rod/attack_self(mob/user, modifiers)
	return ..()

/obj/item/glassblowing/blowing_rod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GlassBlowing", name)
		ui.open()

/obj/item/glassblowing/blowing_rod/ui_data()
	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()

	var/data = list()
	data["inUse"] = in_use

	if(glass)
		data["glass"] = list(
			timeLeft = COOLDOWN_TIMELEFT(glass, remaining_heat),
			totalTime = glass.total_time,
			chosenItem = null,
			stepsRemaining = glass.steps_remaining,
			isFinished = glass.is_finished
		)

		var/obj/item_path = glass.chosen_item
		data["glass"]["chosenItem"] = item_path ? list(name = initial(item_path.name), type = item_path) : null
	else
		data["glass"] = null

	return data

/obj/item/glassblowing/blowing_rod/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!Adjacent(usr))
		return
	add_fingerprint(usr)

	var/obj/item/glassblowing/molten_glass/glass = glass_ref?.resolve()
	var/actioning_speed = usr.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_TIMED

	if(!glass)
		return

	if(action == "Remove")
		if(!glass.chosen_item)
			remove_glass(usr, glass)
			in_use = FALSE
			return

		if(glass.is_finished)
			create_item(usr, glass)
			in_use = FALSE
		else
			remove_glass(usr, glass)
		return

	if(!glass.chosen_item)
		switch(action)
			if("Plate")
				glass.chosen_item = /obj/item/plate/blowing_glass
				glass.steps_remaining = list(blow=3,spin=3,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
			if("Bowl")
				glass.chosen_item = /obj/item/reagent_containers/cup/bowl/blowing_glass
				glass.steps_remaining = list(blow=2,spin=2,paddle=2,shear=0,jacks=3) //blowing, spinning, paddling
			if("Globe")
				glass.chosen_item = /obj/item/glassblowing/glass_globe
				glass.steps_remaining = list(blow=6,spin=3,paddle=0,shear=0,jacks=0) //blowing, spinning
			if("Cup")
				glass.chosen_item = /obj/item/reagent_containers/cup/beaker/large/blowing_glass
				glass.steps_remaining = list(blow=3,spin=3,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
			if("Lens")
				glass.chosen_item = /obj/item/glassblowing/glass_lens
				glass.steps_remaining = list(blow=0,spin=0,paddle=3,shear=3,jacks=3) //paddling, shearing, jacking
			if("Bottle")
				glass.chosen_item = /obj/item/reagent_containers/cup/glass/bottle/small
				glass.steps_remaining = list(blow=3,spin=2,paddle=3,shear=0,jacks=0) //blowing, spinning, paddling
	else
		switch(action)
			if("Blow")
				do_glass_step(STEP_BLOW, usr, actioning_speed, glass)
			if("Spin")
				do_glass_step(STEP_SPIN, usr, actioning_speed, glass)
			if("Paddle")
				do_glass_step(STEP_PADDLE, usr, actioning_speed, glass)
			if("Shear")
				do_glass_step(STEP_SHEAR, usr, actioning_speed, glass)
			if("Jacks")
				do_glass_step(STEP_JACKS, usr, actioning_speed, glass)
			if("Cancel")
				glass.chosen_item = null
				glass.steps_remaining = null
				glass.is_finished = FALSE
				to_chat(usr, span_notice("You start over with the [src]."))


/**
 * Removes the glass object from the rod.
 *
 * Try to put the glass into the user's hands, or on the floor if that fails.
 *
 * Arguments:
 * * mob/user - the mob doing the removing
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/remove_glass(mob/user, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return

	in_use = FALSE
	user.put_in_hands(glass)
	glass.try_burn_user(user)
	glass_ref = null
	icon_state = "blow_pipe_empty"

/**
 * Creates the finished product and delete the glass object used to make it.
 *
 * Try to put the finished product into the user's hands
 *
 * Arguments:
 * * mob/user - the user doing the creating
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/create_item(mob/user, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return
	if(in_use)
		return

	in_use = TRUE
	user.put_in_hands(new glass.chosen_item)
	user.mind.adjust_experience(/datum/skill/production, 30)
	glass_ref = null
	qdel(glass)
	icon_state = "blow_pipe_empty"
	return

/**
 * Display fail message and reset in_use.
 *
 * Craft is finished when all steps in steps_remaining are 0.
 *
 * Arguments:
 * * mob/user - mob to display to
 * * message - to display
 */
/obj/item/glassblowing/blowing_rod/proc/fail_message(message, mob/user)
	to_chat(user, span_warning(message))
	in_use = FALSE

/**
 * Try to do a glassblowing action.
 *
 * Checks for a table and valid tool if applicable, and updates the steps_remaining on the glass object.
 *
 * Arguments:
 * * step_id - the step id e.g. STEP_BLOW
 * * actioning_speed - the speed based on the user's production skill
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 */
/obj/item/glassblowing/blowing_rod/proc/do_glass_step(step_id, mob/user, actioning_speed, obj/item/glassblowing/molten_glass/glass)
	if(!glass)
		return

	if(COOLDOWN_FINISHED(glass, remaining_heat))
		balloon_alert(user, "glass too cool!")
		return FALSE

	if(in_use)
		return

	in_use = TRUE

	if(!check_valid_table(user))
		fail_message("You must be near a non-flammable table!", user)
		return

	var/atom/movable/tool_to_use = check_valid_tool(user, step_id)
	if(!tool_to_use)
		in_use = FALSE
		return FALSE

	to_chat(user, span_notice("You begin to [step_id] [src]."))
	if(!do_after(user, actioning_speed, target = src))
		fail_message("You interrupt an action!", user)
		REMOVE_TRAIT(tool_to_use, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
		return FALSE

	if(glass.steps_remaining)
		// We do not want to have negative values here
		if(glass.steps_remaining[step_id] > 0)
			glass.steps_remaining[step_id]--
			if(check_finished(glass))
				glass.is_finished = TRUE

	REMOVE_TRAIT(tool_to_use, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
	in_use = FALSE

	to_chat(user, span_notice("You finish trying to [step_id] [src]."))
	user.mind.adjust_experience(/datum/skill/production, 10)


/**
 * Check if there is a non-flammable table nearby to do the crafting on.
 *
 * If the user is a master in the production skill, they can skip tables.
 *
 * Arguments:
 * * mob/living/user - the mob doing the action
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/check_valid_table(mob/living/user)
	var/skill_level = user.mind.get_skill_level(/datum/skill/production)
	if(skill_level >= SKILL_LEVEL_MASTER) //
		return TRUE
	for(var/obj/structure/table/check_table in range(1, get_turf(src)))
		if(!(check_table.resistance_flags & FLAMMABLE))
			return TRUE
	return FALSE

/**
 * Check if user is carrying the proper tool for the step.
 *
 * Arguments:
 * * mob/living/carbon/human/user - the mob doing the action
 * * step_id - the step id of the action being done
 *
 * We check to see if the user is using the right tool and if they are currently glassblowing with it.
 * If the correct tool is being used we return the tool. Otherwise we return `FALSE`
 */
/obj/item/glassblowing/blowing_rod/proc/check_valid_tool(mob/living/carbon/human/user, step_id)
	if(!istype(user))
		return FALSE

	if(step_id == STEP_BLOW || step_id == STEP_SPIN)
		if(HAS_TRAIT(user, TRAIT_CURRENTLY_GLASSBLOWING))
			balloon_alert(user, "already glassblowing!")
			return FALSE

		ADD_TRAIT(user, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
		return user

	var/obj/item/glassblowing/used_tool
	switch(step_id)
		if(STEP_PADDLE)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/paddle)
		if(STEP_SHEAR)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/shears)
		if(STEP_JACKS)
			used_tool = user.is_holding_item_of_type(/obj/item/glassblowing/jacks)

	if(!used_tool)
		balloon_alert(user, "need the right tool!")
		return FALSE

	if(HAS_TRAIT(used_tool, TRAIT_CURRENTLY_GLASSBLOWING))
		balloon_alert(user, "already in use!")
		return FALSE

	ADD_TRAIT(used_tool, TRAIT_CURRENTLY_GLASSBLOWING, TRAIT_GLASSBLOWING)
	return used_tool

/**
 * Checks if the glass is ready to craft into its chosen item.
 *
 * Craft is finished when all steps in steps_remaining are 0.
 *
 * Arguments:
 * * obj/item/glassblowing/molten_glass/glass - the glass object
 *
 * Returns TRUE or FALSE.
 */
/obj/item/glassblowing/blowing_rod/proc/check_finished(obj/item/glassblowing/molten_glass/glass)
	for(var/step_id in glass.steps_remaining)
		if(glass.steps_remaining[step_id] != 0)
			return FALSE
	return TRUE

/datum/crafting_recipe/glassblowing_recipe
	reqs = list(/obj/item/stack/sheet/iron = 5)
	category = CAT_MISC

/datum/crafting_recipe/glassblowing_recipe/glass_blowing_rod
	name = "Glass-blowing Blowing Rod"
	result = /obj/item/glassblowing/blowing_rod

/obj/item/glassblowing/jacks
	name = "jacks"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "jacks"

/datum/crafting_recipe/glassblowing_recipe/glass_jack
	name = "Glass-blowing Jacks"
	result = /obj/item/glassblowing/jacks

/obj/item/glassblowing/paddle
	name = "paddle"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "paddle"

/datum/crafting_recipe/glassblowing_recipe/glass_paddle
	name = "Glass-blowing Paddle"
	result = /obj/item/glassblowing/paddle

/obj/item/glassblowing/shears
	name = "shears"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "shears"

/datum/crafting_recipe/glassblowing_recipe/glass_shears
	name = "Glass-blowing Shears"
	result = /obj/item/glassblowing/shears

/obj/item/glassblowing/metal_cup
	name = "metal cup"
	desc = "A tool that helps shape glass during the art process."
	icon_state = "metal_cup_empty"
	var/has_sand = FALSE

/datum/crafting_recipe/glassblowing_recipe/glass_metal_cup
	name = "Glass-blowing Metal Cup"
	result = /obj/item/glassblowing/metal_cup

/obj/item/glassblowing/metal_cup/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_obj = I
		if(!glass_obj.use(1))
			return
		has_sand = TRUE
		icon_state = "metal_cup_full"
	return ..()

#undef DEFAULT_TIMED
#undef STEP_BLOW
#undef STEP_SPIN
#undef STEP_PADDLE
#undef STEP_SHEAR
#undef STEP_JACKS

/obj/item/shard/attackby(obj/item/item, mob/user, params)
	//xenoarch hammer, forging hammer, etc.
	if(item.tool_behaviour == TOOL_HAMMER)
		var/added_color
		switch(src.type)
			if(/obj/item/shard)
				added_color = "#88cdf1"

			if(/obj/item/shard/plasma)
				added_color = "#ff80f4"

			if(/obj/item/shard/plastitanium)
				added_color = "#5d3369"

			if(/obj/item/shard/titanium)
				added_color = "#cfbee0"

		var/obj/colored_item = new /obj/item/stack/ore/glass/zero_cost(get_turf(src))
		colored_item.add_atom_colour(added_color, FIXED_COLOUR_PRIORITY)
		new /obj/effect/decal/cleanable/glass(get_turf(src))
		user.balloon_alert(user, "[src] shatters!")
		playsound(src, SFX_SHATTER, 30, TRUE)
		qdel(src)
		return TRUE

	return ..()

/obj/item/stack/ore/glass/zero_cost
	points = 0
	merge_type = /obj/item/stack/ore/glass/zero_cost

/obj/item/stack/ore/examine(mob/user)
	. = ..()
	if(points == 0)
		. += span_warning("<br> [src] is worthless and will not reward any mining points!")

/datum/skill/production
	name = "Production"
	title = "Producer"
	desc = "The artist who finds themselves using multiple mediums in which to express their creativity."
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
		SKILL_PROBS_MODIFIER = list(10, 15, 20, 25, 30, 35, 40)
	)
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/production

/obj/item/clothing/neck/cloak/skill_reward/production
	name = "legendary producer's cloak"
	desc = "Worn by the most skilled producers, this legendary cloak is only attainable by knowing how to create the best products. \
	This status symbol represents a being who has crafted some of the finest glass and ceramic works."
	icon = 'monkestation/code/modules/blueshift/icons/cloaks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/neck.dmi'
	icon_state = "productioncloak"
	associated_skill_path = /datum/skill/production



/// The baseline time to take for doing actions with the forge, like heating glass, setting ceramics, etc.
#define BASELINE_ACTION_TIME (4 SECONDS)

/// The basline for how long an item such as molten glass will be kept workable after heating
#define BASELINE_HEATING_DURATION (25 SECONDS)

/// The amount the forge's temperature will change per process
#define FORGE_DEFAULT_TEMPERATURE_CHANGE 5
/// The maximum temperature the forge can reach
#define MAX_FORGE_TEMP 100
/// The minimum temperature for using the forge
#define MIN_FORGE_TEMP 50
/// The duration that objects heated in the forge are heated for
#define FORGE_HEATING_DURATION (1 MINUTES)

/// Defines for different levels of the forge, ranging from no level (you play like a noob) to legendary
#define FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB 1
#define FORGE_LEVEL_NOVICE 2
#define FORGE_LEVEL_APPRENTICE 3
#define FORGE_LEVEL_JOURNEYMAN 4
#define FORGE_LEVEL_EXPERT 5
#define FORGE_LEVEL_MASTER 6
#define FORGE_LEVEL_LEGENDARY 7

/// The maximum amount of temperature loss decrease that upgrades can give the forge
#define MAX_TEMPERATURE_LOSS_DECREASE 5

/// The chance per piece of wood added that charcoal will form later
#define CHARCOAL_CHANCE 45

/// Defines for the different levels of smoke coming out of the forge, (good, neutral, bad) are all used for baking, (not cooking) is used for when there is no tray in the forge
#define SMOKE_STATE_NONE 0
#define SMOKE_STATE_GOOD 1
#define SMOKE_STATE_NEUTRAL 2
#define SMOKE_STATE_BAD 3
#define SMOKE_STATE_NOT_COOKING 4

/obj/structure/reagent_forge
	name = "forge"
	desc = "A structure built out of bricks, for heating up metal, or glass, or ceramic, or food, or anything really."
	icon = 'monkestation/code/modules/blueshift/icons/obj/forge_structures.dmi'
	icon_state = "forge_inactive"

	anchored = TRUE
	density = TRUE

	/// What the current internal temperature of the forge is
	var/forge_temperature = 0
	/// What temperature the forge is moving towards
	var/target_temperature = 0
	/// What the minimum target temperature is, used for upgrades
	var/minimum_target_temperature = 0
	/// What is the current reduction for temperature decrease
	var/temperature_loss_reduction = 0
	/// How many seconds of weak fuel (wood) does the forge have left
	var/forge_fuel_weak = 0
	/// How many seconds of strong fuel (coal) does the forge have left
	var/forge_fuel_strong = 0
	/// Cooldown time for processing on the forge
	COOLDOWN_DECLARE(forging_cooldown)
	/// Is the forge in use or not? If true, prevents most interactions with the forge
	var/in_use = FALSE
	/// The current 'level' of the forge, how upgraded is it from zero to three
	var/forge_level = FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
	/// What smoke particles should be coming out of the forge
	var/smoke_state = SMOKE_STATE_NONE
	/// Tracks any oven tray placed inside of the forge
	var/obj/item/plate/oven_tray/used_tray
	/// List of possible choices for the selection radial
	var/list/radial_choice_list = list()

/obj/structure/reagent_forge/examine(mob/user)
	. = ..()

	if(used_tray)
		. += span_notice("It has [used_tray] in it, which can be removed with an <b>empty hand</b>.")
	else
		. += span_notice("You can place an <b>oven tray</b> in this to <b>bake</b> any items on it.")

	if(forge_level < FORGE_LEVEL_LEGENDARY)
		. += span_notice("Using an <b>empty hand</b> on [src] will upgrade it, if your forging skill level is above the current upgrade's level.")

	switch(forge_level)
		if(FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB)
			. += span_notice("This forge has not been upgraded yet.")

		if(FORGE_LEVEL_NOVICE)
			. += span_notice("This forge has been upgraded by a novice smith.")

		if(FORGE_LEVEL_APPRENTICE)
			. += span_notice("This forge has been upgraded by an apprentice smith.")

		if(FORGE_LEVEL_JOURNEYMAN)
			. += span_notice("This forge has been upgraded by a journeyman smith.")

		if(FORGE_LEVEL_EXPERT)
			. += span_notice("This forge has been upgraded by an expert smith.")

		if(FORGE_LEVEL_MASTER)
			. += span_notice("This forge has been upgraded by a master smith.")

		if(FORGE_LEVEL_LEGENDARY)
			. += span_hierophant("This forge has been upgraded by a legendary smith.") // Legendary skills give you the greatest gift of all, cool text

	switch(temperature_loss_reduction)
		if(0)
			. += span_notice("[src] will lose heat at a normal rate.")
		if(1)
			. += span_notice("[src] will lose heat slightly slower than usual.")
		if(2)
			. += span_notice("[src] will lose heat a bit slower than usual.")
		if(3)
			. += span_notice("[src] will lose heat much slower than usual.")
		if(4)
			. += span_notice("[src] will lose heat signficantly slower than usual.")
		if(5)
			. += span_notice("[src] will lose heat at a practically negligible rate.")

	. += span_notice("<br>[src] is currently [forge_temperature] degrees hot, going towards [target_temperature] degrees.<br>")
	return .

/obj/structure/reagent_forge/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_appearance()
	upgrade_forge(forced = TRUE)

/obj/structure/reagent_forge/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(particles)
	if(used_tray)
		QDEL_NULL(used_tray)
	. = ..()

/obj/structure/reagent_forge/update_appearance(updates)
	. = ..()
	cut_overlays()

	if(used_tray) // If we have a tray inside, check if the forge is on or not, then give the corresponding tray overlay
		var/image/tray_overlay = image(icon = icon, icon_state = "forge_tray_[check_fuel(just_checking = TRUE) ? "active" : "inactive"]")
		add_overlay(tray_overlay)

/// Checks if the forge has fuel, if so what type. If it has either type of fuel, returns TRUE, otherwise returns FALSE. just_checking will check if there is fuel without taking actions
/obj/structure/reagent_forge/proc/check_fuel(just_checking = FALSE)
	if(forge_fuel_strong) // Check for strong fuel (coal) first, as it has more power over weaker fuels
		if(just_checking)
			return TRUE

		forge_fuel_strong -= 5 SECONDS
		target_temperature = 100
		return TRUE

	if(forge_fuel_weak) // If there's no strong fuel, maybe we have weak fuel (wood)
		if(just_checking)
			return TRUE

		forge_fuel_weak -= 5 SECONDS
		target_temperature = 50
		return TRUE

	if(just_checking)
		return FALSE

	target_temperature = minimum_target_temperature // If the forge has no fuel, then we should lowly return to the minimum lowest temp we can do
	return FALSE


/// Creates both a fail message balloon alert, and sets in_use to false
/obj/structure/reagent_forge/proc/fail_message(mob/living/user, message)
	balloon_alert(user, message)
	in_use = FALSE

/// Adjust the temperature to head towards the target temperature, changing icon and creating light if the temperature is rising
/obj/structure/reagent_forge/proc/check_temp()
	if(forge_temperature > target_temperature) // Being above the target temperature will cause the forge to cool down
		forge_temperature -= (FORGE_DEFAULT_TEMPERATURE_CHANGE - temperature_loss_reduction)
		return

	else if((forge_temperature < target_temperature) && (forge_fuel_weak || forge_fuel_strong)) // Being below the target temp, and having fuel, will cause the temp to rise
		forge_temperature += FORGE_DEFAULT_TEMPERATURE_CHANGE
		return

/// If the forge is in use, checks if there is an oven tray, then if there are any mobs actually in use range. If not sets the forge to not be in use.
/obj/structure/reagent_forge/proc/check_in_use()
	if(!in_use)
		return

	if(used_tray) // We check if there's a tray because trays inside of the forge count as it being in use, even if nobody is around
		return

	for(var/mob/living/living_mob in range(1,src))
		if(!living_mob)
			in_use = FALSE

/// Spawns a piece of coal at the forge and renames it to charcoal
/obj/structure/reagent_forge/proc/spawn_coal()
	var/obj/item/stack/sheet/mineral/coal/spawn_coal = new(get_turf(src))
	spawn_coal.name = "charcoal"

/obj/structure/reagent_forge/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, forging_cooldown))
		return

	COOLDOWN_START(src, forging_cooldown, 5 SECONDS)
	check_fuel()
	check_temp()
	check_in_use() // This is here to ensure the forge doesn't remain in_use if it really isn't



	if(!used_tray && check_fuel(just_checking = TRUE))
		set_smoke_state(SMOKE_STATE_NOT_COOKING) // If there is no tray but we have fuel, use the not cooking smoke state
		return

	if(!check_fuel(just_checking = TRUE)) // If there's no fuel, remove it all
		set_smoke_state(SMOKE_STATE_NONE)
		return

	handle_baking_things(seconds_per_tick)

/// Sends signals to bake and items on the used tray, setting the smoke state of the forge according to the most cooked item in it
/obj/structure/reagent_forge/proc/handle_baking_things(seconds_per_tick)
	if(forge_temperature < MIN_FORGE_TEMP) // If we are below minimum forge temp, don't continue on to cooking
		return

	/// The worst off item being baked in our forge right now, to ensure people know when gordon ramsay is gonna be upset at them
	var/worst_cooked_food_state = 0
	for(var/obj/item/baked_item as anything in used_tray.contents)

		var/signal_result = SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PROCESS, src, seconds_per_tick)

		if(signal_result & COMPONENT_HANDLED_BAKING)
			if(signal_result & COMPONENT_BAKING_GOOD_RESULT && worst_cooked_food_state < SMOKE_STATE_GOOD)
				worst_cooked_food_state = SMOKE_STATE_GOOD
			else if(signal_result & COMPONENT_BAKING_BAD_RESULT && worst_cooked_food_state < SMOKE_STATE_NEUTRAL)
				worst_cooked_food_state = SMOKE_STATE_NEUTRAL
			continue

		worst_cooked_food_state = SMOKE_STATE_BAD
		baked_item.fire_act(1000) // Overcooked food really does burn, hot hot hot!

		if(SPT_PROB(10, seconds_per_tick))
			visible_message(span_danger("You smell a burnt smell coming from [src]!")) // Give indication that something is burning in the oven
	set_smoke_state(worst_cooked_food_state)

/// Sets the type of particles that the forge should be generating
/obj/structure/reagent_forge/proc/set_smoke_state(new_state)
	if(new_state == smoke_state)
		return

	smoke_state = new_state

	QDEL_NULL(particles)

	switch(smoke_state)
		if(SMOKE_STATE_NONE)
			icon_state = "forge_inactive"
			set_light(0, 0) // If we aren't heating up and thus not on fire, turn the fire light off
			return

		if(SMOKE_STATE_BAD)
			particles = new /particles/smoke()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_NEUTRAL)
			particles = new /particles/smoke/steam()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_GOOD)
			particles = new /particles/smoke/steam/mild()
			particles.position = list(6, 4, 0)

		if(SMOKE_STATE_NOT_COOKING)
			particles = new /particles/smoke/mild()
			particles.position = list(6, 4, 0)

	icon_state = "forge_active"
	set_light(3, 1, LIGHT_COLOR_FIRE)

/obj/structure/reagent_forge/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(used_tray)
		remove_tray_from_forge(user)
		return

	upgrade_forge(user)

/obj/structure/reagent_forge/attack_robot(mob/living/user)
	. = ..()
	upgrade_forge(user)

/obj/structure/reagent_forge/proc/upgrade_forge(mob/living/user, forced = FALSE)
	var/level_to_upgrade_to

	if(forced || !user) // This is to make sure the ready subtype of forge still works
		level_to_upgrade_to = forge_level
	else
		level_to_upgrade_to = user.mind.get_skill_level(/datum/skill/smithing)

	if((forge_level == level_to_upgrade_to) && !forced)
		to_chat(user, span_notice("[src] was already upgraded by your level of expertise!"))
		return

	switch(level_to_upgrade_to) // Remember to carry things over from past levels in case someone skips levels in upgrading
		if(SKILL_LEVEL_NONE)
			if(!forced)
				to_chat(user, span_notice("You'll need some forging skills to really understand how to upgrade [src]."))
			return

		if(SKILL_LEVEL_NOVICE)
			if(!forced)
				to_chat(user, span_notice("With some experience, you've come to realize there are some easily fixable spots with poor insulation..."))
			temperature_loss_reduction = 1
			forge_level = FORGE_LEVEL_NOVICE

		if(SKILL_LEVEL_APPRENTICE)
			if(!forced)
				to_chat(user, span_notice("Further insulation and protection of the thinner areas means [src] will lose heat just that little bit slower."))
			temperature_loss_reduction = 2
			forge_level = FORGE_LEVEL_APPRENTICE

		if(SKILL_LEVEL_JOURNEYMAN)
			if(!forced)
				to_chat(user, span_notice("Some careful placement and stoking of the flame will allow you to keep at least the embers burning..."))
			minimum_target_temperature = 25 // Will allow quicker reheating from having no fuel
			temperature_loss_reduction = 3
			forge_level = FORGE_LEVEL_JOURNEYMAN

		if(SKILL_LEVEL_EXPERT)
			if(!forced)
				to_chat(user, span_notice("[src] has become nearly perfect, able to hold heat for long enough that even a piece of wood can outmatch the longevity of lesser forges."))
			temperature_loss_reduction = 4
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_EXPERT

		if(SKILL_LEVEL_MASTER)
			if(!forced)
				to_chat(user, span_notice("The perfect forge for a perfect metalsmith, with your knowledge it should bleed heat so slowly, that not even you will live to see [src] cool."))
			temperature_loss_reduction = MAX_TEMPERATURE_LOSS_DECREASE
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_MASTER

	playsound(src, 'sound/weapons/parry.ogg', 50, TRUE) // Play a feedback sound to really let players know we just did an upgrade

//this will allow click dragging certain items
/obj/structure/reagent_forge/MouseDrop_T(obj/attacking_item, mob/living/user)
	. = ..()
	if(!isliving(user))
		return

	if(!isobj(attacking_item))
		return

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/wood)) // Wood is a weak fuel, and will only get the forge up to 50 temperature
		refuel(attacking_item, user)
		return

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/coal)) // Coal is a strong fuel that doesn't need bellows to heat up properly
		refuel(attacking_item, user, TRUE)
		return

	if(istype(attacking_item, /obj/item/stack/ore))
		smelt_ore(attacking_item, user)
		return

/obj/structure/reagent_forge/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!used_tray && istype(attacking_item, /obj/item/plate/oven_tray))
		add_tray_to_forge(user, attacking_item)
		return TRUE

	if(in_use) // If the forge is currently in use by someone (or there is a tray in it) then we cannot use it
		if(used_tray)
			balloon_alert(user, "remove [used_tray] first")
		balloon_alert(user, "forge busy")
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/wood)) // Wood is a weak fuel, and will only get the forge up to 50 temperature
		refuel(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/mineral/coal)) // Coal is a strong fuel that doesn't need bellows to heat up properly
		refuel(attacking_item, user, TRUE)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/ore))
		smelt_ore(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/ceramic))
		handle_ceramics(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/glass))
		handle_glass_sheet_melting(attacking_item, user)
		return TRUE

	if(istype(attacking_item, /obj/item/glassblowing/metal_cup))
		handle_metal_cup_melting(attacking_item, user)
		return TRUE

	return ..()

/// Take the given tray and place it inside the forge, updating everything relevant to that
/obj/structure/reagent_forge/proc/add_tray_to_forge(mob/living/user, obj/item/plate/oven_tray/tray)
	if(used_tray) // This shouldn't be able to happen but just to be safe
		balloon_alert_to_viewers("already has tray")
		return

	if(!user.transferItemToLoc(tray, src, silent = FALSE))
		return

	// need to send the right signal for each item in the tray
	for(var/obj/item/baked_item in tray.contents)
		SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PLACED_IN, src, user)

	balloon_alert_to_viewers("put [tray] in [src]")
	used_tray = tray
	in_use = TRUE // You can't use the forge if there's a tray sitting in it
	update_appearance()

/// Take the used_tray and spit it out, updating everything relevant to that
/obj/structure/reagent_forge/proc/remove_tray_from_forge(mob/living/carbon/user)
	if(!used_tray)
		if(user)
			balloon_alert_to_viewers("no tray")
		return

	if(user)
		user.put_in_hands(used_tray)
		balloon_alert_to_viewers("removed [used_tray]")
	else
		used_tray.forceMove(get_turf(src))
	used_tray = null
	in_use = FALSE

/// Adds to either the strong or weak fuel timers from the given stack
/obj/structure/reagent_forge/proc/refuel(obj/item/stack/refueling_stack, mob/living/user, is_strong_fuel = FALSE)
	in_use = TRUE

	if(is_strong_fuel)
		if(forge_fuel_strong >= 5 MINUTES)
			fail_message(user, "[src] is full on coal")
			return
	if(forge_fuel_weak >= 5 MINUTES)
		fail_message(user, "[src] is full on wood")
		return

	balloon_alert_to_viewers("refueling...")

	var/obj/item/stack/sheet/stack_sheet = refueling_stack
	if(!do_after(user, 3 SECONDS, target = src) || !stack_sheet.use(1))
		fail_message(user, "stopped fueling")
		return

	if(is_strong_fuel)
		forge_fuel_strong += 5 MINUTES
	else
		forge_fuel_weak += 5 MINUTES
	in_use = FALSE
	balloon_alert(user, "fueled [src]")
	user.mind.adjust_experience(/datum/skill/smithing, 5) // You gain small amounts of experience from useful fueling

	if(prob(CHARCOAL_CHANCE) && !is_strong_fuel)
		to_chat(user, span_notice("[src]'s fuel is packed densely enough to have made some charcoal!"))
		addtimer(CALLBACK(src, PROC_REF(spawn_coal)), 1 MINUTES)

/// Takes given ore and smelts it, possibly producing extra sheets if upgraded
/obj/structure/reagent_forge/proc/smelt_ore(obj/item/stack/ore/ore_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)

	if(!ore_item.refined_type)
		fail_message(user, "cannot smelt [ore_item]")
		return

	balloon_alert_to_viewers("smelting...")

	if(!do_after(user, skill_modifier * 3 SECONDS, target = src))
		fail_message(user, "stopped smelting [ore_item]")
		return

	var/src_turf = get_turf(src)
	var/spawning_item = ore_item.refined_type
	var/ore_to_sheet_amount = ore_item.amount

	for(var/spawn_ore in 1 to ore_to_sheet_amount)
		new spawning_item(src_turf)

	in_use = FALSE
	qdel(ore_item)
	return

/// Sets ceramic items from their unusable state into their finished form
/obj/structure/reagent_forge/proc/handle_ceramics(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/ceramic/ceramic_item = attacking_item
	var/ceramic_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME

	if(!ceramic_item.forge_item)
		fail_message(user, "cannot set [ceramic_item]")
		return

	balloon_alert_to_viewers("setting [ceramic_item]")

	if(!do_after(user, ceramic_speed, target = src))
		fail_message("stopped setting [ceramic_item]")
		return

	balloon_alert(user, "finished setting [ceramic_item]")
	var/obj/item/ceramic/spawned_ceramic = new ceramic_item.forge_item(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 50)
	spawned_ceramic.color = ceramic_item.color
	qdel(ceramic_item)
	in_use = FALSE

/// Handles the creation of molten glass from glass sheets
/obj/structure/reagent_forge/proc/handle_glass_sheet_melting(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/stack/sheet/glass/glass_item = attacking_item
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	balloon_alert_to_viewers("heating...")

	if(!do_after(user, glassblowing_speed, target = src) || !glass_item.use(1))
		fail_message(user, "stopped heating [glass_item]")
		return

	in_use = FALSE
	var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 10)
	COOLDOWN_START(spawned_glass, remaining_heat, glassblowing_amount)
	spawned_glass.total_time = glassblowing_amount

/// Handles creating molten glass from a metal cup filled with sand
/obj/structure/reagent_forge/proc/handle_metal_cup_melting(obj/attacking_item, mob/living/user)
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return

	var/obj/item/glassblowing/metal_cup/metal_item = attacking_item
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	if(!metal_item.has_sand)
		fail_message(user, "[metal_item] has no sand")
		return

	balloon_alert_to_viewers("heating...")

	if(!do_after(user, glassblowing_speed, target = src))
		fail_message(user, "stopped heating [metal_item]")
		return

	in_use = FALSE
	metal_item.has_sand = FALSE
	metal_item.icon_state = "metal_cup_empty" // This should be handled a better way but presently this is how it works
	var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 10)
	COOLDOWN_START(spawned_glass, remaining_heat, glassblowing_amount)
	spawned_glass.total_time = glassblowing_amount

/obj/structure/reagent_forge/billow_act(mob/living/user, obj/item/tool)
	if(in_use) // Preventing billow use if the forge is in use to prevent spam
		fail_message(user, "forge busy")
		return

	var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)

	in_use = TRUE

	if(!forge_fuel_strong && !forge_fuel_weak)
		fail_message(user, "no fuel in [src]")
		return

	if(forge_temperature >= MAX_FORGE_TEMP)
		fail_message(user, "[src] cannot heat further")
		return

	balloon_alert_to_viewers("billowing...")

	while(forge_temperature < 91)
		if(!do_after(user, skill_modifier * 2, target = src))
			balloon_alert_to_viewers("stopped billowing")
			return

		forge_temperature += 10
		user.mind.adjust_experience(/datum/skill/smithing, 5) // Billowing, like fueling, gives you some experience in forging

	in_use = FALSE
	balloon_alert(user, "successfully heated [src]")
	return

/obj/structure/reagent_forge/blowrod_act(mob/living/user, obj/item/tool)
	var/obj/item/glassblowing/blowing_rod/blowing_item = tool
	var/glassblowing_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * BASELINE_ACTION_TIME
	var/glassblowing_amount = BASELINE_HEATING_DURATION / user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER)

	if(in_use)
		to_chat(user, span_warning("You cannot do multiple things at the same time!"))
		return
	in_use = TRUE

	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "The temperature is not hot enough to start heating [blowing_item].")
		return

	var/obj/item/glassblowing/molten_glass/find_glass = locate() in blowing_item.contents
	if(!find_glass)
		fail_message(user, "[blowing_item] does not have any glass to heat up.")
		return

	if(!COOLDOWN_FINISHED(find_glass, remaining_heat))
		fail_message(user, "[find_glass] is still has remaining heat.")
		return

	to_chat(user, span_notice("You begin heating up [blowing_item]."))

	if(!do_after(user, glassblowing_speed, target = src))
		fail_message(user, "[blowing_item] is interrupted in its heating process.")
		return

	COOLDOWN_START(find_glass, remaining_heat, glassblowing_amount)
	find_glass.total_time = glassblowing_amount
	to_chat(user, span_notice("You finish heating up [blowing_item]."))
	user.mind.adjust_experience(/datum/skill/smithing, 5)
	user.mind.adjust_experience(/datum/skill/production, 10)
	in_use = FALSE
	return

/obj/structure/reagent_forge/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return TRUE

/obj/structure/reagent_forge/deconstruct(disassembled)
	new /obj/item/stack/sheet/iron/ten(get_turf(src))
	return ..()

/obj/structure/reagent_forge/tier2
	forge_level = FORGE_LEVEL_NOVICE

/obj/structure/reagent_forge/tier3
	forge_level = FORGE_LEVEL_APPRENTICE

/obj/structure/reagent_forge/tier4
	forge_level = FORGE_LEVEL_JOURNEYMAN

/obj/structure/reagent_forge/tier5
	forge_level = FORGE_LEVEL_EXPERT

/obj/structure/reagent_forge/tier6
	forge_level = FORGE_LEVEL_MASTER

/obj/structure/reagent_forge/tier7
	forge_level = FORGE_LEVEL_LEGENDARY

/particles/smoke/mild
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

#undef BASELINE_ACTION_TIME

#undef BASELINE_HEATING_DURATION

#undef FORGE_DEFAULT_TEMPERATURE_CHANGE
#undef MAX_FORGE_TEMP
#undef MIN_FORGE_TEMP
#undef FORGE_HEATING_DURATION

#undef FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
#undef FORGE_LEVEL_NOVICE
#undef FORGE_LEVEL_APPRENTICE
#undef FORGE_LEVEL_JOURNEYMAN
#undef FORGE_LEVEL_EXPERT
#undef FORGE_LEVEL_MASTER
#undef FORGE_LEVEL_LEGENDARY

#undef MAX_TEMPERATURE_LOSS_DECREASE

#undef CHARCOAL_CHANCE


#undef SMOKE_STATE_NONE
#undef SMOKE_STATE_GOOD
#undef SMOKE_STATE_NEUTRAL
#undef SMOKE_STATE_BAD
#undef SMOKE_STATE_NOT_COOKING

/datum/skill/smithing
	name = "Smithing"
	title = "Smithy"
	desc = "The desperate artist who strives after the flames of the forge."
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
		SKILL_PROBS_MODIFIER = list(0, 5, 10, 20, 40, 80, 100)
	)

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/billow_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/billow_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/tong_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/tong_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/hammer_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/hammer_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/blowrod_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/blowrod_act_secondary(mob/living/user, obj/item/tool)
	return
