/**Basic plumbing object.
* It doesn't really hold anything special, YET.
* Objects that are plumbing but not a subtype are as of writing liquid pumps and the reagent_dispenser tank
* Also please note that the plumbing component is toggled on and off by the component using a signal from default_unfasten_wrench, so dont worry about it
*/
/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'icons/obj/pipes_n_cables/hydrochem/plumbers.dmi'
	icon_state = "pump"
	density = TRUE
	processing_flags = START_PROCESSING_MANUALLY
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2.75
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_OFFLINE
	reagents = /datum/reagents/plumbing

	///Plumbing machinery is always gonna need reagents, so we might aswell put it here
	var/buffer = 50
	///Flags for reagents, like INJECTABLE, TRANSPARENT bla bla everything thats in DEFINES/reagents.dm
	var/reagent_flags = TRANSPARENT

/obj/machinery/plumbing/Initialize(mapload, bolt = TRUE)
	. = ..()
	set_anchored(bolt)
	create_reagents(buffer, reagent_flags)
	AddComponent(/datum/component/simple_rotation)
	register_context()

/obj/machinery/plumbing/create_reagents(max_vol, flags)
	if(!ispath(reagents))
		qdel(reagents)
	reagents = new reagents(max_vol, flags)
	reagents.my_atom = src

/obj/machinery/plumbing/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]Anchor"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WELDER && !anchored)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	else if(istype(held_item, /obj/item/plunger))
		context[SCREENTIP_CONTEXT_LMB] = "Flush"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/plumbing/examine(mob/user)
	. = ..()
	if(isobserver(user) || !in_range(src, user))
		return

	. += span_notice("The maximum volume display reads: <b>[reagents.maximum_volume]u capacity</b>. Contains:")
	if(reagents.total_volume)
		for(var/datum/reagent/reg as anything in reagents.reagent_list)
			. += span_notice("[round(reg.volume, CHEMICAL_VOLUME_ROUNDING)]u of [reg.name]")
	else
		. += span_notice("Nothing.")

	if(anchored)
		. += span_notice("It's [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("Needs to be [EXAMINE_HINT("anchored")] to start operations.")
		. += span_notice("It can be [EXAMINE_HINT("welded")] apart.")

	. += span_notice("An [EXAMINE_HINT("plunger")] can be used to flush out reagents.")

/obj/machinery/plumbing/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		if(anchored)
			begin_processing()
		else
			end_processing()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/plumbing/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return NONE

	if(anchored)
		balloon_alert(user, "unanchor first!")
		return ITEM_INTERACT_BLOCKING

	if(I.tool_start_check(user, amount = 1))
		to_chat(user, span_notice("You start slicing the [name] apart."))
		if(I.use_tool(src, user, 1.5 SECONDS, volume = 50))
			deconstruct(TRUE)
			to_chat(user, span_notice("You slice the [name] apart."))
			return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/machinery/plumbing/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("furiously plunging...")
	if(do_after(user, 3 SECONDS, target = src))
		user.balloon_alert_to_viewers("finished plunging")
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/**
 * Specialized reagent container for plumbing. Uses the round robin approach of transferring reagents
 * so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
 */
/datum/reagents/plumbing

/**
 * Same as the parent trans_to except only a few arguments have impact here & the rest of the arguments are discarded.
 * Arguments
 *
 * * atom/target - the target we are transfering to
 * * amount - amount to transfer
 * * datum/reagent/target_id - the reagent id we want to transfer. if null everything gets transfered
 * * methods - this is key for deciding between round-robin or proportional transfer. It does not mean the same as the
 * parent proc. LINEAR for round robin(in this technique reagents are missing/lost/not preserved when there isn't enough space to hold them)
 * NONE means everything is transfered regardless of how much space is available in the receiver in proportions
 */
/datum/reagents/plumbing/trans_to(
	atom/target,
	amount = 1,
	multiplier = 1, //unused for plumbing
	datum/reagent/target_id,
	preserve_data = TRUE, //unused for plumbing
	no_react = FALSE, //unused for plumbing we always want reactions
	mob/transferred_by, //unused for plumbing logging is not important inside plumbing machines
	remove_blacklisted = FALSE, //unused for plumbing, we don't care what reagents are inside us
	methods = LINEAR, //default round robin technique for transferring reagents
	show_message = TRUE, //unused for plumbing, used for logging only
	ignore_stomach = FALSE //unused for plumbing, reagents flow only between machines & is not injected to mobs at any point in time
)
	if(QDELETED(target) || !total_volume)
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to trans_to [amount] amount of reagents")
		return FALSE

	if(!isnull(target_id) && !ispath(target_id))
		stack_trace("invalid target reagent id [target_id] passed to trans_to")
		return FALSE

	var/datum/reagents/target_holder
	if(istype(target, /datum/reagents))
		target_holder = target
	else
		target_holder = target.reagents

	// Prevents small amount problems, as well as zero and below zero amounts.
	amount = round(min(amount, total_volume, target_holder.maximum_volume - target_holder.total_volume), CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	//Set up new reagents to inherit the old ongoing reactions
	transfer_reactions(target_holder)

	var/list/cached_reagents = reagent_list
	var/list/reagents_to_remove = list()
	var/transfer_amount
	var/transfered_amount
	var/total_transfered_amount = 0

	var/round_robin = methods & LINEAR
	var/part
	var/to_transfer
	if(round_robin)
		to_transfer = amount
	else
		part = amount / total_volume

	//first add reagents to target
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(round_robin && !to_transfer)
			break

		if(!isnull(target_id))
			if(reagent.type == target_id)
				force_stop_reagent_reacting(reagent)
				transfer_amount = min(amount, reagent.volume)
			else
				continue
		else
			if(round_robin)
				transfer_amount = min(to_transfer, reagent.volume)
			else
				transfer_amount = reagent.volume * part

		if(reagent.intercept_reagents_transfer(target_holder, amount))
			update_total()
			target_holder.update_total()
			continue

		transfered_amount = target_holder.add_reagent(reagent.type, transfer_amount, copy_data(reagent), chem_temp, reagent.purity, reagent.ph, no_react = TRUE, ignore_splitting = reagent.chemical_flags & REAGENT_DONOTSPLIT) //we only handle reaction after every reagent has been transferred.
		if(!transfered_amount)
			continue
		reagents_to_remove += list(list("R" = reagent, "T" = transfer_amount))
		total_transfered_amount += transfered_amount
		if(round_robin)
			to_transfer -= transfered_amount

		if(!isnull(target_id))
			break

	//remove chemicals that were added above
	for(var/list/data as anything in reagents_to_remove)
		var/datum/reagent/reagent = data["R"]
		transfer_amount = data["T"]
		remove_reagent(reagent.type, transfer_amount)

	//handle reactions
	target_holder.handle_reactions()
	src.handle_reactions()

	return round(total_transfered_amount, CHEMICAL_VOLUME_ROUNDING)
