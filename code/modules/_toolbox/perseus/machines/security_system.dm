/obj/machinery/computer/percsecuritysystem
	name = "PercTech Security System"
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "percsec"
	desc = null
	anchored = 1
	density = 0
	var/timer = 0

	//prison cells
	var/list/prisoncells = list()
	var/prisonerstatus = 0

	//intruder alarm
	var/list/intruderlist = list()
	var/intruders = 0

	//proximity alarm
	var/list/proximitylist = list()
	var/proximityalert = 0
	var/proximity_range = 35

	//item tracking
	var/list/perseus_equipment_list = list()
	var/list/items_unaccountedfor = list()
	var/missing_items = 0
	var/maxmissingitemsshown = 20
	var/add_remove_tracked_item = 0

	//other
	var/recalling = 0
	var/emergency_situation = 0

/obj/machinery/computer/percsecuritysystem/New()
	if(!GLOB.Perseus_Data["Perseus_Security_Systems"] || !istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
		GLOB.Perseus_Data["Perseus_Security_Systems"] = list()
	if(!(src in GLOB.Perseus_Data["Perseus_Security_Systems"]))
		GLOB.Perseus_Data["Perseus_Security_Systems"] += src
	var/image/I = new(src)
	I.loc = src
	I.icon = 'icons/oldschool/perseus.dmi'
	I.icon_state = "percsecimplanted"
	perseus_client_imaged_machines[src] = I
	. = ..()

/obj/machinery/computer/percsecuritysystem/update_icon()

/obj/machinery/computer/percsecuritysystem/proc/preparecells()
	var/area/A = get_area(src)
	for(var/area/AA in A.related)
		for(var/obj/perseuscell/Pcell in AA)
			if(!isturf(Pcell.loc))
				continue
			prisoncells[Pcell.loc] = Pcell.cell_range

/obj/machinery/computer/percsecuritysystem/proc/hostile_check(mob/living/M)
	if(!istype(M) || M.stat == DEAD || istype(M, /mob/living/silicon/ai))
		return 0
	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		if(check_perseus(C))
			return 0
	if(!M.client)
		if(istype(M, /mob/living/simple_animal) && !istype(M, /mob/living/simple_animal/hostile))
			return 0
	return 1

/obj/machinery/computer/percsecuritysystem/proc/in_prison(mob/living/carbon/human/M)
	if(istype(M))
		for(var/turf/T in prisoncells)
			var/turf/MT = get_turf(M)
			if(get_dist(MT,T) <= prisoncells[T])
				return 1
	return 0

/obj/machinery/computer/percsecuritysystem/process()
	. = ..()
	if(!.)
		return
	var/turf/srcturf = get_turf(src)
	var/area/srcarea = get_area(srcturf)
	if(!istype(srcarea) || !istype(srcturf))
		return
	for(var/mob/living/mob in world)
		if(in_prison(mob) || !hostile_check(mob))
			continue
		var/turf/T = get_turf(mob)
		var/area/A = get_area(T)
		if(!istype(T) || !istype(A))
			continue
		if(T.z == srcturf.z)
			if(A in srcarea.related)
				if(mob.restrained())
					continue
				if(!(mob in intruderlist))
					intruderlist += mob
			else if(get_dist(srcturf, T) <= proximity_range)
				if(!mob.ckey)
					continue
				if(!(mob in proximitylist))
					proximitylist += mob
	for(var/M in intruderlist)
		if(!istype(M,/mob/living))
			intruderlist -= M
			continue
		var/mob/living/mob = M
		if(in_prison(mob) || !hostile_check(mob) || mob.restrained())
			intruderlist -= mob
			continue
		var/area/A = get_area(mob)
		if(!A || !(A in srcarea.related))
			intruderlist -= mob
			continue
	for(var/M in proximitylist)
		if(!istype(M,/mob/living))
			intruderlist -= M
			continue
		var/mob/living/mob = M
		if(!hostile_check(mob))
			proximitylist -= mob
			continue
		var/turf/T = get_turf(mob)
		var/area/A = get_area(T)
		if(!istype(T) || !istype(A))
			continue
		if(T.z != srcturf.z)
			proximitylist -= mob
			continue
		else if(get_dist(srcturf, T) > proximity_range)
			proximitylist -= mob
			continue
		if(A in srcarea.related)
			proximitylist -= mob
			continue
	if(!proximitylist.len && proximityalert)
		proximityalert = 0
		perseusAlert("Alert Systems","Ship proximity alert cleared.",3)
	if(proximitylist.len && !proximityalert)
		proximityalert = 1
		perseusAlert("Alert Systems","Warning: Ship Proximity Alert!",1)
	if(intruders && !intruderlist.len)
		disable_intruder_alert()
	if(!intruders && intruderlist.len)
		enable_intruder_alert()
	var/list/missingitems = list()
	var/list/existingpercs = list()
	for(var/mob/living/carbon/human/perchuman in world)
		if(!check_perseus(perchuman))
			continue
		existingpercs += perchuman
	for(var/atom/movable/AM in perseus_equipment_list)
		var/area/AMarea = get_area(AM)
		if(!AMarea)
			continue
		if(AMarea.type == srcarea.type)
			continue
		var/atom/theloc = AM
		while(theloc)
			if(ismob(theloc))
				break
			if(!theloc)
				break
			theloc = theloc.loc
		if(theloc && theloc in existingpercs)
			continue
		if(istype(AM,/obj/item/ammo_casing))
			var/obj/item/ammo_casing/casing = AM
			if(!casing.BB)
				perseus_equipment_list -= AM
				continue
		else if(istype(AM,/obj/item/ammo_box/magazine))
			var/obj/item/ammo_box/magazine/mag = AM
			if(!mag.stored_ammo.len)
				perseus_equipment_list -= AM
				continue
		else if(istype(AM,/obj/item/projectile))
			perseus_equipment_list -= AM
			continue
		missingitems += AM
	var/list/itemsinmissingitems = list()
	for(var/atom/movable/AM in missingitems)
		if(AM.loc in missingitems)
			continue
		itemsinmissingitems += AM
	missingitems = itemsinmissingitems
	var/list/difference = list()
	if(items_unaccountedfor.len)
		difference = missingitems - items_unaccountedfor
	items_unaccountedfor = missingitems
	if((items_unaccountedfor.len && !missing_items)||difference.len)
		missing_items = 1
		var/specific_item_text = ", [items_unaccountedfor.len] items missing."
		if(difference.len == 1)
			for(var/atom/movable/AM in difference)
				specific_item_text = ", the [capitalize(AM.name)] now missing."
				break
		else if(items_unaccountedfor.len == 1)
			for(var/atom/movable/AM in items_unaccountedfor)
				specific_item_text = ", the [capitalize(AM.name)] now missing."
				break
		if(difference.len > 0)
			perseusAlert("Alert Systems","More Perseus property has become unaccounted for[specific_item_text]",1)
		else
			perseusAlert("Alert Systems","There is Perseus property unaccounted for[specific_item_text]",1)
	else if(!items_unaccountedfor.len && missing_items)
		missing_items = 0
		perseusAlert("Alert Systems","All Perseus property is now accounted for.",3)

/obj/machinery/computer/percsecuritysystem/proc/enable_intruder_alert()
	intruders = 1
	var/area/area = get_area(src)
	area.intruderalert(1)
	if(perseusshiprecalling)
		perseusshiprecalling = 0
	perseusAlert("Alert Systems","Intruder detected on the Myncenae III!",2)

/obj/machinery/computer/percsecuritysystem/proc/disable_intruder_alert()
	intruders = 0
	var/area/area = get_area(src)
	area.intruderalert(0)
	perseusAlert("Alert Systems","Intuder alarm cleared.",0)

/obj/machinery/computer/percsecuritysystem/attack_hand(mob/living/user as mob)
	if(!istype(user, /mob/living))
		return
	if(!user.Adjacent(src))
		return
	if(!istype(user,/mob/living/carbon/human))
		to_chat(user, "\red You don't have the dexterity to do this.")
		return
	if(!check_perseus(user))
		to_chat(user, "All you see are strange green numbers falling down the screen from top to bottom like rain.")
		return
	var/intruderstatus = null
	if(intruders)
		intruderstatus = "<font color='red'><B>Active</B></font> <a href='?src=\ref[src];resetalarm=1'>Reset</a>"
	if(!intruders)
		intruderstatus = "<font color='green'><B>Inactive</B></font>"
	var/proximitystatus
	if(proximityalert)
		proximitystatus = "<font color='red'><B>Active</B></font> <a href='?src=\ref[src];resetproxalarm=1'>Reset</a>"
	if(!proximityalert)
		proximitystatus = "<font color='green'><B>Inactive</B></font>"
	var/dat = "<B>Ship Status</B><BR>"
	dat += "Intruder alarm status: "
	dat += intruderstatus
	dat += "<BR>"
	dat += "Proximity alarm status: "
	dat += proximitystatus
	dat += "<BR>"
	var/pdoorstatus = "<B>Closed</B>"
	for(var/obj/machinery/door/poddoor/pdoor in world)
		if(pdoor.id == "prisonship")
			if(!pdoor.density)
				pdoorstatus = "<font color='yellow'><B>Open</B></font>"
	dat += "Mycenae blast door status: [pdoorstatus]<BR>"
	var/list/percfloors = list()
	var/totalpressure = 0
	var/shippressure = 0
	var/area/shiparea = get_area(src)
	if(shiparea)
		for(var/area/AA in shiparea.related)
			for(var/turf/open/floor/percfloor in AA)
				var/hasenginepart = 0
				for(var/obj/structure/shuttle/engine/shuttlepart in percfloor)
					hasenginepart = 1
					break
				if(hasenginepart)
					continue
				if(percfloor.air)
					var/thepressure = percfloor.air.return_pressure()
					if(isnum(thepressure))
						percfloors += thepressure
						totalpressure += thepressure
		if(totalpressure > 0)
			shippressure = round(totalpressure/length(percfloors),0.01)
		var/pressurecolor = "green"
		if(shippressure > 91 && shippressure < 111)
			pressurecolor = "green"
		if(((shippressure <= 91 && shippressure >= 81)|(shippressure >= 111 && shippressure <= 121)))
			pressurecolor = "yellow"
		if(((shippressure < 81)|(shippressure > 121)))
			pressurecolor = "red"
		dat += "Average ship  air pressure: <font color='[pressurecolor]'><B>[shippressure] kPa.</B></font><BR>"
	var/obj/docking_port/mobile/perseusshuttle = SSshuttle.getShuttle("perseus_transfer")
	var/shuttlestatus = perseusshuttle.getStatusText()
	if(!shuttlestatus)
		shuttlestatus = "Shuttle Destroyed"
	dat += "Prison shuttle position: <B>[shuttlestatus]</b><BR>"
	var/list/commander_list = list()
	var/list/enforcer_list = list()
	for(var/mob/living/carbon/human/Human in world)
		var/datum/extra_role/perseus/perseusdatum = check_perseus(Human)
		if(!perseusdatum)
			continue
		if(perseusdatum.iscommander)
			commander_list += Human
		else
			enforcer_list += Human
	dat += "<BR><B>Perseus Personnel Status</B><BR>"
	var/detectcommanders = 0
	dat += "Commanders:<BR>"
	for(var/mob/living/carbon/human/commander in commander_list)
		detectcommanders = 1
		var/livestatus = null
		if(commander.stat == DEAD)
			livestatus = "<font color='red'>Dead</font>"
		else
			livestatus = "<font color='greem'>Living</font>"
		var/damage_report
		var/dam1 = round(commander.getOxyLoss(),1)
		var/dam2 = round(commander.getToxLoss(),1)
		var/dam3 = round(commander.getFireLoss(),1)
		var/dam4 = round(commander.getBruteLoss(),1)
		damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"
		var/area/thearea = get_area(commander)
		dat += "     [commander.name] - [livestatus] - [damage_report] - [thearea]<BR>"
	if(!detectcommanders)
		dat += "None Available<BR>"
	var/detectenforcers = 0
	dat += "Enforcers:<BR>"
	for(var/mob/living/carbon/human/enforcer in enforcer_list)
		detectenforcers++
		var/livestatus = null
		if(enforcer.stat == DEAD)
			livestatus = "<font color='red'>Dead</font>"
		else
			livestatus = "<font color='greem'>Living</font>"
		var/damage_report
		var/dam1 = round(enforcer.getOxyLoss(),1)
		var/dam2 = round(enforcer.getToxLoss(),1)
		var/dam3 = round(enforcer.getFireLoss(),1)
		var/dam4 = round(enforcer.getBruteLoss(),1)
		damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"
		var/area/thearea = get_area(enforcer)
		dat += "[enforcer.name] - [livestatus] - [damage_report] - [thearea]<BR>"
	if(!detectenforcers)
		dat += "None Available<BR>"
	dat += "<BR>"

	dat += "<B>Prisoner Status:</B> "
	var/cellcounttext = 1
	for(var/turf/T in prisoncells)
		dat += "<a href='?src=\ref[src];prisoners=\ref[T]'>Cell [cellcounttext]</a>"
		cellcounttext++
	dat+= "<BR>"
	if(prisonerstatus)
		var/cellnumber = null
		var/currentcell = 0
		for(var/turf/T in prisoncells)
			currentcell++
			if(currentcell == prisonerstatus)
				cellnumber = T
				break
		dat += "Cell [prisonerstatus] prisoner status:<BR>"
		var/celloccupied = 0
		for(var/mob/living/Mob in range(prisoncells[cellnumber],cellnumber))
			if(check_perseus(Mob))
				continue
			var/livestatus = null
			var/damage_report
			if(Mob.stat == DEAD)
				livestatus = "<font color='red'>Dead</font>"
			else
				livestatus = "<font color='greem'>Living</font>"
			celloccupied = 1
			if(istype(Mob,/mob/living/carbon))
				var/mob/living/carbon/P = Mob
				var/dam1 = round(P.getOxyLoss(),1)
				var/dam2 = round(P.getToxLoss(),1)
				var/dam3 = round(P.getFireLoss(),1)
				var/dam4 = round(P.getBruteLoss(),1)
				damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"
			if(istype(Mob,/mob/living/simple_animal))
				var/mob/living/simple_animal/sanimal = Mob
				var/healthmathed = sanimal.health/sanimal.maxHealth*100
				var/roundedhealth = round(healthmathed,1)
				if(roundedhealth < 0)
					roundedhealth = 0
				if(roundedhealth> 100)
					roundedhealth = 100
				var/thecolor
				if(roundedhealth >= 80 )
					thecolor = "green"
				if(roundedhealth < 80 )
					thecolor = "yellow"
				if(roundedhealth < 50 )
					thecolor = "orange"
				if(roundedhealth < 30 )
					thecolor = "red"
				damage_report = "(<font color='[thecolor]'>[roundedhealth]%</font>)"
			if(istype(Mob,/mob/living/silicon/robot))
				var/mob/living/silicon/robot/robot = Mob
				var/newhealth = robot.health+100
				var/newmaxHhealth = robot.maxHealth+100
				var/healthmathed = newhealth/newmaxHhealth*100
				var/roundedhealth = round(healthmathed,1)
				if(roundedhealth < 0)
					roundedhealth = 0
				if(roundedhealth > 100)
					roundedhealth = 100
				var/thecolor
				if(roundedhealth >= 80 )
					thecolor = "green"
				if(roundedhealth < 80 )
					thecolor = "yellow"
				if(roundedhealth < 50 )
					thecolor = "orange"
				if(roundedhealth < 30 )
					thecolor = "red"
				damage_report = "(<font color='[thecolor]'>[roundedhealth]%</font>)"
			dat += "[Mob.name] - [livestatus] - [damage_report]<BR>"
		if(!celloccupied)
			dat += "Unoccupied<BR>"
		dat += "<a href='?src=\ref[src];prisoners=close'>Close</a>"
		var/cellflasher = null
		for(var/obj/machinery/flasher/flasher in range(1,cellnumber))
			cellflasher = flasher
		if(cellflasher)
			dat += "<a href='?src=\ref[src];flash=\ref[cellflasher]'>Flash</a>"
		dat += "<a href='?src=\ref[src];lockdowncell=\ref[cellnumber]'>Toggle Lockdown</a>"
		dat += "<BR>"
	dat += "<BR>"
	dat += "<B>Perseus ship: Mycenae III recall to HQ subroutine.</B><BR>"
	dat += "This recalls the Mycenae III to Perseus HQ. Activating this will take approximately<BR>20 minutes and requires all Perseus personnel to agree.<BR>"
	if(!perseusshiprecalling && !recalling)
		dat += "<a href='?src=\ref[src];mycenaerecall=1'>Activate</a>"
	else
		dat += "<B>ACTIVE: </B>"
		var/recalltimeleftseconds = round((perseusrecalltime-world.time)/10, 1)
		var/recalltimeleft = round(recalltimeleftseconds/60, 1)
		dat += "Time left: [recalltimeleft] minute"
		if(recalltimeleft > 1)
			dat += "s "
		else
			dat += " "
		dat += "<a href='?src=\ref[src];mycenaerecallcancel=1'>Cancel</a>"
	if(items_unaccountedfor.len)
		dat += "<BR><BR>"
		var/theS = ""
		var/theARE = "is"
		if(items_unaccountedfor.len > 1)
			theS = "s"
			theARE = "are"
		dat += "<B>There [theARE] <font color='red'>[items_unaccountedfor.len]</font> Perseus item[theS] unaccounted for:</B><BR>"
		var/maxcount = maxmissingitemsshown
		for(var/atom/movable/AM in items_unaccountedfor)
			dat += "&nbsp;&nbsp;&nbsp;&nbsp;<font color='red'>[capitalize(AM.name)]</font> <a href='?src=\ref[src];removetrackeditem=\ref[AM]'>Ignore</a><BR>"
			maxcount--
			if(maxcount <= 0)
				break
		if(items_unaccountedfor.len > maxmissingitemsshown)
			dat += "showing [maxmissingitemsshown] of [items_unaccountedfor.len] entries."
	dat += "<BR><BR>Add/Remove tracked item. "
	if(add_remove_tracked_item)
		dat += "<a href='?src=\ref[src];toggletrackeditem=1'>Enabled</a>"
	else
		dat += "<a href='?src=\ref[src];toggletrackeditem=1'>Disabled</a>"
	var/datum/browser/popup = new(user, "securitymenu", "PercTech Security System", 600, 700)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/percsecuritysystem/Topic(href, href_list)
	if(..())
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	if(!check_perseus(H))
		return
	if(href_list["resetalarm"])
		var/alarmreset = alert(usr, "Reset intruder alarm?","Intruder alarm reset.","Reset","Cancel")
		if(alarmreset == "Cancel")
			return
		if(alarmreset == "Reset")
			disable_intruder_alert()
			attack_hand(usr)
			return
	if(href_list["resetproxalarm"])
		var/alarmreset = alert(usr, "Reset Proximity alarm?","Proximity alarm reset.","Reset","Cancel")
		if(alarmreset != "Reset")
			return
		proximityalert = list()
		proximityalert = 0
		attack_hand(usr)
		return
	if(href_list["prisoners"])
		if(href_list["prisoners"] == "close")
			prisonerstatus = 0
		var/turf/T = locate(href_list["prisoners"])
		if(T in prisoncells)
			var/currentcell = 1
			for(var/turf/cell in prisoncells)
				if(cell == T)
					prisonerstatus = currentcell
					break
				currentcell++
		attack_hand(usr)
		return
	if(href_list["flash"])
		var/obj/machinery/flasher/flasher = locate(href_list["flash"])
		flasher.flash()
		attack_hand(usr)
		return
	if(href_list["mycenaerecall"])
		if(recalling)
			return
		recalling = 1
		perseusAlert("Recall Systems","Mycenae III recall vote has been activated by [usr]. This will require unanimous agreement from all perseus pesonnel.",0)
		perseusshiprecall()
		spawn(5)
			attack_hand(usr)
		return
	if(href_list["mycenaerecallcancel"])
		recalling = 0
		var/recallcancel = alert(usr, "Confirm Cancel?","Mycenae recall cancelation.","Confirm","No")
		if(recallcancel == "Confirm")
			perseusshiprecalling = 0
			attack_hand(usr)
			return
		else
			attack_hand(usr)
			return
	if(href_list["lockdowncell"])
		var/turf/thecell = locate(href_list["lockdowncell"])
		var/originaldensity = 2
		for(var/obj/machinery/door/poddoor/P in range(2,thecell))
			if(P.id == "prisonshipcell")
				var/turf/theturf = get_turf(P)
				var/newlayer = 2.2
				if(theturf)
					newlayer = theturf.layer+0.2
				if(originaldensity == 2)
					originaldensity = P.density
				P.layer = newlayer
				if(originaldensity)
					spawn(0)
						P.open()
				else
					spawn(0)
						P.close()
		attack_hand(usr)
	//if(href_list["emergencysituation"])
		/*var/turf/cdoorturf = locate(108,103,3)
		var/turf/adoorturf = locate(110,102,3)
		var/obj/machinery/door/airlock/commanderairlock = null
		var/obj/machinery/door/airlock/armoryairlock = null
		for(var/obj/machinery/door/airlock/A in cdoorturf)
			commanderairlock = A
			break
		for(var/obj/machinery/door/airlock/A in adoorturf)
			armoryairlock = A
			break
		if(!emergency_situation)
			emergency_situation = 1
			var/emergencyconfirm = alert(usr, "Are you sure you want to declare an emergency situation.","Declare Emergency Situation.","Confirm","No")
			if(emergencyconfirm != "Confirm")
				return
			perseusAlert("Alert Systems","An emergency situation has been declared! Access to armory granted. A request for backup has been sent.",2)
			if(commanderairlock)
				commanderairlock.emergency = 1
				commanderairlock.update_icon()
			if(armoryairlock)
				armoryairlock.emergency = 1
				armoryairlock.update_icon()
			var/list/backupkeys = list()
			for(var/mob/M in world)
				if(!M.client)
					continue
				if(!perseusList[M.ckey])
					continue
				if(istype(M,/mob/living))
					var/mob/living/L = M
					if(check_perseus(L))
						continue
				to_chat(M, "<i><span class='game say'>Perctech Hivemind, <span class='name'>Back Up Requested:</span> <span class='message'>The Perseus Enforcers have requested backup. You may choose to ignore this message or provide the back up as requested by respawning and signing up as Perseus. Be aware that if you choose to ignore this message; this is an OOC message and as a member of the Perseus Whitelist you are trusted not to use this information in the current round.</span></span></i>")
				M << sound('sound/items/timer.ogg',0,0,0,100)
				backupkeys += M.ckey
			var/thekeys = ""
			if(!backupkeys.len)
				thekeys = "None "
			else
				for(var/keys in backupkeys)
					thekeys += "[keys] "
			message_admins("PERSEUS:[usr.name]([usr.key]) has declared an emergency situation. Back up request heard by ckeys( [thekeys])")
			log_game("PERSEUS:[usr.name]([usr.key]) has declared an emergency situation. Back up request heard by ckeys( [thekeys])")
		else
			emergency_situation = 0
			perseusAlert("Alert Systems","Emergency situation has been canceled.",1)
			if(commanderairlock)
				commanderairlock.emergency = 0
				commanderairlock.update_icon()
			if(armoryairlock)
				armoryairlock.emergency = 0
				armoryairlock.update_icon()
		attack_hand(usr)*/
	if(href_list["removetrackeditem"])
		var/atom/movable/AM = locate(href_list["removetrackeditem"])
		if(istype(AM) && AM in perseus_equipment_list)
			var/choice = alert(usr,"Are you sure you want to stop tracking the [AM.name]?","[src.name]","Confirm","Cancel")
			if(choice == "Confirm" && istype(AM) && AM in perseus_equipment_list)
				perseus_equipment_list -= AM
				to_chat(usr, "[src.name] no longer tracking item: [capitalize(AM.name)]")
				playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
		attack_hand(usr)
	if(href_list["toggletrackeditem"])
		add_remove_tracked_item = !add_remove_tracked_item
		if(add_remove_tracked_item)
			to_chat(usr, "Add/Remove tracked item mode now enabled. Touch this console with an item to add or remove it from being tracked by the system.")
		else
			to_chat(usr, "Add/Remove tracked item mode now disabled.")
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		attack_hand(usr)

/obj/machinery/computer/percsecuritysystem/proc/gather_equipment(var/entity)
	if(entity)
		var/list/thelist = entity
		if(istype(thelist))
			for(var/T in thelist)
				if(!T)
					continue
				if(!(T in perseus_equipment_list))
					perseus_equipment_list += T
		else if(istype(entity, /atom/movable) && !(entity in perseus_equipment_list))
			perseus_equipment_list += entity
	else
		var/area/A = get_area(src)
		for(var/obj/item/I in world)
			var/area/IA = get_area(I)
			if(!istype(IA))
				continue
			if(IA.type == A.type && !(I in perseus_equipment_list))
				perseus_equipment_list += I

var/global/perseusshiprecalling = 0
var/global/perseusrecalltime = 0
proc/perseusshiprecall()
	if(perseusshiprecalling)
		return
	perseusshiprecalling = 1
	var/list/eligableperseus = list()
	var/list/confirmedperseus = list()
	var/list/afkperseus = list()
	for(var/mob/living/carbon/human/H in world)
		if(check_perseus(H) && H.client && H.stat != DEAD)
			var/turf/theturf = get_turf(H)
			if(theturf.z == 2)
				continue
			if(H.client.inactivity >= 4800)
				to_chat(H, "<B>You were AFK for a Mycenae recall vote.</B>")
				afkperseus += H
				continue
			eligableperseus += H
	if(afkperseus.len)
		var/thetext = ""
		var/thenumber = 1
		for(var/mob/M in afkperseus)
			afkperseus[M] = thenumber
			thenumber++
			if(afkperseus[M] == 1)
				thetext += "[M.name]"
			else if(afkperseus.len > 1 && afkperseus[M] >= afkperseus.len)
				thetext += " and [M.name]"
			else if(afkperseus.len > 1 && afkperseus.len < afkperseus.len)
				thetext += ", [M.name]"
		if(thetext)
			perseusAlert("Recall Systems","[thetext] will not be counted in the recall vote.",0)
	if(eligableperseus.len)
		for(var/mob/living/carbon/human/H in eligableperseus)
			spawn(0)
				H << sound('sound/items/timer.ogg',0,0,0,100)
				var/confirmed = alert(H, "Do you wish to recall the Mycenae to HQ?","Mycenae III Recall Activated.","Yes","No")
				if(H)
					if(perseusshiprecalling)
						if(confirmed == "Yes")
							confirmedperseus += H
						else
							perseusshiprecalling = 0
					else
						to_chat(H, "<B>The recall vote has already ended.</B>")
	var/waitticker = 20
	while(waitticker && confirmedperseus.len < eligableperseus.len)
		waitticker--
		if(!perseusshiprecalling)
			break
		sleep(10)
	if(waitticker <= 0 && perseusshiprecalling)
		var/list/percsdidntvote = list()
		var/thetext = ""
		var/thenumber = 1
		for(var/mob/M in eligableperseus)
			if(M in confirmedperseus)
				continue
			percsdidntvote[M] = thenumber
			thenumber++
			if(percsdidntvote[M] == 1)
				thetext += "[M.name]"
			else if(percsdidntvote.len > 1 && percsdidntvote[M] >= percsdidntvote.len)
				thetext += " and [M.name]"
			else if(percsdidntvote.len > 1 && percsdidntvote.len < percsdidntvote.len)
				thetext += ", [M.name]"
		if(thetext)
			perseusAlert("Recall Systems","[thetext] did not vote.",1)
	if(perseusshiprecalling && confirmedperseus.len >= eligableperseus.len)
		perseusAlert("Recall Systems","Mycenae III recall vote passed. The Mycenae III will return to HQ in 20 minutes.",0)
	else
		perseusAlert("Recall Systems","Mycenae III recall vote failed.",0)
		if(GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
			for(var/obj/machinery/computer/percsecuritysystem/C in GLOB.Perseus_Data["Perseus_Security_Systems"])
				C.recalling = 0
		perseusshiprecalling = 0
		return
	perseusrecalltime = world.time + 12000
	var/recalled = 0
	var/fiveminutewarn = 0
	var/oneminutewarn = 0
	while(perseusshiprecalling)
		if(world.time > perseusrecalltime)
			recallmycenae()
			recalled = 1
			perseusshiprecalling = 0
		if(perseusrecalltime-world.time <= 3000 && !fiveminutewarn)
			perseusAlert("Recall Systems","5 minutes remaining untill the Mycenae recalls to HQ.",1)
			fiveminutewarn = 1
		if(perseusrecalltime-world.time <= 600 && !oneminutewarn)
			perseusAlert("Recall Systems","1 minute remaining untill the Mycenae recalls to HQ.",1)
			oneminutewarn = 1
		sleep(10)
	if(!perseusshiprecalling && recalled == 0)
		perseusAlert("Recall Systems","Mycenae III recall has been canceled.",1)
		if(GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
			for(var/obj/machinery/computer/percsecuritysystem/C in GLOB.Perseus_Data["Perseus_Security_Systems"])
				C.recalling = 0
		return

/proc/recallmycenae()
	if(Remove_Mycenae())
		perseusAlert("Recall Systems","If you were not on the Mycenae at this time the ship has left with out you. We are very sorry but you are on your own.",1)


/obj/machinery/computer/percsecuritysystem/Destroy()
	var/area/area = get_area(src)
	area.intruderalert(0)
	if(perseus_client_imaged_machines[src])
		qdel(perseus_client_imaged_machines[src])
		perseus_client_imaged_machines[src] = null
		perseus_client_imaged_machines.Remove(src)
	perseusAlert("Alert Systems","[src] destroyed. System messages will no longer be received.",1)
	if(GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
		GLOB.Perseus_Data["Perseus_Security_Systems"] -= src
	..()

/obj/machinery/computer/percsecuritysystem/attackby(obj/item/I, mob/living/user)
	if(!I||!user)
		return
	if(add_remove_tracked_item)
		if(I in perseus_equipment_list)
			perseus_equipment_list -= I
			to_chat(user, "[capitalize(I.name)] will no longer be tracked by the [src.name].")
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
		else
			perseus_equipment_list += I
			to_chat(user, "[capitalize(I.name)] will now be tracked by the [src.name] as property of Perseus.")
			playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)

/obj/machinery/computer/percsecuritysystem/examine()
	..()
	if(!istype(usr,/mob/living))
		to_chat(usr, "All you see on the screen are strange green numbers falling down from top to bottom like rain.")
	else
		var/mob/living/L = usr
		if(!check_perseus(L))
			to_chat(L, "All you see on the screen are strange green numbers falling down from top to bottom like rain.")
		else
			var/thedesc = "The primary security system for The Mycenae."
			to_chat(usr, thedesc)

/obj/machinery/computer/percsecuritysystem/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			return
		if(3.0)
			return

/obj/machinery/computer/percsecuritysystem/bullet_act(var/obj/item/projectile/Proj)
	return 0

/obj/machinery/computer/percsecuritysystem/emp_act(severity)
	return

/obj/machinery/computer/percsecuritysystem/attack_alien(mob/user)
	return

/obj/perseuscell
	anchored = 1
	density = 0
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/cell_range = 2
	Destroy(force)
		if(force)
			..()
			. = QDEL_HINT_HARDDEL_NOW
		else
			return QDEL_HINT_LETMELIVE
	take_damage()
		return
	singularity_pull()
		return
	singularity_act()
		return 0

/area/proc/intruderalert(intruders = 0)
	if(intruders && !fire && !eject && !party)
		icon_state = "blueold"
		return
	if(!intruders)
		icon_state = null
		return