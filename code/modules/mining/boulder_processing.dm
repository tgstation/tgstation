/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 100 /// fuck if I know set this later

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
			if(prob(15))
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
	use_power(100) //Standardize this, hopefully
	silo_materials.mat_container.insert_item(chosen_boulder, refining_efficiency, breakdown_flags = BREAKDOWN_FLAGS_ORM)
	balloon_alert_to_viewers("Boulder processed!")
	// playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE) //Maybe look for an industrial sound here instead?
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

/obj/machinery/bouldertech/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."
	icon_state = "brm"
	circuit = /obj/item/circuitboard/machine/brm
	usage_sound = 'sound/machines/mining/wooping_teleport.ogg'
	// Are we trying to actively collect boulders automatically?
	var/toggled_on = FALSE

/obj/machinery/bouldertech/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	collect_boulder()

/obj/machinery/bouldertech/brm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	START_PROCESSING(SSmachines, src)
	icon_state = "brm-toggled"
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/bouldertech/brm/process()
	boulders_held = 0
	balloon_alert_to_viewers("Bzzap!")
	if(SSore_generation.available_boulders.len < 1)
		say("No boulders to collect. Entering idle mode.")
		STOP_PROCESSING(SSmachines, src)
		icon_state = "brm"
		update_appearance(UPDATE_ICON_STATE)
		return
	for(var/i in 1 to boulders_processing_max)
		if(!collect_boulder())
			i-- //Retry
	for(var/ground_rocks in loc.contents)
		if(istype(ground_rocks, /obj/item/boulder))

			boulders_held++
			if(boulders_held > boulders_held_max)
				STOP_PROCESSING(SSmachines, src)
				icon_state = "brm"
				update_appearance(UPDATE_ICON_STATE)
				return

/**
 * So, this should be probably handed in a more elegant way going forward, like a small TGUI prompt to select which boulder you want to pull from.
 * However, in the attempt to make this really, REALLY basic but functional until I can actually sit down and get this done we're going to just grab a random entry from the global list and work with it.
 */
/obj/machinery/bouldertech/brm/proc/collect_boulder()
	var/obj/item/boulder/random_boulder = pick(SSore_generation.available_boulders)
	if(random_boulder.processed_by)
		return FALSE
	if(!random_boulder)
		return FALSE
	random_boulder.processed_by = src
	random_boulder.Shake(duration = 1.5 SECONDS)
	SSore_generation.available_boulders -= random_boulder
	//todo: Maybe add some kind of teleporation raster effect thing? filters? I can probably make something happen here...
	sleep(1.5 SECONDS)
	flick("brm-flash", src)
	if(QDELETED(random_boulder))
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("Target lost!")
		return FALSE
	//todo:do the thing we do where we make sure the thing still exists and hasn't been deleted between the start of the recall and after.
	random_boulder.forceMove(drop_location())
	balloon_alert_to_viewers("boulder appears!")
	random_boulder.visible_message(span_warning("[random_boulder] suddenly appears!"))
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	use_power(100)

/obj/machinery/bouldertech/smelter
	name = "boulder smeltery"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."
	icon_state = "furnace"
	holds_minerals = TRUE
	processable_materials = list(
		/datum/material/iron,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/mythril,
		/datum/material/adamantine,
		/datum/material/runite,
	)
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'


/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "BR for short. Accepts boulders and refines non-metallic ores into sheets. Can be upgraded with stock parts or through chemical inputs."
	icon_state = "stacker"
	holds_minerals = TRUE
	processable_materials = list(
		/datum/material/glass,
		/datum/material/plasma,
		/datum/material/diamond,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/plastic,
	)
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'

	/// Reagents that we can use to wash the boulders
	var/list/allowed_reagents = list(/datum/reagent/water, /datum/reagent/lube)
	/// Internal beaker for storing washing fluid
	var/obj/item/reagent_containers/cup/beaker/large/washing_input

/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()

	washing_input = new()
	create_reagents(100, TRANSPARENT)
	AddComponent(/datum/component/plumbing/selective, anchored, custom_receiver = washing_input.reagents, allowed_reagents = src.allowed_reagents)

/// Try and draw reagents and produce waste
/obj/machinery/bouldertech/refinery/proc/process_reagents(volume = MACHINE_REAGENT_TRANSFER)
	if(volume > washing_input.reagents.total_volume) //not enough washing fluid
		return null

	if(reagents.maximum_volume < reagents.total_volume + volume) //we dont have enough space for waste!
		return null

	. = list() //keep track of which reagents we use and how much. list(type = volume)

	// Pull washing fluids from the washing input and remove it, but record they've been used
	for(var/datum/reagent/reagent as anything in washing_input.reagents.reagent_list)
		var/volume_to_draw = min(reagent.volume, volume)

		volume -= volume_to_draw
		.[reagent.type] = volume_to_draw
		washing_input.reagents.remove_reagent(reagent.type, volume_to_draw)

	generate_waste(.)

/// Generate waste reagents, depending on boulders and washing fluid
/obj/machinery/bouldertech/refinery/proc/generate_waste(list/used_reagents)
	reagents.add_reagent(/datum/reagent/consumable/bbqsauce, MACHINE_REAGENT_TRANSFER) // probably use the reagents to determine how much waste you make?

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	var/manipulator_stack = 0
	var/matter_bin_stack = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		manipulator_stack += ((servo.tier - 1))
	boulders_processing_max = clamp(manipulator_stack, 1, 6)
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		matter_bin_stack += ((bin.tier))
	boulders_held_max = matter_bin_stack


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
			new /obj/machinery/bouldertech/smelter(drop_location())
			qdel(src)
	uses--
