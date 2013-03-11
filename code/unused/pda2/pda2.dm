//The advanced pea-green monochrome lcd of tomorrow.


//TO-DO: rearrange all this disk/data stuff so that fixed disks are the parent type
//because otherwise you have carts going into floppy drives and it's ALL MAD
/obj/item/weapon/disk/data/cartridge
	name = "Cart 2.0"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	file_amount = 80.0
	title = "ROM Cart"

	pda2test
		name = "Test Cart"
		New()
			..()
			src.root.add_file( new /datum/computer/file/computer_program/arcade(src))
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.read_only = 1


/obj/item/device/pda2
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by an EEPROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | ONBELT

	var/owner = null
	var/default_cartridge = null // Access level defined by cartridge
	var/obj/item/weapon/disk/data/cartridge/cartridge = null //current cartridge
	var/datum/computer/file/pda_program/active_program = null
	var/datum/computer/file/pda_program/os/host_program = null
	var/datum/computer/file/pda_program/scan/scan_program = null
	var/obj/item/weapon/disk/data/fixed_disk/hd = null
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
//	var/datum/data/record/active1 = null //General
//	var/datum/data/record/active2 = null //Medical
//	var/datum/data/record/active3 = null //Security
//	var/obj/item/weapon/integrated_uplink/uplink = null //Maybe replace uplink with some remote ~syndicate~ server
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

	var/setup_default_cartridge = null //Cartridge contains job-specific programs
	var/setup_drive_size = 24.0 //PDAs don't have much work room at all, really.
	var/setup_system_os_path = /datum/computer/file/pda_program/os/main_os //Needs an operating system to...operate!!


/obj/item/device/pda2/pickup(mob/user)
	if (src.fon)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + src.f_lum)

/obj/item/device/pda2/dropped(mob/user)
	if (src.fon)
		user.sd_SetLuminosity(user.luminosity - src.f_lum)
		src.sd_SetLuminosity(src.f_lum)

/obj/item/device/pda2/New()
	..()
	spawn(5)
		src.hd = new /obj/item/weapon/disk/data/fixed_disk(src)
		src.hd.file_amount = src.setup_drive_size
		src.hd.name = "Minidrive"
		src.hd.title = "Minidrive"

		if(src.setup_system_os_path)
			src.host_program = new src.setup_system_os_path

			src.hd.file_amount = max(src.hd.file_amount, src.host_program.size)

			src.host_program.transfer_holder(src.hd)

		if(radio_controller)
			radio_controller.add_object(src, frequency)


	if (src.default_cartridge)
		src.cartridge = new src.setup_default_cartridge(src)
//	if(src.owner)
//		processing_items.Add(src)

/obj/item/device/pda2/attack_self(mob/user as mob)
	user.machine = src

	var/dat = "<html><head><title>Personal Data Assistant</title></head><body>"

	dat += "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	if (!src.owner)
		if(src.cartridge)
			dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [src.cartridge]</a>"
		dat += "<br>Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=\ref[src];refresh=1'>Retry</a>"
	else
		if(src.active_program)
			dat += src.active_program.return_text()
		else
			if(src.host_program)
				src.run_program(src.host_program)
				dat += src.active_program.return_text()
			else
				if(src.cartridge)
					dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [src.cartridge]</a><br>"
				dat += "<center><font color=red>Fatal Error 0x17<br>"
				dat += "No System Software Loaded</font></center>"
					//To-do: System recovery shit (maybe have a dedicated computer for this kind of thing)


	user << browse(dat,"window=pda2")
	onclose(user,"pda2")
	return

/obj/item/device/pda2/Topic(href, href_list)
	..()

	if (usr.contents.Find(src) || usr.contents.Find(src.master) || (istype(src.loc, /turf) && get_dist(src, usr) <= 1))
		if (usr.stat || usr.restrained())
			return

		src.add_fingerprint(usr)
		usr.machine = src


		if(href_list["return_to_host"])
			if(src.host_program)
				src.active_program = src.host_program
				src.host_program = null

		else if (href_list["eject_cart"])
			src.eject_cartridge()

		else if (href_list["refresh"])
			src.updateSelfDialog()

		else if (href_list["close"])
			usr << browse(null, "window=pda2")
			usr.machine = null

		src.updateSelfDialog()
		return

/obj/item/device/pda2/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if (istype(C, /obj/item/weapon/disk/data/cartridge) && isnull(src.cartridge))
		user.drop_item()
		C.loc = src
		user << "\blue You insert [C] into [src]."
		src.cartridge = C
		src.updateSelfDialog()

	else if (istype(C, /obj/item/weapon/card/id) && !src.owner && C:registered_name)
		src.owner = C:registered_name
		src.name = "PDA-[src.owner]"
		user << "\blue Card scanned."
		src.updateSelfDialog()

/obj/item/device/pda2/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption || !src.owner) return

	if(signal.data["tag"] && signal.data["tag"] != "\ref[src]") return

	if(src.host_program)
		src.host_program.receive_signal(signal)

	if(src.active_program && (src.active_program != src.host_program))
		src.host_program.receive_signal(signal)

	return

/obj/item/device/pda2/attack(mob/M as mob, mob/user as mob)
	if(src.scan_program)
		return
	else
		..()

/obj/item/device/pda2/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	var/scan_dat = null
	if(src.scan_program && istype(src.scan_program))
		scan_dat = src.scan_program.scan_atom(A)

	if(scan_dat)
		A.visible_message("\red [user] has scanned [A]!")
		user.show_message(scan_dat, 1)

	return


/obj/item/device/pda2/proc

	post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src

		var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

		signal.transmission_method = TRANSMISSION_RADIO
		if(frequency)
			return frequency.post_signal(src, signal)
		else
			del(signal)

	eject_cartridge()
		if(src.cartridge)
			var/turf/T = get_turf(src)

			if(src.active_program && (src.active_program.holder == src.cartridge))
				src.active_program = null

			if(src.host_program && (src.host_program.holder == src.cartridge))
				src.host_program = null

			if(src.scan_program && (src.scan_program.holder == src.cartridge))
				src.scan_program = null

			src.cartridge.loc = T
			src.cartridge = null

		return

	//Toggle the built-in flashlight
	toggle_light()
		src.fon = (!src.fon)

		if (ismob(src.loc))
			if (src.fon)
				src.loc.sd_SetLuminosity(src.loc.luminosity + src.f_lum)
			else
				src.loc.sd_SetLuminosity(src.loc.luminosity - src.f_lum)
		else
			src.sd_SetLuminosity(src.fon * src.f_lum)

		src.updateSelfDialog()

	display_alert(var/alert_message) //Add alert overlay and beep
		if (alert_message)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
			for (var/mob/O in hearers(3, src.loc))
				O.show_message(text("\icon[src] *[alert_message]*"))

		src.overlays.Cut()
		src.overlays += image('icons/obj/pda.dmi', "pda-r")
		return

	run_program(datum/computer/file/pda_program/program)
		if((!program) || (!program.holder))
			return 0

		if(!(program.holder in src))
	//		world << "Not in src"
			program = new program.type
			program.transfer_holder(src.hd)

		if(program.master != src)
			program.master = src

		if(!src.host_program && istype(program, /datum/computer/file/pda_program/os))
			src.host_program = program

		if(istype(program, /datum/computer/file/pda_program/scan))
			if(program == src.scan_program)
				src.scan_program = null
			else
				src.scan_program = program
			return 1

		src.active_program = program
		return 1

	delete_file(datum/computer/file/file)
		//world << "Deleting [file]..."
		if((!file) || (!file.holder) || (file.holder.read_only))
			//world << "Cannot delete :("
			return 0

		//Don't delete the running program you jerk
		if(src.active_program == file || src.host_program == file)
			src.active_program = null

		//world << "Now calling del on [file]..."
		del(file)
		return 1