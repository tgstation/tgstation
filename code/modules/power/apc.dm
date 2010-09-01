#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"

	icon_state = "apc0"
	anchored = 1
	req_access = list(access_engine_equip)
	var/area/area
	var/areastring = null
	var/obj/item/weapon/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/light_consumption = 0
	var/equip_consumption = 0
	var/environ_consumption = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/apcwires = 15
	netnum = -1		// set so that APCs aren't found as powernet nodes
//	luminosity = 1

/proc/RandomAPCWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/apcwires = list(0, 0, 0, 0)
	APCIndexToFlag = list(0, 0, 0, 0)
	APCIndexToWireColor = list(0, 0, 0, 0)
	APCWireColorToIndex = list(0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<16, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 4)
			if (apcwires[colorIndex]==0)
				valid = 1
				apcwires[colorIndex] = flag
				APCIndexToFlag[flagIndex] = flag
				APCIndexToWireColor[flagIndex] = colorIndex
				APCWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return apcwires

/obj/machinery/power/apc/updateUsrDialog()
	var/list/nearby = viewers(1, src)
	if (!(stat & BROKEN)) // unbroken
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				src.interact(M)
	if (istype(usr, /mob/living/silicon))
		if (!(usr in nearby))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.interact(usr)

/obj/machinery/power/apc/updateDialog()
	if(!(stat & BROKEN)) // unbroken
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if (M.client && M.machine == src)
				src.interact(M)
	AutoUpdateAI(src)

/obj/machinery/power/apc/New()
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area

	tdir = dir		// to fix Vars bug
	dir = SOUTH

	pixel_x = (tdir & 3)? 0 : (tdir == 4 ? 24 : -24)
	pixel_y = (tdir & 3)? (tdir ==1 ? 24 : -24) : 0

	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/weapon/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	var/area/A = src.loc.loc

	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
	else
		src.area = get_area_name(areastring)
	updateicon()

	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = tdir
	terminal.master = src

	spawn(5)
		src.update()

/obj/machinery/power/apc/examine()
	set src in oview(1)

	if(stat & BROKEN) return

	if(usr && !usr.stat)
		usr << "A control terminal for the area electrical systems."
		if(opened)
			usr << "The cover is open and the power cell is [ cell ? "installed" : "missing"]."
		else
			usr << "The cover is closed."



// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/proc/updateicon()
	if(opened)
		icon_state = "[ cell ? "apc2" : "apc1" ]"		// if opened, show cell if it's inserted
		src.overlays = null								// also delete all overlays
	else if(emagged)
		icon_state = "apcemag"
		src.overlays = null
		return
	else if(wiresexposed)
		icon_state = "apcwires"
		src.overlays = null
		return
	else
		icon_state = "apc0"

		// if closed, update overlays for channel status

		src.overlays = null

		overlays += image('power.dmi', "apcox-[locked]")	// 0=blue 1=red
		overlays += image('power.dmi', "apco3-[charging]") // 0=red, 1=yellow/black 2=green


		if(operating)
			overlays += image('power.dmi', "apco0-[equipment]")	// 0=red, 1=green, 2=blue
			overlays += image('power.dmi', "apco1-[lighting]")
			overlays += image('power.dmi', "apco2-[environ]")

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/weapon/W, mob/user)

	if(stat & BROKEN) return
	if (istype(user, /mob/living/silicon))
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			opened = 0
			updateicon()
		else
			if(coverlocked)
				user << "The cover is locked and cannot be opened."
			else
				opened = 1
				updateicon()
	else if	(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."
			chargecount = 0
		updateicon()
	else if	(istype(W, /obj/item/weapon/screwdriver))	// haxing
		if(opened)
			user << "Close the APC first"
		else if(emagged)
			user << "The interface is broken"
		else
			wiresexposed = !wiresexposed
			user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
			updateicon()

	else if (istype(W, /obj/item/weapon/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			user << "The interface is broken"
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else
			if(src.allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] the APC interface."
				updateicon()
			else
				user << "\red Access denied."
	else if (istype(W, /obj/item/weapon/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel first"
		else
			flick("apc-spark", src)
			sleep(6)
			if(prob(50))
				emagged = 1
				locked = 0
				user << "You emag the APC interface."
				updateicon()
			else
				user << "You fail to [ locked ? "unlock" : "lock"] the APC interface."

/obj/machinery/power/apc/attack_ai(mob/user)
	return src.attack_hand(user)

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)

	add_fingerprint(user)

	if(stat & BROKEN) return
	if(opened && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user << "You remove the power cell."
			charging = 0
			src.updateicon()

	else
		// do APC interaction
		src.interact(user)



/obj/machinery/power/apc/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=apc")
			return
		else if (istype(user, /mob/living/silicon) && src.aidisabled)
			user << "AI control for this APC interface has been disabled."
			user << browse(null, "window=apc")
			return
	if(wiresexposed && (!istype(user, /mob/living/silicon)))
		user.machine = src
		var/t1 = text("<B>Access Panel</B><br>\n")
		var/list/apcwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
		)
		for(var/wiredesc in apcwires)
			var/is_uncut = src.apcwires & APCWireColorToFlag[apcwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[apcwires[wiredesc]]'>Pulse</a> "
			t1 += "<br>"
		t1 += text("<br>\n[(src.locked ? "The APC is locked." : "The APC is unlocked.")]<br>\n[(src.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]<br>\n[(src.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p>\n")
		user << browse(t1, "window=apcwires")
		onclose(user, "apcwires")

	user.machine = src
	var/t = "<TT><B>Area Power Controller</B> ([area.name])<HR>"

	if(locked && (!istype(user, /mob/living/silicon)))
		t += "<I>(Swipe ID card to unlock inteface.)</I><BR>"
		t += "Main breaker : <B>[operating ? "On" : "Off"]</B><BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		t += "Power cell: <B>[cell ? "[round(cell.percent())]%" : "<FONT COLOR=red>Not connected.</FONT>"]</B>"
		if(cell)
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "Auto" : "Off"])"

		t += "<BR><HR>Power channels<BR><PRE>"

		var/list/L = list ("Off","Off (Auto)", "On", "On (Auto)")

		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : <B>[L[equipment+1]]</B><BR>"
		t += "Lighting:     [add_lspace(lastused_light, 6)] W : <B>[L[lighting+1]]</B><BR>"
		t += "Environmental:[add_lspace(lastused_environ, 6)] W : <B>[L[environ+1]]</B><BR>"

		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: <B>[coverlocked ? "Engaged" : "Disengaged"]</B>"

	else
		if (!istype(user, /mob/living/silicon))
			t += "<I>(Swipe ID card to lock interface.)</I><BR>"
		t += "Main breaker: [operating ? "<B>On</B> <A href='?src=\ref[src];breaker=1'>Off</A>" : "<A href='?src=\ref[src];breaker=1'>On</A> <B>Off</B>" ]<BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		if(cell)
			t += "Power cell: <B>[round(cell.percent())]%</B>"
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "<A href='?src=\ref[src];cmode=1'>Off</A> <B>Auto</B>" : "<B>Off</B> <A href='?src=\ref[src];cmode=1'>Auto</A>"])"

		else
			t += "Power cell: <B><FONT COLOR=red>Not connected.</FONT></B>"

		t += "<BR><HR>Power channels<BR><PRE>"


		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : "
		switch(equipment)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];eqp=2'>On</A> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <B>On</B> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"

		t += "Lighting:     [add_lspace(lastused_light, 6)] W : "

		switch(lighting)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];lgt=2'>On</A> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <B>On</B> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"


		t += "Environmental:[add_lspace(lastused_environ, 6)] W : "
		switch(environ)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];env=2'>On</A> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <B>On</B> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (On)</B>"



		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: [coverlocked ? "<B><A href='?src=\ref[src];lock=1'>Engaged</A></B>" : "<B><A href='?src=\ref[src];lock=1'>Disengaged</A></B>"]"


		if (istype(user, /mob/living/silicon))
			t += "<BR><HR><A href='?src=\ref[src];overload=1'><I>Overload lighting circuit</I></A><BR>"


	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=apc")
	onclose(user, "apc")
	return

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"




/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
//		if (area.name == "AI Chamber")
//			spawn(10)
//				world << " [area.name] [area.power_equip]"
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
//		if (area.name == "AI Chamber")
//			world << "[area.power_equip]"
	area.power_change()

/obj/machinery/power/apc/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/get_connection()
	if(stat & BROKEN)	return 0
	return 1

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	var/net = get_connection()		// find the powernet of the connected cable
	if(!net)		// cable is unpowered
		return 0
	return src.apcelectrocute(user, prb, net)

/obj/machinery/power/apc/proc/apcelectrocute(mob/user, prb, netnum)

	if(stat == 2)
		return 0

	if(!prob(prb))
		return 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/prot = 1

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			prot = G.siemens_coefficient
	else if (istype(user, /mob/living/silicon))
		return 0

	if(prot == 0)		// elec insulted gloves protect completely
		return 0

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	var/shock_damage = 0
	if(cell_type == 2500)	//someone juiced up the grid enough, people going to die!
		shock_damage = min(rand(70,145),rand(70,145))*prot
		cell_type = cell_type - 2000
	else if(cell_type >= 1750)
		shock_damage = min(rand(35,110),rand(35,110))*prot
		cell_type = cell_type - 1600
	else if(cell_type >= 1500)
		shock_damage = min(rand(30,100),rand(30,100))*prot
		cell_type = cell_type - 1000
	else if(cell_type >= 750)
		shock_damage = min(rand(25,90),rand(25,90))*prot
		cell_type = cell_type - 500
	else if(cell_type >= 250)
		shock_damage = min(rand(20,80),rand(20,80))*prot
		cell_type = cell_type - 125
	else if(cell_type >= 100)
		shock_damage = min(rand(20,65),rand(20,65))*prot
		cell_type = cell_type - 50
	else
		return 0

	user.burn_skin(shock_damage)
	user << "\red <B>You feel a powerful shock course through your body!</B>"
	sleep(1)

	if(user.stunned < shock_damage)	user.stunned = shock_damage
	if(user.weakened < 20*prot)	user.weakened = 20*prot
	for(var/mob/M in viewers(src))
		if(M == user)	continue
		M.show_message("\red [user.name] was shocked by the [src.name]!", 3, "\red You hear a heavy electrical crack", 2)
	return 1


/obj/machinery/power/apc/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	apcwires &= ~wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			src.shock(usr, 50)			//this doesn't work for some reason, give me a while I'll figure it out
			src.shorted = 1
			src.updateUsrDialog()
		if(APC_WIRE_MAIN_POWER2)
			src.shock(usr, 50)
			src.shorted = 1
			src.updateUsrDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateUsrDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever


/obj/machinery/power/apc/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	apcwires |= wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(APC_WIRE_MAIN_POWER2)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50)
				src.updateUsrDialog()
		if (APC_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aidisabledDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aidisabled == 1)
				src.aidisabled = 0
			src.updateUsrDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever

/obj/machinery/power/apc/proc/pulse(var/wireColor)
	//var/wireFlag = apcWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(APC_WIRE_IDSCAN)			//unlocks the APC for 30 seconds, if you have a better way to hack an APC I'm all ears
			src.locked = 0
			spawn(300)
				src.locked = 1
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER1)
			if(shorted == 0)
				shorted = 1
			spawn(1200)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER2)
			if(shorted == 0)
				shorted = 1
			spawn(1200)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
			spawn(10)
				if (src.aidisabled == 1)
					src.aidisabled = 0
				src.updateDialog()


/obj/machinery/power/apc/Topic(href, href_list)
	..()
	if (((in_range(src, usr) && istype(src.loc, /turf))) || ((istype(usr, /mob/living/silicon) && !(src.aidisabled))))
		usr.machine = src
		if (href_list["apcwires"])
			var/t1 = text2num(href_list["apcwires"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(t1)
		else if (href_list["lock"])
			coverlocked = !coverlocked

		else if (href_list["breaker"])
			operating = !operating
			src.update()
			updateicon()

		else if (href_list["cmode"])
			chargemode = !chargemode
			if(!chargemode)
				charging = 0
				updateicon()

		else if (href_list["eqp"])
			var/val = text2num(href_list["eqp"])

			equipment = (val==1) ? 0 : val

			updateicon()
			update()

		else if (href_list["lgt"])
			var/val = text2num(href_list["lgt"])

			lighting = (val==1) ? 0 : val

			updateicon()
			update()
		else if (href_list["env"])
			var/val = text2num(href_list["env"])

			environ = (val==1) ? 0 :val

			updateicon()
			update()
		else if( href_list["close"] )
			usr << browse(null, "window=apc")
			usr.machine = null
			return
		else if (href_list["close2"])
			usr << browse(null, "window=apcwires")
			usr.machine = null
			return

		else if (href_list["overload"])
			if( istype(usr, /mob/living/silicon) && !src.aidisabled )
				src.overload_lighting()
		return

		src.updateUsrDialog()

	else
		usr << browse(null, "window=apc")
		usr.machine = null

	return

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & BROKEN)
		return
	if(!area.requires_power)
		return


	/*
	if (equipment > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.equip_consumption, EQUIP)
	if (lighting > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.light_consumption, LIGHT)
	if (environ > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.environ_consumption, ENVIRON)

	area.calc_lighting() */

	lastused_light = area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_environ = area.usage(ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(cell && !shorted)

		// draw power from cell as before

		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > 0 || perapc > lastused_total)		// if power excess, or enough anyway, recharge the cell
														// by the same amount just used

			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc

			if( (cell.charge/CELLRATE+perapc) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?

				cell.charge = min(cell.maxcharge, cell.charge + CELLRATE * perapc)	//recharge with what we can
				add_load(perapc)		// so draw what we can from the grid
				charging = 0

			else	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		// set channels depending on how much charge we have left

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15)			// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is perapc share, capped to cell capacity, or % per second constant (Whichever is smallest)
				var/ch = min(perapc, (cell.maxcharge - cell.charge), (cell.maxcharge*CHARGELEVEL))
				add_load(ch) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so

		if(cell.charge >= cell.maxcharge)
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || last_ch != charging)
		updateicon()
		update()

	src.updateDialog()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/proc/autoset(var/val, var/on)

	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/meteorhit(var/obj/O as obj)

	set_broken()
	return

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1.0)
			set_broken()
			del(src)
			return
		if(2.0)
			if (prob(50))
				set_broken()
		if(3.0)
			if (prob(25))
				set_broken()
		else
	return

/obj/machinery/power/apc/blob_act()
	if (prob(50))
		set_broken()


/obj/machinery/power/apc/proc/set_broken()
	stat |= BROKEN
	icon_state = "apc-b"
	overlays = null

	operating = 0
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(!get_connection() || !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.charge-=20;
		spawn(0)
			for(var/area/A in area.related)
				for(var/obj/machinery/light/L in A)
					L.on = 1
					L.broken()
					sleep(1)
