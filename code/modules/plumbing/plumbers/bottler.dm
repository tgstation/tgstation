/obj/machinery/plumbing/bottler
	name = "chemical bottler"
	desc = "Puts reagents into containers, like bottles and beakers in the tile facing the green light spot, they will exit on the red light spot if successfully filled."
	icon_state = "bottler"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 100

	///how much do we fill
	var/wanted_amount = 10
	///where things are sent
	var/turf/goodspot = null
	///where things are taken
	var/turf/inputspot = null
	///where beakers that are already full will be sent
	var/turf/badspot = null
	///Does the plumbing machine have a correct tile setup
	var/valid_output_configuration = FALSE

/obj/machinery/plumbing/bottler/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)
	setDir(dir)

/obj/machinery/plumbing/bottler/examine(mob/user)
	. = ..()
	. += span_notice("A small screen indicates that it will fill for [wanted_amount]u.")
	if(!valid_output_configuration)
		. += span_warning("A flashing notification on the screen reads: \"Output location error!\"")

///changes the tile array
/obj/machinery/plumbing/bottler/setDir(newdir)
	. = ..()
	var/turf/target_turf = get_turf(src)
	switch(dir)
		if(NORTH)
			goodspot = get_step(target_turf, NORTH)
			inputspot = get_step(target_turf, SOUTH)
			badspot = get_step(target_turf, EAST)
		if(SOUTH)
			goodspot = get_step(target_turf, SOUTH)
			inputspot = get_step(target_turf, NORTH)
			badspot = get_step(target_turf, WEST)
		if(WEST)
			goodspot = get_step(target_turf, WEST)
			inputspot = get_step(target_turf, EAST)
			badspot = get_step(target_turf, NORTH)
		if(EAST)
			goodspot = get_step(target_turf, EAST)
			inputspot = get_step(target_turf, WEST)
			badspot = get_step(target_turf, SOUTH)

	//If by some miracle
	if( ( !valid_output_configuration ) && ( goodspot != null && inputspot != null && badspot != null ) )
		valid_output_configuration = TRUE
		begin_processing()

///changing input ammount with a window
/obj/machinery/plumbing/bottler/interact(mob/user)
	. = ..()
	if(!valid_output_configuration)
		to_chat(user, span_warning("A flashing notification on the screen reads: \"Output location error!\""))
		return .
	var/new_amount = tgui_input_number(user, "Set Amount to Fill", "Desired Amount", max_value = reagents.maximum_volume, round_value = TRUE)
	if(!new_amount || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return .
	wanted_amount = new_amount
	to_chat(user, span_notice(" The [src] will now fill for [wanted_amount]u."))

/obj/machinery/plumbing/bottler/process(seconds_per_tick)
	if(!is_operational)
		return
	// Sanity check the result locations and stop processing if they don't exist
	if(goodspot == null || badspot == null || inputspot == null)
		valid_output_configuration = FALSE
		return PROCESS_KILL

	///see if machine has enough to fill, is anchored down and has any inputspot objects to pick from
	if(reagents.total_volume >= wanted_amount && anchored && length(inputspot.contents))
		use_energy(active_power_usage * seconds_per_tick)
		var/obj/AM = pick(inputspot.contents)///pick a reagent_container that could be used
		//allowed containers
		var/static/list/allowed_containers = list(
			/obj/item/reagent_containers/cup,
			/obj/item/ammo_casing/shotgun/dart,
		)
		if(is_type_in_list(AM, allowed_containers))
			var/obj/item/B = AM
			///see if it would overflow else inject
			if((B.reagents.total_volume + wanted_amount) <= B.reagents.maximum_volume)
				reagents.trans_to(B, wanted_amount)
				B.forceMove(goodspot)
				return
			///glass was full so we move it away
			AM.forceMove(badspot)
		else if(istype(AM, /obj/item/slime_extract)) ///slime extracts need inject
			AM.forceMove(goodspot)
			reagents.trans_to(AM, wanted_amount, methods = INJECT)
		else if(istype(AM, /obj/item/slimecross/industrial)) ///no need to move slimecross industrial things
			reagents.trans_to(AM, wanted_amount, methods = INJECT)
