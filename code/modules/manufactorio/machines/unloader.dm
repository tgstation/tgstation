/obj/machinery/power/manufacturing/unloader
	name = "manufacturing crate unloader"
	desc = "Unloads crates (and ore boxes) passed into it, ejecting the empty crate to the side and its contents forwards. Use a multitool to flip the crate output."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader-corner"
	circuit = /obj/item/circuitboard/machine/manuunloader
	/// power used per attempt to unload a crate
	var/power_to_unload_crate = 2 KILO WATTS
	/// whether the side we output unloaded crates is flipped
	var/flip_side = FALSE

/obj/machinery/power/manufacturing/unloader/update_overlays()
	. = ..()
	. += generate_io_overlays(dir, COLOR_ORANGE) // OUT - stuff in it
	. += generate_io_overlays(REVERSE_DIR(dir), COLOR_MODERATE_BLUE) // IN - crate
	. += generate_io_overlays(turn(dir, flip_side ? 90 : -90), COLOR_ORANGE) // OUT -- empty crate

/obj/machinery/power/manufacturing/unloader/request_resource() //returns held crate if someone wants to do that for some reason
	var/list/real_contents = contents - circuit
	if(!length(real_contents))
		return
	return (real_contents)[1]

/obj/machinery/power/manufacturing/unloader/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "flipped")
	flip_side = !flip_side
	update_appearance()

/obj/machinery/power/manufacturing/unloader/receive_resource(obj/receiving, atom/from, receive_dir)
	if(surplus() < power_to_unload_crate || receive_dir != REVERSE_DIR(dir))
		return MANUFACTURING_FAIL
	var/list/real_contents = contents - circuit
	if(length(real_contents))
		return MANUFACTURING_FAIL_FULL

	var/obj/structure/closet/as_closet = receiving
	var/obj/structure/ore_box/as_orebox = receiving
	if(istype(as_closet))
		if(!as_closet.can_open())
			return MANUFACTURING_FAIL
	else if(!istype(as_orebox))
		return MANUFACTURING_FAIL
	receiving.Move(src, get_dir(receiving, src))
	START_PROCESSING(SSfastprocess, src)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/unloader/process(seconds_per_tick)
	var/list/real_contents = contents - circuit
	if(!length(real_contents))
		return PROCESS_KILL
	if(surplus() < power_to_unload_crate)
		return
	add_load(power_to_unload_crate)
	var/obj/structure/closet/closet = real_contents[1]
	if(istype(closet))
		return unload_crate(closet)
	else
		return unload_orebox(closet)

/obj/machinery/power/manufacturing/unloader/proc/unload_crate(obj/structure/closet/closet)
	if (!closet.contents_initialized)
		closet.contents_initialized = TRUE
		closet.PopulateContents()
		SEND_SIGNAL(closet, COMSIG_CLOSET_CONTENTS_INITIALIZED)
	for(var/atom/thing as anything in closet.contents)
		if(ismob(thing))
			continue
		send_resource(thing, dir)
	if(!length(closet.contents) && send_resource(closet, turn(dir, flip_side ? 90 : -90)))
		closet.open(force = TRUE)
		return PROCESS_KILL

/obj/machinery/power/manufacturing/unloader/proc/unload_orebox(obj/structure/ore_box/box)
	for(var/atom/thing as anything in box.contents)
		send_resource(thing, dir)
	if(!length(box.contents) && send_resource(box, turn(dir, flip_side ? 90 : -90)))
		return PROCESS_KILL
