/obj/item/air_sensor
	name = "air sensor"
	desc = "Measures atmospheric information. This one is unfastened."
	icon = 'icons/obj/atmospherics/components/sensor.dmi'
	icon_state = "gsensor0"

/obj/item/air_sensor/Initialize(mapload, ...)
	. = ..()
	var/matrix/M = matrix()
	M.Turn(-12)
	transform = M

/obj/item/air_sensor/wrench_act(mob/living/user, obj/item/I)
	if(!isfloorturf(loc))
		to_chat(user, "<span class='warning'>Place it on the ground first!</span>")

	user.visible_message("<span class='notice'>[user] fastens [src] to the floor.</span>", "<span class='notice'>You fasten [src] to the floor.</span>")
	new /obj/machinery/air_sensor(loc)
	qdel(src)
	return TRUE

/// Reads air data
/obj/machinery/air_sensor
	name = "air sensor"
	desc = "Measures atmospheric information."
	icon = 'icons/obj/atmospherics/components/sensor.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	layer = GAS_PUMP_LAYER
	power_channel = AREA_USAGE_ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 40, ACID = 0)

	var/datum/gas_mixture/last_read
	var/datum/airalarm_control/control

/obj/machinery/air_sensor/Initialize(mapload, ...)
	..()
	var/area/A = get_area(src)
	name = "\proper [A.name] air sensor [assign_random_name()]"
	SSair.start_processing_machine(src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/air_sensor/LateInitialize()
	register_with_area_control()
	RegisterSignal(src, COMSIG_AREA_ENTERED, .proc/on_area_change)

/obj/machinery/air_sensor/Destroy()
	control?.unregister_sensor(src)
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/air_sensor/proc/on_area_change()
	control?.unregister_sensor(src)
	register_with_area_control()

/obj/machinery/air_sensor/proc/register_with_area_control()
	var/area/current_area = get_area(src)
	current_area.ensure_air_control()
	current_area.air_control.register_sensor(src)

/obj/machinery/air_sensor/process_atmos()
	if(!is_operational || !isturf(loc))
		return

	last_read = loc.return_air()

/obj/machinery/air_sensor/on_set_is_operational(old_value)
	. = ..()
	update_icon()

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[is_operational]"

/obj/machinery/air_sensor/wrench_act(mob/living/user, obj/item/I)
	user.visible_message("<span class='notice'>[user] unfastens [src] from the floor.</span>", "<span class='notice'>You unfasten [src] from the floor.</span>")
	new /obj/item/air_sensor(drop_location())
	qdel(src)
	return TRUE
