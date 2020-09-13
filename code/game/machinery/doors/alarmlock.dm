/obj/machinery/door/airlock/alarmlock
	name = "glass alarm airlock"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	opacity = FALSE
	assemblytype = /obj/structure/door_assembly/door_assembly_public
	glass = TRUE

	var/datum/radio_frequency/air_connection
	var/air_frequency = FREQ_ATMOS_ALARMS
	autoclose = FALSE

/obj/machinery/airlock_sensor/ComponentInitialize()
	AddComponent(/datum/component/radio_interface, frequency, RADIO_AIRALARM, id_tag)
	RegisterSignal(src, COMSIG_RADIO_RECEIVE_DATA, ./proc/receive_signal)
	. = ..()

/obj/machinery/door/airlock/alarmlock/Initialize()
	. = ..()
	INVOKE_ASYNC(src, .proc/open)

/obj/machinery/door/airlock/alarmlock/proc/receive_signal(datum/signal/signal)
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	var/alarm_area = signal.data["zone"]
	var/alert = signal.data["alert"]

	if(alarm_area == get_area_name(src))
		switch(alert)
			if("severe")
				autoclose = TRUE
				close()
			if("minor", "clear")
				autoclose = FALSE
				open()
