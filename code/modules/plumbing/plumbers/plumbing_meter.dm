/obj/machinery/reagent_meter
	name = "Duct reagent meter"
	desc = "Used to measure reagents inside an plumbing duct"
	icon = 'icons/obj/pipes_n_cables/meter.dmi'
	icon_state = "meter"
	power_channel = AREA_USAGE_ENVIRON
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1
	///The pipe we are attaching to
	var/obj/machinery/duct/pipe
	///The piping layer of the target
	var/duct_layer = DUCT_LAYER_DEFAULT

/obj/machinery/reagent_meter/Initialize(mapload, target_layer)
	. = ..()

	if(GLOB.plumbing_layer_names["[target_layer]"])
		duct_layer = target_layer

	for(var/obj/machinery/duct/target in get_turf(src))
		if(target.duct_layer == duct_layer)
			pipe = target
			RegisterSignal(pipe.net.pipeline, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(update))
			RegisterSignal(pipe.net.pipeline, COMSIG_QDELETING, PROC_REF(reassign))
			RegisterSignal(pipe, COMSIG_QDELETING, PROC_REF(deconstruct))
			break

	var/offset

	switch(duct_layer)
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10

	pixel_x = offset
	pixel_y = offset
	layer = PLUMBING_PIPE_VISIBILE_LAYER + duct_layer * 0.0003

	register_context()

/obj/machinery/reagent_meter/on_deconstruction(disassembled)
	. = ..()
	new /obj/item/reagent_meter(drop_location(), duct_layer)

/obj/machinery/reagent_meter/examine(mob/user)
	. = ..()
	. += span_notice("The pipeline has [pipe.net.pipeline.total_volume]u/[pipe.net.pipeline.maximum_volume]u of reagents.")
	if(pipe.net.pipeline.total_volume)
		. += span_notice("It contains.")
		for(var/datum/reagent/reg as anything in pipe.net.pipeline.reagent_list)
			. += span_notice("[round(reg.volume, CHEMICAL_VOLUME_ROUNDING)]u of [reg.name].")
	. += span_notice("It can be [EXAMINE_HINT("wrenched")] apart.")

/obj/machinery/reagent_meter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/reagent_meter/on_set_is_operational(old_value)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/reagent_meter/update_overlays()
	. = ..()
	if(!is_operational)
		return

	var/pipe_layer = PLUMBING_PIPE_VISIBILE_LAYER + duct_layer * 0.0003
	. += image('icons/obj/pipes_n_cables/meter.dmi', "buttons4", layer = pipe_layer)

	var/level = ROUND_UP(6 * (pipe.net.pipeline.total_volume / pipe.net.pipeline.maximum_volume))
	if(level)
		var/image/overlay = image('icons/obj/pipes_n_cables/meter.dmi', "pressure3_[level]", layer = pipe_layer)
		switch(pipe.net.pipeline.chem_temp)
			if(0 to 100)
				overlay.color = COLOR_VIOLET
			if(100 to 200)
				overlay.color = COLOR_BLUE
			if(200 to 400)
				overlay.color = COLOR_VIBRANT_LIME
			if(400 to 600)
				overlay.color = COLOR_YELLOW
			if(600 to 800)
				overlay.color = COLOR_ORANGE
			if(800 to INFINITY)
				overlay.color = COLOR_RED
		. += overlay

/obj/machinery/reagent_meter/proc/update()
	SIGNAL_HANDLER

	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/reagent_meter/proc/reassign()
	SIGNAL_HANDLER

	RegisterSignal(pipe.net.pipeline, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(update))

	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/reagent_meter/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_FAILURE
	if(tool.use_tool(src, user, 2 SECONDS, volume = 50))
		deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS

/obj/item/reagent_meter
	name = "reagent meter"
	desc = "A meter that can be wrenched on ducts"
	icon = 'icons/obj/pipes_n_cables/pipe_item.dmi'
	icon_state = "meter"
	inhand_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	///The piping layer of the target
	var/duct_layer = DUCT_LAYER_DEFAULT

/obj/item/reagent_meter/Initialize(mapload, target_layer)
	. = ..()
	if(GLOB.plumbing_layer_names["[target_layer]"])
		duct_layer = target_layer

/obj/item/reagent_meter/examine(mob/user)
	. = ..()
	. += span_notice("It can be [EXAMINE_HINT("wrenched")] on a duct at [GLOB.plumbing_layer_names["[duct_layer]"]].")

/obj/item/reagent_meter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Anchor"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_meter/wrench_act(mob/living/user, obj/item/wrench/W)
	. = ITEM_INTERACT_FAILURE
	for(var/obj/machinery/duct/target in get_turf(src))
		if(target.duct_layer == duct_layer)
			new /obj/machinery/reagent_meter(loc, duct_layer)
			W.play_tool_sound(src)
			to_chat(user, span_notice("You fasten the meter to the pipe."))
			qdel(src)
			return ITEM_INTERACT_SUCCESS

