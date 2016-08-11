// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/modular_computer
	name = "Modular Microcomputer"
	desc = "A small portable microcomputer."

	var/enabled = 0											// Whether the computer is turned on.
	var/screen_on = 1										// Whether the computer is active/opened/it's screen is on.
	var/datum/computer_file/program/active_program = null	// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons
	var/computer_emagged = 0								// Whether the computer is emagged.

	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	var/icon_state_unpowered = null							// Icon state when the computer is turned off
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/max_hardware_size = 0								// Maximal hardware size. Currently, tablets have 1, laptops 2 and consoles 3. Limits what hardware types can be installed.
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.

	// Damage of the chassis. If the chassis takes too much damage it will break apart.
	var/damage = 0				// Current damage level
	var/broken_damage = 50		// Damage level at which the computer ceases to operate
	var/max_damage = 100		// Damage level at which the computer breaks apart.

	// Important hardware (must be installed for computer to work)
	var/obj/item/weapon/computer_hardware/processor_unit/processor_unit				// CPU. Without it the computer won't run. Better CPUs can run more programs at once.
	var/obj/item/weapon/computer_hardware/network_card/network_card					// Network Card component of this computer. Allows connection to NTNet
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive						// Hard Drive component of this computer. Stores programs and files.
	var/obj/item/weapon/computer_hardware/battery_module/battery_module				// An internal power source for this computer. Can be recharged.
	// Optional hardware (improves functionality, but is not critical for computer to work)
	var/obj/item/weapon/computer_hardware/card_slot/card_slot						// ID Card slot component of this computer. Mostly for HoP modification console that needs ID slot for modification.
	var/obj/item/weapon/computer_hardware/card_slot/card_slot2						// second slot. popular demand requested the hop need to insert 2 ids.
	var/obj/item/weapon/computer_hardware/nano_printer/nano_printer					// Nano Printer component of this computer, for your everyday paperwork needs.
	var/obj/item/weapon/computer_hardware/hard_drive/portable/portable_drive		// Portable data storage

	var/list/idle_threads = list()							// Idle programs on background. They still receive process calls but can't be interacted with.
	var/obj/physical = null



// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_id()
	set name = "Eject ID"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(!Adjacent(usr))
		usr << "<span class='warning'>You can't reach it.</span>"
		return

	proc_eject_id(usr)

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_usb()
	set name = "Eject Portable Device"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || !istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(!Adjacent(usr))
		usr << "<span class='warning'>You can't reach it.</span>"
		return

	proc_eject_usb(usr)

/obj/item/modular_computer/proc/proc_eject_id(mob/user, slot)
	if(!user)
		user = usr

	if(!card_slot)
		user << "\The [src] does not have an ID card slot"
		return

	if(!card_slot.stored_card && !card_slot.stored_card2)
		user << "There is no card in \the [src]"
		return

	if(active_program)
		active_program.event_idremoved(0, slot)

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		P.event_idremoved(1, slot)
	if(card_slot.stored_card && (!slot || slot == 1))
		card_slot.stored_card.forceMove(get_turf(src))
		card_slot.stored_card = null
	if(card_slot.stored_card2 && (!slot || slot == 2))
		card_slot.stored_card2.forceMove(get_turf(src))
		card_slot.stored_card2 = null
	user << "You remove the card[card_slot.stored_card && card_slot.stored_card2 && !slot ? "s" : ""] from \the [src]"

/obj/item/modular_computer/proc/proc_eject_usb(mob/user)
	if(!user)
		user = usr

	if(!portable_drive)
		user << "There is no portable device connected to \the [src]."
		return

	uninstall_component(user, portable_drive)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	if(enabled)
		ui_interact(user)
	else if(check_rights_for(user.client, R_ADMIN))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/emag_act(mob/user)
	if(computer_emagged)
		user << "\The [src] was already emagged."
		return 0
	else
		computer_emagged = 1
		user << "You emag \the [src]. It's screen briefly shows a \"OVERRIDE ACCEPTED: New software downloads available.\" message."
		return 1

/obj/item/modular_computer/examine(mob/user)
	..()
	if(damage > broken_damage)
		user << "<span class='danger'>It is heavily damaged!</span>"
	else if(damage)
		user << "It is damaged."

/obj/item/modular_computer/New()
	START_PROCESSING(SSmachine, src)
	update_icon()
	if(!physical)
		physical = src
	..()

/obj/item/modular_computer/Destroy()
	kill_program(1)
	STOP_PROCESSING(SSmachine, src)
	for(var/H in get_all_components())
		var/obj/item/weapon/computer_hardware/CH = H
		uninstall_component(null, CH)
		qdel(CH)
	return ..()

/obj/item/modular_computer/update_icon()
	icon_state = icon_state_unpowered
	cut_overlays()
	if(!enabled)
		return
	if(active_program)
		add_overlay(active_program.program_icon_state ? active_program.program_icon_state : icon_state_menu)
	else
		add_overlay(icon_state_menu)

// Used by child types if they have other power source than battery
/obj/item/modular_computer/proc/check_power_override()
	return 0

// Operates NanoUI
/obj/item/modular_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)


	if(!screen_on || !enabled)
		if(ui)
			ui.close()
		return 0
	if((!battery_module || !battery_module.battery.charge) && !check_power_override())
		if(ui)
			ui.close()
		return 0

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.ui_interact(user)
		return

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		physical.visible_message("\The [src] beeps three times, it's screen displaying \"DISK ERROR\" warning.")
		return // No HDD, No HDD files list or no stored files. Something is very broken.

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)

		ui = new(user, src, ui_key, "computer_main", "NTOS Main menu", 400, 500, master_ui, state)
		ui.open()
		ui.set_autoupdate(state = 1)


/obj/item/modular_computer/ui_data(mob/user)

	var/list/data = get_header_data()
	data["programs"] = list()
	for(var/datum/computer_file/program/P in hard_drive.stored_files)
		var/running = 0
		if(P in idle_threads)
			running = 1

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = running))

	return data


// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/attack_self(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

/obj/item/modular_computer/proc/break_apart()
	physical.visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/sheet/metal(newloc, round(steel_sheet_cost/2))
	for(var/C in get_all_components())
		var/obj/item/weapon/computer_hardware/H = C
		uninstall_component(null, H)
		H.forceMove(newloc)
		if(prob(25))
			H.take_damage(rand(10,30))
	relay_qdel()
	qdel()

/obj/item/modular_computer/proc/turn_on(mob/user)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(damage > broken_damage)
		if(issynth)
			user << "You send an activation signal to \the [src], but it responds with an error code. It must be damaged."
		else
			user << "You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."
		return
	if(processor_unit && ((battery_module && battery_module.battery.charge && battery_module.check_functionality()) || check_power_override())) // Battery-run and charged or non-battery but powered by APC.
		if(issynth)
			user << "You send an activation signal to \the [src], turning it on"
		else
			user << "You press the power button and start up \the [src]"
		enabled = 1
		update_icon()
		ui_interact(user)
	else // Unpowered
		if(issynth)
			user << "You send an activation signal to \the [src] but it does not respond"
		else
			user << "You press the power button but \the [src] does not respond"

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process()
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0

	if(damage > broken_damage)
		shutdown_computer()
		return 0

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature)) // Active program requires NTNet to run but we've just lost connection. Crash.
		active_program.event_networkfailure(0)

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)

	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick()
			active_program.ntnet_status = get_ntnet_status()
			active_program.computer_emagged = computer_emagged
		else
			active_program = null

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.process_tick()
			P.ntnet_status = get_ntnet_status()
			P.computer_emagged = computer_emagged
		else
			idle_threads.Remove(P)

	handle_power() // Handles all computer power interaction
	//check_update_ui_need()

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	if(battery_module)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_module.battery.percent())] %"
		data["PC_showbatteryicon"] = 1
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = battery_module ? 1 : 0

	switch(get_ntnet_status())
		if(0)
			data["PC_ntneticon"] = "sig_none.gif"
		if(1)
			data["PC_ntneticon"] = "sig_low.gif"
		if(2)
			data["PC_ntneticon"] = "sig_high.gif"
		if(3)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(idle_threads.len)
		var/list/program_headers = list()
		for(var/I in idle_threads)
			var/datum/computer_file/program/P = I
			if(!P.ui_header)
				continue
			program_headers.Add(list(list(
				"icon" = P.ui_header
			)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = worldtime2text()
	data["PC_hasheader"] = 1
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(forced = 0)
	if(active_program)
		active_program.kill_program(forced)
		active_program = null
	var/mob/user = usr
	if(user && istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
	update_icon()

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(specific_action = 0)
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return 0
	return ntnet_global.add_log(text, network_card)

/obj/item/modular_computer/proc/shutdown_computer(loud = 1)
	kill_program(1)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(1)
		idle_threads.Remove(P)
	if(loud)
		physical.visible_message("\The [src] shuts down.")
	enabled = 0
	update_icon()
	return

// Handles user's GUI input
/obj/item/modular_computer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("PC_exit")
			kill_program()
			return 1
		if("PC_shutdown")
			shutdown_computer()
			return 1
		if("PC_minimize")
			var/mob/user = usr
			if(!active_program || !processor_unit)
				return

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs

			active_program = null
			update_icon()
			if(user && istype(user))
				ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!istype(P) || P.program_state == PROGRAM_STATE_KILLED)
				return

			P.kill_program(1)
			user << "<span class='notice'>Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed.</span>"

		if("PC_runprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!P || !istype(P)) // Program not found or it's not executable program.
				user << "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>"
				return

			P.computer = src

			if(!P.is_supported_by_hardware(hardware_flag, 1, user))
				return

			// The program is already running. Resume it.
			if(P in idle_threads)
				P.program_state = PROGRAM_STATE_ACTIVE
				active_program = P
				idle_threads.Remove(P)
				update_icon()
				return

			if(idle_threads.len >= processor_unit.max_idle_programs+1)
				user << "<span class='notice'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error</span>"
				return

			if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
				user << "<span class='danger'>\The [src]'s screen shows \"NETWORK ERROR - Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>"
				return
			P.computer_emagged = computer_emagged
			if(P.run_program(user))
				active_program = P
				update_icon()
			return 1
		else
			return

// Used in following function to reduce copypaste
/obj/item/modular_computer/proc/power_failure(malfunction = 0)
	if(enabled) // Shut down the computer
		physical.visible_message("<span class='danger'>\The [src]'s screen flickers \"BATTERY [malfunction ? "MALFUNCTION" : "CRITICAL"]\" warning as it shuts down unexpectedly.</span>")
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/I in idle_threads)
			var/datum/computer_file/program/PRG = I
			PRG.event_powerfailure(1)
		shutdown_computer(0)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power()
	if(!battery_module || battery_module.battery.charge <= 0) // Battery-run but battery is depleted.
		power_failure()
		return 0

	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage

	for(var/obj/item/weapon/computer_hardware/H in get_all_components())
		if(H.enabled)
			power_usage += H.power_usage

	if(battery_module)
		if(!battery_module.check_functionality())
			power_failure(1)
			return
		if(!battery_module.battery.use(power_usage * CELLRATE))
			battery_module.battery.charge = 0
			power_failure()
			return 0

	last_power_usage = power_usage

/obj/item/modular_computer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id)) // ID Card, try to insert it.
		var/obj/item/weapon/card/id/I = W
		if(!card_slot)
			user << "You try to insert \the [I] into \the [src], but it does not have an ID card slot installed."
			return

		if(card_slot.stored_card && card_slot.stored_card2)
			user << "You try to insert \the [I] into \the [src], but it's ID card slots are occupied."
			return
		if(!user.drop_item(I))
			return
		if(!card_slot.stored_card)
			card_slot.stored_card = I
		else
			card_slot.stored_card2 = I
		I.forceMove(src)
//		update_uis()
		user << "You insert \the [I] into \the [src]."
		return
	if(istype(W, /obj/item/weapon/paper))
		if(!nano_printer)
			return
		nano_printer.attackby(W, user)
	if(istype(W, /obj/item/weapon/computer_hardware))
		var/obj/item/weapon/computer_hardware/C = W
		if(C.hardware_size <= max_hardware_size)
			try_install_component(user, C)
		else
			user << "This component is too large for \the [src]."
	if(istype(W, /obj/item/weapon/wrench))
		var/list/components = get_all_components()
		if(components.len)
			user << "Remove all components from \the [src] before disassembling it."
			return
		new /obj/item/stack/sheet/metal( get_turf(src.loc), steel_sheet_cost )
		physical.visible_message("\The [src] has been disassembled by [user].")
		relay_qdel()
		qdel(src)
		return
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			user << "\The [W] is off."
			return

		if(!damage)
			user << "\The [src] does not require repairs."
			return

		user << "You begin repairing damage to \the [src]..."
		if(WT.remove_fuel(round(damage/75)) && do_after(usr, damage/10))
			damage = 0
			user << "You repair \the [src]."
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		var/list/all_components = get_all_components()
		if(!all_components.len)
			user << "This device doesn't have any components installed."
			return
		var/list/component_names = list()
		for(var/obj/item/weapon/computer_hardware/H in all_components)
			component_names.Add(H.name)

		var/choice = input(usr, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in component_names

		if(!choice)
			return

		if(!Adjacent(usr))
			return

		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(choice)

		if(!H)
			return

		uninstall_component(user, H)

		return

	..()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Attempts to install the hardware into apropriate slot.
/obj/item/modular_computer/proc/try_install_component(mob/living/user, obj/item/weapon/computer_hardware/H, found = 0)
	// "USB" flash drive.
	if(istype(H, /obj/item/weapon/computer_hardware/hard_drive/portable))
		if(portable_drive)
			user << "This computer's portable drive slot is already occupied by \the [portable_drive]."
			return
		found = 1
		portable_drive = H
	else if(istype(H, /obj/item/weapon/computer_hardware/hard_drive))
		if(hard_drive)
			user << "This computer's hard drive slot is already occupied by \the [hard_drive]."
			return
		found = 1
		hard_drive = H
	else if(istype(H, /obj/item/weapon/computer_hardware/network_card))
		if(network_card)
			user << "This computer's network card slot is already occupied by \the [network_card]."
			return
		found = 1
		network_card = H
	else if(istype(H, /obj/item/weapon/computer_hardware/nano_printer))
		if(nano_printer)
			user << "This computer's nano printer slot is already occupied by \the [nano_printer]."
			return
		found = 1
		nano_printer = H
	else if(istype(H, /obj/item/weapon/computer_hardware/card_slot))
		if(card_slot)
			user << "This computer's card slot is already occupied by \the [card_slot]."
			return
		found = 1
		card_slot = H
	else if(istype(H, /obj/item/weapon/computer_hardware/battery_module))
		if(battery_module)
			user << "This computer's battery slot is already occupied by \the [battery_module]."
			return
		found = 1
		battery_module = H
	else if(istype(H, /obj/item/weapon/computer_hardware/processor_unit))
		if(processor_unit)
			user << "This computer's processor slot is already occupied by \the [processor_unit]."
			return
		found = 1
		processor_unit = H
	if(found)
		user << "You install \the [H] into \the [src]"
		H.holder2 = src
		if(!user.drop_item(H))
			return
		H.forceMove(src)

// Uninstalls component. Found and Critical vars may be passed by parent types, if they have additional hardware.
/obj/item/modular_computer/proc/uninstall_component(mob/living/user, obj/item/weapon/computer_hardware/H, found = 0, critical = 0)
	if(portable_drive == H)
		portable_drive = null
		found = 1
	if(hard_drive == H)
		hard_drive = null
		found = 1
		critical = 1
	if(network_card == H)
		network_card = null
		found = 1
	if(nano_printer == H)
		nano_printer = null
		found = 1
	if(card_slot == H)
		card_slot = null
		found = 1
	if(battery_module == H)
		battery_module = null
		found = 1
	if(processor_unit == H)
		processor_unit = null
		found = 1
		critical = 1
	if(found)
		if(user)
			user << "You remove \the [H] from \the [src]."
		H.forceMove(get_turf(src))
		H.holder2 = null
	if(critical && enabled)
		if(user)
			user << "<span class='danger'>\The [src]'s screen freezes for few seconds and then displays an \"HARDWARE ERROR: Critical component disconnected. Please verify component connection and reboot the device. If the problem persists contact technical support for assistance.\" warning.</span>"
		shutdown_computer()
		update_icon()


// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/modular_computer/proc/find_hardware_by_name(name)
	if(portable_drive && (portable_drive.name == name))
		return portable_drive
	if(hard_drive && (hard_drive.name == name))
		return hard_drive
	if(network_card && (network_card.name == name))
		return network_card
	if(nano_printer && (nano_printer.name == name))
		return nano_printer
	if(card_slot && (card_slot.name == name))
		return card_slot
	if(battery_module && (battery_module.name == name))
		return battery_module
	if(processor_unit && (processor_unit.name == name))
		return processor_unit
	return null

// Returns list of all components
/obj/item/modular_computer/proc/get_all_components()
	var/list/all_components = list()
	if(hard_drive)
		all_components.Add(hard_drive)
	if(network_card)
		all_components.Add(network_card)
	if(portable_drive)
		all_components.Add(portable_drive)
	if(nano_printer)
		all_components.Add(nano_printer)
	if(card_slot)
		all_components.Add(card_slot)
	if(battery_module)
		all_components.Add(battery_module)
	if(processor_unit)
		all_components.Add(processor_unit)
	return all_components

/obj/item/modular_computer/proc/take_damage(amount, component_probability, damage_casing = 1, randomize = 1)
	if(randomize)
		// 75%-125%, rand() works with integers, apparently.
		amount *= (rand(75, 125) / 100.0)
	amount = round(amount)
	if(damage_casing)
		damage += amount
		damage = max(0,min(max_damage,damage))

	if(component_probability)
		for(var/I in get_all_components())
			var/obj/item/weapon/computer_hardware/H = I
			if(prob(component_probability))
				H.take_damage(round(amount / 2))

	if(damage >= max_damage)
		break_apart()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/item/modular_computer/ex_act(severity)
	take_damage(rand(100,200) / severity, 30 / severity)

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/item/modular_computer/emp_act(severity)
	take_damage(rand(100,200) / severity, 50 / severity, 0)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/item/modular_computer/bullet_act(obj/item/projectile/Proj)
	switch(Proj.damage_type)
		if(BRUTE)
			take_damage(Proj.damage, Proj.damage / 2)
		if(BURN)
			take_damage(Proj.damage, Proj.damage / 1.5)

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	else
		return src