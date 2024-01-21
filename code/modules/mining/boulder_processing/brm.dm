#define MANUAL_TELEPORT_SOUND 'sound/machines/mining/manual_teleport.ogg'
#define AUTO_TELEPORT_SOUND 'sound/machines/mining/auto_teleport.ogg'

/obj/machinery/bouldertech/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."
	icon_state = "brm"
	circuit = /obj/item/circuitboard/machine/brm
	usage_sound = MANUAL_TELEPORT_SOUND
	processing_flags = START_PROCESSING_MANUALLY
	boulders_held_max = 2
	/// Are we trying to actively collect boulders automatically?
	var/toggled_on = FALSE
	/// How long does it take to collect a boulder?
	var/teleportation_time = 1.5 SECONDS
	/// Cooldown used for left click teleportation.
	COOLDOWN_DECLARE(manual_teleport_cooldown)

/obj/machinery/bouldertech/brm/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/brm(src))

/obj/machinery/bouldertech/brm/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/bouldertech/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!handle_teleport_conditions(user))
		return
	pre_collect_boulder()

	COOLDOWN_START(src, manual_teleport_cooldown, teleportation_time)

/obj/machinery/bouldertech/brm/attack_robot(mob/user)
	if(!handle_teleport_conditions(user))
		return
	pre_collect_boulder()

	COOLDOWN_START(src, manual_teleport_cooldown, teleportation_time)

/obj/machinery/bouldertech/brm/attackby(obj/item/attacking_item, mob/user, params)
	if(is_wire_tool(attacking_item) && panel_open)
		wires.interact(user)
		return TRUE
	return ..()

/obj/machinery/bouldertech/brm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_auto_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/bouldertech/brm/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_auto_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/bouldertech/brm/process()
	if(SSore_generation.available_boulders.len < 1)
		say("No boulders to collect. Entering idle mode.")
		toggled_on = FALSE
		update_appearance(UPDATE_ICON_STATE)
		return PROCESS_KILL
	for(var/i in 1 to boulders_processing_max)
		if(pre_collect_boulder())
			continue
		toggled_on = FALSE
		update_appearance(UPDATE_ICON_STATE)
		return PROCESS_KILL
	for(var/obj/item/boulder/ground_rocks in loc.contents)
		boulders_contained += ground_rocks
		if(boulders_contained.len < boulders_held_max)
			continue
		toggled_on = FALSE
		boulders_contained.Cut()
		update_appearance(UPDATE_ICON_STATE)
		return PROCESS_KILL

/obj/machinery/bouldertech/brm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Teleport single boulder"
	context[SCREENTIP_CONTEXT_RMB] = "Toggle automatic boulder retrieval"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/bouldertech/brm/examine(mob/user)
	. = ..()
	. += span_notice("The small screen reads there are [span_boldnotice("[SSore_generation.available_boulders.len] boulders")] available to teleport.")

/obj/machinery/bouldertech/brm/RefreshParts()
	. = ..()
	var/scanner_stack = 0
	var/laser_stack = 0
	for(var/datum/stock_part/scanning_module/scanner in component_parts)
		scanner_stack += scanner.tier
	boulders_processing_max = scanner_stack
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		laser_stack += laser.tier
	boulders_held_max = laser_stack + 1

/obj/machinery/bouldertech/brm/update_icon_state()
	if(toggled_on && !panel_open)
		icon_state = "[initial(icon_state)]-toggled"
		return
	return ..()

/**
 * Handles qualifiers for enabling teleportation of boulders.
 * Returns TRUE if the teleportation can proceed, FALSE otherwise.
 */
/obj/machinery/bouldertech/brm/proc/handle_teleport_conditions(mob/user)
	if(!COOLDOWN_FINISHED(src, manual_teleport_cooldown))
		return FALSE
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return FALSE
	playsound(src, MANUAL_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/**
 * Begins to collect a boulder from the available boulders list in SSore_generation.
 * Boulders must not be processed by another BRM or machine, and must be in the available boulders list.
 * A selected boulder is picked randomly.
 * The actual movement is then handled by collect_boulder() after a timed callback.
 */
/obj/machinery/bouldertech/brm/proc/pre_collect_boulder()
	if(!SSore_generation.available_boulders.len)
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("no boulders to collect!")
		return FALSE //Nothing to collect
	var/obj/item/boulder/random_boulder = pick(SSore_generation.available_boulders)
	if(random_boulder.processed_by)
		return FALSE

	random_boulder.processed_by = src
	random_boulder.Shake(duration = 1.5 SECONDS)
	SSore_generation.available_boulders -= random_boulder
	addtimer(CALLBACK(src, PROC_REF(collect_boulder), random_boulder), 1.5 SECONDS)
	return TRUE

/**
 * Collects a boulder from the available boulders list in SSore_generation.
 * Handles the movement of the boulder as well as visual effects on the BRM.
 * @param obj/item/boulder/random_boulder The boulder to collect.
 */
/obj/machinery/bouldertech/brm/proc/collect_boulder(obj/item/boulder/random_boulder)
	flick("brm-flash", src)
	if(QDELETED(random_boulder))
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("target lost!")
		return FALSE
	playsound(src, AUTO_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	random_boulder.forceMove(drop_location())
	random_boulder.processed_by = null
	random_boulder.pixel_x = rand(-2, 2)
	random_boulder.pixel_y = rand(-2, 2)
	balloon_alert_to_viewers("boulder appears!")
	random_boulder.visible_message(span_warning("[random_boulder] suddenly appears!"))
	use_power(BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1)
	return TRUE

/**
 * Toggles automatic boulder retrieval on.
 * Adjusts the teleportation sound, icon state, and begins processing.
 * @param mob/user The user who toggled the BRM.
 */
/obj/machinery/bouldertech/brm/proc/toggle_auto_on(mob/user)
	if(panel_open)
		if(user)
			balloon_alert(user, "close panel first!")
		return
	toggled_on = TRUE
	START_PROCESSING(SSmachines, src)
	update_appearance(UPDATE_ICON_STATE)
	usage_sound = AUTO_TELEPORT_SOUND

#undef MANUAL_TELEPORT_SOUND
#undef AUTO_TELEPORT_SOUND
