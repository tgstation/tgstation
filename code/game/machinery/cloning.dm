/var/list/geneticsrecords = list()
//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_medlab) //For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 10 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk

/obj/machinery/computer/cloning
	name = "Cloning console"
	icon = 'computer.dmi'
	icon_state = "dna"
	circuit = "/obj/item/weapon/circuitboard/cloning"
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = "Initializing System..."
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/data/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/wantsscan = 1
	var/wantspod = 1
	var/list/message = list()

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "Cloning Data Disk"
	icon = 'cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = 1.0
	var/data = ""
	var/ue = 0
	var/data_type = "ui" //ui|se
	var/owner = "God Emperor of Mankind"
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	ue = 1
	read_only = 1

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	data_type = "se"
	data = "0983E840344C39F4B059D5145FC5785DC6406A4FFF"
	read_only = 1

/obj/machinery/computer/cloning/New()
	..()
	spawn(5)
		updatemodules()
		/*src.scanner = locate(/obj/machinery/dna_scannernew, get_step(src, scandir))
		src.pod1 = locate(/obj/machinery/clonepod, get_step(src, poddir))

		src.temp = ""
		if (isnull(src.scanner) && wantsscan)
			src.temp += " <font color=red>SCNR-ERROR</font>"
		if (isnull(src.pod1) && wantspod)
			src.temp += " <font color=red>POD1-ERROR</font>"
		else if (wantspod)
			src.pod1.connected = src

		if (src.temp == "")
			src.temp = "System ready."*/
		return
	return

/obj/machinery/computer/cloning/proc/updatemodules()
	//world << "UPDATING MODULES"
	src.scanner = findscanner()//locate(/obj/machinery/dna_scannernew, get_step(src, WEST))
	src.pod1 = findcloner()//locate(/obj/machinery/clonepod, get_step(src, EAST))
	//world << "SEARCHING FOR MACHEIN"
	//src.temp = ""
	//if (isnull(src.scanner))
	//	src.temp += " <font color=red>SCNR-ERROR</font>"
	if (!isnull(src.pod1)  && !wantspod)
		src.pod1.connected = src
	//	src.temp += " <font color=red>POD1-ERROR</font>"
	//else

	//if (src.temp == "")
	//	src.temp = "System ready."

/obj/machinery/computer/cloning/proc/findscanner()
	//..()
	//world << "SEARCHING FOR SCANNER"
	var/obj/machinery/dna_scannernew/scannerf = null
	for(dir in list(1,2,4,8,5,6,9,10))
		//world << "SEARCHING IN [dir]"
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
		if (!isnull(scannerf))
			//world << "FOUND"
			break
	if(isnull(scannerf) && wantsscan)
		src.temp += " <font color=red>SCNR-ERROR</font>"
	return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	//..()
	//world << "SEARCHING FOR POD"
	var/obj/machinery/clonepod/podf = null
	for(dir in list(1,2,4,8,5,6,9,10))
		//world << "SEARCHING IN [dir]"
		podf = locate(/obj/machinery/clonepod, get_step(src, dir))
		if (!isnull(podf))
			//world << "FOUND"
			break
	if(isnull(podf) && wantspod)
		src.temp += " <font color=red>POD1-ERROR</font>"
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
	if(!(user in message))
		user << "\blue This machine looks extremely complex. You'd probably need a decent knowledge of Genetics to understand it."
		message += user
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
			if(wantsscan)
				dat += "<h4>Scanner Functions</h4>"

				if (isnull(src.scanner))
					dat += "No scanner connected!"
				else
					if (src.scanner.occupant)
						dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [src.scanner.occupant]</a>"
					else
						dat += "Scanner unoccupied"

					dat += "<br>Lock status: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Locked" : "Unlocked"]</a>"

			dat += "<h4>Database Functions</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)
			dat += "<h4>Current records</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=1'>Back</a><br><br>"
			for(var/datum/data/record/R in geneticsrecords)
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
				<b>SE:</b> [src.active_record.fields["SE"]]<br><br>"}
				if(wantspod)
					dat += "<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"

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

	if ((href_list["scan"]) && (!isnull(src.scanner)))
		src.scan_mob(src.scanner.occupant)

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
			var/obj/item/weapon/card/id/C = usr.equipped()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(src.check_access(C))
					geneticsrecords.Remove(src.active_record)
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
		if(C)
			var/mob/selected = find_dead_player("[C.fields["ckey"]]")
			var/answer = alert(selected,"Do you want to return to life?","Cloning","Yes","No")
			if(answer == "No")
				selected = null
//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if ((!selected) || (!src.pod1) || (src.pod1.occupant) || (src.pod1.mess) || !config.revival_cloning)
				src.temp = "Unable to initiate cloning cycle." // most helpful error message in THE HISTORY OF THE WORLD
			else if (src.pod1.growclone(selected, C.fields["name"], C.fields["UI"], C.fields["SE"], C.fields["mind"], C.fields["mrace"], C.fields["interface"],C.fields["changeling"],C.fields["original"]))
				src.temp = "Cloning cycle activated."
				geneticsrecords.Remove(C)
				del(C)
				src.menu = 1

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	if ((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna))
		src.temp = "Error: Unable to locate valid genetic data."
		return
	if (subject.brain_op_stage == 4.0)
		src.temp = "Error: No signs of intelligence detected."
		return
//	if (subject.suiciding == 1)
//		src.temp = "Error: Subject's brain is not responding to scanning stimuli."
//		return
//	if ((!subject.ckey) || (!subject.client))
//		src.temp = "Error: Mental interface failure."
//		return
	if (subject.mutations & HUSK)
		src.temp = "Error: Mental interface failure."
		return
	if (!isnull(find_record(subject.ckey)))
		src.temp = "Subject already in database."
		return

	subject.dna.check_integrity()

	var/ckey = subject.ckey
	if(!ckey && subject && subject.mind)
		ckey = subject.mind.key

	var/datum/data/record/R = new /datum/data/record(  )
	R.fields["mrace"] = subject.mutantrace
	R.fields["ckey"] = ckey
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)
	R.fields["UI"] = subject.dna.uni_identity
	R.fields["SE"] = subject.dna.struc_enzymes
	R.fields["changeling"] = subject.changeling
	R.fields["original"] = subject.original_name

	// Preferences stuff
	R.fields["interface"] = subject.UI



	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		var/datum/organ/external/O = subject.organs[pick(subject.organs)]
		imp = new /obj/item/weapon/implant/health(O)
		O.implant += imp
		imp.implanted = subject
		R.fields["imp"] = "\ref[imp]"
	//Update it if needed
	else
		R.fields["imp"] = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[subject.mind]"

	geneticsrecords += R //Save it to the global scan list.
	src.temp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/data/record/R in geneticsrecords)
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


//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/M in world)
		//Dead people only thanks!
		if ((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if ((istype(M, /mob/living/carbon/human)) && (M:brain_op_stage >= 4.0))
			continue

		if (M.ckey == find_key)
			selected = M
			break
	if(!selected) //Search for a ghost if dead body with client isn't found.
		for(var/mob/dead/observer/ghost in world)
			if (ghost.corpse && ghost.corpse.mind.key == find_key)
				selected = ghost
				break
	return selected

//Disk stuff.
/obj/item/weapon/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadisk[diskcolor]"

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	user << "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."

/obj/item/weapon/disk/data/examine()
	set src in oview(5)
	..()
	usr << text("The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")
	return

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if (!src.implanted)
		return "ERROR"
	else
		src.healthstring = "[round(src.implanted:getOxyLoss())] - [round(src.implanted:getFireLoss())] - [round(src.implanted:getToxLoss())] - [round(src.implanted:getBruteLoss())]"
		if (!src.healthstring)
			src.healthstring = "ERROR"
		return src.healthstring

/obj/machinery/clonepod/attack_ai(mob/user as mob)
	return attack_hand(user)
/obj/machinery/clonepod/attack_paw(mob/user as mob)
	return attack_hand(user)
/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if ((isnull(src.occupant)) || (stat & NOPOWER))
		return
	if ((!isnull(src.occupant)) && (src.occupant.stat != 2))
		var/completion = (100 * ((src.occupant.health + 100) / (src.heal_level + 100)))
		user << "Current clone cycle is [round(completion)]% complete."
	return

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(mob/ghost as mob, var/clonename, var/ui, var/se, var/mindref, var/mrace, var/UI, var/datum/changeling/changelingClone, var/original_name)
	if(((!ghost) || (!ghost.client)) || src.mess || src.attempting)
		return 0

	src.attempting = 1 //One at a time!!
	src.locked = 1

	src.eject_wait = 1
	spawn(30)
		src.eject_wait = 0

	src.occupant = new /mob/living/carbon/human(src)

	occupant:UI = UI // set interface preference

	ghost.client.mob = src.occupant

	src.icon_state = "pod_1"
	//Get the clone body ready
	src.occupant.rejuv = 10
	src.occupant.adjustCloneLoss(190) //new damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	src.occupant.adjustBrainLoss(90)
	src.occupant.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	src.occupant.health = (src.occupant.getBruteLoss() + src.occupant.getToxLoss() + src.occupant.getOxyLoss() + src.occupant.getCloneLoss())

	src.occupant << "\blue <b>Clone generation process initiated.</b>"
	src.occupant << "\blue This will take a moment, please hold."

	if(clonename)
		src.occupant.real_name = clonename
	else
		src.occupant.real_name = "clone"  //No null names!!
	src.occupant.original_name = original_name


	var/datum/mind/clonemind = (locate(mindref) in ticker.minds)

	if ((clonemind) && (istype(clonemind))) //Move that mind over!!
		clonemind.transfer_to(src.occupant)
		clonemind.original = src.occupant
	else //welp
		src.occupant.mind = new /datum/mind(  )
		src.occupant.mind.key = src.occupant.key
		src.occupant.mind.current = src.occupant
		src.occupant.mind.original = src.occupant
		src.occupant.mind.transfer_to(src.occupant)
		ticker.minds += src.occupant.mind

	// -- Mode/mind specific stuff goes here

	switch(ticker.mode.name)
		if("revolution")
			if(src.occupant.mind in ticker.mode:revolutionaries)
				ticker.mode:update_all_rev_icons() //So the icon actually appears
			if(src.occupant.mind in ticker.mode:head_revolutionaries)
				ticker.mode:update_all_rev_icons()
		if("nuclear emergency")
			if (src.occupant.mind in ticker.mode:syndicates)
				ticker.mode:update_all_synd_icons()
		if("cult")
			if (src.occupant.mind in ticker.mode:cult)
				ticker.mode:add_cultist(src.occupant.mind)
				ticker.mode:update_all_cult_icons() //So the icon actually appears

	if (changelingClone && occupant.mind in ticker.mode.changelings)
		occupant.changeling = changelingClone
		src.occupant.make_changeling()

	// -- End mode specific stuff

	if(istype(ghost, /mob/dead/observer))
		del(ghost) //Don't leave ghosts everywhere!!

	if(!src.occupant.dna)
		src.occupant.dna = new /datum/dna(  )
	if(ui)
		src.occupant.dna.uni_identity = ui
		updateappearance(src.occupant, ui)
	if(se)
		src.occupant.dna.struc_enzymes = se
		randmutb(src.occupant) //Sometimes the clones come out wrong.
	src.occupant:update_face()
	src.occupant:update_body()
	src.occupant:mutantrace = mrace
	src.occupant:suiciding = 0
	src.attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			src.go_out()
		return

	if((src.occupant) && (src.occupant.loc == src))
		if((src.occupant.stat == 2) || (src.occupant.suiciding))  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Rejected: Deceased.")
			return

		else if(src.occupant.health < src.heal_level)
			src.occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			src.occupant.adjustCloneLoss(-2)

			//Premature clones may have brain damage.
			src.occupant.adjustBrainLoss(-1)

			//So clones don't die of oxyloss in a running pod.
			if (src.occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				src.occupant.reagents.add_reagent("inaprovaline", 60)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			src.occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((src.occupant.health >= src.heal_level) && (!src.eject_wait))
			src.connected_message("Cloning Process Complete.")
			src.locked = 0
			src.go_out()
			return

	else if ((!src.occupant) || (src.occupant.loc != src))
		src.occupant = null
		if (src.locked)
			src.locked = 0
		if (!src.mess)
			icon_state = "pod_0"
		use_power(200)
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!src.check_access(W))
			user << "\red Access Denied."
			return
		if ((!src.locked) || (isnull(src.occupant)))
			return
		if ((src.occupant.health < -20) && (src.occupant.stat != 2))
			user << "\red Access Refused."
			return
		else
			src.locked = 0
			user << "System unlocked."
	else if (istype(W, /obj/item/weapon/card/emag))
		if (isnull(src.occupant))
			return
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		user << "You force an emergency ejection."
		src.locked = 0
		src.go_out()
		return
	else
		..()

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!message)
		return 0

	src.connected.temp = message
	src.connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if (src.locked)
		return

	if (src.mess) //Clean that mess and dump those gibs!
		src.mess = 0
		gibs(src.loc)
		src.icon_state = "pod_0"

		/*
		for(var/obj/O in src)
			O.loc = src.loc
		*/
		return

	if (!(src.occupant))
		return

	/*
	for(var/obj/O in src)
		O.loc = src.loc
	*/

	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.icon_state = "pod_0"
	src.eject_wait = 0 //If it's still set somehow.
	domutcheck(src.occupant) //Waiting until they're out before possible monkeyizing.
	src.occupant = null
	return

/obj/machinery/clonepod/proc/malfunction()
	if(src.occupant)
		src.connected_message("Critical Error!")
		src.mess = 1
		src.icon_state = "pod_g"
		src.occupant.ghostize()
		spawn(5)
			del(src.occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/severity)) malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/*
 *	Diskette Box
 */
/obj/item/weapon/storage/diskbox
	name = "Diskette Box"
	icon_state = "disk_kit"
	item_state = "syringe_kit"

/obj/item/weapon/storage/diskbox/New()
	..()
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

//SOME SCRAPS I GUESS
/* EMP grenade/spell effect
		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()
*/