#define AIRLOCK_CLOSED 1
#define AIRLOCK_CLOSING 2
#define AIRLOCK_OPEN 3
#define AIRLOCK_OPENING 4
#define AIRLOCK_DENY 5
#define AIRLOCK_EMAG 6

/obj/machinery/door/airlock
	icon = 'modular_bandastation/aesthetics/airlocks/icons/station/public.dmi'
	overlays_file = 'modular_bandastation/aesthetics/airlocks/icons/station/overlays.dmi'
	note_overlay_file = 'modular_bandastation/aesthetics/airlocks/icons/station/overlays.dmi'

	doorOpen = 'modular_bandastation/aesthetics/airlocks/sound/open.ogg'
	doorClose = 'modular_bandastation/aesthetics/airlocks/sound/close.ogg'
	boltUp = 'modular_bandastation/aesthetics/airlocks/sound/bolts_up.ogg'
	boltDown = 'modular_bandastation/aesthetics/airlocks/sound/bolts_down.ogg'

/obj/machinery/door/airlock/update_overlays()
	. = ..()
	if(!lights || !hasPower())
		return
	var/light_state
	switch(airlock_state)
		if(AIRLOCK_CLOSED)
			if(!locked && !emergency)
				light_state = "poweron"
		if(AIRLOCK_OPEN)
			if(locked)
				light_state = AIRLOCK_LIGHT_BOLTS
			else if(emergency)
				light_state = AIRLOCK_LIGHT_EMERGENCY
			else
				light_state = "poweron"
			light_state = "[light_state]_open"
	. += get_airlock_overlay("lights_[light_state]", overlays_file, src, em_block = FALSE)


#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG
