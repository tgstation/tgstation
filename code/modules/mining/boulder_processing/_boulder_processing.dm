/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE

	/// What is the efficiency of minerals produced by the machine?
	var/refining_efficiency = 1
	/// How many boulders can we process maximum per loop?
	var/boulders_processing_max = 1
	/// What boulder(s) are we holding?
	var/list/boulders_contained = list()
	/// How many boulders can we hold maximum?
	var/boulders_held_max = 1
	/// Does this machine have a mineral storage link to the silo?
	var/holds_minerals = FALSE
	/// What materials do we accept and process out of boulders? Removing iron from an iron/glass boulder would leave a boulder with glass.
	var/list/processable_materials = list()
	/// If we get a boulder with one of these inside, we'll drop it back out.
	var/static/list/drop_if_contained = list(
		/obj/item/relic,
	)

	/// What sound plays when a thing operates?
	var/usage_sound = 'sound/machines/mining/wooping_teleport.ogg'
	/// Cooldown associated with the usage_sound played.
	COOLDOWN_DECLARE(sound_cooldown)

	/// Silo link to it's materials list.
	var/datum/component/remote_materials/silo_materials
	///Does this machine hold mining points?
	var/holds_mining_points = FALSE
	/// Mining points held by the machine for miners.
	var/points_held = 0

/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()
	register_context()
	if(holds_minerals)
		silo_materials = AddComponent(/datum/component/remote_materials, mapload)

/obj/machinery/bouldertech/LateInitialize()
	. = ..()
	if(!holds_minerals)
		return
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/bouldertech/Destroy()
	boulders_contained = null
	silo_materials = null
	return ..()

/obj/machinery/bouldertech/update_icon_state()
	. = ..()
	if(anchored)
		icon_state ="[initial(icon_state)]"
	else
		icon_state ="[initial(icon_state)]-off"

/obj/machinery/bouldertech/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		update_appearance(UPDATE_ICON_STATE)
		START_PROCESSING(SSmachines, src)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_pry_open(tool, close_after_pry = TRUE, closed_density = FALSE))
		return ITEM_INTERACT_SUCCESS
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, params)
	if(holds_minerals && istype(attacking_item, /obj/item/boulder))
		var/obj/item/boulder/my_boulder = attacking_item
		update_boulder_count()
		if(!accept_boulder(my_boulder))
			balloon_alert_to_viewers("full!")
			return
		balloon_alert_to_viewers("accepted")
		START_PROCESSING(SSmachines, src)
		return TRUE
	if(istype(attacking_item, /obj/item/card/id) && holds_mining_points)
		if(points_held <= 0)
			balloon_alert_to_viewers("no points to claim!")
			if(!COOLDOWN_FINISHED(src, sound_cooldown))
				return TRUE
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
			return FALSE
		var/obj/item/card/id/id_card = attacking_item
		var/amount = tgui_input_number(user, "How many mining points do you wish to claim? ID Balance: [id_card.registered_account.mining_points], stored mining points: [points_held]", "Transfer Points", max_value = points_held, min_value = 0, round_value = 1)
		if(!amount)
			return TRUE
		if(amount > points_held)
			amount = points_held
		id_card.registered_account.mining_points += amount
		points_held = round(points_held - amount)
		to_chat(user, span_notice("You claim [amount] mining points from \the [src] to [id_card]."))
		return TRUE
	return ..()

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		balloon_alert(user, "anchor first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!holds_minerals)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(!length(boulders_contained))
		balloon_alert_to_viewers("No boulders to remove!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	remove_boulder(pick(boulders_contained))
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/machinery/bouldertech/deconstruct(disassembled)
	. = ..()
	if(length(contents))
		for(var/obj/item/boulder/boulder in contents)
			remove_boulder(boulder)

/obj/machinery/bouldertech/process()
	if(!anchored)
		return PROCESS_KILL
	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)
		if(QDELETED(potential_boulder))
			boulders_contained -= potential_boulder
			break
		if(boulders_concurrent <= 0)
			break //Try again next time

		if(!istype(potential_boulder, /obj/item/boulder))
			potential_boulder.forceMove(drop_location())
			CRASH("\The [src] had a non-boulder in it's boulders contained!")

		var/obj/item/boulder/boulder = potential_boulder
		if(boulder.durability < 0)
			CRASH("\The [src] had a boulder with negative durability!")
		if(!check_for_processable_materials(boulder.custom_materials)) //Checks for any new materials we can process.
			boulders_concurrent-- //We count skipped boulders
			remove_boulder(boulder)
			continue
		boulders_concurrent--
		boulder.durability-- //One less durability to the processed boulder.
		if(COOLDOWN_FINISHED(src, sound_cooldown))
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(loc, usage_sound, 29, FALSE, SHORT_RANGE_SOUND_EXTRARANGE) //This can get annoying. One play per process() call.
		stop_processing_check = TRUE
		if(boulder.durability <= 0)
			breakdown_boulder(boulder) //Crack that bouwlder open!
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL


/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(istype(mover, /obj/item/boulder))
		var/obj/item/boulder/boulder = mover
		return boulder.can_get_processed()
	return ..()

/obj/machinery/bouldertech/examine(mob/user)
	. = ..()
	if(holds_mining_points)
		. += span_notice("The machine reads that it has [span_bold("[points_held] mining points")] stored. Swipe an ID to claim them.")

/**
 * Accepts a boulder into the machinery, then converts it into minerals.
 * If the boulder can be fully processed by this machine, we take the materials, insert it into the silo, and destroy the boulder.
 * If the boulder has materials left, we make a copy of the boulder to hold the processable materials, take the processable parts, and eject the original boulder.
 * @param chosen_boulder The boulder to being breaking down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE
	if(!length(chosen_boulder.custom_materials))
		qdel(chosen_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_boulder_count()
		return FALSE
	if(isnull(silo_materials))
		return FALSE

	//here we loop through the boulder's ores
	var/list/processable_ores = list()
	var/tripped = FALSE
	//If a material is in the boulder's custom_materials, but not in the processable_materials list, we add it to the processable_ores list to add back to a leftover boulder.
	for(var/datum/material/possible_mat as anything in chosen_boulder.custom_materials)
		if(!is_type_in_list(possible_mat, processable_materials))
			continue
		var/quantity = chosen_boulder.custom_materials[possible_mat]
		points_held = round(points_held + (quantity * possible_mat.points_per_unit * MINING_POINT_MACHINE_MULTIPLIER)) // put point total here into machine
		processable_ores += possible_mat
		processable_ores[possible_mat] = quantity
		chosen_boulder.custom_materials -= possible_mat //Remove it from the boulder now that it's tracked
		tripped = TRUE
	if(!tripped)
		remove_boulder(chosen_boulder)
		say("Nothing to process!")
		return FALSE //we shouldn't spend more time processing a boulder with contents we don't care about.
	use_power(BASE_MACHINE_ACTIVE_CONSUMPTION)
	check_for_boosts() //Calls the relevant behavior for boosting the machine's efficiency, if able.
	var/is_artifact = (istype(chosen_boulder, /obj/item/boulder/artifact)) //We need to know if it's an artifact so we can carry it over to the new boulder.
	var/obj/item/boulder/disposable_boulder = new (src)
	disposable_boulder.custom_materials = processable_ores
	silo_materials.insert_item(disposable_boulder, refining_efficiency)
	qdel(disposable_boulder)

	refining_efficiency = initial(refining_efficiency) //Reset refining efficiency to 100% now that we've processed any relevant ores.
	if(!length(chosen_boulder.custom_materials))
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(is_artifact)
			points_held = round((points_held + MINER_POINT_MULTIPLIER) * MINING_POINT_MACHINE_MULTIPLIER) /// Artifacts give bonus points!
		chosen_boulder.break_apart()
		update_boulder_count()
		return TRUE //We've processed all the materials in the boulder, so we can just destroy it in break_apart.

	chosen_boulder.restart_processing_cooldown() //So that we don't pick it back up!
	chosen_boulder.durability = rand(chosen_boulder.boulder_size, chosen_boulder.boulder_size + BOULDER_SIZE_SMALL) //Reset durability to a random value between the boulder's size and a little more.
	remove_boulder(chosen_boulder)
	return TRUE

/**
 * Accepts a boulder into the machine. Used when a boulder is first placed into the machine.
 * @param new_boulder The boulder to be accepted.
 */
/obj/machinery/bouldertech/proc/accept_boulder(obj/item/boulder/new_boulder)
	if(isnull(new_boulder))
		return FALSE
	if(boulders_contained.len >= boulders_held_max) //Full already
		return FALSE
	if(!istype(new_boulder)) //Can't be processed
		return FALSE
	if(!new_boulder.custom_materials) //Shouldn't happen, but just in case.
		qdel(new_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	new_boulder.forceMove(src)
	boulders_contained += new_boulder
	SSore_generation.available_boulders -= new_boulder
	START_PROCESSING(SSmachines, src) //Starts processing if we aren't already.
	return TRUE

/**
 * Ejects a boulder from the machine. Used when a boulder is finished processing, or when a boulder can't be processed.
 * @param drop_turf The location to eject the boulder to. If null, it will eject to the machine's drop_location().
 * @param specific_boulder The boulder to be ejected.
 */
/obj/machinery/bouldertech/proc/remove_boulder(obj/item/boulder/specific_boulder, turf/drop_turf = null)
	if(isnull(specific_boulder))
		CRASH("remove_boulder() called with no boulder!")
	if(!length(specific_boulder.custom_materials))
		qdel(specific_boulder)
		update_boulder_count()
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	specific_boulder.restart_processing_cooldown() //Reset the cooldown so we don't pick it back up by the same machine.
	if(isturf(drop_turf))
		specific_boulder.forceMove(drop_turf)
	else
		specific_boulder.forceMove(drop_location())
	if(!update_boulder_count())
		return TRUE
	STOP_PROCESSING(SSmachines, src)
	balloon_alert_to_viewers("clear!")
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	return TRUE

/**
 * Getter proc to determine how many boulders are contained in the machine.
 * Also adds their reference to the boulders_contained list.
 */
/obj/machinery/bouldertech/proc/update_boulder_count()
	boulders_contained = list()
	for(var/obj/item/boulder/boulder in contents)
		boulders_contained += boulder
	return boulders_contained.len

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_boulder), atom_movable)

/**
 * Looks for a boost to the machine's efficiency, and applies it if found.
 * Applied more on the chemistry integration but can be used for other things if desired.
 */
/obj/machinery/bouldertech/proc/check_for_boosts()
	refining_efficiency = initial(refining_efficiency) //Reset refining efficiency to 100%.

/**
 * Checks if a custom_material is in a list of processable materials in the machine.
 * @param list/custom_material A list of materials, presumably taken from a boulder. If a material that this machine can process is in this list, it will return true, inclusively.
 */
/obj/machinery/bouldertech/proc/check_for_processable_materials(list/boulder_mats)
	for(var/material as anything in boulder_mats)
		if(is_type_in_list(material, processable_materials))
			return TRUE
	return FALSE

///Beacon to launch a new mining setup when activated. For testing and speed!
/obj/item/boulder_beacon
	name = "boulder beacon"
	desc = "N.T. approved boulder beacon, toss it down and you will have a full bouldertech mining station."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "floor_beacon"
	/// Number of activations left on this beacon. Uses will be removed as the beacon is used and each triggers a different machine to be spawned from it.
	var/uses = 3

/obj/item/boulder_beacon/attack_self()
	loc.visible_message(span_warning("\The [src] begins to beep loudly!"))
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 1 SECONDS)

/**
 * Spawns a new bouldertech machine from the beacon, then removes a use from the beacon.
 * Use one spawns a BRM teleporter, then a refinery, and lastly a smelter.
 */
/obj/item/boulder_beacon/proc/launch_payload()
	playsound(src, SFX_SPARKS, 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	switch(uses)
		if(3)
			new /obj/machinery/bouldertech/brm(drop_location())
		if(2)
			new /obj/machinery/bouldertech/refinery(drop_location())
		if(1)
			new /obj/machinery/bouldertech/refinery/smelter(drop_location())
			qdel(src)
	uses--
