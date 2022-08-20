/**
  * ### Void Engines
  * These engines are literally magic. Adminspawn only.
  */
/obj/machinery/power/shuttle/engine/void
	name = "void thruster"
	desc = "A thruster using technology to breach voidspace for propulsion."
	icon_state = "burst_void"
	icon_state_off = "burst_void"
	icon_state_closed = "burst_void"
	icon_state_open = "burst_void_open"
	circuit = /obj/item/circuitboard/machine/shuttle/engine/void
	thrust = 400

/obj/machinery/power/shuttle/engine/void/return_fuel()
	return TRUE

/obj/machinery/power/shuttle/engine/void/return_fuel_cap()
	return TRUE

/obj/machinery/power/shuttle/engine/void/burn_engine()
	return thrust
