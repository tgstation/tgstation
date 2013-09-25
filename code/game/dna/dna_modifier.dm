#define DNA_BLOCK_SIZE 3

/////////////////////////// DNA MACHINES
/obj/machinery/dna_scannernew
	name = "\improper DNA modifier"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
	var/locked = 0
	var/mob/living/carbon/occupant = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

/obj/machinery/dna_scannernew/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonescanner(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/cable_coil(src)
	component_parts += new /obj/item/weapon/cable_coil(src)
	RefreshParts()

/obj/machinery/dna_scannernew/allow_drop()
	return 0

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject DNA Scanner"

	if (usr.stat != 0)
		return

	eject_occupant()

	add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/proc/eject_occupant()
	src.go_out()
	for(var/obj/O in src)
		if((!istype(O,/obj/item/weapon/circuitboard/clonescanner)) && (!istype(O,/obj/item/weapon/stock_parts)) && (!istype(O,/obj/item/weapon/cable_coil)))
			O.loc = get_turf(src)//Ejects items that manage to get in there (exluding the components)
	if(!occupant)
		for(var/mob/M in src)//Failsafe so you can get mobs out
			M.loc = get_turf(src)

/obj/machinery/dna_scannernew/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter DNA Scanner"

	if (usr.stat != 0)
		return
	if (!ishuman(usr) && !ismonkey(usr)) //Make sure they're a mob that has dna
		usr << "\blue Try as you might, you can not climb up into the scanner."
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.stop_pulling()
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "scanner_1"
	/*
	for(var/obj/O in src)    // THIS IS P. STUPID -- LOVE, DOOHL
		//O = null
		del(O)
		//Foreach goto(124)
	*/
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/attackby(var/obj/item/weapon/item as obj, var/mob/user as mob)
	if(istype(item, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "\red A beaker is already loaded into the machine."
			return

		beaker = item
		user.drop_item()
		item.loc = src
		user.visible_message("[user] adds \a [item] to \the [src]!", "You add \a [item] to \the [src]!")
		return
	else if (!istype(item, /obj/item/weapon/grab))
		return
	var/obj/item/weapon/grab/G = item
	if (!ismob(G.affecting))
		return
	if (src.occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "scanner_1"

	src.add_fingerprint(user)

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

		if(!M.client && M.mind)
			for(var/mob/dead/observer/ghost in player_list)
				if(ghost.mind == M.mind)
					ghost << "<b><font color = #330033><font size = 3>Your corpse has been placed into a cloning scanner. Return to your body if you want to be resurrected/cloned!</b> (Verbs -> Ghost -> Re-enter corpse)</font color>"
					break
	del(G)
	return

/obj/machinery/dna_scannernew/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
/*
//	it's like this was -just- here to break constructed dna scanners -Pete
//	if that's not the case, slap my shit and uncomment this.
//	for(var/obj/O in src)
//		O.loc = src.loc
*/
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "scanner_0"
	return

/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				del(src)
				return
		else
	return


/obj/machinery/dna_scannernew/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/computer/scan_consolenew
	name = "DNA Modifier Access Console"
	desc = "Scand DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = 1
	var/selected_ui_block = 1.0
	var/selected_ui_subblock = 1.0
	var/selected_se_block = 1.0
	var/selected_se_subblock = 1.0
	var/selected_ui_target = 1
	var/selected_ui_target_hex = 1
	var/radiation_duration = 2.0
	var/radiation_intensity = 1.0
	var/list/buffers = list(
		list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
		list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
		list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0)
	)
	var/irradiating = 0
	var/injector_ready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/weapon/disk/data/disk = null
	var/selected_menu_key = null
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 400

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
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
	if (istype(I, /obj/item/weapon/disk/data)) //INSERT SOME diskS
		if (!src.disk)
			user.drop_item()
			I.loc = src
			src.disk = I
			user << "You insert [I]."
			nanomanager.update_uis(src) // update all UIs attached to src()
			return
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/scan_consolenew/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/computer/scan_consolenew/blob_act()

	if(prob(75))
		del(src)

/obj/machinery/computer/scan_consolenew/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

/obj/machinery/computer/scan_consolenew/New()
	..()
	spawn(5)
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				break
		spawn(250)
			src.injector_ready = 1
		return
	return

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(var/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= length(buffer)/3, i++)
		arr += "[i]:[copytext(buffer,i*3-2,i*3+1)]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/setInjectorBlock(var/obj/item/weapon/dnainjector/I, var/blk, var/buffer)
	var/pos = findtext(blk,":")
	if(!pos) return 0
	var/id = text2num(copytext(blk,1,pos))
	if(!id) return 0
	I.block = id
	I.dna = copytext(buffer,id*3-2,id*3+1)
	return 1

/obj/machinery/computer/scan_consolenew/attackby(obj/item/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/disk/data)) && (!src.disk))
		user.drop_item()
		W.loc = src
		src.disk = W
		user << "You insert [W]."
		nanomanager.update_uis(src) // update all UIs attached to src()
/*
/obj/machinery/computer/scan_consolenew/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	if (!( src.status )) //remove this
		return
	return
*/
/obj/machinery/computer/scan_consolenew/attack_paw(user as mob)
	ui_interact(user)

/obj/machinery/computer/scan_consolenew/attack_ai(user as mob)
	src.add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/computer/scan_consolenew/attack_hand(user as mob)
	if(!..())
		ui_interact(user)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)

	if(user == connected.occupant || user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["selectedMenuKey"] = selected_menu_key
	data["locked"] = src.connected.locked
	data["hasOccupant"] = connected.occupant ? 1 : 0

	data["isInjectorReady"] = injector_ready

	data["hasDisk"] = disk ? 1 : 0

	var/diskData[0]
	if (!disk)
		diskData["data"] = null
		diskData["owner"] = null
		diskData["label"] = null
		diskData["type"] = null
		diskData["ue"] = null
	else
		diskData["data"] = disk.data
		diskData["owner"] = disk.owner
		diskData["label"] = disk.name
		diskData["type"] = disk.data_type
		diskData["ue"] = disk.ue
	data["disk"] = diskData

	data["buffers"] = buffers

	data["radiationIntensity"] = radiation_intensity
	data["radiationDuration"] = radiation_duration
	data["irradiating"] = irradiating

	data["dnaBlockSize"] = DNA_BLOCK_SIZE
	data["selectedUIBlock"] = selected_ui_block
	data["selectedUISubBlock"] = selected_ui_subblock
	data["selectedSEBlock"] = selected_se_block
	data["selectedSESubBlock"] = selected_se_subblock
	data["selectedUITarget"] = selected_ui_target
	data["selectedUITargetHex"] = selected_ui_target_hex

	var/occupantData[0]
	if (!src.connected.occupant || !src.connected.occupant.dna)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["isViableSubject"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["uniqueEnzymes"] = null
		occupantData["uniqueIdentity"] = null
		occupantData["structuralEnzymes"] = null
		occupantData["radiationLevel"] = null
	else
		occupantData["name"] = connected.occupant.name
		occupantData["stat"] = connected.occupant.stat
		occupantData["isViableSubject"] = 1
		if (NOCLONE in connected.occupant.mutations || !src.connected.occupant.dna)
			occupantData["isViableSubject"] = 0
		occupantData["health"] = connected.occupant.health
		occupantData["maxHealth"] = connected.occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["uniqueEnzymes"] = connected.occupant.dna.unique_enzymes
		occupantData["uniqueIdentity"] = connected.occupant.dna.uni_identity
		occupantData["structuralEnzymes"] = connected.occupant.dna.struc_enzymes
		occupantData["radiationLevel"] = connected.occupant.radiation
	data["occupant"] = occupantData;

	data["isBeakerLoaded"] = connected.beaker ? 1 : 0
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(connected.beaker)
		data["beakerLabel"] = connected.beaker.label_text ? connected.beaker.label_text : null
		if (connected.beaker.reagents && connected.beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in connected.beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	if (!ui) // no ui has been passed, so we'll search for one
	{
		ui = nanomanager.get_open_ui(user, src, ui_key)
	}
	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "dna_modifier.tmpl", "DNA Modifier Console", 660, 700)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return 0 // don't update uis
	if(!istype(usr.loc, /turf))
		return 0 // don't update uis
	if(!src || !src.connected)
		return 0 // don't update uis
	if(irradiating) // Make sure that it isn't already irradiating someone...
		return 0 // don't update uis

	add_fingerprint(usr)

	if (href_list["selectMenuKey"])
		selected_menu_key = href_list["selectMenuKey"]
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["toggleLock"])
		if ((src.connected && src.connected.occupant))
			src.connected.locked = !( src.connected.locked )
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["pulseRadiation"])
		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1//lock it
		nanomanager.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0

		if (!src.connected.occupant)
			return 1 // return 1 forces an update to all Nano uis attached to src

		if (prob(95))
			if(prob(75))
				randmutb(src.connected.occupant)
			else
				randmuti(src.connected.occupant)
		else
			if(prob(95))
				randmutg(src.connected.occupant)
			else
				randmuti(src.connected.occupant)

		src.connected.occupant.radiation += ((src.radiation_intensity*3)+src.radiation_duration*3)
		src.connected.locked = lock_state
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["radiationDuration"])
		if (text2num(href_list["radiationDuration"]) > 0)
			if (src.radiation_duration < 20)
				src.radiation_duration += 2
		else
			if (src.radiation_duration > 2)
				src.radiation_duration -= 2
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["radiationIntensity"])
		if (text2num(href_list["radiationIntensity"]) > 0)
			if (src.radiation_intensity < 10)
				src.radiation_intensity++
		else
			if (src.radiation_intensity > 1)
				src.radiation_intensity--
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if (href_list["changeUITarget"] && text2num(href_list["changeUITarget"]) > 0)
		if (src.selected_ui_target < 15)
			src.selected_ui_target++
			src.selected_ui_target_hex = src.selected_ui_target
			switch(selected_ui_target)
				if(10)
					src.selected_ui_target_hex = "A"
				if(11)
					src.selected_ui_target_hex = "B"
				if(12)
					src.selected_ui_target_hex = "C"
				if(13)
					src.selected_ui_target_hex = "D"
				if(14)
					src.selected_ui_target_hex = "E"
				if(15)
					src.selected_ui_target_hex = "F"
		else
			src.selected_ui_target = 0
			src.selected_ui_target_hex = 0
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["changeUITarget"] && text2num(href_list["changeUITarget"]) < 1)
		if (src.selected_ui_target > 0)
			src.selected_ui_target--
			src.selected_ui_target_hex = src.selected_ui_target
			switch(selected_ui_target)
				if(10)
					src.selected_ui_target_hex = "A"
				if(11)
					src.selected_ui_target_hex = "B"
				if(12)
					src.selected_ui_target_hex = "C"
				if(13)
					src.selected_ui_target_hex = "D"
				if(14)
					src.selected_ui_target_hex = "E"
		else
			src.selected_ui_target = 15
			src.selected_ui_target_hex = "F"
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["selectUIBlock"] && href_list["selectUISubblock"]) // This chunk of code updates selected block / sub-block based on click
		var/select_block = text2num(href_list["selectUIBlock"])
		var/select_subblock = text2num(href_list["selectUISubblock"])
		if ((select_block <= 13) && (select_block >= 1))
			src.selected_ui_block = select_block
		if ((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
			src.selected_ui_subblock = select_subblock
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["pulseUIRadiation"])
		var/block
		var/newblock
		var/tstructure2
		block = getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),src.selected_ui_subblock,1)

		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1//lock it
		nanomanager.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0

		if (!src.connected.occupant)
			return 1

		if (prob((80 + (src.radiation_duration / 2))))
			block = miniscrambletarget(num2text(selected_ui_target), src.radiation_intensity, src.radiation_duration)
			newblock = null
			if (src.selected_ui_subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),2,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),3,1)
			if (src.selected_ui_subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),1,1) + block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),3,1)
			if (src.selected_ui_subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),1,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.selected_ui_block,DNA_BLOCK_SIZE),2,1) + block
			tstructure2 = setblock(src.connected.occupant.dna.uni_identity, src.selected_ui_block, newblock,DNA_BLOCK_SIZE)
			src.connected.occupant.dna.uni_identity = tstructure2
			updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			src.connected.occupant.radiation += (src.radiation_intensity+src.radiation_duration)
		else
			if	(prob(20+src.radiation_intensity))
				randmutb(src.connected.occupant)
				domutcheck(src.connected.occupant,src.connected)
			else
				randmuti(src.connected.occupant)
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			src.connected.occupant.radiation += ((src.radiation_intensity*2)+src.radiation_duration)
		src.connected.locked = lock_state
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if (href_list["injectRejuvenators"])
		if (!connected.occupant)
			return 0
		var/inject_amount = round(text2num(href_list["injectRejuvenators"]), 5) // round to nearest 5
		if (inject_amount < 0) // Since the user can actually type the commands himself, some sanity checking
			inject_amount = 0
		if (inject_amount > 50)
			inject_amount = 50
		connected.beaker.reagents.trans_to(connected.occupant, inject_amount)
		connected.beaker.reagents.reaction(connected.occupant)
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if (href_list["selectSEBlock"] && href_list["selectSESubblock"]) // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
		var/select_block = text2num(href_list["selectSEBlock"])
		var/select_subblock = text2num(href_list["selectSESubblock"])
		if ((select_block <= STRUCDNASIZE) && (select_block >= 1))
			src.selected_se_block = select_block
		if ((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
			src.selected_se_subblock = select_subblock
		return 1 // return 1 forces an update to all Nano uis attached to src

	if (href_list["pulseSERadiation"])
		var/block
		var/newblock
		var/tstructure2
		var/oldblock

		block = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),src.selected_se_subblock,1)

		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1 //lock it
		nanomanager.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0

		if(src.connected.occupant)
			if (prob((80 + (src.radiation_duration / 2))))
				if ((src.selected_se_block != 2 || src.selected_se_block != 12 || src.selected_se_block != 8 || src.selected_se_block || 10) && prob (20))
					oldblock = src.selected_se_block
					block = miniscramble(block, src.radiation_intensity, src.radiation_duration)
					newblock = null
					if (src.selected_se_block > 1 && src.selected_se_block < STRUCDNASIZE/2)
						src.selected_se_block++
					else if (src.selected_se_block > STRUCDNASIZE/2 && src.selected_se_block < STRUCDNASIZE)
						src.selected_se_block--
					if (src.selected_se_subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),3,1)
					if (src.selected_se_subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),3,1)
					if (src.selected_se_subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.selected_se_block, newblock,DNA_BLOCK_SIZE)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radiation_intensity+src.radiation_duration)
					src.selected_se_block = oldblock
				else
				//
					block = miniscramble(block, src.radiation_intensity, src.radiation_duration)
					newblock = null
					if (src.selected_se_subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),3,1)
					if (src.selected_se_subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),3,1)
					if (src.selected_se_subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.selected_se_block,DNA_BLOCK_SIZE),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.selected_se_block, newblock,DNA_BLOCK_SIZE)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radiation_intensity+src.radiation_duration)
			else
				if	(prob(80-src.radiation_duration))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += ((src.radiation_intensity*2)+src.radiation_duration)
		src.connected.locked = lock_state
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["ejectBeaker"])
		if(connected.beaker)
			connected.beaker.loc = connected.loc
			connected.beaker = null
		return 1

	if(href_list["ejectOccupant"])
		connected.eject_occupant()
		return 1

	// Transfer Buffer Management
	if(href_list["bufferOption"])
		var/bufferOption = href_list["bufferOption"]

		// These bufferOptions do not require a bufferId
		if (bufferOption == "wipeDisk")
			if ((isnull(src.disk)) || (src.disk.read_only))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			src.disk.data = null
			src.disk.data_type = null
			src.disk.ue = null
			src.disk.owner = null
			src.disk.name = null
			//src.temphtml = "Data saved."
			return 1

		if (bufferOption == "ejectDisk")
			if (!src.disk)
				return
			src.disk.loc = get_turf(src)
			src.disk = null
			return 1

		// All bufferOptions from here on require a bufferId
		if (!href_list["bufferId"])
			return 0

		var/bufferId = text2num(href_list["bufferId"])

		if (bufferId < 1 || bufferId > 3)
			return 0 // Not a valid buffer id

		if (bufferOption == "saveUI")
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffers[bufferId]["ue"] = 0
				src.buffers[bufferId]["data"] = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffers[bufferId]["owner"] = src.connected.occupant.name
				else
					src.buffers[bufferId]["owner"] = src.connected.occupant.real_name
				src.buffers[bufferId]["label"] = "Unique Identifier"
				src.buffers[bufferId]["type"] = "ui"
			return 1

		if (bufferOption == "saveUIAndUE")
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffers[bufferId]["data"] = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffers[bufferId]["owner"] = src.connected.occupant.name
				else
					src.buffers[bufferId]["owner"] = src.connected.occupant.real_name
				src.buffers[bufferId]["label"] = "Unique Identifier + Unique Enzymes"
				src.buffers[bufferId]["type"] = "ui"
				src.buffers[bufferId]["ue"] = 1
			return 1

		if (bufferOption == "saveSE")
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffers[bufferId]["ue"] = 0
				src.buffers[bufferId]["data"] = src.connected.occupant.dna.struc_enzymes
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffers[bufferId]["owner"] = src.connected.occupant.name
				else
					src.buffers[bufferId]["owner"] = src.connected.occupant.real_name
				src.buffers[bufferId]["label"] = "Structural Enzymes"
				src.buffers[bufferId]["type"] = "se"
			return 1

		if (bufferOption == "clear")
			src.buffers[bufferId]["data"] = null
			src.buffers[bufferId]["owner"] = null
			src.buffers[bufferId]["label"] = null
			src.buffers[bufferId]["ue"] = null
			return 1

		if (bufferOption == "changeLabel")
			var/label = src.buffers[bufferId]["label"] ? src.buffers[bufferId]["label"] : "New Label"
			src.buffers[bufferId]["label"] = sanitize(input("New Label:", "Edit Label", label))
			return 1

		if (bufferOption == "transfer")
			if (!src.connected.occupant || (NOCLONE in src.connected.occupant.mutations) || !src.connected.occupant.dna)
				return

			irradiating = 2
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			nanomanager.update_uis(src) // update all UIs attached to src

			sleep(10*2) // sleep for 2 seconds

			irradiating = 0
			src.connected.locked = lock_state

			if (src.buffers[bufferId]["type"] == "ui")
				if (src.buffers[bufferId]["ue"])
					src.connected.occupant.real_name = src.buffers[bufferId]["owner"]
					src.connected.occupant.name = src.buffers[bufferId]["owner"]
				src.connected.occupant.dna.uni_identity = src.buffers[bufferId]["data"]
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffers[bufferId]["type"] == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffers[bufferId]["data"]
				domutcheck(src.connected.occupant,src.connected)
			src.connected.occupant.radiation += rand(20,50)
			return 1

		if (bufferOption == "createInjector")
			if (src.injector_ready)
				var/success = 1
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dnatype = src.buffers[bufferId]["type"]
				if(href_list["createBlockInjector"])
					var/blk = input(usr,"Select Block","Block") in all_dna_blocks(src.buffers[bufferId]["data"])
					success = setInjectorBlock(I,blk,src.buffers[bufferId]["data"])
				else
					I.dna = src.buffers[bufferId]["data"]
				if(success)
					I.loc = src.loc
					I.name += " ([src.buffers[bufferId]["label"]])"
					if (src.buffers[bufferId]["ue"]) I.ue = src.buffers[bufferId]["owner"] //lazy haw haw
					//src.temphtml = "Injector created."
					src.injector_ready = 0
					spawn(300)
						src.injector_ready = 1
				//else
					//src.temphtml = "Error in injector creation."
			//else
				//src.temphtml = "Replicator not ready yet."
			return 1

		if (bufferOption == "loadDisk")
			if ((isnull(src.disk)) || (!src.disk.data) || (src.disk.data == ""))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			src.buffers[bufferId]["data"] = src.disk.data
			src.buffers[bufferId]["type"] = src.disk.data_type
			src.buffers[bufferId]["ue"] = src.disk.ue
			src.buffers[bufferId]["owner"] = src.disk.owner
			//src.temphtml = "Data loaded."
			return 1

		if (bufferOption == "saveDisk")
			if ((isnull(src.disk)) || (src.disk.read_only))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			src.disk.data = buffers[bufferId]["data"]
			src.disk.data_type = src.buffers[bufferId]["type"]
			src.disk.ue = src.buffers[bufferId]["ue"]
			src.disk.owner = src.buffers[bufferId]["owner"]
			src.disk.name = "data disk - '[src.buffers[bufferId]["owner"]]'"
			//src.temphtml = "Data saved."
			return 1


/////////////////////////// DNA MACHINES
