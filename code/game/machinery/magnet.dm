// Magnetic attractor, creates variable magnetic fields and attraction.
// Can also be used to emit electron/proton beams to create a center of magnetism on another tile

// tl;dr: it's magnets lol
// This was created for firing ranges, but I suppose this could have other applications - Doohl

#define MAX_ELECTRICITY_LEVEL 12
#define MAX_MAGNETIC_LEVEL 4
#define MAX_DIST 20

/obj/machinery/magnetic_module
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_magnet-f"
	name = "electromagnetic generator"
	desc = "A device that uses station power to create points of magnetic energy."
	level = 1		// underfloor
	layer = LOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

	var/freq = FREQ_MAGNETS		// radio frequency
	var/electricity_level = 1 // intensity of the magnetic pull
	var/magnetic_field = 1 // the range of magnetic attraction
	var/code = 0 // frequency code, they should be different unless you have a group of magnets working together or something
	var/turf/center // the center of magnetic attraction
	var/on = FALSE

	// x, y modifiers to the center turf; (0, 0) is centered on the magnet, whereas (1, -1) is one tile right, one tile down
	var/center_x = 0
	var/center_y = 0
	var/cooldown_timer

/obj/machinery/magnetic_module/Initialize()
	..()
	var/turf/T = loc
	hide(T.intact)
	center = T
	SSradio.add_object(src, freq, RADIO_MAGNETS)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/magnetic_module/LateInitialize()
	if(on)
		spread_register_net()

/obj/machinery/magnetic_module/Destroy()
	SSradio.remove_object(src, freq)
	center = null
	return ..()

// update the invisibility and icon
/obj/machinery/magnetic_module/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon()

// update the icon_state
/obj/machinery/magnetic_module/update_icon_state()
	var/state="floor_magnet"
	var/onstate=""
	if(!on)
		onstate="0"

	if(invisibility)
		icon_state = "[state][onstate]-f"	// if invisible, set icon to faded version
											// in case of being revealed by T-scanner
	else
		icon_state = "[state][onstate]"

/obj/machinery/magnetic_module/receive_signal(datum/signal/signal)

	var/command = signal.data["command"]
	var/modifier = signal.data["modifier"]
	var/signal_code = signal.data["code"]
	if(command && (signal_code == code))

		Cmd(command, modifier)



/obj/machinery/magnetic_module/proc/Cmd(command, modifier)
	cancel_register_net()
	if(command)
		switch(command)
			if("set-electriclevel")
				if(modifier)
					electricity_level = CLAMP(modifier, 1, MAX_ELECTRICITY_LEVEL)
			if("set-magneticfield")
				if(modifier)
					magnetic_field = CLAMP(modifier, 1, MAX_MAGNETIC_LEVEL)

			if("add-elec")
				electricity_level = min(electricity_level+1, MAX_ELECTRICITY_LEVEL)
			if("sub-elec")
				electricity_level = max(electricity_level-1, 1)
			if("add-mag")
				magnetic_field = min(magnetic_field+1, MAX_MAGNETIC_LEVEL)
			if("sub-mag")
				magnetic_field = max(magnetic_field-1, 1)

			if("set-x")
				if(modifier)
					center_x = CLAMP(modifier, -MAX_DIST, MAX_DIST)
			if("set-y")
				if(modifier)
					center_y = CLAMP(modifier, -MAX_DIST, MAX_DIST)

			if("N") // NORTH
				center_y = min(center_y+1, MAX_DIST)
			if("S")	// SOUTH
				center_y = max(center_y-1, -MAX_DIST)
			if("E") // EAST
				center_x = min(center_x+1, MAX_DIST)
			if("W") // WEST
				center_x = max(center_x-1, -MAX_DIST)
			if("C") // CENTER
				center_x = 0
				center_y = 0
			if("R") // RANDOM
				center_x = rand(-MAX_DIST, MAX_DIST)
				center_y = rand(-MAX_DIST, MAX_DIST)

			if("set-code")
				if(modifier)
					code = modifier
			if("toggle-power")
				on = !on
	center = locate(x+center_x, y+center_y, z)
	spread_register_net()

/obj/machinery/magnetic_module/process()
	if(stat & NOPOWER)
		on = FALSE
		cancel_register_net()

	// Update power usage:
	if(on)
		use_power = ACTIVE_POWER_USE
		active_power_usage = electricity_level*15
	else
		use_power = NO_POWER_USE

	update_icon()

/obj/machinery/magnetic_module/proc/spread_register_net()
	if(!on || magnetic_field < 1 || timeleft(cooldown_timer))
		return
	cooldown_timer = null
	for(var/turf/T in orange(magnetic_field, center))
		RegisterSignal(T, COMSIG_ATOM_ENTERED, .proc/magnetic_pull)

/obj/machinery/magnetic_module/proc/cancel_register_net()
	for(var/turf/T in orange(magnetic_field, center))
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)

/obj/machinery/magnetic_module/proc/magnetic_pull(datum/source, atom/movable/entering, /atom/A)
	if(isobj(entering))
		if(entering.anchored || !(entering.flags_1 & CONDUCT_1))
			return
	else if(issilicon(entering))
		if(isAI(entering))
			return
	step_towards(entering, center)
	cancel_register_net()
	use_power(electricity_level * 5)
	cooldown_timer = addtimer(CALLBACK(src, .proc/spread_register_net), MAX_ELECTRICITY_LEVEL-electricity_level+1, TIMER_STOPPABLE)


/obj/machinery/magnetic_controller
	name = "magnetic control console"
	icon = 'icons/obj/airlock_machines.dmi' // uses an airlock machine icon, THINK GREEN HELP THE ENVIRONMENT - RECYCLING!
	icon_state = "airlock_control_standby"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 45
	var/frequency = FREQ_MAGNETS
	var/code = 0
	var/list/magnets = list()
	var/title = "Magnetic Control Console"
	var/autolink = 0 // if set to 1, can't probe for other magnets!

	var/pathpos = 1 // position in the path
	var/path = "w;e;e;w;s;n;n;s" // text path of the magnet
	var/speed = 1 // lowest = 1, highest = 10
	var/list/rpath = list() // real path of the magnet, used in iterator

	var/moving = 0 // 1 if scheduled to loop
	var/looping = 0 // 1 if looping

	var/datum/radio_frequency/radio_connection


/obj/machinery/magnetic_controller/Initialize()
	. = ..()
	if(autolink)
		for(var/obj/machinery/magnetic_module/M in GLOB.machines)
			if(M.freq == frequency && M.code == code)
				magnets.Add(M)

	if(path) // check for default path
		filter_path() // renders rpath
	radio_connection = SSradio.add_object(src, frequency, RADIO_MAGNETS)

/obj/machinery/magnetic_controller/Destroy()
	SSradio.remove_object(src, frequency)
	magnets = null
	rpath = null
	return ..()

/obj/machinery/magnetic_controller/process()
	if(magnets.len == 0 && autolink)
		for(var/obj/machinery/magnetic_module/M in GLOB.machines)
			if(M.freq == frequency && M.code == code)
				magnets.Add(M)

/obj/machinery/magnetic_controller/ui_interact(mob/user)
	. = ..()
	var/dat = "<B>Magnetic Control Console</B><BR><BR>"
	if(!autolink)
		dat += {"
		Frequency: <a href='?src=[REF(src)];operation=setfreq'>[frequency]</a><br>
		Code: <a href='?src=[REF(src)];operation=setfreq'>[code]</a><br>
		<a href='?src=[REF(src)];operation=probe'>Probe Generators</a><br>
		"}

	if(magnets.len >= 1)

		dat += "Magnets confirmed: <br>"
		var/i = 0
		for(var/obj/machinery/magnetic_module/M in magnets)
			i++
			dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;< \[[i]\] (<a href='?src=[REF(src)];radio-op=togglepower'>[M.on ? "On":"Off"]</a>) | Electricity level: <a href='?src=[REF(src)];radio-op=minuselec'>-</a> [M.electricity_level] <a href='?src=[REF(src)];radio-op=pluselec'>+</a>; Magnetic field: <a href='?src=[REF(src)];radio-op=minusmag'>-</a> [M.magnetic_field] <a href='?src=[REF(src)];radio-op=plusmag'>+</a><br>"

	dat += "<br>Speed: <a href='?src=[REF(src)];operation=minusspeed'>-</a> [speed] <a href='?src=[REF(src)];operation=plusspeed'>+</a><br>"
	dat += "Path: {<a href='?src=[REF(src)];operation=setpath'>[path]</a>}<br>"
	dat += "Moving: <a href='?src=[REF(src)];operation=togglemoving'>[moving ? "Enabled":"Disabled"]</a>"


	user << browse(dat, "window=magnet;size=400x500")
	onclose(user, "magnet")

/obj/machinery/magnetic_controller/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	if(href_list["radio-op"])

		// Prepare signal beforehand, because this is a radio operation
		var/datum/signal/signal = new(list("code" = code))

		// Apply any necessary commands
		switch(href_list["radio-op"])
			if("togglepower")
				signal.data["command"] = "toggle-power"

			if("minuselec")
				signal.data["command"] = "sub-elec"
			if("pluselec")
				signal.data["command"] = "add-elec"

			if("minusmag")
				signal.data["command"] = "sub-mag"
			if("plusmag")
				signal.data["command"] = "add-mag"


		// Broadcast the signal

		radio_connection.post_signal(src, signal, filter = RADIO_MAGNETS)

		updateUsrDialog()

	if(href_list["operation"])
		switch(href_list["operation"])
			if("plusspeed")
				speed = min(speed+1, 10)
			if("minusspeed")
				speed = max(speed-1, 1)
			if("setpath")
				var/newpath = copytext(sanitize(input(usr, "Please define a new path!",,path) as text|null),1,MAX_MESSAGE_LEN)
				if(newpath && newpath != "")
					moving = 0 // stop moving
					path = newpath
					pathpos = 1 // reset position
					filter_path() // renders rpath

			if("togglemoving")
				moving = !moving
				if(moving)
					INVOKE_ASYNC(src, .proc/MagnetMove)


	updateUsrDialog()

/obj/machinery/magnetic_controller/proc/MagnetMove()
	if(looping)
		return

	while(moving && rpath.len >= 1)

		if(stat & (BROKEN|NOPOWER))
			break

		looping = 1

		// Prepare the radio signal
		var/datum/signal/signal = new(list("code" = code))

		if(pathpos > rpath.len) // if the position is greater than the length, we just loop through the list!
			pathpos = 1

		var/nextmove = uppertext(rpath[pathpos]) // makes it un-case-sensitive

		if(!(nextmove in list("N","S","E","W","C","R")))
			// N, S, E, W are directional
			// C is center
			// R is random (in magnetic field's bounds)
			qdel(signal)
			break // break the loop if the character located is invalid

		signal.data["command"] = nextmove


		pathpos++ // increase iterator

		// Broadcast the signal
		INVOKE_ASYNC(CALLBACK(radio_connection, /datum/radio_frequency.proc/post_signal, src, signal, RADIO_MAGNETS))

		if(speed == 10)
			sleep(1)
		else
			sleep(12-speed)

	looping = 0


/obj/machinery/magnetic_controller/proc/filter_path()
	// Generates the rpath variable using the path string, think of this as "string2list"
	// Doesn't use params2list() because of the akward way it stacks entities
	rpath = list() //  clear rpath
	var/maximum_character = min( 50, length(path) ) // chooses the maximum length of the iterator. 50 max length

	for(var/i=1, i<=maximum_character, i++) // iterates through all characters in path

		var/nextchar = copytext(path, i, i+1) // find next character

		if(!(nextchar in list(";", "&", "*", " "))) // if char is a separator, ignore
			rpath += copytext(path, i, i+1) // else, add to list

		// there doesn't HAVE to be separators but it makes paths syntatically visible

#undef MAX_ELECTRICITY_LEVEL
#undef MAX_MAGNETIC_LEVEL
#undef MAX_DIST
