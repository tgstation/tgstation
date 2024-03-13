/**
 * The 'Main' extractor hub, that owns all the rest.
 * Also known as the 'bottom middle piece', which also works as a pipe in itself.
 * This was split into its own file just cause the readability sucked.
 */
/obj/structure/plasma_extraction_hub/part/pipe/main
	///Boolean on whether we've started drilling.
	var/drilling = FALSE
	///List of all parts connected to the extraction hub, not including ourselves.
	var/list/obj/structure/plasma_extraction_hub/hub_parts = list()

/obj/structure/plasma_extraction_hub/part/pipe/main/Initialize(mapload)
	. = ..()
	//the only one that calls setup, as the creator
	setup_parts()

/obj/structure/plasma_extraction_hub/part/pipe/main/Destroy()
	. = ..()
	QDEL_LIST(hub_parts)

///Copied over from Gravity Generator, this sets up the parts of the plasma extraction hub, and its
///3 pipe starting points.
/obj/structure/plasma_extraction_hub/part/pipe/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = CORNER_BLOCK_OFFSET(our_turf, 3, 3, -1, 0)
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/structure/plasma_extraction_hub/part/new_part
		switch(count)
			//east
			if(4)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe(T)
				new_part.setDir(EAST)
				hub_parts += new_part
			//west
			if(6)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe(T)
				new_part.setDir(WEST)
				hub_parts += new_part
			else
				new_part = new/obj/structure/plasma_extraction_hub/part(T)
		new_part.pipe_owner = src

/obj/structure/plasma_extraction_hub/part/pipe/main/interact(mob/user)
	. = ..()
	var/list/radial_menu_options = list(
		(drilling ? "Stop" : "Start") = image(icon = 'icons/hud/radial.dmi', icon_state = drilling ? "radial_close" : "radial_open"),
		"Cancel" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_close"),
	)
	var/radial_reset_menu = show_radial_menu(user, src, radial_menu_options, require_near = TRUE)
	if(radial_reset_menu != "Stop" && radial_reset_menu != "Start")
		return
	toggle_mining(user)

/obj/structure/plasma_extraction_hub/part/pipe/main/proc/toggle_mining(mob/user)
	if(drilling)
		drilling = FALSE
		STOP_PROCESSING(SSprocessing, src)
		for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts as anything in hub_parts + src)
			pipe_parts.stop_drilling()
		return
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts as anything in hub_parts + src)
		if(!pipe_parts.check_parts())
			balloon_alert(user, "cant start, pipes incomplete!")
			return
	drilling = TRUE
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts as anything in hub_parts + src)
		pipe_parts.start_drilling()
	START_PROCESSING(SSprocessing, src)

/obj/structure/plasma_extraction_hub/part/pipe/main/process(seconds_per_tick)
	if(HAS_TRAIT(src, TRAIT_FROZEN)) //halp
		return
	var/broken_hub = FALSE
	for(var/obj/structure/plasma_extraction_hub/part/pipe/pipe_parts as anything in hub_parts + src)
		if(!pipe_parts.currently_functional)
			broken_hub = TRUE
			break
	if(broken_hub)
		to_chat(world, span_warning("One or more pipes were broken, couldn't process."))
		return
	to_chat(world, span_green("Passed processing, extracting plasma."))
