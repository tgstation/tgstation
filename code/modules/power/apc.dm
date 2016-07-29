<<<<<<< HEAD
=======
#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128

<<<<<<< HEAD
#define APC_RESET_EMP "emp"

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096
#define APC_UPOVERLAY_OPERATING 8192

<<<<<<< HEAD

#define APC_UPDATE_ICON_COOLDOWN 200 // 20 seconds
=======
#define APC_UPDATE_ICON_COOLDOWN 100 // 10 seconds

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
<<<<<<< HEAD
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."

=======
	desc = "A control terminal for the area electrical systems."
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon_state = "apc0"
	anchored = 1
	use_power = 0
	req_access = list(access_engine_equip)
<<<<<<< HEAD
	var/area/area
	var/areastring = null
	var/obj/item/weapon/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
=======
	var/spooky=0
	var/obj/item/weapon/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0                      //0=closed, 1=opened, 2=cover removed
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
	var/obj/machinery/power/terminal/terminal = null
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
<<<<<<< HEAD
=======
	var/wiresexposed = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
<<<<<<< HEAD
	var/mob/living/silicon/ai/occupier = null
	var/longtermpower = 10
	var/auto_name = 0
=======
	var/mob/living/silicon/ai/occupant = null
	var/longtermpower = 10
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = 0
	var/updating_icon = 0
<<<<<<< HEAD
=======
	var/datum/wires/apc/wires = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
<<<<<<< HEAD
	var/health = 50

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(!terminal)
		make_terminal()
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=0)
	..()
	apcs_list += src

	wires = new /datum/wires/apc(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		setDir(ndir)
	src.tdir = dir		// to fix Vars bug
	setDir(SOUTH)

	if(auto_name)
		name = "\improper [get_area(src)] APC"

	pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
	pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
	if (building==0)
		init()
	else
		area = src.loc.loc:master
		opened = 1
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		src.update_icon()
		spawn(5)
			src.update()

/obj/machinery/power/apc/Destroy()
	apcs_list -= src

	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	if(occupier)
		malfvacate(1)
	qdel(wires)
	wires = null
	if(cell)
		qdel(cell)
	if(terminal)
		disconnect_terminal()
	. = ..()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.setDir(tdir)
	terminal.master = src
=======

	var/is_critical = 0 // Endgame scenarios will not destroy this APC.

	var/make_alerts = TRUE // Should this APC make power alerts to the area?

	machine_flags = WIREJACK
	holomap = TRUE
	auto_holomap = TRUE

/obj/machinery/power/apc/no_alerts
	make_alerts = FALSE

// Frame only.
/obj/machinery/power/apc/frame
	icon_state = "apcmaint"

/obj/machinery/power/apc/frame/New()
	return ..(loc, dir, 1)

/obj/machinery/power/apc/New(loc, var/ndir, var/building=0)
	..(loc)
	wires = new(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	src.tdir = dir		// to fix Vars bug
	dir = SOUTH

	if(areaMaster.areaapc)
		world.log << "Secondary APC detected in area: [areaMaster.name], deleting the second APC"
		qdel(src)
		return
	areaMaster.set_apc(src)

	if(src.tdir & 3)
		pixel_x = 0
		pixel_y = (src.tdir == 1 ? 24 : -24)
	else
		pixel_x = (src.tdir == 4 ? 24 : -24)
		pixel_y = 0

	if (building==0)
		init()
	else
		opened = 1
		operating = 0
		stat |= MAINT

	if(ticker)
		initialize()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
<<<<<<< HEAD
		src.cell = new/obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = src.loc.loc

	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
	else
		src.area = get_area_by_name(areastring)
	update_icon()

	make_terminal()

	spawn(5)
		src.update()
=======
		src.cell = new/obj/item/weapon/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	finalise_terminal() //creates the terminal itself

/obj/machinery/power/apc/finalise_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal {auto_holomap = 0} (src.loc)
	terminal.dir = tdir
	terminal.master = src
	var/turf/T = loc
	if (istype(T))
		T.soft_add_holomap(terminal)

/obj/machinery/power/apc/initialize()
	..()

	name = "[areaMaster.name] APC"

	update_icon()

	spawn(5)
		update()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(stat & BROKEN)
<<<<<<< HEAD
		user << "Looks broken."
		return
	if(opened)
		if(has_electronics && terminal)
			user << "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
		else
			user << "It's [!terminal?" not":""]wired up."
			user << "The electronics are[!has_electronics?"n't":""] installed."

	else
		if (stat & MAINT)
			user << "The cover is closed. Something is wrong with it. It doesn't work."
		else if (malfhack)
			user << "The cover is broken. It may be hard to force it open."
		else
			user << "The cover is closed."


// update the APC icon to show the three base states
// also add overlays for indicator lights
=======
		to_chat(user, "Looks broken.")
		return
	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].")
		else if (!has_electronics && terminal)
			to_chat(user, "There are some wires but no any electronics.")
		else if (has_electronics && !terminal)
			to_chat(user, "Electronics installed but not wired.")
		else /* if (!has_electronics && !terminal) */
			to_chat(user, "There is no electronics nor connected wires.")
	else
		if (stat & MAINT)
			to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
		else if (malfhack)
			to_chat(user, "The cover is broken. It may be hard to force it open.")
		else
			to_chat(user, "The cover is closed.")

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/machinery/power/apc/update_icon()
	if (!status_overlays)
		status_overlays = 1
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

<<<<<<< HEAD
		status_overlays_equipment[1] = image(icon, "apco0-0")
=======
		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")

<<<<<<< HEAD
=======


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update)
		return

	if(update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
<<<<<<< HEAD
				if (update_state & UPSTATE_BROKE || malfhack)
					icon_state = "[basestate]-b-nocover"
				else
					icon_state = "[basestate]-nocover"
=======
				icon_state = "[basestate]-nocover"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"

<<<<<<< HEAD
	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			overlays = 0

	if(update & 2)
		if(overlays.len)
			overlays.len = 0
		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			add_overlay(status_overlays_lock[locked+1])
			add_overlay(status_overlays_charging[charging+1])
			if(operating)
				add_overlay(status_overlays_equipment[equipment+1])
				add_overlay(status_overlays_lighting[lighting+1])
				add_overlay(status_overlays_environ[environ+1])
=======


	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			overlays = 0
			return
	if(update & 2)

		if(overlays.len)
			overlays = 0

		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			overlays += status_overlays_lock[locked+1]
			overlays += status_overlays_charging[charging+1]
			if(operating)
				overlays += status_overlays_equipment[equipment+1]
				overlays += status_overlays_lighting[lighting+1]
				overlays += status_overlays_environ[environ+1]
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


/obj/machinery/power/apc/proc/check_updates()

<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(opened)
		if(opened==1)
			update_state |= UPSTATE_OPENED1
		if(opened==2)
			update_state |= UPSTATE_OPENED2
<<<<<<< HEAD
	else if(emagged || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
=======
	else if(emagged || malfai || spooky)
		update_state |= UPSTATE_BLUESCREEN
	else if(wiresexposed)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == 1)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == 2)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

<<<<<<< HEAD

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
<<<<<<< HEAD
	if(last_update_overlay != update_overlay)
		results += 2
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()

=======
	if(last_update_overlay != update_overlay && update_overlay != 0)
		results += 2
	return results




// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!updating_icon)
		updating_icon = 1
		// Start the update
		spawn(APC_UPDATE_ICON_COOLDOWN)
			update_icon()
			updating_icon = 0

<<<<<<< HEAD
//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar) && opened)
		if (has_electronics==1)
			if (terminal)
				user << "<span class='warning'>Disconnect the wires first!</span>"
				return
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			user << "<span class='notice'>You are trying to remove the power control board...</span>" //lpeters - fixed grammar issues
			if(do_after(user, 50/W.toolspeed, target = src))
				if (has_electronics==1)
					has_electronics = 0
					if ((stat & BROKEN) || malfhack)
						user.visible_message(\
							"[user.name] has broken the power control board inside [src.name]!",\
							"<span class='notice'>You break the charred power control board and remove the remains.</span>",
							"<span class='italics'>You hear a crack.</span>")
						//ticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [src.name]!",\
							"<span class='notice'>You remove the power control board.</span>")
						new /obj/item/weapon/electronics/apc(loc)
		else if (opened!=2) //cover isn't removed
			opened = 0
			update_icon()
	else if (istype(W, /obj/item/weapon/crowbar) && !((stat & BROKEN) || malfhack) )
		if(coverlocked && !(stat & MAINT))
			user << "<span class='warning'>The cover is locked and cannot be opened!</span>"
=======
/obj/machinery/power/apc/spook()
	if(spooky) return // Fuck you we're already spooky
	if(!..()) return //If blessed, return

	spooky=1
	update_icon()
	spawn(10)
		spooky=0
		update_icon()

//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/W, mob/user)
	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	src.add_fingerprint(user)
	if (iscrowbar(W) && opened)
		if (has_electronics==1)
			if (terminal)
				to_chat(user, "<span class='warning'>Disconnect wires first.</span>")
				return
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(user, "You are trying to remove the power control board...")//lpeters - fixed grammar issues

			if (do_after(user, src, 50) && opened && !terminal && has_electronics == 1)
				has_electronics = 0
				if ((stat & BROKEN) || malfhack)
					user.visible_message(\
						"<span class='warning'>[user.name] has broken the power control board inside [src.name]!</span>",\
						"You broke the charred power control board and remove the remains.",
						"You hear a crack!")
					//ticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
				else
					user.visible_message(\
						"<span class='warning'>[user.name] has removed the power control board from [src.name]!</span>",\
						"You remove the power control board.")
					new /obj/item/weapon/circuitboard/power_control(loc)
		else if (opened!=2) //cover isn't removed
			opened = 0
			update_icon()
	else if (iscrowbar(W) && !((stat & BROKEN) || malfhack) )
		if(coverlocked && !(stat & MAINT))
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			return
		else
			opened = 1
			update_icon()
<<<<<<< HEAD
	else if	(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		if(cell)
			user << "<span class='warning'>There is a power cell already installed!</span>"
			return
		else
			if (stat & MAINT)
				user << "<span class='warning'>There is no connector for your power cell!</span>"
				return
			if(!user.drop_item())
				return
			W.loc = src
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				"<span class='notice'>You insert the power cell.</span>")
			chargecount = 0
			update_icon()
	else if	(istype(W, /obj/item/weapon/screwdriver))	// haxing
		if(opened)
			if (cell)
				user << "<span class='warning'>Close the APC first!</span>" //Less hints more mystery!
=======
	else if	(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(cell)

			if(user.drop_item(W, src))
				to_chat(user, "You swap the power cell within with the new cell in your hand.")
				var/obj/item/weapon/oldpowercell = cell
				cell = W
				chargecount = 0
				update_icon()
				user.put_in_hands(oldpowercell)
				return

		else
			if (stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell.</span>")
				return
			if(user.drop_item(W, src))
				cell = W
				user.visible_message(\
					"<span class='warning'>[user.name] has inserted the power cell to [src.name]!</span>",\
					"You insert the power cell.")
				chargecount = 0
				update_icon()
	else if	(isscrewdriver(W))	// haxing
		if(opened)
			if (cell)
				to_chat(user, "<span class='warning'>Close the APC first.</span>")//Less hints more mystery!

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				return
			else
				if (has_electronics==1 && terminal)
					has_electronics = 2
					stat &= ~MAINT
<<<<<<< HEAD
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					user << "<span class='notice'>You screw the circuit electronics into place.</span>"
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					user << "<span class='notice'>You unfasten the electronics.</span>"
				else /* has_electronics==0 */
					user << "<span class='warning'>There is nothing to secure!</span>"
					return
				update_icon()
		else if(emagged)
			user << "<span class='warning'>The interface is broken!</span>"
		else
			panel_open = !panel_open
			user << "The wires have been [panel_open ? "exposed" : "unexposed"]"
			update_icon()

	else if (W.GetID())			// trying to unlock the interface with an ID card
		if(emagged)
			user << "<span class='warning'>The interface is broken!</span>"
		else if(opened)
			user << "<span class='warning'>You must close the cover to swipe an ID card!</span>"
		else if(panel_open)
			user << "<span class='warning'>You must close the panel!</span>"
		else if(stat & (BROKEN|MAINT))
			user << "<span class='warning'>Nothing happens!</span>"
		else
			if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the APC interface.</span>"
				update_icon()
			else
				user << "<span class='warning'>Access denied.</span>"
	else if (istype(W, /obj/item/stack/cable_coil) && !terminal && opened && has_electronics!=2)
		if (src.loc:intact)
			user << "<span class='warning'>You must remove the floor plating in front of the APC first!</span>"
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			user << "<span class='warning'>You need ten lengths of cable for APC!</span>"
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							"<span class='notice'>You start adding cables to the APC frame...</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics != 2)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N))
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					return
				C.use(10)
				user << "<span class='notice'>You add cables to the APC frame.</span>"
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/weapon/wirecutters) && terminal && opened && has_electronics!=2)
		terminal.dismantle(user)

	else if (istype(W, /obj/item/weapon/electronics/apc) && opened && has_electronics==0 && !((stat & BROKEN) || malfhack))
		user.visible_message("[user.name] inserts the power control board into [src].", \
							"<span class='notice'>You start to insert the power control board into the frame...</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(has_electronics==0)
				has_electronics = 1
				user << "<span class='notice'>You place the power control board inside the frame.</span>"
				qdel(W)
	else if (istype(W, /obj/item/weapon/electronics/apc) && opened && has_electronics==0 && ((stat & BROKEN) || malfhack))
		user << "<span class='warning'>You cannot put the board inside, the frame is damaged!</span>"
=======
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You screw the circuit electronics into place.")
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You unfasten the electronics.")
				else /* has_electronics==0 */
					to_chat(user, "<span class='warning'>There is nothing to secure.</span>")
					return
				update_icon()
		else if(emagged)
			to_chat(user, "The interface is broken.")
		else if(has_electronics == 2)
			wiresexposed = !wiresexposed
			to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
			update_icon()
		else
			to_chat(user, "<span class='warning'>You open the panel and find nothing inside.</span>")
			return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "The interface is broken.")
		else if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(src.allowed(usr) && !isWireCut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else if (istype(W, /obj/item/weapon/card/emag) && !(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel first")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			flick("apc-spark", src)
			if (do_after(user, src, 6) && !opened && !wiresexposed && !(stat & (BROKEN|MAINT)) && !emagged)
				if(prob(50))
					emagged = 1
					locked = 0
					to_chat(user, "You emag the APC interface.")
					update_icon()
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")
	else if (istype(W, /obj/item/stack/cable_coil) && !terminal && opened && has_electronics != 2)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return

		if(make_terminal(user))
			C.use(10)
			terminal.connect_to_network()

	else if (iswirecutter(W) && opened && terminal && has_electronics!=2)
		var/turf/T = get_turf(src)
		if (T.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first.</span>")
			return
		to_chat(user, "You begin to cut the cables...")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if (do_after(user, src, 50) && opened && terminal && has_electronics != 2 && !T.intact)
			if (prob(50) && electrocute_mob(usr, terminal.get_powernet(), terminal))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			getFromPool(/obj/item/stack/cable_coil, get_turf(user), 10)
			user.visible_message(\
				"<span class='warning'>[user.name] cut the cables and dismantled the power terminal.</span>",\
				"You cut the cables and dismantle the power terminal.")
			qdel(terminal)
			terminal = null
	else if (istype(W, /obj/item/weapon/circuitboard/power_control) && opened && has_electronics==0 && !((stat & BROKEN) || malfhack))
		to_chat(user, "You begin to insert the power control board into the frame...")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if (do_after(user, src, 10) && opened && has_electronics == 0 && !((stat & BROKEN) || malfhack))
			has_electronics = 1
			to_chat(user, "You place the power control board inside the frame.")
			qdel(W)
			W = null
	else if (istype(W, /obj/item/weapon/circuitboard/power_control) && opened && has_electronics==0 && ((stat & BROKEN) || malfhack))
		to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return
	else if (istype(W, /obj/item/weapon/weldingtool) && opened && has_electronics==0 && !terminal)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
<<<<<<< HEAD
			user << "<span class='warning'>You need more welding fuel to complete this task!</span>"
			return
		user.visible_message("[user.name] welds [src].", \
							"<span class='notice'>You start welding the APC frame...</span>", \
							"<span class='italics'>You hear welding.</span>")
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, 50/W.toolspeed, target = src))
			if(!src || !WT.remove_fuel(3, user)) return
			if (emagged || malfhack || (stat & BROKEN) || opened==2)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message(\
					"[user.name] has cut [src] apart with [W].",\
					"<span class='notice'>You disassembled the broken APC frame.</span>")
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(\
					"[user.name] has cut [src] from the wall with [W].",\
					"<span class='notice'>You cut the APC frame from the wall.</span>")
			qdel(src)
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened && emagged)
=======
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "You start welding the APC frame...")
		playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
		if (do_after(user, src, 50))
			if(!src || !WT.remove_fuel(3, user)) return
			if (emagged || malfhack || (stat & BROKEN) || opened==2)
				getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 1)
				user.visible_message(\
					"<span class='warning'>[src] has been cut apart by [user.name] with the weldingtool.</span>",\
					"You disassembled the broken APC frame.",\
					"<span class='warning'>You hear welding.</span>")
			else
				new /obj/item/mounted/frame/apc_frame(loc)
				user.visible_message(\
					"<span class='warning'>[src] has been cut from the wall by [user.name] with the weldingtool.</span>",\
					"You cut the APC frame from the wall.",\
					"<span class='warning'>You hear welding.</span>")
			qdel(src)
			return
	else if (istype(W, /obj/item/mounted/frame/apc_frame) && opened && emagged)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		emagged = 0
		if (opened==2)
			opened = 1
		user.visible_message(\
<<<<<<< HEAD
			"[user.name] has replaced the damaged APC frontal panel with a new one.",\
			"<span class='notice'>You replace the damaged APC frontal panel with a new one.</span>")
		qdel(W)
		update_icon()
	else if (istype(W, /obj/item/wallframe/apc) && opened && ((stat & BROKEN) || malfhack))
		if (has_electronics)
			user << "<span class='warning'>You cannot repair this APC until you remove the electronics still inside!</span>"
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							"<span class='notice'>You begin to replace the damaged APC frame...</span>")
		if(do_after(user, 50, target = src))
			user << "<span class='notice'>You replace the damaged APC frame with a new one.</span>"
			qdel(W)
=======
			"<span class='warning'>[user.name] has replaced the damaged APC frontal panel with a new one.</span>",\
			"You replace the damaged APC frontal panel with a new one.")
		qdel(W)
		W = null
		update_icon()
	else if (istype(W, /obj/item/mounted/frame/apc_frame) && opened && ((stat & BROKEN) || malfhack))
		if (has_electronics)
			to_chat(user, "You cannot repair this APC until you remove the electronics still inside.")
			return
		to_chat(user, "You begin to replace the damaged APC frame...")
		if(do_after(user, src, 50))
			user.visible_message(\
				"<span class='warning'>[user.name] has replaced the damaged APC frame with new one.</span>",\
				"You replace the damaged APC frame with new one.")
			qdel(W)
			W = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			stat &= ~BROKEN
			malfai = null
			malfhack = 0
			if (opened==2)
				opened = 1
			update_icon()
<<<<<<< HEAD

	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/power/apc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	..()
	if((malfhack || (stat & BROKEN)) && !opened)
		if(damage < 10)
			return
		health -= damage
		if(health <= 0)
			opened = 2
			visible_message("<span class='warning'>The APC cover is knocked down!</span>")
			update_icon()

/obj/machinery/power/apc/emag_act(mob/user)
	if(!emagged && !malfhack)
		if(opened)
			user << "<span class='warning'>You must close the cover to swipe an ID card!</span>"
		else if(panel_open)
			user << "<span class='warning'>You must close the panel first!</span>"
		else if(stat & (BROKEN|MAINT))
			user << "<span class='warning'>Nothing happens!</span>"
		else
			flick("apc-spark", src)
			emagged = 1
			locked = 0
			user << "<span class='notice'>You emag the APC interface.</span>"
			update_icon()
=======
	else
		// The extra crowbar thing fixes MoMMIs not being able to remove APCs.
		// They can just pop them off with a crowbar.
		if (	((stat & BROKEN) || malfhack) \
				&& !opened \
				&& ( \
					(W.force >= 5 && W.w_class >= W_CLASS_MEDIUM) \
					|| istype(W,/obj/item/weapon/crowbar) \
				) \
				&& prob(20) )
			opened = 2
			user.visible_message("<span class='warning'>The APC cover was knocked down with the [W.name] by [user.name]!</span>", \
				"<span class='warning'>You knock down the APC cover with your [W.name]!</span>", \
				"You hear bang")
			update_icon()
		else
			if (istype(user, /mob/living/silicon))
				return src.attack_hand(user)
			if (!opened && wiresexposed && \
				(istype(W, /obj/item/device/multitool) || \
				iswirecutter(W) || istype(W, /obj/item/device/assembly/signaler)))
				return src.attack_hand(user)
			/*user.visible_message("<span class='warning'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", \
				"<span class='warning'>You hit the [src.name] with your [W.name]!</span>", \
				"You hear bang")*/
			..() //Sanity
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
<<<<<<< HEAD
	if(!user)
		return
	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("[user.name] removes the power cell from [src.name]!",\
								 "<span class='notice'>You remove the power cell.</span>")
			//user << "You remove the power cell."
			charging = 0
			src.update_icon()
		return
	..()

/obj/machinery/power/apc/attack_alien(mob/living/carbon/alien/humanoid/user)
	..()
	if(malfhack || (stat & BROKEN))
		return
	if(opened == 0)
		if(!panel_open)
			panel_open = 1
			update_icon()
			visible_message("<span class='danger'>The [src.name]'s cover flies open, exposing the wires!</span>")

		else if(panel_open && !wires.is_all_cut())
			wires.cut_all()
			update_icon()
			visible_message("<span class='danger'>The [src.name]'s wires are shredded!</span>")
	else if(opened == 1)
		if(cell)
			cell.loc = user.loc
			cell.updateicon()
			cell = null
			visible_message("<span class='danger'>The [src.name]'s power cell flies off!</span>")
			charging = 0
			update_icon()


/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "apc", name, 535, 515, master_ui, state)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
=======
//	if (!can_use(user)) This already gets called in interact() and in topic()
//		return
	if(!user)
		return
	if(!isobserver(user))
		src.add_fingerprint(user)
		if(usr == user && opened)
			if(cell && Adjacent(user))
				if(isAI(user))
					interact(user)
					return
				else if(issilicon(user) && !isMoMMI(user)) // MoMMIs can hold one item in their tool slot.
					cell.loc=src.loc // Drop it, whoops.
				else
					user.put_in_hands(cell)

				cell.add_fingerprint(user)
				cell.updateicon()

				src.cell = null
				user.visible_message("<span class='warning'>[user.name] removes the power cell from [src.name]!</span>", "You remove the power cell.")
//				to_chat(user, "You remove the power cell.")
				charging = 0
				src.update_icon()
			return
		if(stat & (BROKEN|MAINT))
			return

	src.interact(user)

/obj/machinery/power/apc/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(!user)
		return
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user.name] slashes at the [src.name]!</span>", "<span class='notice'>You slash at the [src.name]!</span>")
	playsound(get_turf(src), 'sound/weapons/slash.ogg', 100, 1)

	var/allcut = wires.IsAllCut()

	if(beenhit >= pick(3, 4) && wiresexposed != 1)
		wiresexposed = 1
		src.update_icon()
		src.visible_message("<span class='warning'>The [src.name]'s cover flies open, exposing the wires!</span>")

	else if(wiresexposed == 1 && allcut == 0)
		wires.CutAll()
		src.update_icon()
		src.visible_message("<span class='warning'>The [src.name]'s wires are shredded!</span>")
	else
		beenhit += 1
	return


/obj/machinery/power/apc/interact(mob/user)
	if (!user)
		return

	if (wiresexposed)
		wires.Interact(user)

	if (stat & (BROKEN | MAINT | EMPED))
		return

	ui_interact(user)

/obj/machinery/power/apc/proc/get_malf_status(mob/user)
	if (ticker && ticker.mode && (user.mind in ticker.mode.malf_ai) && istype(user, /mob/living/silicon/ai))
		if (src.malfai == (user:parent ? user:parent : user))
			if (src.occupant == user)
				return 3 // 3 = User is shunted in this APC
			else if (istype(user.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(!user)
		return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
<<<<<<< HEAD
		"totalLoad" = lastused_total,
		"coverLocked" = coverlocked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
=======
		"totalLoad" = lastused_equip + lastused_light + lastused_environ,
		"coverLocked" = coverlocked,
		"siliconUser" = istype(user, /mob/living/silicon) || isAdminGhost(user), // Allow aghosts to fuck with APCs
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		"malfStatus" = get_malf_status(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = lastused_equip,
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = lastused_light,
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = lastused_environ,
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)
<<<<<<< HEAD
	return data


/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(istype(malf) && malf.malf_picker)
		if(malfai == (malf.parent || malf))
			if(occupier == malf)
				return 3 // 3 = User is shunted in this APC
			else if(istype(malf.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

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

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(user.has_unlimited_silicon_privilege)
=======

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[areaMaster.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	return "[areaMaster.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		areaMaster.power_light = (lighting > 1)
		areaMaster.power_equip = (equipment > 1)
		areaMaster.power_environ = (environ > 1)
//		if (area.name == "AI Chamber")
//			spawn(10)
//				to_chat(world, " [area.name] [area.power_equip]")
	else
		areaMaster.power_light = 0
		areaMaster.power_equip = 0
		areaMaster.power_environ = 0
//		if (area.name == "AI Chamber")
//			to_chat(world, "[area.power_equip]")
	areaMaster.power_change()

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	return wires.IsIndexCut(wireIndex)


/obj/machinery/power/apc/proc/can_use(mob/user as mob, var/loud = 0) //used by attack_hand() and Topic()
	if (user.stat && !isobserver(user))
		to_chat(user, "<span class='warning'>You must be conscious to use this [src]!</span>")
		return 0
	if(!user.client)
		return 0
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use this [src]!</span>")
		nanomanager.close_user_uis(user, src)

		return 0
	if(user.restrained())
		to_chat(user, "<span class='warning'>You must have free hands to use this [src]</span>")
		return 0
	if(user.lying)
		to_chat(user, "<span class='warning'>You must stand to use this [src]!</span>")
		return 0
	if (istype(user, /mob/living/silicon))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if (                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
<<<<<<< HEAD
				user << "<span class='danger'>\The [src] has eee disabled!</span>"
			return FALSE
	return TRUE

/obj/machinery/power/apc/ui_act(action, params)
	if(..() || !can_use(usr, 1) || (locked && !usr.has_unlimited_silicon_privilege))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if(emagged || (stat & (BROKEN|MAINT)))
					usr << "The APC does not respond to the command."
				else
					locked = !locked
					update_icon()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker()
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = 0
				update_icon()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
		if("hack")
			if(get_malf_status(usr))
				malfhack(usr)
		if("occupy")
			if(get_malf_status(usr))
				malfoccupy(usr)
		if("deoccupy")
			if(get_malf_status(usr))
				malfvacate()

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	update()
	update_icon()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != 1)
		return
	if(malf.malfhacking)
		malf << "You are already hacking an APC."
		return
	malf << "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process."
	malf.malfhack = src
	malf.malfhacking = addtimer(malf, "malfhacked", 600, FALSE, src)

	var/obj/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /obj/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		malf << "<span class='warning'>You must evacuate your current APC first!</span>"
		return
	if(!malf.can_shunt)
		malf << "<span class='warning'>You cannot shunt!</span>"
		return
	if(src.z != 1)
		return
	src.occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	src.occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(src.occupier.name,"APC Copy"))
		src.occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		src.occupier.parent = malf.parent
	else
		src.occupier.parent = malf
	malf.shunted = 1
	malf.mind.transfer_to(src.occupier)
	src.occupier.eyeobj.name = "[src.occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	src.occupier.verbs += /mob/living/silicon/ai/proc/corereturn
	src.occupier.cancel_camera()


/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!src.occupier)
		return
	if(src.occupier.parent && src.occupier.parent.stat != 2)
		src.occupier.mind.transfer_to(src.occupier.parent)
		src.occupier.parent.shunted = 0
		src.occupier.parent.adjustOxyLoss(src.occupier.getOxyLoss())
		src.occupier.parent.cancel_camera()
		qdel(src.occupier)

	else
		src.occupier << "<span class='danger'>Primary core damaged, unable to return core processes.</span>"
		if(forced)
			src.occupier.loc = src.loc
			src.occupier.death()
			src.occupier.gib()
			for(var/obj/item/weapon/pinpointer/P in pinpointer_list)
				P.switch_mode_to(TRACK_NUKE_DISK) //Pinpointers go back to tracking the nuke disk
				P.nuke_warning = FALSE
=======
				to_chat(user, "<span class='warning'>\The [src] have AI control disabled!</span>")
				nanomanager.close_user_uis(user, src)

			return 0
	else if(isobserver(user))
		if(malfhack && istype(malfai) && !isAdminGhost(user))
			if(!loud)
				to_chat(user, "<span class='warning'>\The [src] have AI control disabled!</span>")
				nanomanager.close_user_uis(user, src)
			return 0
	else
		if ((!in_range(src, user) || !istype(src.loc, /turf)))
			nanomanager.close_user_uis(user, src)

			return 0

	var/mob/living/carbon/human/H = user
	if (istype(H))
		if(H.getBrainLoss() >= 60)
			for(var/mob/M in viewers(src, null))
				to_chat(M, "<span class='warning'>[H] stares cluelessly at [src] and drools.</span>")
			return 0
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return 0
	return 1

/obj/machinery/power/apc/Topic(href, href_list)
	if(..())
		return 0
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1
	if(!can_use(usr, 1))
		return 0
	if(!istype(usr, /mob/living/silicon) && locked)
	// Shouldn't happen, this is here to prevent href exploits
		to_chat(usr, "You must unlock the panel to use this!")
		return 1
	if (href_list["lock"])
		coverlocked = !coverlocked

	else if (href_list["breaker"])
		toggle_breaker()

	else if (href_list["cmode"])
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			update_icon()

	else if (href_list["eqp"])
		var/val = text2num(href_list["eqp"])
		equipment = setsubsystem(val)
		update_icon()
		update()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		lighting = setsubsystem(val)
		update_icon()
		update()

	else if (href_list["env"])
		var/val = text2num(href_list["env"])
		environ = setsubsystem(val)
		update_icon()
		update()

	else if (href_list["overload"])
		if(istype(usr, /mob/living/silicon))
			src.overload_lighting()

	else if (href_list["malfhack"])
		var/mob/living/silicon/ai/malfai = usr
		if(get_malf_status(malfai)==1)
			if (malfai.malfhacking)
				to_chat(malfai, "You are already hacking an APC.")
				return 1
			to_chat(malfai, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
			malfai.malfhack = src
			malfai.malfhacking = 1
			sleep(600)
			if(src && malfai)
				if (!src.aidisabled)
					malfai.malfhack = null
					malfai.malfhacking = 0
					locked = 1
					if (ticker.mode.config_tag == "malfunction")
						if (STATION_Z == z)
							ticker.mode:apcs++
					if(usr:parent)
						src.malfai = usr:parent
					else
						src.malfai = usr
					to_chat(malfai, "Hack complete. The APC is now under your exclusive control.")
					update_icon()

	else if (href_list["occupyapc"])
		if(get_malf_status(usr))
			malfoccupy(usr)

	else if (href_list["deoccupyapc"])
		if(get_malf_status(usr))
			malfvacate()

	else if (href_list["toggleaccess"])
		if(istype(usr, /mob/living/silicon))
			if(emagged || (stat & (BROKEN|MAINT)))
				to_chat(usr, "The APC does not respond to the command.")
			else
				locked = !locked
				update_icon()

	return 1

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating

	if(malfai)
		if (ticker.mode.config_tag == "malfunction")
			if (STATION_Z == z)
				operating ? ticker.mode:apcs++ : ticker.mode:apcs--

	src.update()
	update_icon()

/obj/machinery/power/apc/proc/malfoccupy(var/mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current apc first.</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt.</span>")
		return
	if(STATION_Z != z)
		return
	src.occupant = new /mob/living/silicon/ai(src,malf.laws,null,1)
	src.occupant.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(src.occupant.name,"APC Copy"))
		src.occupant.name = "[malf.name] APC Copy"
	if(malf.parent)
		src.occupant.parent = malf.parent
	else
		src.occupant.parent = malf
	malf.mind.transfer_to(src.occupant)
	src.occupant.eyeobj.name = "[src.occupant.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
		malf = null
	src.occupant.verbs += /mob/living/silicon/ai/proc/corereturn
	src.occupant.verbs += /datum/game_mode/malfunction/proc/takeover
	src.occupant.cancel_camera()
	if (seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
		for(var/obj/item/weapon/pinpointer/point in world)
			point.the_disk = src //the pinpointer will detect the shunted AI


/obj/machinery/power/apc/proc/malfvacate(var/forced)
	if(!src.occupant)
		return
	if(src.occupant.parent && src.occupant.parent.stat != 2)
		src.occupant.mind.transfer_to(src.occupant.parent)
		src.occupant.parent.adjustOxyLoss(src.occupant.getOxyLoss())
		src.occupant.parent.cancel_camera()
		qdel(src.occupant)
		src.occupant = null
		if (seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
			for(var/obj/item/weapon/pinpointer/point in world)
				for(var/datum/mind/AI_mind in ticker.mode.malf_ai)
					var/mob/living/silicon/ai/A = AI_mind.current // the current mob the mind owns
					if(A.stat != DEAD)
						point.the_disk = A //The pinpointer tracks the AI back into its core.

	else
		to_chat(src.occupant, "<span class='warning'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			src.occupant.loc = src.loc
			src.occupant.death()
			src.occupant.gib()
			for(var/obj/item/weapon/pinpointer/point in world)
				point.the_disk = null //the pinpointer will go back to pointing at the nuke disc.


/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!src.malfhack && STATION_Z == z)
		if(prob(3))
			src.locked = 1
			if (src.cell.charge > 0)
//				to_chat(world, "<span class='warning'>blew APC in [src.loc.loc]</span>")
				src.cell.charge = 0
				cell.corrupt()
				src.malfhack = 1
				update_icon()
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				for(var/mob/M in viewers(src))
					M.show_message("<span class='warning'>The [src.name] suddenly lets out a blast of smoke and some sparks!</span>", 1, "<span class='warning'>You hear sizzling electronics.</span>", 2)

/obj/machinery/power/apc/can_attach_terminal(mob/user)
	return user.loc == src.loc && has_electronics != 2 && !terminal
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

<<<<<<< HEAD
/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
=======
/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.get_powernet())
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		terminal.powernet.load += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & (BROKEN|MAINT))
		return
<<<<<<< HEAD
	if(!area.requires_power)
=======
	if(!areaMaster.requires_power)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return

	/*
	if (equipment > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.equip_consumption, EQUIP)
	if (lighting > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.light_consumption, LIGHT)
	if (environ > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.environ_consumption, ENVIRON)

	area.calc_lighting() */
<<<<<<< HEAD
	lastused_light = area.usage(STATIC_LIGHT)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	area.clear_usage()
=======

	lastused_light = areaMaster.usage(LIGHT)
	lastused_light += areaMaster.usage(STATIC_LIGHT)
	lastused_equip = areaMaster.usage(EQUIP)
	lastused_light += areaMaster.usage(STATIC_EQUIP)
	lastused_environ = areaMaster.usage(ENVIRON)
	lastused_light += areaMaster.usage(STATIC_ENVIRON)
	areaMaster.clear_usage()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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

	//if(debug)
	//	world.log << "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light] - Longterm: [longtermpower]"

	if(cell && !shorted)
<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

<<<<<<< HEAD
		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
=======
		if(excess > lastused_total) // if power excess recharge the cell
									// by the same amount just used
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
<<<<<<< HEAD
			if((cell.charge/CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
=======

			if((cell.charge / CELLRATE + excess) >= lastused_total)					// can we draw enough from cell+grid to cover last usage?
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				cell.charge = min(cell.maxcharge, cell.charge + CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = 0

			else	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
<<<<<<< HEAD
			area.poweralert(0, src)
=======
			if(areaMaster.poweralm && make_alerts)
				areaMaster.poweralert(0, src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
<<<<<<< HEAD
			area.poweralert(0, src)
=======
			if(areaMaster.poweralm && make_alerts)
				areaMaster.poweralert(0, src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else if(cell.percent() < 30 && longtermpower < 0)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
<<<<<<< HEAD
			area.poweralert(0, src)
=======
			if(areaMaster.poweralm && make_alerts)
				areaMaster.poweralert(0, src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
<<<<<<< HEAD
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell
		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*CELLRATE, cell.maxcharge*CHARGELEVEL)
=======
			if(cell.percent() > 75 && !areaMaster.poweralm && !make_alerts)
				areaMaster.poweralert(1, src)

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess * CELLRATE, cell.maxcharge * CHARGELEVEL)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				add_load(ch/CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0
<<<<<<< HEAD
=======
					charging = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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
<<<<<<< HEAD
		area.poweralert(0, src)

	// update icon & area power if anything changed

=======
		if(!make_alerts)
			areaMaster.poweralert(0, src)

	// update icon & area power if anything changed
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

<<<<<<< HEAD
/obj/machinery/power/apc/proc/autoset(val, on)
=======
obj/machinery/power/apc/proc/autoset(var/val, var/on)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1
<<<<<<< HEAD
	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3
	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1
	return val

/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
			update_icon()
			update()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(occupier)
		occupier.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update_icon()
	update()
	addtimer(src, "reset", 600, FALSE, APC_RESET_EMP)
	..()

/obj/machinery/power/apc/ex_act(severity, target)
	..()
	if(!qdeleted(src))
		switch(severity)
			if(2)
				if(prob(50))
					set_broken()
			if(3)
				if(prob(25))
					set_broken()

/obj/machinery/power/apc/blob_act(obj/effect/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	stat |= BROKEN
	operating = 0
	if(occupier)
=======

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/emp_act(severity)
	flick("apc-spark", src)
	if(cell)
		cell.emp_act(severity)
	if(occupant)
		occupant.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update()
	spawn(600/severity)
		lighting = 3
		equipment = 3
		environ = 3
		update()
	..()

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1.0)
			//set_broken() //now Destroy() do what we need
			if (cell)
				cell.ex_act(1.0) // more lags woohoo
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				set_broken()
				if (cell && prob(50))
					cell.ex_act(2.0)
		if(3.0)
			if (prob(25))
				set_broken()
				if (cell && prob(25))
					cell.ex_act(3.0)
	return

/obj/machinery/power/apc/blob_act()
	if (prob(75))
		set_broken()
		if (cell && prob(5))
			cell.blob_act()

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		if (ticker.mode.config_tag == "malfunction")
			if (STATION_Z == z)
				ticker.mode:apcs--
	stat |= BROKEN
	operating = 0
	if(occupant)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		malfvacate(1)
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20);
		spawn(0)
<<<<<<< HEAD
			for(var/area/A in area.related)
				for(var/obj/machinery/light/L in A)
					L.on = 1
					L.broken()
					stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(isalien(user))
		return 0
	if(electrocute_mob(user, src, src))
		return 1
	else
		return 0
=======
			for(var/obj/machinery/light/L in areaMaster)
				L.on = 1
				L.broken()
				sleep(1)

/obj/machinery/power/apc/Destroy()
	areaMaster.remove_apc(src)
	if(malfai && operating)
		if (ticker.mode.config_tag == "malfunction")
			if (STATION_Z == z)
				ticker.mode:apcs--
	areaMaster.power_light = 0
	areaMaster.power_equip = 0
	areaMaster.power_environ = 0
	areaMaster.power_change()
	if(occupant)
		malfvacate(1)

	if(cell)
		cell.loc = loc
		cell = null

	if(terminal)
		terminal.master = null
		terminal = null

	if(wires)
		qdel(wires)
		wires = null

	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

<<<<<<< HEAD
#undef APC_UPDATE_ICON_COOLDOWN

/*Power module, used for APC construction*/
/obj/item/weapon/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
=======
/obj/machinery/power/apc/cultify()
	if(src.invisibility != INVISIBILITY_MAXIMUM)
		src.invisibility = INVISIBILITY_MAXIMUM

/obj/machinery/power/apc/change_area(oldarea, newarea)
	..()
	name = replacetext(name,oldarea,newarea)

/obj/machinery/power/apc/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		locked = !locked
		update_icon()
		return 1
	return 0

#undef APC_UPDATE_ICON_COOLDOWN
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
