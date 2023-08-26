/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 100 // fuck if I know set this later

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
	/// What sound plays when a thing operates?
	var/usage_sound = 'sound/machines/mining/wooping_teleport.ogg'
	// Cooldown associated with the usage_sound played.
	COOLDOWN_DECLARE(sound_cooldown)

	/// Silo link to it's materials list.
	var/datum/component/remote_materials/silo_materials
	/// Mining points held by the machine for miners.
	var/points_held = 0

/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()
	if(holds_minerals)
		silo_materials = AddComponent(
			/datum/component/remote_materials, \
			mapload, \
			mat_container_flags = BREAKDOWN_FLAGS_ORM|MATCONTAINER_NO_INSERT|MATCONTAINER_EXAMINE \
		)

/obj/machinery/bouldertech/LateInitialize()
	. = ..()
	if(!holds_minerals)
		return
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/bouldertech/Destroy()
	. = ..()
	boulders_contained = null
	silo_materials = null

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(holds_minerals && istype(attacking_item, /obj/item/boulder))
		var/obj/item/boulder/my_boulder = attacking_item
		update_boulder_count()
		if(!accept_boulder(my_boulder))
			visible_message(span_warning("[my_boulder] is rejected!"))
			return
		visible_message(span_warning("[my_boulder] is accepted into \the [src]"))
		START_PROCESSING(SSmachines, src)
		return

/obj/machinery/bouldertech/deconstruct(disassembled)
	. = ..()
	if(holds_minerals)
		qdel(silo_materials)
	if(contents.len)
		for(var/obj/item/boulder/boulder in contents)
			remove_boulder(boulder)

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
		return FALSE

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_pry_open(tool, close_after_pry = TRUE, closed_density = FALSE))
		return FALSE
	if(default_deconstruction_crowbar(tool))
		return FALSE

/obj/machinery/bouldertech/process()
	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)
		if(!potential_boulder)
			break
		if(boulders_concurrent <= 0)
			break //Try again next time
		if(!boulders_contained.len)
			break

		if(!istype(potential_boulder, /obj/item/boulder))
			potential_boulder.forceMove(drop_location())
			CRASH("\The [src] had a non-boulder in it!")

		var/obj/item/boulder/boulder = potential_boulder
		if(!check_for_processable_materials(boulder.custom_materials)) //Checks for any new materials we can process.
			say("no processable materials found!")
			boulders_concurrent-- //We count skipped boulders
			remove_boulder(boulder)
			continue
		boulders_concurrent--
		boulder.durability-- //One less durability to the processed boulder.
		if(COOLDOWN_FINISHED(src, sound_cooldown))
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
		playsound(loc, usage_sound, 40, FALSE, SHORT_RANGE_SOUND_EXTRARANGE) //This can get annoying. One play per process() call.
		stop_processing_check = TRUE
		if(boulder.durability <= 0)
			breakdown_boulder(boulder) //Crack that bouwlder open!
			continue
		else
			if(prob(25))
				var/list/quips = list("clang!", "crack!", "bang!", "clunk!", "clank!",)
				balloon_alert_to_viewers("[pick(quips)]")
	if(!stop_processing_check)
		STOP_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("clear!")
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return


/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(istype(mover, /obj/item/boulder))
		var/obj/item/boulder/boulder = mover
		if(boulder.can_get_processed())
			return TRUE
		return FALSE

/**
 * Accepts a boulder into the machinery, then converts it into minerals.
 * @param chosen_boulder The boulder to being breaking down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	if(isnull(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE
	if(QDELETED(chosen_boulder))
		return FALSE

	if(!chosen_boulder.custom_materials)
		qdel(chosen_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_boulder_count()
		return FALSE
	if(isnull(silo_materials))
		return
	//here we loop through the boulder's ores
	var/list/remaining_ores = list()
	var/tripped = FALSE
	refining_efficiency = initial(refining_efficiency) //Reset refining efficiency to 100%.
	//If a material is in the boulder's custom_materials, but not in the processable_materials list, we add it to the remaining_ores list to add back to a leftover boulder.
	for(var/datum/material/possible_mat as anything in chosen_boulder.custom_materials)
		if(!is_type_in_list(possible_mat, processable_materials))
			var/quantity = chosen_boulder.custom_materials[possible_mat]
			visible_message(span_warning("[quantity] units of [possible_mat] are left over!"))
			remaining_ores += possible_mat
			remaining_ores[possible_mat] = quantity
			chosen_boulder.custom_materials[possible_mat] = null
		else
			points_held += (chosen_boulder.custom_materials[possible_mat] * possible_mat.points_per_unit)/// put point total here into machine
			tripped = TRUE
			visible_message(span_warning("WE TRIPPED!"))

	if(!tripped)
		visible_message(span_warning("No ores found! Removing [chosen_boulder]."))
		remove_boulder(chosen_boulder)
		return FALSE //we shouldn't spend more time processing a boulder with contents we don't care about.
	use_power(100)
	check_for_boosts() //Calls the relevant behavior for boosting the machine's efficiency, if able.
	silo_materials.mat_container.insert_item(chosen_boulder, refining_efficiency, breakdown_flags = BREAKDOWN_FLAGS_ORM,)
	balloon_alert_to_viewers("Boulder processed!")
	if(!remaining_ores.len)
		qdel(chosen_boulder)
		say("boulder deleted! removed.")
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_boulder_count()
		return TRUE

	say("we carried over! new boulder has been made.")
	var/obj/item/boulder/new_rock = new (src)
	new_rock.set_custom_materials(remaining_ores)
	new_rock.reset_processing_cooldown() //So that we don't pick it back up!
	remove_boulder(new_rock)
	return TRUE

/obj/machinery/bouldertech/proc/accept_boulder(obj/item/boulder/new_boulder)
	if(isnull(new_boulder))
		return FALSE
	if(boulders_contained.len >= boulders_held_max) //Full already
		visible_message(span_warning("no space!"))
		return FALSE
	if(!new_boulder.custom_materials) //Shouldn't happen, but just in case.
		qdel(new_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	new_boulder.forceMove(src)
	boulders_contained += new_boulder
	START_PROCESSING(SSmachines, src) //Starts processing if we aren't already.
	return TRUE

/obj/machinery/bouldertech/proc/remove_boulder(obj/item/boulder/specific_boulder)
	if(!specific_boulder)
		CRASH("remove_boulder() called with no boulder!")
	if(isnull(specific_boulder))
		return FALSE
	if(!specific_boulder.custom_materials)
		say("Empty boulder removed!")
		qdel(specific_boulder)
		update_boulder_count()
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	specific_boulder.reset_processing_cooldown()
	specific_boulder.forceMove(drop_location())
	update_boulder_count()
	visible_message(span_notice("[boulders_contained.len] boulders remaining! THIS IS THE ONE IN REMOVE BOULDER!!!"))
	return TRUE

/obj/machinery/bouldertech/proc/update_boulder_count()
	boulders_contained = list()
	for(var/obj/item/boulder/boulder in contents)
		boulders_contained += boulder
	return boulders_contained.len

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_boulder), atom_movable)

/obj/machinery/bouldertech/proc/check_for_boosts()
	return

/obj/machinery/bouldertech/proc/check_for_processable_materials(list/boulder_mats)
	var/skip = TRUE // Check that it's something we actually care about first!
	for(var/material as anything in boulder_mats)
		if(is_type_in_list(material, processable_materials))
			skip = FALSE
			break
	return skip

///Beacon to launch a new mining setup when activated. For testing and speed!
/obj/item/boulder_beacon
	name = "boulder beacon"
	desc = "N.T. approved boulder beacon, toss it down and you will have a full bouldertech mining station."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "floor_beacon"
	var/uses = 3

/obj/item/boulder_beacon/attack_self()
	loc.visible_message(span_warning("\The [src] begins to beep loudly!"))
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 1 SECONDS)

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
