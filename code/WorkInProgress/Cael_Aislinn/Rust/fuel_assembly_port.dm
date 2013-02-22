

/obj/machinery/rust_fuel_assembly_port
	name = "Fuel Assembly Port"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "port2"
	density = 0
	var/obj/item/weapon/fuel_assembly/cur_assembly
	layer = 4
	var/busy = 0
	anchored = 1

	var/opened = 1 //0=closed, 1=opened
	var/coverlocked = 0
	var/locked = 0
	var/has_electronics = 0 // 0 - none, bit 1 - circuitboard, bit 2 - wires

/obj/machinery/rust_fuel_assembly_port/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/fuel_assembly) && !opened)
		if(cur_assembly)
			user << "\red There is already a fuel rod assembly in there!"
		else
			cur_assembly = I
			user.drop_item()
			I.loc = src
			icon_state = "port1"

/obj/machinery/rust_fuel_assembly_port/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER) || opened)
		return

	if(!busy)
		busy = 1
		if(cur_assembly)
			spawn(30)
				if(!try_insert_assembly())
					spawn(30)
						eject_assembly()
						busy = 0
				else
					busy = 0
		else
			spawn(30)
				try_draw_assembly()
				busy = 0

/obj/machinery/rust_fuel_assembly_port/proc/try_insert_assembly()
	var/success = 0
	if(cur_assembly)
		var/turf/check_turf = get_step(get_turf(src), src.dir)
		check_turf = get_step(check_turf, src.dir)
		for(var/obj/machinery/power/rust_fuel_injector/I in check_turf)
			if(I.stat & (BROKEN|NOPOWER))
				break
			if(I.cur_assembly)
				break

			I.cur_assembly = cur_assembly
			cur_assembly.loc = I
			cur_assembly = null
			icon_state = "port0"
			success = 1

	if(success)
		src.visible_message("\blue \icon[src] a green light flashes on [src] as it inserts it's fuel rod assembly into an injector.")
	else
		src.visible_message("\red \icon[src] a red light flashes on [src] as it attempts to insert it's fuel rod assembly into an injector.")
	return success

/obj/machinery/rust_fuel_assembly_port/proc/eject_assembly()
	if(cur_assembly)
		var/turf/check_turf = get_step(get_turf(src), src.dir)
		cur_assembly.loc = check_turf
		cur_assembly = null
		icon_state = "port0"
		return 1
	else
		src.visible_message("\red \icon[src] a red light flashes on [src] as it attempts to eject it's fuel rod assembly.")

/obj/machinery/rust_fuel_assembly_port/proc/try_draw_assembly()
	var/success = 0
	if(cur_assembly)
		var/turf/check_turf = get_step(get_turf(src), src.dir)
		check_turf = get_step(check_turf, src.dir)
		for(var/obj/machinery/power/rust_fuel_injector/I in check_turf)
			if(I.stat & (BROKEN|NOPOWER))
				break
			if(!I.cur_assembly)
				break
			if(I.injecting)
				break
			if(I.stat != 2)
				break

			cur_assembly = I.cur_assembly
			cur_assembly.loc = src
			I.cur_assembly = null
			icon_state = "port1"
			success = 1

	if(success)
		src.visible_message("\icon[src] a blue light flashes on [src] as it draws a fuel rod assembly from an injector.")
	else
		src.visible_message("\red \icon[src] a red light flashes on [src] as it attempts to draw a fuel rod assembly from an injector.")
	return success

/*
/obj/machinery/rust_fuel_assembly_port/verb/try_insert_assembly_verb()
	set name = "Attempt to insert assembly from port into injector"
	set category = "Object"
	set src in oview(1)

	if(!busy)
		try_insert_assembly()

/obj/machinery/rust_fuel_assembly_port/verb/eject_assembly_verb()
	set name = "Attempt to eject assembly from port"
	set category = "Object"
	set src in oview(1)

	if(!busy)
		eject_assembly()

/obj/machinery/rust_fuel_assembly_port/verb/try_draw_assembly_verb()
	set name = "Draw assembly from injector"
	set category = "Object"
	set src in oview(1)

	if(!busy)
		try_draw_assembly()
*/
