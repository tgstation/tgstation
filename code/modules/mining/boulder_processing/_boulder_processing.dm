/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

	/// What is the efficiency of minerals produced by the machine?
	var/refining_efficiency = 1
	/// How much durability of an boulder can we reduce
	var/boulders_processing_power = BOULDER_SIZE_SMALL
	/// How many boulders can we hold maximum?
	var/boulders_held_max = 1
	/// What sound plays when a thing operates?
	var/usage_sound = 'sound/machines/mining/wooping_teleport.ogg'
	/// Silo link to it's materials list.
	var/datum/component/remote_materials/silo_materials
	/// Mining points held by the machine for miners.
	var/points_held = 0
	///The action verb to display to players
	var/action = "processing"

	/// Cooldown associated with the sound played for collecting mining points.
	COOLDOWN_DECLARE(sound_cooldown)
	/// Cooldown associated with taking in boulds.
	COOLDOWN_DECLARE(accept_cooldown)

/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()

	silo_materials = AddComponent(
		/datum/component/remote_materials, \
		mapload, \
		mat_container_flags = MATCONTAINER_NO_INSERT \
	)

	register_context()

/obj/machinery/bouldertech/LateInitialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/bouldertech/Destroy()
	silo_materials = null
	return ..()

/obj/machinery/bouldertech/on_deconstruction()
	if(length(contents))
		for(var/obj/item/boulder/boulder in contents)
			remove_boulder(boulder)

/obj/machinery/bouldertech/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = CONTEXTUAL_SCREENTIP_SET

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove Boulder"
		return

	if(istype(held_item, /obj/item/boulder))
		context[SCREENTIP_CONTEXT_LMB] = "Insert boulder"
	else if(istype(held_item, /obj/item/card/id) && points_held > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim mining points"
	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "" : "Un"] Anchor"
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"

/obj/machinery/bouldertech/examine(mob/user)
	. = ..()
	. += span_notice("The machine reads that it has [span_bold("[points_held] mining points")] stored. Swipe an ID to claim them.")
	. += span_notice("Click to remove a stored boulder.")

	var/boulder_count = 0
	for(var/obj/item/boulder/potential_boulder in contents)
		boulder_count += 1
	. += span_notice("Storage capacity = <b>[boulder_count]/[boulders_held_max] boulders</b>.")
	. += span_notice("Processing power upto <b>[boulders_processing_power] steps</b> at a time.")

	if(anchored)
		. += span_notice("Its [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] to start operations.")

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")

	if(panel_open)
		. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/bouldertech/update_icon_state()
	. = ..()
	var/suffix = ""
	if(!anchored || !is_operational || (machine_stat & (BROKEN | NOPOWER)) || panel_open)
		suffix = "-off"
	icon_state ="[initial(icon_state)][suffix]"

/obj/machinery/bouldertech/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		if(anchored)
			begin_processing()
		else
			end_processing()
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(istype(mover, /obj/item/boulder))
		var/obj/item/boulder/boulder = mover
		return can_process_boulder(boulder)
	return ..()

/**
 * Can we process the boulder, checks only the boulders state & machines capacity
 * Arguments
 *
 * * obj/item/boulder/new_boulder - the boulder we are checking
 */
/obj/machinery/bouldertech/proc/can_process_boulder(obj/item/boulder/new_boulder)
	PRIVATE_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	//machine not operational
	if(!anchored || panel_open || !is_operational || machine_stat & (BROKEN | NOPOWER))
		return FALSE

	//not a valid boulder
	if(!istype(new_boulder) || QDELETED(new_boulder))
		return FALSE

	//someone just processed this
	if(new_boulder.processed_by)
		return FALSE

	//no space to hold boulders
	var/boulder_count = 0
	for(var/obj/item/boulder/potential_boulder in contents)
		boulder_count += 1
	if(boulder_count > boulders_held_max)
		return FALSE

	//did we cooldown enough to accept a boulder
	return COOLDOWN_FINISHED(src, accept_cooldown)

/**
 * Accepts a boulder into the machine. Used when a boulder is first placed into the machine.
 * Arguments
 *
 * * obj/item/boulder/new_boulder - the boulder to accept
 */
/obj/machinery/bouldertech/proc/accept_boulder(obj/item/boulder/new_boulder)
	if(!can_process_boulder(new_boulder))
		return FALSE

	if(!length(new_boulder.custom_materials)) //Shouldn't happen, but just in case.
		qdel(new_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	new_boulder.forceMove(src)

	COOLDOWN_START(src, accept_cooldown, 1.5 SECONDS)

	return TRUE

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(!can_process_boulder(atom_movable))
		return

	INVOKE_ASYNC(src, PROC_REF(accept_boulder), atom_movable)

/**
 * Looks for a boost to the machine's efficiency, and applies it if found.
 * Applied more on the chemistry integration but can be used for other things if desired.
 */
/obj/machinery/bouldertech/proc/check_for_boosts()
	PROTECTED_PROC(TRUE)

	refining_efficiency = initial(refining_efficiency) //Reset refining efficiency to 100%.

/**
 * Checks if this machine can process this material
 * Arguments
 *
 * * datum/material/mat - the material to process
 */
/obj/machinery/bouldertech/proc/can_process_material(datum/material/mat)
	PROTECTED_PROC(TRUE)

	return FALSE

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, params)
	if(panel_open)
		return ..()

	if(istype(attacking_item, /obj/item/boulder))
		. = TRUE
		var/obj/item/boulder/my_boulder = attacking_item
		if(!accept_boulder(my_boulder))
			balloon_alert_to_viewers("cannot accept!")
			return
		balloon_alert_to_viewers("accepted")
		return

	if(istype(attacking_item, /obj/item/card/id))
		. = TRUE
		if(points_held <= 0)
			balloon_alert_to_viewers("no points to claim!")
			if(!COOLDOWN_FINISHED(src, sound_cooldown))
				return
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
			return

		var/obj/item/card/id/id_card = attacking_item
		var/amount = tgui_input_number(user, "How many mining points do you wish to claim? ID Balance: [id_card.registered_account.mining_points], stored mining points: [points_held]", "Transfer Points", max_value = points_held, min_value = 0, round_value = 1)
		if(!amount)
			return
		if(amount > points_held)
			amount = points_held
		id_card.registered_account.mining_points += amount
		points_held = round(points_held - amount)
		to_chat(user, span_notice("You claim [amount] mining points from \the [src] to [id_card]."))
		return

	return ..()

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || panel_open)
		return

	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(panel_open)
		balloon_alert(user, "close panel!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/boulder/boulder = locate(/obj/item/boulder) in contents
	if(!boulder)
		balloon_alert_to_viewers("No boulders to remove!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	remove_boulder(boulder)

	return SECONDARY_ATTACK_CONTINUE_CHAIN

/**
 * Accepts a boulder into the machinery, then converts it into minerals.
 * If the boulder can be fully processed by this machine, we take the materials, insert it into the silo, and destroy the boulder.
 * If the boulder has materials left, we make a copy of the boulder to hold the processable materials, take the processable parts, and eject the original boulder.
 * @param chosen_boulder The boulder to being breaking down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	PRIVATE_PROC(TRUE)

	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE
	if(!length(chosen_boulder.custom_materials))
		qdel(chosen_boulder)
		playsound(loc, usage_sound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE

	//here we loop through the boulder's ores
	var/list/rejected_mats = list()
	for(var/datum/material/possible_mat as anything in chosen_boulder.custom_materials)
		var/quantity = chosen_boulder.custom_materials[possible_mat]
		if(!can_process_material(possible_mat))
			rejected_mats[possible_mat] = quantity
			continue
		points_held = round(points_held + (quantity * possible_mat.points_per_unit * MINING_POINT_MACHINE_MULTIPLIER)) // put point total here into machine
		if(!silo_materials.mat_container.insert_amount_mat(quantity * refining_efficiency, possible_mat))
			rejected_mats[possible_mat] = quantity
	use_power(BASE_MACHINE_ACTIVE_CONSUMPTION)

	//Calls the relevant behavior for boosting the machine's efficiency, if able.
	check_for_boosts()
	chosen_boulder.set_custom_materials(rejected_mats, refining_efficiency)

	//break the boulder down if we have processed all its materials
	if(!length(chosen_boulder.custom_materials))
		playsound(loc, usage_sound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(istype(chosen_boulder, /obj/item/boulder/artifact))
			points_held = round((points_held + MINER_POINT_MULTIPLIER) * MINING_POINT_MACHINE_MULTIPLIER) /// Artifacts give bonus points!
		chosen_boulder.break_apart()
		return TRUE //We've processed all the materials in the boulder, so we can just destroy it in break_apart.

	//eject the boulder since we are done with it
	return remove_boulder(chosen_boulder)

/obj/machinery/bouldertech/process()
	if(!anchored || panel_open || !is_operational || machine_stat & (BROKEN | NOPOWER))
		return

	var/boulders_found = FALSE
	var/boulder_removed = FALSE
	var/boulders_step_power = boulders_processing_power
	while(boulders_step_power > 0)
		boulders_found = FALSE
		for(var/obj/item/boulder/potential_boulder in contents)
			boulders_found = TRUE
			if(boulders_step_power <= 0)
				break //Try again next time
			boulders_step_power--

			var/step_power = min(boulders_step_power, potential_boulder.durability)
			if(potential_boulder.durability > 0)
				potential_boulder.durability -= step_power //boulder processed by set power.
				boulders_step_power -= step_power
				if(potential_boulder.durability > 0) //check again if we have to go another round
					continue

			boulder_removed = breakdown_boulder(potential_boulder) //Crack that boulder open!
			if(boulders_step_power <= 0)
				break

		//no boulders are present
		if(!boulders_found)
			break

	//when the boulder is removed it plays sound and  displays a balloon alert. don't overlap when that happens
	if(boulders_found && !boulder_removed)
		playsound(loc, usage_sound, 29, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		balloon_alert_to_viewers(action)

/**
 * Ejects a boulder from the machine. Used when a boulder is finished processing, or when a boulder can't be processed.
 * Arguments
 *
 * * obj/item/boulder/specific_boulder - the boulder to remove
 */
/obj/machinery/bouldertech/proc/remove_boulder(obj/item/boulder/specific_boulder)
	PRIVATE_PROC(TRUE)

	if(QDELETED(specific_boulder))
		return FALSE
	if(!length(specific_boulder.custom_materials))
		qdel(specific_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE

	//Reset durability to little random lower value cause we have crushed it so many times
	var/size = specific_boulder.boulder_size
	if(size == BOULDER_SIZE_SMALL)
		specific_boulder.durability = rand(2, BOULDER_SIZE_SMALL - 1)
	else
		specific_boulder.durability = rand(BOULDER_SIZE_SMALL, size - 1)
	specific_boulder.processed_by = src //so we don't take in the boulder again after we just ejected it
	specific_boulder.forceMove(drop_location())
	specific_boulder.processed_by = null //now since move is done we can safely clear the reference

	balloon_alert_to_viewers("clear!")
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	return TRUE
