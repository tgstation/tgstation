#define BORG_WIRE_LAWCHECK 1
#define BORG_WIRE_MAIN_POWER1 2
#define BORG_WIRE_MAIN_POWER2 3
#define BORG_WIRE_AI_CONTROL 4
#define BORG_WIRE_CAMERA 5

/proc/RandomBorgWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/Borgwires = list(0, 0, 0, 0, 0)
	BorgIndexToFlag = list(0, 0, 0, 0, 0)
	BorgIndexToWireColor = list(0, 0, 0, 0, 0)
	BorgWireColorToIndex = list(0, 0, 0, 0, 0)
	var/flagIndex = 1
	//I think it's easier to read this way, also doesn't rely on the random number generator to land on a new wire.
	var/list/colorIndexList = list(BORG_WIRE_LAWCHECK, BORG_WIRE_MAIN_POWER1, BORG_WIRE_MAIN_POWER2, BORG_WIRE_AI_CONTROL, BORG_WIRE_CAMERA)
	for (var/flag=1, flag<=16, flag+=flag)
		var/colorIndex = pick(colorIndexList)
		if (Borgwires[colorIndex]==0)
			Borgwires[colorIndex] = flag
			BorgIndexToFlag[flagIndex] = flag
			BorgIndexToWireColor[flagIndex] = colorIndex
			BorgWireColorToIndex[colorIndex] = flagIndex
			colorIndexList -= colorIndex // Shortens the list.
		//world.log << "Flag: [flag], CIndex: [colorIndex], FIndex: [flagIndex]"
		flagIndex+=1
	return Borgwires

/mob/living/silicon/robot/proc/isWireColorCut(var/wireColor)
	var/wireFlag = BorgWireColorToFlag[wireColor]
	return ((src.borgwires & wireFlag) == 0)

/mob/living/silicon/robot/proc/isWireCut(var/wireIndex)
	var/wireFlag = BorgIndexToFlag[wireIndex]
	return ((src.borgwires & wireFlag) == 0)

/mob/living/silicon/robot/proc/cut(var/wireColor)
	var/wireFlag = BorgWireColorToFlag[wireColor]
	var/wireIndex = BorgWireColorToIndex[wireColor]
	borgwires &= ~wireFlag
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if (src.lawupdate == 1)
				src << "LawSync protocol engaged."
				src.show_laws()
		if (BORG_WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if (src.connected_ai)
				src.connected_ai = null
		if (BORG_WIRE_CAMERA)
			if(!isnull(src.camera) && !scrambledcodes)
				src.camera.status = 0
				src.camera.deactivate(usr, 0) // Will kick anyone who is watching the Cyborg's camera.

	src.interact(usr)

/mob/living/silicon/robot/proc/mend(var/wireColor)
	var/wireFlag = BorgWireColorToFlag[wireColor]
	var/wireIndex = BorgWireColorToIndex[wireColor]
	borgwires |= wireFlag
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK) //turns law updates back on assuming the borg hasn't been emagged
			if (src.lawupdate == 0 && !src.emagged)
				src.lawupdate = 1
		if(BORG_WIRE_CAMERA)
			if (!isnull(src.camera) && !scrambledcodes)
				src.camera.status = 1
				src.camera.deactivate(usr, 0) // Will kick anyone who is watching the Cyborg's camera.

	src.interact(usr)


/mob/living/silicon/robot/proc/pulse(var/wireColor)
	var/wireIndex = BorgWireColorToIndex[wireColor]
	switch(wireIndex)
		if(BORG_WIRE_LAWCHECK)	//Forces a law update if the borg is set to receive them. Since an update would happen when the borg checks its laws anyway, not much use, but eh
			if (src.lawupdate)
				src.lawsync()

		if (BORG_WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			if(!src.emagged)
				src.connected_ai = select_active_ai()

		if (BORG_WIRE_CAMERA)
			if(!isnull(src.camera) && src.camera.status && !scrambledcodes)
				src.camera.deactivate(usr, 0) // Kick anyone watching the Cyborg's camera, doesn't display you disconnecting the camera.
				usr << "[src]'s camera lens focuses loudly."
				src << "Your camera lens focuses loudly."

	src.interact(usr)

/mob/living/silicon/robot/proc/interact(mob/user)
	if(wiresexposed && (!istype(user, /mob/living/silicon)))
		user.machine = src
		var/t1 = text("<B>Access Panel</B><br>\n")
		var/list/Borgwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Blue" = 5,
		)
		for(var/wiredesc in Borgwires)
			var/is_uncut = src.borgwires & BorgWireColorToFlag[Borgwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];borgwires=[Borgwires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];borgwires=[Borgwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[Borgwires[wiredesc]]'>Pulse</a> "
			t1 += "<br>"
		t1 += text("<br>\n[(src.lawupdate ? "The LawSync light is on." : "The LawSync light is off.")]<br>\n[(src.connected_ai ? "The AI link light is on." : "The AI link light is off.")]")
		t1 += text("<br>\n[((!isnull(src.camera) && src.camera.status == 1) ? "The Camera light is on." : "The Camera light is off.")]<br>\n")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p>\n")
		user << browse(t1, "window=borgwires")
		onclose(user, "borgwires")

/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (((in_range(src, usr) && istype(src.loc, /turf))) && !istype(usr, /mob/living/silicon))
		usr.machine = src
		if (href_list["borgwires"])
			var/t1 = text2num(href_list["borgwires"])
			if (!( istype(usr.get_active_hand(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(t1)
		else if (href_list["close2"])
			usr << browse(null, "window=borgwires")
			usr.machine = null
			return

#undef BORG_WIRE_LAWCHECK
#undef BORG_WIRE_MAIN_POWER1
#undef BORG_WIRE_MAIN_POWER2
#undef BORG_WIRE_AI_CONTROL
#undef BORG_WIRE_CAMERA