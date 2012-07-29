/obj/machinery/computer/scan_consolenew
	name = "DNA Modifier Access Console"
	desc = "Scand DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = 1
	var/uniblock = 1.0
	var/strucblock = 1.0
	var/subblock = 1.0
	var/unitarget = 1
	var/unitargethex = 1
	var/status = null
	var/radduration = 2.0
	var/radstrength = 1.0
	var/radacc = 1.0
	var/buffer1 = null
	var/buffer2 = null
	var/buffer3 = null
	var/buffer1owner = null
	var/buffer2owner = null
	var/buffer3owner = null
	var/buffer1label = null
	var/buffer2label = null
	var/buffer3label = null
	var/buffer1type = null
	var/buffer2type = null
	var/buffer3type = null
	var/buffer1iue = 0
	var/buffer2iue = 0
	var/buffer3iue = 0
	var/delete = 0
	var/injectorready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/temphtml = null
	var/obj/machinery/dna_scanner/connected = null
	var/obj/item/weapon/disk/data/diskette = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/scan_consolenew/M = new /obj/item/weapon/circuitboard/scan_consolenew( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/scan_consolenew/M = new /obj/item/weapon/circuitboard/scan_consolenew( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	if (istype(I, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_item()
			I.loc = src
			src.diskette = I
			user << "You insert [I]."
			src.updateUsrDialog()
			return
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/cloning
	name = "Cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	circuit = "/obj/item/weapon/circuitboard/cloning"
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/data/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text

/obj/machinery/computer/cloning/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	src.pod1 = findcloner()

	if (!isnull(src.pod1))
		src.pod1.connected = src // Some variable the pod needs

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))

		// If found, then we break, and return the scanner
		if (!isnull(scannerf))
			break

	// If no scanner was found, it will return null
	return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null

	for(dir in list(NORTH,EAST,SOUTH,WEST))

		podf = locate(/obj/machinery/clonepod, get_step(src, dir))

		if (!isnull(podf))
			break

	return podf

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_item()
			W.loc = src
			src.diskette = W
			user << "You insert [W]."
			src.updateUsrDialog()
			return
	else
		..()
	return

/obj/machinery/computer/cloning/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	user.machine = src
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	var/dat = "<h3>Cloning System Control</h3>"
	dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"

	dat += "<br><tt>[temp]</tt><br>"

	switch(src.menu)
		if(1)
			// Modules
			dat += "<h4>Modules</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if (isnull(src.scanner))
				dat += " <font color=red>Scanner-ERROR</font><br>"
			else
				dat += " <font color=green>Scanner-Found!</font><br>"
			if (isnull(src.pod1))
				dat += " <font color=red>Pod-ERROR</font><br>"
			else
				dat += " <font color=green>Pod-Found!</font><br>"

			// Scanner
			dat += "<h4>Scanner Functions</h4>"

			if(loading)
				dat += "<b>Scanning...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if (isnull(src.scanner))
				dat += "No scanner connected!<br>"
			else
				if (src.scanner.occupant)
					if(scantemp == "Scanner unoccupied") scantemp = "" // Stupid check to remove the text

					dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [src.scanner.occupant]</a><br>"
				else
					scantemp = "Scanner unoccupied"

				dat += "Lock status: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Locked" : "Unlocked"]</a><br>"

			// Database
			dat += "<h4>Database Functions</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)
			dat += "<h4>Current records</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=1'>Back</a><br><br>"
			for(var/datum/data/record/R in src.records)
				dat += "<a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.fields["id"]]-[R.fields["name"]]</a><br>"

		if(3)
			dat += "<h4>Selected Record</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"

			if (!src.active_record)
				dat += "<font color=red>ERROR: Record not found.</font>"
			else
				dat += "<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Delete Record</a></font><br>"
				dat += "<b>Name:</b> [src.active_record.fields["name"]]<br>"

				var/obj/item/weapon/implant/health/H = locate(src.active_record.fields["imp"])

				if ((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()] | OXY-BURN-TOX-BRUTE<br>"
				else
					dat += "<font color=red>Unable to locate implant.</font><br>"

				if (!isnull(src.diskette))
					dat += "<a href='byond://?src=\ref[src];disk=load'>Load from disk.</a>"

					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>"
					dat += "<br>"
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [src.active_record.fields["UI"]]<br>
				<b>SE:</b> [src.active_record.fields["SE"]]<br><br>
				<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"}

		if(4)
			if (!src.active_record)
				src.menu = 2
			dat = "[src.temp]<br>"
			dat += "<h4>Confirm Record Deletion</h4>"

			dat += "<b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>"
			dat += "<b><a href='byond://?src=\ref[src];menu=3'>No</a></b>"


	user << browse(dat, "window=cloning")
	onclose(user, "cloning")
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	if ((href_list["scan"]) && (!isnull(src.scanner)))
		scantemp = ""

		loading = 1
		src.updateUsrDialog()

		spawn(20)
			src.scan_mob(src.scanner.occupant)

			loading = 0
			src.updateUsrDialog()


		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(src.scanner)))
		if ((!src.scanner.locked) && (src.scanner.occupant))
			src.scanner.locked = 1
		else
			src.scanner.locked = 0

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"])
		if ((isnull(src.active_record.fields["ckey"])) || (src.active_record.fields["ckey"] == ""))
			del(src.active_record)
			src.temp = "ERROR: Record Corrupt"
		else
			src.menu = 3

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Delete record?"
			src.menu = 4

		else if (src.menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(src.check_access(C))
					src.records.Remove(src.active_record)
					del(src.active_record)
					src.temp = "Record deleted."
					src.menu = 2
				else
					src.temp = "Access Denied."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(src.diskette)) || (src.diskette.data == ""))
					src.temp = "Load error."
					src.updateUsrDialog()
					return
				if (isnull(src.active_record))
					src.temp = "Record error."
					src.menu = 1
					src.updateUsrDialog()
					return

				if (src.diskette.data_type == "ui")
					src.active_record.fields["UI"] = src.diskette.data
					if (src.diskette.ue)
						src.active_record.fields["name"] = src.diskette.owner
				else if (src.diskette.data_type == "se")
					src.active_record.fields["SE"] = src.diskette.data

				src.temp = "Load successful."
			if("eject")
				if (!isnull(src.diskette))
					src.diskette.loc = src.loc
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Save error."
			src.updateUsrDialog()
			return

		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				src.diskette.data = src.active_record.fields["UI"]
				src.diskette.ue = 0
				src.diskette.data_type = "ui"
			if("ue")
				src.diskette.data = src.active_record.fields["UI"]
				src.diskette.ue = 1
				src.diskette.data_type = "ui"
			if("se")
				src.diskette.data = src.active_record.fields["SE"]
				src.diskette.ue = 0
				src.diskette.data_type = "se"
		src.diskette.owner = src.active_record.fields["name"]
		src.diskette.name = "data disk - '[src.diskette.owner]'"
		src.temp = "Save \[[href_list["save_disk"]]\] successful."

	else if (href_list["refresh"])
		src.updateUsrDialog()

	else if (href_list["clone"])
		var/datum/data/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			var/mob/selected = find_dead_player("[C.fields["ckey"]]")

//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if ((!selected) || (!src.pod1) || (src.pod1.occupant) || (src.pod1.mess) || !config.revival_cloning)
				src.temp = "Unable to initiate cloning cycle." // most helpful error message in THE HISTORY OF THE WORLD
			else if (src.pod1.growclone(selected, C.fields["name"], C.fields["UI"], C.fields["SE"], C.fields["mind"], C.fields["mrace"], C.fields["interface"],C.fields["changeling"]))
				src.temp = "Cloning cycle activated."
				src.records.Remove(C)
				del(C)
				src.menu = 1

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	if ((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna))
		scantemp = "Error: Unable to locate valid genetic data."
		return
	if (subject.brain_op_stage == 4.0)
		scantemp = "Error: No signs of intelligence detected."
		return
	if (subject.suiciding == 1)
		scantemp = "Error: Subject's brain is not responding to scanning stimuli."
		return
	if ((!subject.ckey) || (!subject.client))
		scantemp = "Error: Mental interface failure."
		return
	if (NOCLONE in subject.mutations)
		scantemp = "Error: Mental interface failure."
		return
	if (!isnull(find_record(subject.ckey)))
		scantemp = "Subject already in database."
		return

	subject.dna.check_integrity()

	var/datum/data/record/R = new /datum/data/record(  )
	R.fields["mrace"] = subject.mutantrace
	R.fields["ckey"] = subject.ckey
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)
	R.fields["UI"] = subject.dna.uni_identity
	R.fields["SE"] = subject.dna.struc_enzymes
	R.fields["changeling"] = subject.changeling

	// Preferences stuff
	R.fields["interface"] = subject.UI



	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		R.fields["imp"] = "\ref[imp]"
	//Update it if needed
	else
		R.fields["imp"] = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/data/record/R in src.records)
		if (R.fields["ckey"] == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/power_change()

	if(stat & BROKEN)
		icon_state = "commb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER