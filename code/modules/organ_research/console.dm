/obj/machinery/computer/orndconsole
	name = "ORND console"
	desc = "A computer console used for operating ORND machines and storing data."
	//todo: add circuit
	icon_screen = "organscan"
	icon_keyboard = "generic_key"
	var/first_use = 1	//If first_use = 1, it will try to auto-connect with nearby devices
	var/obj/machinery/ornd/bodyscanner/linked_scanner = null
	var/obj/machinery/ornd/orgsynth/linked_synth = null
	var/obj/machinery/ornd/organres/linked_res = null

/obj/machinery/computer/orndconsole/Initialize()
	.=..()
	SyncDevices()

/obj/machinery/computer/orndconsole/proc/SyncDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/ornd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/ornd/bodyscanner))
			if(linked_scanner == null)
				linked_scanner = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/ornd/organres))
			if(linked_res == null)
				linked_res = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/ornd/orgsynth))
			if(linked_synth == null)
				linked_synth = D
				D.linked_console = src
	first_use = 0