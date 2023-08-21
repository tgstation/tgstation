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
	/// How many boulders are we holding?
	var/boulders_held = 0
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


/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()
	if(holds_minerals)
		silo_materials = AddComponent(
		/datum/component/remote_materials, \
		mapload, \
		mat_container_flags = MATCONTAINER_NO_INSERT, \
	)

/obj/machinery/bouldertech/LateInitialize()
	. = ..()
	if(!holds_minerals)
		return
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

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

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers) //todo: this probably shouldn't exist? maybe retool elsewhere?
	. = ..()
	remove_boulder()

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
	var/blocker = FALSE
	var/boulders_concurrent = boulders_processing_max
	for(var/i in 1 to contents.len)
		if(boulders_concurrent <= 0)
			return //Try again next time
		if(!istype(contents[i], /obj/item/boulder))
			continue
		var/obj/item/boulder/boulder = contents[i]
		boulders_concurrent--
		boulder.durability-- //One less durability to the processed boulder.
		if(COOLDOWN_FINISHED(src, sound_cooldown))
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(loc, usage_sound, (60-(5*abs(boulder.durability))), FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		blocker = TRUE
		if(boulder.durability <= 0)
			breakdown_boulder(boulder) //Crack that bouwlder open!
			continue
		else
			if(prob(25))
				var/list/quips = list("clang!", "crack!", "bang!", "clunk!", "clank!",)
				balloon_alert_to_viewers("[pick(quips)]")
	if(!blocker)
		STOP_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("clear!")
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return


/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(boulders_held >= boulders_held_max)
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
			visible_message(span_warning("[possible_mat] remains at [quantity] value!"))
			remaining_ores += possible_mat
			remaining_ores[possible_mat] = quantity
			chosen_boulder.custom_materials[possible_mat] = null
		else
			tripped = TRUE

	if(!tripped)
		remove_boulder(chosen_boulder)
		return FALSE //we shouldn't spend more time processing a boulder with contents we don't care about.
	use_power(100)
	check_for_boosts() //Calls the relevant behavior for boosting the machine's efficiency, if able.
	silo_materials.mat_container.insert_item(chosen_boulder, refining_efficiency, breakdown_flags = BREAKDOWN_FLAGS_ORM)
	balloon_alert_to_viewers("Boulder processed!")
	if(!remaining_ores.len)
		qdel(chosen_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_boulder_count()
		return TRUE

	var/obj/item/boulder/new_rock = new (src)
	new_rock.set_custom_materials(remaining_ores)
	remove_boulder(new_rock)
	return TRUE

/obj/machinery/bouldertech/proc/accept_boulder(obj/item/boulder/new_boulder)
	if(isnull(new_boulder))
		return FALSE
	if(boulders_held >= boulders_held_max) //Full already
		visible_message(span_warning("no space!"))
		return FALSE
	if(!new_boulder.custom_materials) //Shouldn't happen, but just in case.
		qdel(new_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	new_boulder.forceMove(src)
	boulders_held++
	START_PROCESSING(SSmachines, src) //Starts processing if we aren't already.
	return TRUE

/obj/machinery/bouldertech/proc/remove_boulder(obj/item/boulder/specific_boulder)
	if(!contents.len)
		return FALSE
	var/obj/item/possible_boulder = specific_boulder
	if(isnull(possible_boulder))
		for(var/i in 1 to contents.len)
			if(istype(contents[i], /obj/item/boulder))
				possible_boulder = contents[i]
				break
	if(isnull(possible_boulder))
		return FALSE
	if(!possible_boulder.custom_materials)
		qdel(possible_boulder)
		update_boulder_count()
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	var/obj/item/boulder/real_boulder = possible_boulder
	real_boulder.reset_processing_cooldown()
	real_boulder.forceMove(src.drop_location())
	boulders_held = clamp(boulders_held--, 0, boulders_held_max)
	visible_message(span_warning("[boulders_held] remaining!"))
	update_boulder_count()
	return TRUE

/obj/machinery/bouldertech/proc/update_boulder_count()
	boulders_held = 0
	for(var/obj/item/boulder/boulder in contents)
		boulders_held++
	return boulders_held

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_boulder), atom_movable)

/obj/machinery/bouldertech/proc/check_for_boosts()
	return

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
