///The fuel amount wasted as heat
#define GRILL_FUELUSAGE_IDLE 0.5
///The fuel amount used to actually grill the item
#define GRILL_FUELUSAGE_ACTIVE 5

/obj/machinery/grill
	name = "Barbeque grill"
	desc = "Just like the old days. Smokes items over a light heat"
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	processing_flags = START_PROCESSING_MANUALLY
	use_power = NO_POWER_USE

	///The amount of fuel gained from stacks or reagents
	var/grill_fuel = 0
	///The item we are trying to grill
	var/obj/item/food/grilled_item
	///The amount of time the food item has spent on the grill
	var/grill_time = 0
	///Sound loop for the sizzling sound
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Initialize(mapload)
	. = ..()
	create_reagents(30, NO_REACT)
	grill_loop = new(src, FALSE)
	register_context()

/obj/machinery/grill/Destroy()
	QDEL_NULL(grilled_item)
	QDEL_NULL(grill_loop)
	return ..()

/obj/machinery/grill/on_deconstruction(disassembled)
	if(!QDELETED(grilled_item))
		grilled_item.forceMove(drop_location())

	new /obj/item/assembly/igniter(loc)
	new /obj/item/stack/sheet/iron(loc, 5)
	new /obj/item/stack/rods(loc, 5)

	if(grill_fuel > 0)
		var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
		smoke.set_up(1, holder = src, location = loc)
		smoke.start()

/obj/machinery/grill/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item) || (held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1) || (held_item.resistance_flags & INDESTRUCTIBLE))
		return

	if(istype(held_item, /obj/item/stack/sheet/mineral/coal) || istype(held_item, /obj/item/stack/sheet/mineral/wood))
		context[SCREENTIP_CONTEXT_LMB] = "Add fuel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(is_reagent_container(held_item) && held_item.is_open_container() && held_item.reagents.total_volume)
		context[SCREENTIP_CONTEXT_LMB] = "Add fuel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(IS_EDIBLE(held_item) && !HAS_TRAIT(held_item, TRAIT_NODROP))
		context[SCREENTIP_CONTEXT_LMB] = "Add item"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]anchor"
		return CONTEXTUAL_SCREENTIP_SET
	else if(!anchored && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/grill/examine(mob/user)
	. = ..()

	. += span_notice("Add fuel via wood/coal stacks or any open container having a good fuel source")
	. += span_notice("Monkey energy > Oil > Welding fuel > Ethanol. Others cause bad effects")
	. += span_notice("Place any food item on top via hand to start grilling")

	if(!anchored)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")
	if(anchored)
		. += span_notice("Its [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] to work.")

/obj/machinery/grill/update_icon_state()
	if(!QDELETED(grilled_item))
		icon_state = "grill"
		return ..()
	if(grill_fuel > 0)
		icon_state = "grill_on"
		return ..()
	icon_state = "grill_open"
	return ..()

/obj/machinery/grill/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == grilled_item)
		grill_time = 0
		grill_loop.stop()
		grilled_item = null

/obj/machinery/grill/attack_hand(mob/living/user, list/modifiers)
	if(!QDELETED(grilled_item))
		balloon_alert(user, "item removed")
		grilled_item.forceMove(drop_location())
		update_appearance(UPDATE_ICON_STATE)
		return TRUE

	return ..()

/obj/machinery/grill/attack_ai(mob/user)
	return //the ai can't physically flip the lid for the grill


/// Makes grill fuel from a unit of stack
/obj/machinery/grill/proc/burn_stack()
	PRIVATE_PROC(TRUE)

	//compute boost from wood or coal
	var/boost
	for(var/obj/item/stack in contents)
		boost = 5 * (GRILL_FUELUSAGE_IDLE + GRILL_FUELUSAGE_ACTIVE)
		if(istype(stack, /obj/item/stack/sheet/mineral/coal))
			boost *= 2
		if(stack.use(1))
			grill_fuel += boost
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/grill/item_interaction(mob/living/user, obj/item/weapon, list/modifiers)
	if(user.combat_mode || (weapon.item_flags & ABSTRACT) || (weapon.flags_1 & HOLOGRAM_1) || (weapon.resistance_flags & INDESTRUCTIBLE))
		return NONE

	if(istype(weapon, /obj/item/stack/sheet/mineral/coal) || istype(weapon, /obj/item/stack/sheet/mineral/wood))
		if(!QDELETED(grilled_item))
			return NONE
		if(!anchored)
			balloon_alert(user, "anchor it first!")
			return ITEM_INTERACT_BLOCKING

		//required for amount subtypes
		var/target_type
		if(istype(weapon, /obj/item/stack/sheet/mineral/coal))
			target_type = /obj/item/stack/sheet/mineral/coal
		else
			target_type = /obj/item/stack/sheet/mineral/wood

		//transfer or merge stacks if we have enough space
		var/merged = FALSE
		var/obj/item/stack/target = weapon
		for(var/obj/item/stack/stored in contents)
			if(!istype(stored, target_type))
				continue
			if(stored.amount == MAX_STACK_SIZE)
				balloon_alert(user, "no space!")
				return ITEM_INTERACT_BLOCKING
			target.merge(stored)
			merged = TRUE
			break
		if(!merged)
			weapon.forceMove(src)

		to_chat(user, span_notice("You add [src] to the fuel stack."))
		if(!grill_fuel)
			burn_stack()
			begin_processing()
		return ITEM_INTERACT_SUCCESS

	if(is_reagent_container(weapon) && weapon.is_open_container())
		var/obj/item/reagent_containers/container = weapon
		if(!QDELETED(grilled_item))
			return NONE
		if(!anchored)
			balloon_alert(user, "anchor it first!")
			return ITEM_INTERACT_BLOCKING

		var/transfered_amount = weapon.reagents.trans_to(src, container.amount_per_transfer_from_this)
		if(transfered_amount)
			//reagents & their effects on fuel
			var/static/list/fuel_map = list(
				/datum/reagent/consumable/monkey_energy = 4,
				/datum/reagent/fuel/oil = 3,
				/datum/reagent/fuel = 2,
				/datum/reagent/consumable/ethanol = 1
			)

			//compute extra fuel to be obtained from everything transfered
			var/boost
			var/additional_fuel = 0
			for(var/datum/reagent/stored as anything in reagents.reagent_list)
				boost = fuel_map[stored.type]
				if(!boost) //anything we don't recognize as fuel has inverse effects
					boost = -1
				boost = boost * stored.volume * (GRILL_FUELUSAGE_IDLE + GRILL_FUELUSAGE_ACTIVE)
				additional_fuel += boost

			//add to fuel source
			reagents.clear_reagents()
			grill_fuel += additional_fuel
			if(grill_fuel <= 0) //can happen if you put water or something
				grill_fuel = 0
			else
				begin_processing()
			update_appearance(UPDATE_ICON_STATE)

			//feedback
			to_chat(user, span_notice("You transfer [transfered_amount]u to the fuel source."))
			return ITEM_INTERACT_SUCCESS

		balloon_alert(user, "no fuel transfered!")
		return ITEM_INTERACT_BLOCKING

	if(IS_EDIBLE(weapon))
		//sanity checks
		if(!anchored)
			balloon_alert(user, "anchor first!")
			return ITEM_INTERACT_BLOCKING
		if(HAS_TRAIT(weapon, TRAIT_NODROP))
			return ..()
		if(!QDELETED(grilled_item))
			balloon_alert(user, "remove item first!")
			return ITEM_INTERACT_BLOCKING
		if(grill_fuel <= 0)
			balloon_alert(user, "no fuel!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(weapon, src))
			balloon_alert(user, "[weapon] is stuck in your hand!")
			return ITEM_INTERACT_BLOCKING

		//add the item on the grill
		grill_time = 0
		grilled_item = weapon
		var/datum/component/sizzle/sizzle = grilled_item.GetComponent(/datum/component/sizzle)
		if(!isnull(sizzle))
			grill_time = sizzle.time_elapsed()
		to_chat(user, span_notice("You put the [grilled_item] on [src]."))
		update_appearance(UPDATE_ICON_STATE)
		grill_loop.start()
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/grill/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(anchored)
		balloon_alert(user, "unanchor first!")
		return

	if(default_deconstruction_crowbar(tool, ignore_panel = TRUE))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/grill/process(seconds_per_tick)
	if(!anchored)
		return PROCESS_KILL

	var/fuel_usage = GRILL_FUELUSAGE_IDLE * seconds_per_tick
	if(grill_fuel < fuel_usage)
		grill_fuel = 0
		burn_stack()
		if(grill_fuel < fuel_usage) //could not make any fuel
			return PROCESS_KILL

	//use fuel, create smoke puffs for immersion
	grill_fuel -= fuel_usage
	if(SPT_PROB(0.5, seconds_per_tick))
		var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
		smoke.set_up(1, holder = src, location = loc)
		smoke.start()

	fuel_usage = GRILL_FUELUSAGE_ACTIVE * seconds_per_tick
	if(!QDELETED(grilled_item))
		//check to see if we need to burn more fuel
		if(grill_fuel < fuel_usage)
			burn_stack()
			if(grill_fuel < fuel_usage) //could not make any fuel
				return

		//grill the item
		var/last_grill_time = grill_time
		grill_time += seconds_per_tick * 10 //convert to deciseconds
		grilled_item.reagents.add_reagent(/datum/reagent/consumable/char, 0.5 * seconds_per_tick)
		grilled_item.AddComponent(/datum/component/sizzle, grill_time)

		//check to see if we have grilled our item to perfection
		var/time_limit = 20 SECONDS
		var/datum/component/grillable/custom_grilling = grilled_item.GetComponent(/datum/component/grillable)
		if(!isnull(custom_grilling))
			time_limit = custom_grilling.required_cook_time
		if(grill_time >= time_limit)
			grilled_item.RemoveElement(/datum/element/grilled_item, last_grill_time)
			grilled_item.AddElement(/datum/element/grilled_item, grill_time)

		//use fuel
		grill_fuel -= fuel_usage

/obj/machinery/grill/unwrenched
	anchored = FALSE

#undef GRILL_FUELUSAGE_IDLE
#undef GRILL_FUELUSAGE_ACTIVE
