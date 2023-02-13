#define PROCESSOR_SELECT_RECIPE(movable_input) LAZYACCESS(processor_inputs[type], movable_input.type)

/obj/machinery/processor
	name = "food processor"
	desc = "An industrial grinder used to process meat and other foods. Keep hands clear of intake area while operating."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/processor
	var/broken = FALSE
	var/processing = FALSE
	var/rating_speed = 1
	var/rating_amount = 1
	var/list/processor_contents
	/*
	 * Static, nested list. The first layer contains all food processor types.
	 * The second layer contains input typepaths (key) and the associated food_processor_process datums (assoc) the processor can access.
	 * This allows for different types of processor to produce different outputs from same input as long as the recipes require different processors.
	 */
	var/static/list/processor_inputs

/obj/machinery/processor/Initialize(mapload)
	. = ..()
	if(processor_inputs)
		return
	processor_inputs = list()
	for(var/datum/food_processor_process/recipe as anything in subtypesof(/datum/food_processor_process))
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

/obj/machinery/processor/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		rating_amount = matter_bin.tier
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		rating_speed = manipulator.tier

/obj/machinery/processor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Outputting <b>[rating_amount]</b> item(s) at <b>[rating_speed*100]%</b> speed.")

/obj/machinery/processor/proc/process_food(datum/food_processor_process/recipe, atom/movable/what)
	if(recipe.output && loc && !QDELETED(src))
		var/list/cached_mats = recipe.preserve_materials && what.custom_materials
		var/cached_multiplier = (recipe.food_multiplier * rating_amount)
		for(var/i in 1 to cached_multiplier)
			var/atom/processed_food = new recipe.output(drop_location())
			what.reagents.copy_to(processed_food, what.reagents.total_volume, multiplier = 1 / cached_multiplier)
			if(cached_mats)
				processed_food.set_custom_materials(cached_mats, 1 / cached_multiplier)

	if(isliving(what))
		var/mob/living/themob = what
		themob.gib(TRUE,TRUE,TRUE)
	else
		qdel(what)
	LAZYREMOVE(processor_contents, what)

/obj/machinery/processor/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/processor/attackby(obj/item/O, mob/living/user, params)
	if(processing)
		to_chat(user, span_warning("[src] is in the process of processing!"))
		return TRUE
	if(default_deconstruction_screwdriver(user, "processor", "processor1", O))
		return

	if(default_pry_open(O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/S in T.contents)
			if(!IS_EDIBLE(S))
				continue
			var/datum/food_processor_process/P = PROCESSOR_SELECT_RECIPE(S)
			if(P)
				if(T.atom_storage.attempt_remove(S, src))
					LAZYADD(processor_contents, S)
					loaded++

		if(loaded)
			to_chat(user, span_notice("You insert [loaded] items into [src]."))
		return

	var/datum/food_processor_process/P = PROCESSOR_SELECT_RECIPE(O)
	if(P)
		user.visible_message(span_notice("[user] put [O] into [src]."), \
			span_notice("You put [O] into [src]."))
		user.transferItemToLoc(O, src, TRUE)
		LAZYADD(processor_contents, O)
		return 1
	else if(!user.combat_mode)
		to_chat(user, span_warning("That probably won't blend!"))
		return 1
	else
		return ..()

/obj/machinery/processor/interact(mob/user)
	if(processing)
		to_chat(user, span_warning("[src] is in the process of processing!"))
		return TRUE
	if(ismob(user.pulling) && PROCESSOR_SELECT_RECIPE(user.pulling))
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		var/mob/living/pushed_mob = user.pulling
		visible_message(span_warning("[user] stuffs [pushed_mob] into [src]!"))
		pushed_mob.forceMove(src)
		LAZYADD(processor_contents, pushed_mob)
		user.stop_pulling()
		return
	if(!LAZYLEN(processor_contents))
		to_chat(user, span_warning("[src] is empty!"))
		return TRUE
	processing = TRUE
	user.visible_message(span_notice("[user] turns on [src]."), \
		span_notice("You turn on [src]."), \
		span_hear("You hear a food processor."))
	playsound(src.loc, 'sound/machines/blender.ogg', 50, TRUE)
	use_power(active_power_usage)
	var/total_time = 0
	for(var/atom/movable/movable_input as anything in processor_contents)
		var/datum/food_processor_process/recipe = PROCESSOR_SELECT_RECIPE(movable_input)
		if (!recipe)
			log_admin("DEBUG: [movable_input] in processor doesn't have a suitable recipe. How did it get in there? Please report it immediately!!!")
			continue
		total_time += recipe.time
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = (total_time / rating_speed)*5) //start shaking
	sleep(total_time / rating_speed)
	for(var/atom/movable/O in processor_contents)
		var/datum/food_processor_process/P = PROCESSOR_SELECT_RECIPE(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How do you put it in?")
			continue
		process_food(P, O)
	pixel_x = base_pixel_x //return to its spot after shaking
	processing = FALSE
	visible_message(span_notice("\The [src] finishes processing."))

/obj/machinery/processor/verb/eject()
	set category = "Object"
	set name = "Eject Contents"
	set src in oview(1)
	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if (!usr.canUseTopic())
		return
	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_UI))
			return
	dump_inventory_contents()
	add_fingerprint(usr)

/obj/machinery/processor/dump_inventory_contents()
	. = ..()
	if(!LAZYLEN(processor_contents))
		processor_contents = null

/obj/machinery/processor/container_resist_act(mob/living/user)
	user.forceMove(drop_location())
	user.visible_message(span_notice("[user] crawls free of the processor!"))

/obj/machinery/processor/slime
	name = "slime processor"
	desc = "An industrial grinder with a sticker saying appropriated for science department. Keep hands clear of intake area while operating."
	circuit = /obj/item/circuitboard/machine/processor/slime

/obj/machinery/processor/slime/adjust_item_drop_location(atom/movable/AM)
	var/static/list/slimecores = subtypesof(/obj/item/slime_extract)
	var/i = 0
	if(!(i = slimecores.Find(AM.type))) // If the item is not found
		return
	if (i <= 16) // If in the first 12 slots
		AM.pixel_x = AM.base_pixel_x - 12 + ((i%4)*8)
		AM.pixel_y = AM.base_pixel_y - 12 + (round(i/4)*8)
		return i
	var/ii = i - 16
	AM.pixel_x = AM.base_pixel_x - 8 + ((ii%3)*8)
	AM.pixel_y = AM.base_pixel_y - 8 + (round(ii/3)*8)
	return i

/obj/machinery/processor/slime/process()
	if(processing)
		return
	var/mob/living/simple_animal/slime/picked_slime
	for(var/mob/living/simple_animal/slime/slime in range(1,src))
		if(slime.loc == src)
			continue
		if(isslime(slime))
			if(slime.stat)
				picked_slime = slime
				break
	if(!picked_slime)
		return
	var/datum/food_processor_process/P = PROCESSOR_SELECT_RECIPE(picked_slime)
	if (!P)
		return

	visible_message(span_notice("[picked_slime] is sucked into [src]."))
	LAZYADD(processor_contents, picked_slime)
	picked_slime.forceMove(src)

/obj/machinery/processor/slime/process_food(datum/food_processor_process/recipe, atom/movable/what)
	var/mob/living/simple_animal/slime/S = what
	if (istype(S))
		var/C = S.cores
		if(S.stat != DEAD)
			LAZYREMOVE(processor_contents, S)
			S.forceMove(drop_location())
			S.visible_message(span_notice("[C] crawls free of the processor!"))
			return
		for(var/i in 1 to (C+rating_amount-1))
			var/atom/movable/item = new S.coretype(drop_location())
			adjust_item_drop_location(item)
			SSblackbox.record_feedback("tally", "slime_core_harvested", 1, S.colour)
	..()

#undef PROCESSOR_SELECT_RECIPE
