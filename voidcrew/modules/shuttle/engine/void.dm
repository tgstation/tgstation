/**
  * ### Void Engines
  * These engines are literally magic. Adminspawn only.
  */
/obj/machinery/power/shuttle_engine/ship/void
	name = "void thruster"
	desc = "A thruster using technology to breach voidspace for propulsion."
	icon_state = "burst_void"
	circuit = /obj/item/circuitboard/machine/engine/void
	engine_power = 400

	icon_state_off = "burst_void"
	icon_state_closed = "burst_void"
	icon_state_open = "burst_void_open"

/obj/machinery/power/shuttle_engine/ship/void/return_fuel()
	return TRUE

/obj/machinery/power/shuttle_engine/ship/void/return_fuel_cap()
	return TRUE

/obj/machinery/power/shuttle_engine/ship/void/burn_engine()
	SHOULD_CALL_PARENT(FALSE)
	return engine_power
