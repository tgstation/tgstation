/obj/machinery/computer/orndconsole
	name = "ORND console"
	desc = "A computer console used for operating ORND machines and storing data."
	//todo: add circuit
	icon_screen = "organscan"
	icon_keyboard = "generic_key"
	var/obj/machinery/ornd/bodyscanner/linked_scanner
	var/obj/machinery/ornd/orgsynth/linked_synth
	var/obj/machinery/ornd/organres/linked_res
	var/list/savedOrgans = list()
	var/screen = 0
	var/scan
	//0 is main menu
	//1 is chemical menu

/obj/machinery/computer/orndconsole/Initialize()
	. = ..()
	SyncDevices()
	if(!GLOB.refDatum)
		GLOB.refDatum = new /datum/ornd

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

/obj/machinery/computer/orndconsole/interact(mob/user)
	SyncDevices()
	var/dat = ""
	switch(screen)
		if(0)
			dat += "<div class='statusDisplay'><h3>ORND menu:</h3><br>"
			if(linked_res.heldorgan)
				dat += "<a href='?src=\ref[src];scan=1'>Scan organ</a><br>"
			else
				dat += "<span class='linkOff'>Scan organ</span><br>"
			dat += "<A href='?src=\ref[src];screen=1'>Chemical Storage</A><br>"
			dat += "Known organs:<br>"
			for(var/D in savedOrgans)
				var/datum/organ/O = savedOrgans[D]
				if(!linked_synth.canBuild)
					dat += "<span class='linkOff'>[O.name]</span>"
				else
					dat += "<a href='?src=\ref[src];make=[O];multiplier=1'>[O.name]</a>"

	var/datum/browser/popup = new(user, "orndconsole", "Organ Research Console", 450, 440)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/orndconsole/Topic(href, href_list)
	if(..())
		return

	if(href_list["scan"])
		if(linked_res)
			savedOrgan += linked_res.scan()


