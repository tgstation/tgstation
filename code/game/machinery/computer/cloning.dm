/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/computer/cloning
	req_access = list(ACCESS_HEADS) //ONLY USED FOR RECORD DELETION RIGHT NOW.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods //Linked cloning pods
	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp = "Ready to Scan"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/data/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/autoprocess = 0

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Initialize()
	..()
	updatemodules(TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(pods)
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/cloning/proc/GetAvailablePod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.occupant && pod.clonemind == mind)
				return null
			if(pod.is_operational() && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/cloning/proc/HasEfficientPod()
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.is_operational() && pod.efficiency > 5)
				return TRUE

/obj/machinery/computer/cloning/proc/GetAvailableEfficientPod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.occupant && pod.clonemind == mind)
				return pod
			else if(!. && pod.is_operational() && !(pod.occupant || pod.mess) && pod.efficiency > 5)
				. = pod

/obj/machinery/computer/cloning/process()
	if(!(scanner && LAZYLEN(pods) && autoprocess))
		return

	if(scanner.occupant && scanner.scan_level > 2)
		scan_occupant(scanner.occupant)

	for(var/datum/data/record/R in records)
		var/obj/machinery/clonepod/pod = GetAvailableEfficientPod(R.fields["mind"])

		if(!pod)
			return

		if(pod.occupant)
			continue	//how though?

		if(pod.growclone(R.fields["ckey"], R.fields["name"], R.fields["UI"], R.fields["SE"], R.fields["mind"], R.fields["mrace"], R.fields["features"], R.fields["factions"]))
			records -= R

/obj/machinery/computer/cloning/proc/updatemodules(findfirstcloner)
	src.scanner = findscanner()
	if(findfirstcloner && !LAZYLEN(pods))
		findcloner()

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))

		// If found and operational, return the scanner
		if (!isnull(scannerf) && scannerf.is_operational())
			return scannerf

	// If no scanner was found, it will return null
	return null

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null

	for(dir in list(NORTH,EAST,SOUTH,WEST))

		podf = locate(/obj/machinery/clonepod, get_step(src, dir))

		if (!isnull(podf) && podf.is_operational())
			AttachCloner(podf)

/obj/machinery/computer/cloning/proc/AttachCloner(obj/machinery/clonepod/pod)
	if(!pod.connected)
		pod.connected = src
		LAZYADD(pods, pod)

/obj/machinery/computer/cloning/proc/DetachCloner(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			if(!user.drop_item())
				return
			W.loc = src
			src.diskette = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			src.updateUsrDialog()
	else if(istype(W,/obj/item/device/multitool))
		var/obj/item/device/multitool/P = W

		if(istype(P.buffer, /obj/machinery/clonepod))
			if(get_area(P.buffer) != get_area(src))
				to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
				P.buffer = null
				return
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
			var/obj/machinery/clonepod/pod = P.buffer
			if(pod.connected)
				pod.connected.DetachCloner(pod)
			AttachCloner(pod)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()

/obj/machinery/computer/cloning/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/cloning/interact(mob/user)
	user.set_machine(src)
	add_fingerprint(user)

	if(..())
		return

	updatemodules(TRUE)

	var/dat = ""
	dat += "<a href='byond://?src=\ref[src];refresh=1'>Refresh</a>"

	if(scanner && HasEfficientPod() && scanner.scan_level > 2)
		if(!autoprocess)
			dat += "<a href='byond://?src=\ref[src];task=autoprocess'>Autoprocess</a>"
		else
			dat += "<a href='byond://?src=\ref[src];task=stopautoprocess'>Stop autoprocess</a>"
	else
		dat += "<span class='linkOff'>Autoprocess</span>"
	dat += "<h3>Cloning Pod Status</h3>"
	dat += "<div class='statusDisplay'>[temp]&nbsp;</div>"

	switch(src.menu)
		if(1)
			// Modules
			if (isnull(src.scanner) || !LAZYLEN(pods))
				dat += "<h3>Modules</h3>"
				//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
				if (isnull(src.scanner))
					dat += "<font class='bad'>ERROR: No Scanner detected!</font><br>"
				if (!LAZYLEN(pods))
					dat += "<font class='bad'>ERROR: No Pod detected</font><br>"

			// Scanner
			if (!isnull(src.scanner))
				var/mob/living/scanner_occupant = get_mob_or_brainmob(scanner.occupant)

				dat += "<h3>Scanner Functions</h3>"

				dat += "<div class='statusDisplay'>"
				if(!scanner_occupant)
					dat += "Scanner Unoccupied"
				else if(loading)
					dat += "[scanner_occupant] => Scanning..."
				else
					if(scanner_occupant.ckey != scantemp_ckey)
						scantemp = "Ready to Scan"
						scantemp_ckey = scanner_occupant.ckey
					dat += "[scanner_occupant] => [scantemp]"
				dat += "</div>"

				if(scanner_occupant)
					dat += "<a href='byond://?src=\ref[src];scan=1'>Start Scan</a>"
					dat += "<br><a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Unlock Scanner" : "Lock Scanner"]</a>"
				else
					dat += "<span class='linkOff'>Start Scan</span>"

			// Database
			dat += "<h3>Database Functions</h3>"
			if (src.records.len && src.records.len > 0)
				dat += "<a href='byond://?src=\ref[src];menu=2'>View Records ([src.records.len])</a><br>"
			else
				dat += "<span class='linkOff'>View Records (0)</span><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a><br>"



		if(2)
			dat += "<h3>Current records</h3>"
			dat += "<a href='byond://?src=\ref[src];menu=1'><< Back</a><br><br>"
			for(var/datum/data/record/R in records)
				dat += "<h4>[R.fields["name"]]</h4>Scan ID [R.fields["id"]] <a href='byond://?src=\ref[src];view_rec=[R.fields["id"]]'>View Record</a>"
		if(3)
			dat += "<h3>Selected Record</h3>"
			dat += "<a href='byond://?src=\ref[src];menu=2'><< Back</a><br>"

			if (!src.active_record)
				dat += "<font class='bad'>Record not found.</font>"
			else
				dat += "<h4>[src.active_record.fields["name"]]</h4>"
				dat += "Scan ID [src.active_record.fields["id"]] <a href='byond://?src=\ref[src];clone=[active_record.fields["id"]]'>Clone</a><br>"

				var/obj/item/weapon/implant/health/H = locate(src.active_record.fields["imp"])

				if ((H) && (istype(H)))
					dat += "<b>Health Implant Data:</b><br />[H.sensehealth()]<br><br />"
				else
					dat += "<font class='bad'>Unable to locate Health Implant.</font><br /><br />"

				dat += "<b>Unique Identifier:</b><br /><span class='highlight'>[src.active_record.fields["UI"]]</span><br>"
				dat += "<b>Structural Enzymes:</b><br /><span class='highlight'>[src.active_record.fields["SE"]]</span><br>"

				if(diskette && diskette.fields)
					dat += "<div class='block'>"
					dat += "<h4>Inserted Disk</h4>"
					dat += "<b>Contents:</b> "
					var/list/L = list()
					if(diskette.fields["UI"])
						L += "Unique Identifier"
					if(diskette.fields["UE"] && diskette.fields["name"] && diskette.fields["blood_type"])
						L += "Unique Enzymes"
					if(diskette.fields["SE"])
						L += "Structural Enzymes"
					dat += english_list(L, "Empty", " + ", " + ")
					dat += "<br /><a href='byond://?src=\ref[src];disk=load'>Load from Disk</a>"

					dat += "<br /><a href='byond://?src=\ref[src];disk=save'>Save to Disk</a>"
					dat += "</div>"

				dat += "<font size=1><a href='byond://?src=\ref[src];del_rec=1'>Delete Record</a></font>"

		if(4)
			if (!src.active_record)
				src.menu = 2
			dat = "[src.temp]<br>"
			dat += "<h3>Confirm Record Deletion</h3>"

			dat += "<b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>"
			dat += "<b><a href='byond://?src=\ref[src];menu=3'>Cancel</a></b>"


	var/datum/browser/popup = new(user, "cloning", "Cloning System Control")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	if(href_list["task"])
		switch(href_list["task"])
			if("autoprocess")
				autoprocess = 1
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			if("stopautoprocess")
				autoprocess = 0
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

	else if ((href_list["scan"]) && !isnull(scanner) && scanner.is_operational())
		scantemp = ""

		loading = 1
		src.updateUsrDialog()
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		say("Initiating scan...")

		spawn(20)
			src.scan_occupant(scanner.occupant)

			loading = 0
			src.updateUsrDialog()
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)


		//No locking an open scanner.
	else if ((href_list["lock"]) && !isnull(scanner) && scanner.is_operational())
		if ((!scanner.locked) && (scanner.occupant))
			scanner.locked = TRUE
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			scanner.locked = FALSE
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

	else if(href_list["view_rec"])
		playsound(src, "terminal_type", 25, 0)
		src.active_record = find_record("id", href_list["view_rec"], records)
		if(active_record)
			if(!active_record.fields["ckey"])
				records -= active_record
				active_record = null
				src.temp = "<font class='bad'>Record Corrupt</font>"
			else
				src.menu = 3
		else
			src.temp = "Record missing."

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Delete record?"
			src.menu = 4
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)

		else if (src.menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_held_item()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(src.check_access(C))
					src.temp = "[src.active_record.fields["name"]] => Record deleted."
					src.records.Remove(active_record)
					active_record = null
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
					src.menu = 2
				else
					src.temp = "<font class='bad'>Access Denied.</font>"
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if (!diskette || !istype(diskette.fields) || !diskette.fields["name"] || !diskette.fields)
					src.temp = "<font class='bad'>Load error.</font>"
					src.updateUsrDialog()
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return
				if (!src.active_record)
					src.temp = "<font class='bad'>Record error.</font>"
					src.menu = 1
					src.updateUsrDialog()
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return

				for(var/key in diskette.fields)
					src.active_record.fields[key] = diskette.fields[key]
				src.temp = "Load successful."
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

			if("eject")
				if(src.diskette)
					src.diskette.loc = src.loc
					src.diskette = null
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			if("save")
				if(!diskette || diskette.read_only || !active_record || !active_record.fields)
					src.temp = "<font class='bad'>Save error.</font>"
					src.updateUsrDialog()
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return

				diskette.fields = active_record.fields.Copy()
				diskette.name = "data disk - '[src.diskette.fields["name"]]'"
				src.temp = "Save successful."
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

	else if (href_list["refresh"])
		src.updateUsrDialog()
		playsound(src, "terminal_type", 25, 0)

	else if (href_list["clone"])
		var/datum/data/record/C = find_record("id", href_list["clone"], records)
		//Look for that player! They better be dead!
		if(C)
			var/obj/machinery/clonepod/pod = GetAvailablePod()
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!LAZYLEN(pods))
				temp = "<font class='bad'>No Clonepods detected.</font>"
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			else if(!pod)
				temp = "<font class='bad'>No Clonepods available.</font>"
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			else if(!config.revival_cloning)
				temp = "<font class='bad'>Unable to initiate cloning cycle.</font>"
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			else if(pod.occupant)
				temp = "<font class='bad'>Cloning cycle already in progress.</font>"
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			else if(pod.growclone(C.fields["ckey"], C.fields["name"], C.fields["UI"], C.fields["SE"], C.fields["mind"], C.fields["mrace"], C.fields["features"], C.fields["factions"]))
				temp = "[C.fields["name"]] => <font class='good'>Cloning cycle in progress...</font>"
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				records.Remove(C)
				if(active_record == C)
					active_record = null
				menu = 1
			else
				temp = "[C.fields["name"]] => <font class='bad'>Initialisation failure.</font>"
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

		else
			temp = "<font class='bad'>Data corruption.</font>"
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])
		playsound(src, "terminal_type", 25, 0)

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_occupant(occupant)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(iscarbon(mob_occupant))
		var/mob/living/carbon/C = mob_occupant
		dna = C.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/B = mob_occupant
		dna = B.stored_dna

	if(!istype(dna))
		scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(mob_occupant.suiciding || mob_occupant.hellbound)
		scantemp = "<font class='bad'>Subject's brain is not responding to scanning stimuli.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if((mob_occupant.disabilities & NOCLONE) && (src.scanner.scan_level < 2))
		scantemp = "<font class='bad'>Subject no longer contains the fundamental materials required to create a living clone.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	if ((!mob_occupant.ckey) || (!mob_occupant.client))
		scantemp = "<font class='bad'>Mental interface failure.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if (find_record("ckey", mob_occupant.ckey, records))
		scantemp = "<font class='average'>Subject already in database.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/data/record/R = new()
	if(dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		R.fields["mrace"] = dna.species
	else
		var/datum/species/rando_race = pick(config.roundstart_races)
		R.fields["mrace"] = rando_race.type

	R.fields["ckey"] = mob_occupant.ckey
	R.fields["name"] = mob_occupant.real_name
	R.fields["id"] = copytext(md5(mob_occupant.real_name), 2, 6)
	R.fields["UE"] = dna.unique_enzymes
	R.fields["UI"] = dna.uni_identity
	R.fields["SE"] = dna.struc_enzymes
	R.fields["blood_type"] = dna.blood_type
	R.fields["features"] = dna.features
	R.fields["factions"] = mob_occupant.faction

	if (!isnull(mob_occupant.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[mob_occupant.mind]"

   //Add an implant if needed
	var/obj/item/weapon/implant/health/imp
	for(var/obj/item/weapon/implant/health/HI in mob_occupant.implants)
		imp = HI
		break
	if(!imp)
		imp = new /obj/item/weapon/implant/health(mob_occupant)
		imp.implant(mob_occupant)
	R.fields["imp"] = "\ref[imp]"

	src.records += R
	scantemp = "Subject successfully scanned."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
