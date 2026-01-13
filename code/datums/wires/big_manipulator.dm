/datum/wires/big_manipulator
	holder_type = /obj/machinery/big_manipulator
	proper_name = "Big_Manipulator"

/datum/wires/big_manipulator/New(atom/holder)
	wires = list(
		WIRE_ON,
		WIRE_DROP,
		WIRE_ITEM_TYPE,
		WIRE_CHANGE_MODE,
		WIRE_ONE_PRIORITY_BUTTON,
		WIRE_THROW_RANGE
	)
	return ..()

/datum/wires/big_manipulator/interactable(mob/user)
	var/obj/machinery/big_manipulator/holder_manipulator = holder

	return holder_manipulator.panel_open ? ..() : FALSE

/datum/wires/big_manipulator/get_status()
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	var/list/status = list()
	status += "The big light bulb [holder_manipulator.power_access_wire_cut ? "is off" : "is glowing [holder_manipulator.on ? "green" : "red"]"]."
	status += "The small light bulb [holder_manipulator.held_object ? "is glowing bright green" : "is off"]."
	status += "The green number on the display shows [length(holder_manipulator.pickup_points)]."
	status += "The red number on the display shows [length(holder_manipulator.dropoff_points)]."
	return status

/datum/wires/big_manipulator/on_pulse(wire)
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	switch(wire)
		if(WIRE_ON)
			holder_manipulator.try_press_on(usr)
		if(WIRE_DROP)
			holder_manipulator.drop_held_atom()

/datum/wires/big_manipulator/on_cut(wire, mend, source)
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	if(wire == WIRE_ON)
		if(mend)
			holder_manipulator.power_access_wire_cut = FALSE
			return
		holder_manipulator.power_access_wire_cut = TRUE
