#define ENGINE_HEAT_TARGET 600
#define ENGINE_HEATING_POWER 5000000

/**
  * ## Engine Thrusters
  * The workhorse of any movable ship, these engines (usually) take in some kind fuel and produce thrust to move ships.
  */

/obj/machinery/power/shuttle/engine
	name = "shuttle thruster"
	desc = "A thruster for shuttles."
	circuit = /obj/item/circuitboard/machine/shuttle/engine
	can_atmos_pass = ATMOS_PASS_NO //so people can actually tend to their engines

	///Whether or not the engine is enabled and can be used. Controlled from helm consoles and by hitting with a multitool.
	var/enabled = TRUE
	///How much thrust this engine generates when burned fully.
	var/thrust = 0
	///I don't really know what this is but it's used a lot
	var/thruster_active = FALSE

/**
  * Uses up a specified percentage of the fuel cost, and returns the amount of thrust if successful.
  * * percentage - The percentage of total thrust that should be used
  */
/obj/machinery/power/shuttle/engine/proc/burn_engine(percentage = 100)
	update_icon_state()
	return FALSE

/**
  * Returns how much "Fuel" is left. (For use with engine displays.)
  */
/obj/machinery/power/shuttle/engine/proc/return_fuel()
	return

/**
  * Returns how much "Fuel" can be held. (For use with engine displays.)
  */
/obj/machinery/power/shuttle/engine/proc/return_fuel_cap()
	return

/**
  * Updates the engine state.
  * All functions should return if the parent function returns false.
  */
/obj/machinery/power/shuttle/engine/proc/update_engine()
	thruster_active = TRUE
	if(panel_open)
		thruster_active = FALSE
		return FALSE
	return TRUE

/**
  * Updates the engine's icon and engine state.
  */
/obj/machinery/power/shuttle/engine/update_icon_state()
	. = ..()
	update_engine() //Calls this so it sets the accurate icon
	if(panel_open)
		icon_state = icon_state_open
	else if(thruster_active)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_off

/obj/machinery/power/shuttle/engine/Initialize()
	. = ..()
	update_icon_state()
	alter_engine_power(0.5)

/obj/machinery/power/shuttle/engine/Destroy()
	. = ..()
	alter_engine_power(-0.5)

/obj/machinery/power/shuttle/engine/on_construction()
	. = ..()
	update_icon_state()

/obj/machinery/power/shuttle/engine/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(do_after(user, MIN_TOOL_SOUND_DELAY, target=src))
		enabled = !enabled
		to_chat(user, "<span class='notice'>You [enabled ? "enable" : "disable"] [src].")

///Propagates the change to the shuttle.
/obj/machinery/power/shuttle/engine/proc/alter_engine_power(mod)
	if(mod == 0)
		return
/* //voidcrew todo: ship functionality
	if(SSshuttle.is_in_shuttle_bounds(src))
		var/obj/docking_port/mobile/ship = SSshuttle.get_containing_shuttle(src)
		if(ship)
			ship.alter_engines(mod, src)
*/

#undef ENGINE_HEAT_TARGET
#undef ENGINE_HEATING_POWER
