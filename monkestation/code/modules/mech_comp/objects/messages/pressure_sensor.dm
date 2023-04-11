/obj/item/mcobject/messaging/pressure_sensor
	name = "pressure sensor"
	base_icon_state = "comp_pressure"
	icon_state = "comp_pressure"

	COOLDOWN_DECLARE(cd)

/obj/item/mcobject/messaging/pressure_sensor/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/mcobject/messaging/pressure_sensor/proc/on_entered(datum/source, atom/movable/thing)
	set waitfor = FALSE

	if(!anchored)
		return

	if(!thing.density)
		return

	if(!COOLDOWN_FINISHED(src, cd))
		return

	if(!thing.has_gravity())
		return

	COOLDOWN_START(src, cd, 0.2 SECONDS)
	fire(stored_message)
	log_message("triggered by [key_name(source)]", LOG_MECHCOMP)
