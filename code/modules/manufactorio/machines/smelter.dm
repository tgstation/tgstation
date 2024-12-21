/obj/machinery/power/manufacturing/smelter
	name = "manufacturing smelter"
	desc = "Pretty much incinerates whatever is put into it. Refines ore (not boulders)."
	icon_state = "smelter"
	circuit = /obj/item/circuitboard/machine/manusmelter
	/// power used to smelt
	var/power_cost = 4 KILO WATTS
	/// our output, if the way out was blocked is held here
	var/atom/movable/withheld

/obj/machinery/power/manufacturing/smelter/update_overlays()
	. = ..()
	. += generate_io_overlays(dir, COLOR_ORANGE) // OUT - stuff in it
	. += generate_io_overlays(REVERSE_DIR(dir), COLOR_MODERATE_BLUE) // IN - to crush

/obj/machinery/power/manufacturing/smelter/receive_resource(obj/receiving, atom/from, receive_dir)
	if(!isitem(receiving) || surplus() < power_cost  || receive_dir != REVERSE_DIR(dir))
		return MANUFACTURING_FAIL
	var/list/stacks = contents - circuit
	if(length(stacks) >= 5 && !may_merge_in_contents_and_do_so(receiving))
		return MANUFACTURING_FAIL_FULL
	receiving.Move(src, get_dir(receiving, src))
	START_PROCESSING(SSmanufacturing, src)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/smelter/Destroy()
	. = ..()
	QDEL_NULL(withheld)

/obj/machinery/power/manufacturing/smelter/atom_destruction(damage_flag)
	withheld?.Move(drop_location())
	return ..()

/obj/machinery/power/manufacturing/smelter/process(seconds_per_tick)
	var/list/stacks = contents - circuit
	if(!length(stacks))
		return

	var/list/stacks_preprocess = contents - circuit
	var/obj/item/stack/ore/ore = stacks_preprocess[length(stacks_preprocess)]
	if(isnull(ore))
		return
	if(isnull(withheld) && surplus() >= power_cost)
		icon_state="smelter_on"
		add_load(power_cost)
		if(istype(ore))
			var/obj/item/stack/new_stack = new ore.refined_type(null, min(5, ore.amount), FALSE)
			new_stack.moveToNullspace()
			ore.use(min(5, ore.amount))
			ore = new_stack
		else
			ore.fire_act(1400)
		withheld = ore
	else if(surplus() < power_cost)
		icon_state = "smelter"
	if(send_resource(withheld, dir))
		withheld = null // nullspace thumbs down
	if(!length(contents - circuit))
		return PROCESS_KILL //we finished
