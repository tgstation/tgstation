/**
  * ## Engine Thrusters
  * The workhorse of any movable ship, these engines (usually) take in some kind fuel and produce thrust to move ships.
  * Voidcrew subtype is to add unique icons, and being able to enable/disable it at will.
  */
/obj/machinery/power/shuttle_engine/ship
	name = "shuttle thruster"
	desc = "A thruster for shuttles."
	icon = 'voidcrew/modules/shuttle/icons/shuttle.dmi'
	circuit = /obj/item/circuitboard/machine/engine
	can_atmos_pass = ATMOS_PASS_NO //so people can actually tend to their engines

	///How much thrust this engine generates when burned fully.
	engine_power = 0

	///Whether or not the engine is enabled and can be used. Controlled from helm consoles and by hitting with a multitool.
	var/enabled = TRUE
	///I don't really know what this is but it's used a lot
	var/thruster_active = FALSE

	///Icon when the machine is screwdrivered open, takes priority over the other two
	var/icon_state_open = "burst_plasma_open"
	///The icon when the machine is closed and active.
	var/icon_state_closed = "burst_plasma"
	///The icon when the machine is closed, but NOT active.
	var/icon_state_off = "burst_plasma_off"

/**
  * Uses up a specified percentage of the fuel cost, and returns the amount of thrust if successful.
  * * percentage - The percentage of total thrust that should be used
  */
/obj/machinery/power/shuttle_engine/ship/proc/burn_engine(percentage = 100)
	SHOULD_CALL_PARENT(TRUE)
	update_appearance(UPDATE_ICON)
	return FALSE

/**
  * Returns how much "Fuel" is left. (For use with engine displays.)
  */
/obj/machinery/power/shuttle_engine/ship/proc/return_fuel()
	return

/**
  * Returns how much "Fuel" can be held. (For use with engine displays.)
  */
/obj/machinery/power/shuttle_engine/ship/proc/return_fuel_cap()
	return

/**
  * Updates the engine state.
  * All functions should return if the parent function returns false.
  */
/obj/machinery/power/shuttle_engine/ship/proc/update_engine()
	thruster_active = !panel_open
	return thruster_active

/**
  * Updates the engine's icon and engine state.
  */
/obj/machinery/power/shuttle_engine/ship/update_icon_state()
	. = ..()
	update_engine() //Calls this so it sets the accurate icon
	if(panel_open)
		icon_state = icon_state_open
	else if(thruster_active)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_off

/obj/machinery/power/shuttle_engine/ship/Initialize()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/power/shuttle_engine/ship/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!do_after(user, MIN_TOOL_SOUND_DELAY, target=src))
		return ..()
	enabled = !enabled
	to_chat(user, span_notice("You [enabled ? "enable" : "disable"] \the [src]."))
	update_appearance(UPDATE_ICON)

/obj/machinery/power/shuttle_engine/ship/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, tool))
		return TRUE
	update_appearance(UPDATE_ICON)
	return FALSE

/obj/machinery/power/shuttle_engine/ship/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!panel_open)
		user.balloon_alert(user, "open panel first!")
		return FALSE
	if(default_deconstruction_crowbar(tool))
		return TRUE
	return FALSE
