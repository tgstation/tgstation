///Sound played when boulders are teleported manually by hand
#define MANUAL_TELEPORT_SOUND 'sound/machines/mining/manual_teleport.ogg'
///Sound played when boulders are teleported automatically in process()
#define AUTO_TELEPORT_SOUND 'sound/machines/mining/auto_teleport.ogg'
///Time taken to spawn a boulder, also the cooldown applied before the next manual teleportation
#define TELEPORTATION_TIME (1.5 SECONDS)
///Cooldown for automatic teleportation after processing boulders_processing_max number of boulders
#define BATCH_COOLDOWN (3 SECONDS)

/obj/machinery/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "brm"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/brm
	processing_flags = START_PROCESSING_MANUALLY
	anchored = TRUE
	density = TRUE

	/// How many boulders can we process maximum per loop?
	var/boulders_processing_max = 1
	/// Are we trying to actively collect boulders automatically?
	var/toggled_on = FALSE
	///Have we finished processing a full batch of boulders
	var/batch_processing = FALSE

	/// Cooldown used for left click teleportation.
	COOLDOWN_DECLARE(manual_teleport_cooldown)
	/// Cooldown used for automatic teleportation after processing boulders_processing_max number of boulders.
	COOLDOWN_DECLARE(batch_start_cooldown)

/obj/machinery/brm/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/brm(src))
	register_context()

/obj/machinery/brm/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/brm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = CONTEXTUAL_SCREENTIP_SET

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Teleport single boulder"
		context[SCREENTIP_CONTEXT_RMB] = "Toggle [toggled_on ? "Off" : "On"] automatic boulder retrieval"
		return

	if(!isnull(held_item))
		if(held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "" : "Un"] Anchor"
			return
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
			return

		if(panel_open)
			if(held_item.tool_behaviour == TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			else if(is_wire_tool(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Open Wires"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/brm/examine(mob/user)
	. = ..()
	. += span_notice("The small screen reads there are [span_boldnotice("[SSore_generation.available_boulders.len] boulders")] available to teleport.")
	. += span_notice("Can collect upto <b>[boulders_processing_max] boulders</b> at a time.")
	. += span_notice("Automatic boulder retrival can be toggled [EXAMINE_HINT("[toggled_on ? "Off" : "On"]")] with [EXAMINE_HINT("Right Click")].")

	if(anchored)
		. += span_notice("Its [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] to start operations.")

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "Closed" : "Open"].")

	if(panel_open)
		. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] apart.")
		. += span_notice("Use a [EXAMINE_HINT("multitool")] or [EXAMINE_HINT("wirecutters")] to interact with wires.")

/obj/machinery/brm/update_icon_state()
	icon_state = initial(icon_state)

	if(!anchored || !is_operational || machine_stat & (BROKEN | NOPOWER) || panel_open)
		icon_state = "[icon_state]-off"
		return

	if(toggled_on)
		icon_state = "[icon_state]-toggled"
		return

	return ..()

/obj/machinery/brm/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/brm/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/brm/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

///To allow boulders on a conveyer belt to move unobstructed if multiple machines are made on a single line
/obj/machinery/brm/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(istype(mover, /obj/item/boulder))
		return TRUE
	return ..()

/obj/machinery/brm/RefreshParts()
	. = ..()

	boulders_processing_max = 0
	for(var/datum/stock_part/part in component_parts)
		boulders_processing_max += part.tier

	boulders_processing_max = ROUND_UP((boulders_processing_max / 12) * 7)

/obj/machinery/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || panel_open)
		return
	if(!handle_teleport_conditions(user))
		return

	if(pre_collect_boulder())
		balloon_alert(user, "teleporting")
	COOLDOWN_START(src, manual_teleport_cooldown, TELEPORTATION_TIME)

	return TRUE

/**
 * Handles qualifiers for enabling teleportation of boulders.
 * Returns TRUE if the teleportation can proceed, FALSE otherwise.
 * Arguments
 *
 * * mob/user - the mob to inform if conditions aren't met
 */
/obj/machinery/brm/proc/handle_teleport_conditions(mob/user)
	PRIVATE_PROC(TRUE)

	if(!COOLDOWN_FINISHED(src, manual_teleport_cooldown))
		return FALSE
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return FALSE
	if(batch_processing)
		balloon_alert(user, "batch still processing!")
		return FALSE
	playsound(src, MANUAL_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/brm/attack_robot(mob/user)
	. = ..()
	if(. || panel_open)
		return
	if(!handle_teleport_conditions(user))
		return

	if(pre_collect_boulder())
		balloon_alert(user, "teleporting")
	COOLDOWN_START(src, manual_teleport_cooldown, TELEPORTATION_TIME)

	return TRUE

/obj/machinery/brm/attackby(obj/item/attacking_item, mob/user, params)
	if(is_wire_tool(attacking_item) && panel_open)
		wires.interact(user)
		return TRUE
	return ..()

/obj/machinery/brm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || panel_open)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_auto_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Toggles automatic boulder retrieval on.
 * Adjusts the teleportation sound, icon state, and begins processing.
 * @param mob/user The user who toggled the BRM.
 */
/obj/machinery/brm/proc/toggle_auto_on(mob/user)
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return
	if(!is_operational || machine_stat & (BROKEN | NOPOWER))
		return

	toggled_on = ! toggled_on
	if(toggled_on)
		begin_processing()
	else
		end_processing()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/brm/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || panel_open)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	toggle_auto_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/brm/process()
	if(!toggled_on)
		return PROCESS_KILL

	//have some cooldown after processing the previous batch of boulders
	if(!COOLDOWN_FINISHED(src, batch_start_cooldown))
		return

	pre_collect_boulder(FALSE, boulders_processing_max)

/**
 * Begins to collect a boulder from the available boulders list in SSore_generation.
 * Boulders must be in the available boulders list.
 * A selected boulder is picked randomly.
 * The actual movement is then handled by collect_boulder() after a timed callback.
 * Arguments
 *
 * * feedback - should we play sound and display allert if now boulders are available
 * * boulders_remaining - how many boulders we want to try & collect spawning a boulder every TELEPORTATION_TIME seconds
 * * new_batch - is this the very 1st boulder processed from boulders_remaining. Used to wait for all the boulders to be collected
 */
/obj/machinery/brm/proc/pre_collect_boulder(feedback = TRUE, boulders_remaining = 1, new_batch = TRUE)
	PRIVATE_PROC(TRUE)

	if(!anchored || panel_open || !is_operational || machine_stat & (BROKEN | NOPOWER))
		return FALSE

	//no more boulders
	if(!SSore_generation.available_boulders.len)
		if(feedback)
			playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
			balloon_alert_to_viewers("no boulders to collect!")
		batch_processing = FALSE
		return FALSE

	//we are trying to process a new batch of boulders
	if(new_batch)
		if(batch_processing) //the previous one hasen't completed yet, wait
			return FALSE
		batch_processing = TRUE

	var/obj/item/boulder/random_boulder = pick(SSore_generation.available_boulders)
	if(random_boulder.processed_by)
		return FALSE
	SSore_generation.available_boulders -= random_boulder
	random_boulder.processed_by = src
	random_boulder.Shake(shake_interval = TELEPORTATION_TIME)
	addtimer(CALLBACK(src, PROC_REF(collect_boulder), random_boulder, feedback, boulders_remaining), TELEPORTATION_TIME)
	return TRUE

/**
 * Callback to spawn a boulder collected in pre_collect_boulder(). Can be used to collect
 * multiple boulders by setting boulders_remaining but must only be called by pre_collect_boulder()
 * and not directly
 * Arguments
 *
 * * obj/item/boulder/random_boulder - the boulder we are trying to move out
 * * feedback - see pre_collect_boulder()
 * * boulders_remaining - passed back to pre_collect_boulder() if count > 0
 */
/obj/machinery/brm/proc/collect_boulder(obj/item/boulder/random_boulder, feedback, boulders_remaining)
	if(QDELETED(random_boulder))
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("target lost!")
		return FALSE

	flick("brm-flash", src)
	playsound(src, toggled_on ? AUTO_TELEPORT_SOUND : MANUAL_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	random_boulder.forceMove(drop_location())
	random_boulder.pixel_x = rand(-2, 2)
	random_boulder.pixel_y = rand(-2, 2)
	random_boulder.processed_by = null
	balloon_alert_to_viewers("boulder appears!")
	use_power(active_power_usage)

	boulders_remaining -= 1
	if(boulders_remaining <= 0)
		COOLDOWN_START(src, batch_start_cooldown, BATCH_COOLDOWN)
		batch_processing = FALSE
		return TRUE
	else
		return pre_collect_boulder(feedback, boulders_remaining, FALSE)

#undef MANUAL_TELEPORT_SOUND
#undef AUTO_TELEPORT_SOUND
#undef TELEPORTATION_TIME
#undef BATCH_COOLDOWN
