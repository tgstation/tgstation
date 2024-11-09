/obj/machinery/power/manufacturing/router // Basically a splitter
	name = "manufacturing router"
	desc = "Distributes input to 3 output directions equally. Stacks are split, and you may toggle outputs with a multitool. May not receive from other routers."
	allow_mob_bump_intake = TRUE
	icon_state = "splitter"
	circuit = /obj/item/circuitboard/machine/manurouter
	/// outputs disabled with a multitool
	var/list/disabled_dirs = list()
	/// directions we can output to right now
	var/list/directions

/obj/machinery/power/manufacturing/router/Initialize(mapload)
	. = ..()
	directions = GLOB.cardinals.Copy()

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
			variant = (direction == dir) ? "in" : "out"
		var/image/new_overlay = image(icon, "splitter_[variant]", layer = layer+0.001, dir = direction)
		. += new_overlay

/obj/machinery/power/manufacturing/router/receive_resource(obj/receiving, atom/from, receive_dir)
	if(istype(from, /obj/machinery/power/manufacturing/router))
		return MANUFACTURING_FAIL
	var/list/filtered = directions - receive_dir - disabled_dirs
	if(!length(filtered))
		directions = GLOB.cardinals.Copy()
	for(var/target in filtered)
		directions -= target
		if(isstack(receiving))
			receiving = handle_stack(receiving, receive_dir)
		if(send_resource(receiving, target))
			dir = receive_dir
			update_appearance(UPDATE_OVERLAYS) // im sorry
			return MANUFACTURING_SUCCESS
	return MANUFACTURING_FAIL_FULL

/obj/machinery/power/manufacturing/router/proc/handle_stack(obj/item/stack/stack, direction)
	if(stack.amount <= 1) // last implementation was just not good so lets cheap out
		return stack
	return stack.split_stack(amount = 1)
