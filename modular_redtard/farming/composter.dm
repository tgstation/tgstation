/// Ratwood's composter (code/modules/farming/composter.dm): food, stalks and apple cores go in raw; raw compost has to be
/// flipped (right click, by hand or quicker with a pitchfork or a shovel), and flipped compost rots into ready compost, a quarter
/// of it drying out to be flipped again. Ready compost comes out a heap at a time by hand. It works on SSobj only while flipped
/// compost is rotting (Ratwood SSprocessing every second).
/obj/structure/composter
	/// Compost waiting to be flipped (Ratwood unflipped_compost).
	var/unflipped_compost = 0
	/// Compost rotting (Ratwood flipped_compost).
	var/flipped_compost = 0
	/// Compost ready to take out (Ratwood ready_compost).
	var/ready_compost = 0
	/// Whether it is processing.
	var/processing = FALSE
	/// Share of the most compost it starts with, ready (Ratwood halffull and full composters).
	var/rogue_start_share = 0

/obj/structure/composter/halffull
	rogue_start_share = 0.5

/obj/structure/composter/full
	rogue_start_share = 1

/obj/structure/composter/Initialize(mapload)
	. = ..()
	if(rogue_start_share)
		ready_compost = rogue_value("farm_compost_max") * rogue_start_share
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/composter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/composter/examine(mob/user)
	. = ..()
	var/per_item = rogue_value("farm_compost_per_item")
	if(ready_compost > per_item)
		. += span_info("There is some ready compost.")
	if(unflipped_compost > flipped_compost && unflipped_compost >= per_item)
		. += span_warning("The compost requires flipping!")
		. += span_notice("Flip it by right clicking it with an empty hand.")

/obj/structure/composter/process(seconds_per_tick)
	var/dt = seconds_per_tick * (1 SECONDS)
	var/compost_to_process = min(dt * rogue_value("farm_compost_rate") / (1 MINUTES), flipped_compost)
	// Change flipped compost into most processed compost, and some back unflipped
	var/dry_share = rogue_value("farm_compost_dry_share")
	flipped_compost -= compost_to_process
	unflipped_compost += compost_to_process * dry_share
	ready_compost += compost_to_process * (1 - dry_share)
	maybe_stop_processing()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/composter/proc/get_total_compost()
	return unflipped_compost + flipped_compost + ready_compost

/obj/structure/composter/proc/try_handle_flipping_compost(obj/item/attacking_item, mob/living/user)
	var/using_tool = istype(attacking_item, /obj/item/rogueweapon/pitchfork) || istype(attacking_item, /obj/item/rogueweapon/shovel)
	var/do_time = using_tool ? rogue_value("farm_compost_flip_tool_time") : rogue_value("farm_compost_flip_hand_time")
	var/fatigue = rogue_value("farm_compost_flip_fatigue") * (using_tool ? 0.5 : 1)
	if(do_after(user, user.rogue_farming_time(do_time), target = src))
		user.rogue_farming_fatigue(fatigue)
		to_chat(user, span_notice("I flip the compost."))
		if(using_tool)
			playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
		flip_compost()
	return TRUE

/obj/structure/composter/proc/flip_compost()
	flipped_compost += unflipped_compost
	unflipped_compost = 0
	maybe_start_processing()
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood try_handle_adding_compost(): what rots goes in, as long as there is room.
/obj/structure/composter/proc/try_handle_adding_compost(obj/item/attacking_item, mob/living/user, batch_process)
	var/compost_value = 0
	if(istype(attacking_item, /obj/item/reagent_containers/food/snacks) || istype(attacking_item, /obj/item/natural/chaff))
		compost_value = rogue_value("farm_compost_food")
	if(istype(attacking_item, /obj/item/trash/applecore))
		compost_value = rogue_value("farm_compost_core")
	if(compost_value <= 0)
		return FALSE
	var/most = rogue_value("farm_compost_max")
	if(get_total_compost() >= most)
		if(!batch_process)
			to_chat(user, span_warning("There's too much compost!"))
		return FALSE
	unflipped_compost += min(compost_value, most - get_total_compost())
	if(!batch_process)
		to_chat(user, span_notice("I add \the [attacking_item] to \the [src]"))
	qdel(attacking_item)
	return TRUE

/obj/structure/composter/proc/try_handle_removing_compost(mob/living/user)
	if(ready_compost < rogue_value("farm_compost_per_item"))
		to_chat(user, span_warning("There's not enough processed compost!"))
		return TRUE
	user.rogue_farming_fatigue(rogue_value("farm_compost_take_fatigue"))
	to_chat(user, span_notice("I take out some ready compost."))
	var/obj/item/compost/compost = take_out_compost()
	if(compost)
		user.put_in_active_hand(compost)
	return TRUE

/obj/structure/composter/proc/take_out_compost()
	var/per_item = rogue_value("farm_compost_per_item")
	if(ready_compost < per_item)
		return
	ready_compost -= per_item
	. = new /obj/item/compost(get_turf(src))
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood attackby(): compostables go in, a bag's compostables all at once.
/obj/structure/composter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(istype(tool, /obj/item/storage/roguebag) && length(tool.contents))
		user.changeNext_move(CLICK_CD_MELEE)
		if(get_total_compost() >= rogue_value("farm_compost_max"))
			to_chat(user, span_warning("There's too much compost!"))
			return ITEM_INTERACT_BLOCKING
		var/success = FALSE
		for(var/obj/item/bagged_item in tool.contents)
			if(try_handle_adding_compost(bagged_item, user, TRUE))
				success = TRUE
				if(get_total_compost() >= rogue_value("farm_compost_max"))
					break
		if(success)
			to_chat(user, span_info("I dump all the compostables inside [tool] into [src]."))
			tool.update_appearance()
		else
			to_chat(user, span_warning("There's nothing in [tool] that can be composted."))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	if(try_handle_adding_compost(tool, user, FALSE))
		user.changeNext_move(CLICK_CD_MELEE)
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Ratwood attack_hand(): take out a heap of ready compost.
/obj/structure/composter/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	return try_handle_removing_compost(user)

/// Ratwood attack_right(): flip the compost by hand...
/obj/structure/composter/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	INVOKE_ASYNC(src, PROC_REF(try_handle_flipping_compost), null, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// ...or with whatever is in the hand, quicker with a pitchfork or a shovel.
/obj/structure/composter/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	try_handle_flipping_compost(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/composter/update_overlays()
	. = ..()
	var/most = rogue_value("farm_compost_max")
	var/per_item = rogue_value("farm_compost_per_item")
	var/total_unprocessed = unflipped_compost + flipped_compost
	var/unprocessed_dry_overlay_name
	if(total_unprocessed >= most * 0.6)
		unprocessed_dry_overlay_name = "pre_compost_heavy_dry"
		. += mutable_appearance(icon, "pre_compost_heavy")
	else if(total_unprocessed >= most * 0.3)
		unprocessed_dry_overlay_name = "pre_compost_mid_dry"
		. += mutable_appearance(icon, "pre_compost_mid")
	else if(total_unprocessed >= per_item)
		unprocessed_dry_overlay_name = "pre_compost_low_dry"
		. += mutable_appearance(icon, "pre_compost_low")
	if(unflipped_compost > flipped_compost && unprocessed_dry_overlay_name)
		var/mutable_appearance/dry_ma = mutable_appearance(icon, unprocessed_dry_overlay_name)
		dry_ma.color = "#ffbb6d"
		dry_ma.alpha = 40
		. += dry_ma
	if(ready_compost >= most * 0.6)
		. += mutable_appearance(icon, "post_compost_heavy")
	else if(ready_compost >= most * 0.3)
		. += mutable_appearance(icon, "post_compost_mid")
	else if(ready_compost >= per_item)
		. += mutable_appearance(icon, "post_compost_low")

/obj/structure/composter/proc/maybe_start_processing()
	// Start processing if there is any flipped compost to process
	if(!processing && flipped_compost > 0 && rogue_farming_enabled())
		START_PROCESSING(SSobj, src)
		processing = TRUE

/obj/structure/composter/proc/maybe_stop_processing()
	// Stop processing if there is no flipped compost left
	if(processing && flipped_compost <= 0)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
