#define CAMERA_WIRE_FOCUS 1
#define CAMERA_WIRE_POWER 2
#define CAMERA_WIRE_LIGHT 3
#define CAMERA_WIRE_ALARM 4
#define CAMERA_WIRE_NOTHING1 5
#define CAMERA_WIRE_NOTHING2 6

/obj/machinery/camera/proc/randomCameraWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0)
	IndexToFlag = list(0, 0, 0, 0, 0, 0)
	IndexToWireColor = list(0, 0, 0, 0, 0, 0)
	WireColorToIndex = list(0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	//I think it's easier to read this way, also doesn't rely on the random number generator to land on a new wire.
	var/list/colorIndexList = list(CAMERA_WIRE_FOCUS, CAMERA_WIRE_POWER, CAMERA_WIRE_LIGHT, CAMERA_WIRE_ALARM, CAMERA_WIRE_NOTHING1, CAMERA_WIRE_NOTHING2)
	for (var/flag=1, flag<=32, flag+=flag)
		var/colorIndex = pick(colorIndexList)
		if (wires[colorIndex]==0)
			wires[colorIndex] = flag
			IndexToFlag[flagIndex] = flag
			IndexToWireColor[flagIndex] = colorIndex
			WireColorToIndex[colorIndex] = flagIndex
			colorIndexList -= colorIndex // Shortens the list.
		//world.log << "Flag: [flag], CIndex: [colorIndex], FIndex: [flagIndex]"
		flagIndex+=1
	return wires

/obj/machinery/camera/proc/isWireColorCut(var/wireColor)
	var/wireFlag = WireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/camera/proc/isWireCut(var/wireIndex)
	var/wireFlag = IndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/camera/proc/canDeconstruct()
	if(isWireCut(CAMERA_WIRE_POWER) && isWireCut(CAMERA_WIRE_FOCUS) && isWireCut(CAMERA_WIRE_LIGHT) && isWireCut(CAMERA_WIRE_NOTHING1) && isWireCut(CAMERA_WIRE_NOTHING2))
		return 1
	else
		return 0

/obj/machinery/camera/proc/cut(var/wireColor)
	var/wireFlag = WireColorToFlag[wireColor]
	var/wireIndex = WireColorToIndex[wireColor]
	wires &= ~wireFlag
	switch(wireIndex)
		if(CAMERA_WIRE_FOCUS)
			setViewRange(short_range)

		if(CAMERA_WIRE_POWER)
			deactivate(usr, 1)
			//shock(usr)

		if(CAMERA_WIRE_LIGHT)
			light_disabled = 1

		if(CAMERA_WIRE_ALARM)
			triggerCameraAlarm()

	src.interact(usr)

/obj/machinery/camera/proc/mend(var/wireColor)
	var/wireFlag = WireColorToFlag[wireColor]
	var/wireIndex = WireColorToIndex[wireColor]
	wires |= wireFlag
	switch(wireIndex)
		if(CAMERA_WIRE_FOCUS)
			setViewRange(initial(view_range))

		if(CAMERA_WIRE_POWER)
			deactivate(usr, 1)

		if(CAMERA_WIRE_LIGHT)
			light_disabled = 0

		if(CAMERA_WIRE_ALARM)
			cancelCameraAlarm()

	src.interact(usr)


/obj/machinery/camera/proc/pulse(var/wireColor)
	var/wireIndex = WireColorToIndex[wireColor]
	switch(wireIndex)
		if(CAMERA_WIRE_FOCUS)
			var/new_range = (view_range == initial(view_range) ? short_range : initial(view_range))
			setViewRange(new_range)

		if(CAMERA_WIRE_POWER)
			deactivate(usr, 0) // Kicks anyone watching the camera

		if(CAMERA_WIRE_LIGHT)
			light_disabled = !light_disabled

		if(CAMERA_WIRE_ALARM)
			src.visible_message("\icon[src] *beep*", "\icon[src] *beep*")

	src.interact(usr)

/obj/machinery/camera/proc/interact(mob/living/user as mob)
	if(!panel_open)
		return

	user.machine = src
	var/t1 = text("<B>Access Panel</B><br>\n")
	var/list/wires = list(
		"Orange" = 1,
		"Dark red" = 2,
		"White" = 3,
		"Yellow" = 4,
		"Blue" = 5,
		"Pink" = 6
	)
	for(var/wiredesc in wires)
		var/is_uncut = src.wires & WireColorToFlag[wires[wiredesc]]
		t1 += "[wiredesc] wire: "
		if(!is_uncut)
			t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Mend</a>"
		else
			t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Cut</a> "
			t1 += "<a href='?src=\ref[src];pulse=[wires[wiredesc]]'>Pulse</a> "
		t1 += "<br>"

	t1 += "<br>\n[(src.view_range == initial(view_range) ? "The focus light is on." : "The focus light is off.")]"
	t1 += "<br>\n[(src.can_use() ? "The power link light is on." : "The power link light is off.")]"
	t1 += "<br>\n[(light_disabled ? "The camera light is off." : "The camera light is on.")]"
	t1 += "<br>\n[(alarm_on ? "The alarm light is on." : "The alarm light is off.")]"

	t1 += "<p><a href='?src=\ref[src];close2=1'>Close</a></p>\n"
	user << browse(t1, "window=wires")
	onclose(user, "wires")



/obj/machinery/camera/Topic(href, href_list)
	..()
	if (in_range(src, usr) && istype(src.loc, /turf))
		usr.machine = src
		if (href_list["wires"])
			var/t1 = text2num(href_list["wires"])
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
			usr << browse(null, "window=wires")
			usr.machine = null
			return


#undef CAMERA_WIRE_FOCUS
#undef CAMERA_WIRE_POWER
#undef CAMERA_WIRE_LIGHT
#undef CAMERA_WIRE_ALARM
#undef CAMERA_WIRE_NOTHING1
#undef CAMERA_WIRE_NOTHING2