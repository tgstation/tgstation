/obj/machinery/power/manufacturing/router // Basically a splitter
	name = "manufacturing router"
	desc = "Distributes input to 3 output directions equally. Stacks are split, and you may toggle outputs with a multitool. May not receive from other routers. Will skip sides with a conveyor facing it."
	allow_mob_bump_intake = TRUE
	icon_state = "splitter"
	circuit = /obj/item/circuitboard/machine/manurouter
	/// outputs disabled with a multitool
	var/list/disabled_dirs = list()
	/// input dir = last output dir
	var/list/direction_last_output = list()
	/// dirs we received something from and have not outputted an item from
	var/list/dirs_received_from = list()

/obj/machinery/power/manufacturing/router/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	var/to_toggle = get_dir(src, user)
	if(!(to_toggle in GLOB.cardinals))
		balloon_alert(user, "stand inline!")
		return ITEM_INTERACT_FAILURE
	if(to_toggle in disabled_dirs)
		disabled_dirs -= to_toggle
	else
		disabled_dirs += to_toggle
	update_appearance(UPDATE_OVERLAYS)
	balloon_alert(user, "toggled output")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/router/update_overlays()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/variant
		if(disabled_dirs.Find(direction))
			variant = "bl"
		else
			variant = !length(dirs_received_from) || (direction in dirs_received_from) ? "in" : "out"
		var/image/new_overlay = image(icon, "splitter_[variant]", layer = layer+0.001, dir = direction)
		. += new_overlay

/obj/machinery/power/manufacturing/router/receive_resource(obj/receiving, atom/from, receive_dir)
	if(istype(from, /obj/machinery/power/manufacturing/router) || (receive_dir in disabled_dirs))
		return MANUFACTURING_FAIL
	dirs_received_from |= receive_dir

	var/list/valid_dirs_for_output = GLOB.cardinals - disabled_dirs - receive_dir // Every cardinal but the one that players disabled and the one we received from
	for(var/checking_dir in valid_dirs_for_output)
		var/obj/machinery/conveyor/potential_conveyor = locate() in get_step(src, checking_dir)
		if(isnull(potential_conveyor) || potential_conveyor.dir != REVERSE_DIR(checking_dir)) // Remove dirs that have conveyors facing us in valid_dirs_for_output
			continue
		valid_dirs_for_output -= checking_dir

	if(!length(valid_dirs_for_output)) // No possible output
		return MANUFACTURING_FAIL

	var/target_output_dir
	if(isnull(direction_last_output["[receive_dir]"]))
		var/reverse = REVERSE_DIR(receive_dir)
		target_output_dir = (reverse in valid_dirs_for_output) ? reverse : pick(valid_dirs_for_output) //initialize with the reverse of receive_dir (go forward) or a random value from valid_dirs_for_output if the former isnt applicable
		direction_last_output["[receive_dir]"] = target_output_dir
	else
		var/dir_index = WRAP_UP(valid_dirs_for_output.Find(direction_last_output["[receive_dir]"]), length(valid_dirs_for_output)) //get the next entry in valid_dirs_for_output
		target_output_dir = valid_dirs_for_output[dir_index]

	direction_last_output["[receive_dir]"] = target_output_dir
	var/obj/item/stack/source_stack
	if(isstack(receiving)) //split stacks
		source_stack = receiving
		receiving = handle_stack(receiving, receive_dir)
	if(send_resource(receiving, target_output_dir))
		dirs_received_from -= target_output_dir
		update_appearance(UPDATE_OVERLAYS) // im sorry
		return MANUFACTURING_SUCCESS
	if(!isnull(source_stack) && source_stack != receiving) // send_resource is easily the worst shit i have written so i kinda gotta do this without sacrificing something else
		var/obj/item/stack/as_stack = receiving
		as_stack.merge(source_stack) //so the stack doesnt disappear on failure
	return MANUFACTURING_FAIL

/obj/machinery/power/manufacturing/router/proc/handle_stack(obj/item/stack/stack, direction)
	if(stack.amount <= 1) // last implementation was just not good so lets cheap out
		return stack
	return stack.split_stack(1)
