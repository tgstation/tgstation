/obj/machinery/mass_driver
	name = "mass driver"
	desc = "The finest in spring-loaded piston toy technology, now on a space station near you."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "mass_driver"
	circuit = /obj/item/circuitboard/machine/mass_driver
	var/power = 1
	var/code = 1
	var/id = 1
	var/drive_range = 10
	var/power_per_obj = 1000

/obj/machinery/mass_driver/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/mass_driver(src)

/obj/machinery/mass_driver/chapelgun
	name = "holy driver"
	id = MASSDRIVER_CHAPEL

/obj/machinery/mass_driver/ordnance
	id = MASSDRIVER_ORDNANCE

/obj/machinery/mass_driver/trash
	id = MASSDRIVER_DISPOSALS

/obj/machinery/mass_driver/shack
	id = MASSDRIVER_SHACK

/obj/machinery/mass_driver/Destroy()
	for(var/obj/machinery/computer/pod/control as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/pod))
		if(control.id == id)
			control.connected = null
	QDEL_NULL(wires)
	return ..()

/obj/machinery/mass_driver/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

/obj/machinery/mass_driver/proc/drive(amount)
	if(machine_stat & (BROKEN|NOPOWER) || panel_open)
		return
	use_energy(power_per_obj)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored || ismecha(O)) //Mechs need their launch platforms.
			if(ismob(O) && !isliving(O))
				continue
			O_limit++
			if(O_limit >= 20)
				audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
				break
			use_energy(power_per_obj)
			O.throw_at(target, drive_range * power, power)
	flick("mass_driver1", src)

/obj/machinery/mass_driver/attackby(obj/item/I, mob/living/user, params)

	if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	if(default_deconstruction_screwdriver(user, "mass_driver_o", "mass_driver", I))
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/mass_driver/RefreshParts()
	. = ..()
	for(var/datum/stock_part/servo/new_servo in component_parts)
		drive_range += new_servo.tier * 10

/obj/machinery/mass_driver/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(machine_stat & (BROKEN|NOPOWER) || panel_open)
		return
	drive()
