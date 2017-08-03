//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128

#define APC_RESET_EMP "emp"

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


// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire connection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."

	icon_state = "apc0"
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = null
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF

	var/lon_range = 1.5
	var/area/area
	var/areastring = null
	var/obj/item/weapon/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = TRUE
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/transfer_in_progress = FALSE //Is there an AI being transferred out of us?
	var/longtermpower = 10
	var/auto_name = 0
	var/failure_timer = 0
	var/force_update = 0
	var/update_state = -1
	var/update_overlay = -1
	var/icon_update_needed = FALSE

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=0)
	if (!req_access)
		req_access = list(ACCESS_ENGINE_EQUIP)
	if (!armor)
		armor = list(melee = 20, bullet = 20, laser = 10, energy = 100, bomb = 30, bio = 100, rad = 100, fire = 90, acid = 50)
	..()
	GLOB.apcs_list += src

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
	if (building)
		area = get_area(src)
		opened = 1
		operating = FALSE
		name = "[area.name] APC"
		stat |= MAINT
		src.update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = FALSE
	area.power_equip = FALSE
	area.power_environ = FALSE
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

/obj/machinery/power/apc/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_icon()
		updateUsrDialog()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.setDir(tdir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = src.loc.loc

	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
	else
		src.area = locate(text2path(areastring)) in GLOB.sortedAreas
	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(stat & BROKEN)
		return
	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].")
		else
			to_chat(user, "It's [ !terminal ? "not" : "" ] wired up.")
			to_chat(user, "The electronics are[!has_electronics?"n't":""] installed.")

	else
		if (stat & MAINT)
			to_chat(user, "The cover is closed. Something is wrong with it. It doesn't work.")
		else if (malfhack)
			to_chat(user, "The cover is broken. It may be hard to force it open.")
		else
			to_chat(user, "The cover is closed.")


// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()
	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update)
		icon_update_needed = FALSE
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
				if (update_state & UPSTATE_BROKE || malfhack)
					icon_state = "[basestate]-b-nocover"
				else
					icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"
		else if(update_state & UPSTATE_MAINT)
			icon_state = "apc0"

	if(!(update_state & UPSTATE_ALLGOOD))
		cut_overlays()

	if(update & 2)
		cut_overlays()
		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			var/list/O = list(
				"apcox-[locked]",
				"apco3-[charging]")
			if(operating)
				O += "apco0-[equipment]"
				O += "apco1-[lighting]"
				O += "apco2-[environ]"
			add_overlay(O)

	// And now, separately for cleanness, the lighting changing
	if(update_state & UPSTATE_ALLGOOD)
		switch(charging)
			if(0)
				light_color = LIGHT_COLOR_RED
			if(1)
				light_color = LIGHT_COLOR_BLUE
			if(2)
				light_color = LIGHT_COLOR_GREEN
		set_light(lon_range)
	else if(update_state & UPSTATE_BLUESCREEN)
		light_color = LIGHT_COLOR_BLUE
		set_light(lon_range)
	else
		set_light(0)

	icon_update_needed = FALSE

/obj/machinery/power/apc/proc/check_updates()
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
	if(opened)
		if(opened==1)
			update_state |= UPSTATE_OPENED1
		if(opened==2)
			update_state |= UPSTATE_OPENED2
	else if(emagged || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
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


	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar)) //Using crowbar
		if (opened) // a) on open apc
			if (has_electronics==1)
				if (terminal)
					to_chat(user, "<span class='warning'>Disconnect the wires first!</span>")
					return
				playsound(src.loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You are trying to remove the power control board...</span>" )
				if(do_after(user, 50*W.toolspeed, target = src))
					if (has_electronics==1)
						has_electronics = 0
						if (stat & BROKEN)
							user.visible_message(\
								"[user.name] has broken the power control board inside [src.name]!",\
								"<span class='notice'>You break the charred power control board and remove the remains.</span>",
								"<span class='italics'>You hear a crack.</span>")
							return
							//SSticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
						else if (emagged) // We emag board, not APC's frame
							emagged = FALSE
							user.visible_message(\
								"[user.name] has discarded emaged power control board from [src.name]!",\
								"<span class='notice'>You discarded shorten board.</span>")
							return
						else if (malfhack) // AI hacks board, not APC's frame
							user.visible_message(\
								"[user.name] has discarded strangely programmed power control board from [src.name]!",\
								"<span class='notice'>You discarded strangely programmed board.</span>")
							malfai = null
							malfhack = 0
							return
						else
							user.visible_message(\
								"[user.name] has removed the power control board from [src.name]!",\
								"<span class='notice'>You remove the power control board.</span>")
							new /obj/item/weapon/electronics/apc(loc)
							return
			else if (opened!=2) //cover isn't removed
				opened = 0
				coverlocked = TRUE //closing cover relocks it
				update_icon()
				return
		else if (!(stat & BROKEN)) // b) on closed and not broken APC
			if(coverlocked && !(stat & MAINT)) // locked...
				to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
				return
			else if (panel_open) // wires are exposed
				to_chat(user, "<span class='warning'>Exposed wires prevents you from opening it!</span>")
				return
			else
				opened = 1
				update_icon()
				return

	else if	(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
			return
		else
			if (stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell!</span>")
				return
			if(!user.drop_item())
				return
			W.forceMove(src)
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				"<span class='notice'>You insert the power cell.</span>")
			chargecount = 0
			update_icon()

	else if	(istype(W, /obj/item/weapon/screwdriver))	// haxing
		if(opened)
			if (cell)
				to_chat(user, "<span class='warning'>Close the APC first!</span>") //Less hints more mystery!
				return
			else
				if (has_electronics==1)
					has_electronics = 2
					stat &= ~MAINT
					playsound(src.loc, W.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You screw the circuit electronics into place.</span>")
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					playsound(src.loc, W.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You unfasten the electronics.</span>")
				else /* has_electronics==0 */
					to_chat(user, "<span class='warning'>There is nothing to secure!</span>")
					return
				update_icon()
		else if(emagged)
			to_chat(user, "<span class='warning'>The interface is broken!</span>")
		else if((stat & MAINT) && !opened)
			..() //its an empty closed frame... theres no wires to expose!
		else
			panel_open = !panel_open
			to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"]")
			update_icon()

	else if (W.GetID())			// trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "<span class='warning'>The interface is broken!</span>")
		else if(opened)
			to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>You must close the panel!</span>")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "<span class='warning'>Nothing happens!</span>")
		else
			if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
				locked = !locked
				to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the APC interface.</span>")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			throw EXCEPTION("attackby on APC when it's not on a turf")
			return
		if (host_turf.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first!</span>")
			return
		else if (terminal) // it already have terminal
			to_chat(user, "<span class='warning'>This APC is already wired!</span>")
			return
		else if (has_electronics == 0)
			to_chat(user, "<span class='warning'>There is nothing to wire!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten lengths of cable for APC!</span>")
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							"<span class='notice'>You start adding cables to the APC frame...</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics > 0)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, "<span class='notice'>You add cables to the APC frame.</span>")
				make_terminal()
				terminal.connect_to_network()

	else if (istype(W, /obj/item/weapon/wirecutters) && terminal && opened)
		terminal.dismantle(user, W)

	else if (istype(W, /obj/item/weapon/electronics/apc) && opened)
		if (has_electronics!=0) // there are already electronicks inside
			to_chat(user, "<span class='warning'>You cannot put the board inside, there already is one!</span>")
			return
		else if (stat & BROKEN)
			to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged!</span>")
			return

		user.visible_message("[user.name] inserts the power control board into [src].", \
							"<span class='notice'>You start to insert the power control board into the frame...</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(has_electronics==0)
				has_electronics = 1
				locked = TRUE //We placed new, locked board in
				to_chat(user, "<span class='notice'>You place the power control board inside the frame.</span>")
				qdel(W)

	else if (istype(W, /obj/item/weapon/weldingtool) && opened && has_electronics==0 && !terminal)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task!</span>")
			return
		user.visible_message("[user.name] welds [src].", \
							"<span class='notice'>You start welding the APC frame...</span>", \
							"<span class='italics'>You hear welding.</span>")
		playsound(src.loc, WT.usesound, 50, 1)
		if(do_after(user, 50*W.toolspeed, target = src))
			if(!src || !WT.remove_fuel(3, user)) return
			if ((stat & BROKEN) || opened==2)
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

	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(stat & BROKEN || opened==2 || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, "<span class='warning'>You found no reason for repairing this APC</span>")
			return
		if (!(stat & BROKEN) && opened==2) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							"<span class='notice'>You begin to replace APC's cover...</span>")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, "<span class='notice'>You replace missing APC's cover.</span>")
				qdel(W)
				opened = 1
				update_icon()
			return
		if (has_electronics)
			to_chat(user, "<span class='warning'>You cannot repair this APC until you remove the electronics still inside!</span>")
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							"<span class='notice'>You begin to replace the damaged APC frame...</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You replace the damaged APC frame with a new one.</span>")
			qdel(W)
			stat &= ~BROKEN
			obj_integrity = max_integrity
			if (opened==2)
				opened = 1
			update_icon()
	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 15 && (!(stat & BROKEN) || malfai))
		return 0
	. = ..()


/obj/machinery/power/apc/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		set_broken()

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != 2)
			opened = 2
			visible_message("<span class='warning'>The APC cover is knocked down!</span>")
			update_icon()

/obj/machinery/power/apc/emag_act(mob/user)
	if(!emagged && !malfhack)
		if(opened)
			to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>You must close the panel first!</span>")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "<span class='warning'>Nothing happens!</span>")
		else
			flick("apc-spark", src)
			playsound(src, "sparks", 75, 1)
			emagged = TRUE
			locked = FALSE
			to_chat(user, "<span class='notice'>You emag the APC interface.</span>")
			update_icon()

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
	if(!user)
		return
	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] removes \the [cell] from [src]!","<span class='notice'>You remove \the [cell].</span>")
			user.put_in_hands(cell)
			cell.update_icon()
			src.cell = null
			charging = 0
			src.update_icon()
		return
	if((stat & MAINT) && !opened) //no board; no interface
		return
	..()

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "apc", name, 535, 515, master_ui, state)
		ui.open()
	if(ui)
		ui.set_autoupdate(state = (failure_timer ? 1 : 0))

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = lastused_total,
		"coverLocked" = coverlocked,
		"siliconUser" = user.has_unlimited_silicon_privilege || user.using_power_flow_console(),
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
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(user.has_unlimited_silicon_privilege)
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
				to_chat(user, "<span class='danger'>\The [src] has eee disabled!</span>")
			return FALSE
	return TRUE

/obj/machinery/power/apc/ui_act(action, params)
	if(..() || !can_use(usr, 1) || (locked && !usr.has_unlimited_silicon_privilege && !failure_timer))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if(emagged || (stat & (BROKEN|MAINT)))
					to_chat(usr, "The APC does not respond to the command.")
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
		if("reboot")
			failure_timer = 0
			update_icon()
			update()
	return 1

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
		to_chat(malf, "You are already hacking an APC.")
		return
	to_chat(malf, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, /mob/living/silicon/ai/.proc/malfhacked, src), 600, TIMER_STOPPABLE)

	var/obj/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /obj/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current APC first!</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt!</span>")
		return
	if(src.z != ZLEVEL_STATION)
		return
	occupier = new /mob/living/silicon/ai(src, malf.laws, malf) //DEAR GOD WHY?	//IKR????
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = 1
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	occupier.verbs += /mob/living/silicon/ai/proc/corereturn
	occupier.cancel_camera()


/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = 0
		occupier.parent.setOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		occupier.parent.verbs -= /mob/living/silicon/ai/proc/corereturn
		qdel(occupier)
	else
		to_chat(occupier, "<span class='danger'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			occupier.loc = src.loc
			occupier.death()
			occupier.gib()
			for(var/obj/item/weapon/pinpointer/P in GLOB.pinpointer_list)
				P.switch_mode_to(TRACK_NUKE_DISK) //Pinpointers go back to tracking the nuke disk
				P.nuke_warning = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(card.AI)
		to_chat(user, "<span class='warning'>[card] is already occupied!</span>")
		return
	if(!occupier)
		to_chat(user, "<span class='warning'>There's nothing in [src] to transfer!</span>")
		return
	if(!occupier.mind || !occupier.client)
		to_chat(user, "<span class='warning'>[occupier] is either inactive or destroyed!</span>")
		return
	if(!occupier.parent.stat)
		to_chat(user, "<span class='warning'>[occupier] is refusing all attempts at transfer!</span>" )
		return
	if(transfer_in_progress)
		to_chat(user, "<span class='warning'>There's already a transfer in progress!</span>")
		return
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return
	var/turf/T = get_turf(user)
	if(!T)
		return
	transfer_in_progress = TRUE
	user.visible_message("<span class='notice'>[user] slots [card] into [src]...</span>", "<span class='notice'>Transfer process initiated. Sending request for AI approval...</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	occupier << sound('sound/misc/notice2.ogg') //To alert the AI that someone's trying to card them if they're tabbed out
	if(alert(occupier, "[user] is attempting to transfer you to \a [card.name]. Do you consent to this?", "APC Transfer", "Yes - Transfer Me", "No - Keep Me Here") == "No - Keep Me Here")
		to_chat(user, "<span class='danger'>AI denied transfer request. Process terminated.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
		transfer_in_progress = FALSE
		return
	if(user.loc != T)
		to_chat(user, "<span class='danger'>Location changed. Process terminated.</span>")
		to_chat(occupier, "<span class='warning'>[user] moved away! Transfer canceled.</span>")
		transfer_in_progress = FALSE
		return
	to_chat(user, "<span class='notice'>AI accepted request. Transferring stored intelligence to [card]...</span>")
	to_chat(occupier, "<span class='notice'>Transfer starting. You will be moved to [card] shortly.</span>")
	if(!do_after(user, 50, target = src))
		to_chat(occupier, "<span class='warning'>[user] was interrupted! Transfer canceled.</span>")
		transfer_in_progress = FALSE
		return
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return
	user.visible_message("<span class='notice'>[user] transfers [occupier] to [card]!</span>", "<span class='notice'>Transfer complete! [occupier] is now stored in [card].</span>")
	to_chat(occupier, "<span class='notice'>Transfer complete! You've been stored in [user]'s [card.name].</span>")
	occupier.forceMove(card)
	card.AI = occupier
	occupier.parent.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.powernet.load += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_icon()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return
	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		return

	/*
	if (equipment > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.equip_consumption, EQUIP)
	if (lighting > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.light_consumption, LIGHT)
	if (environ > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.environ_consumption, ENVIRON)

	area.calc_lighting() */
	lastused_light = area.usage(STATIC_LIGHT)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
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

	//if(debug)
	//	world.log << "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light] - Longterm: [longtermpower]"

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
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

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30 && longtermpower < 0)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell
		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
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
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
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

	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/obj/machinery/power/apc/proc/autoset(val, on)
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
	addtimer(CALLBACK(src, .proc/reset, APC_RESET_EMP), 600)
	..()

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	stat |= BROKEN
	operating = FALSE
	if(occupier)
		malfvacate(1)
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, .proc/break_lights)

/obj/machinery/power/apc/proc/break_lights()
	for(var/area/A in area.related)
		for(var/obj/machinery/light/L in A)
			L.on = TRUE
			L.break_light_tube()
			L.on = FALSE
			stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return 0
	if(electrocute_mob(user, src, src, 1, TRUE))
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0


/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/M in area.contents)
		if(M.critical_machine)
			return
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/I = A
		if(get_area(I) == area)
			return

	failure_timer = max(failure_timer, round(duration))

#undef UPSTATE_CELL_IN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_RESET_EMP

//update_overlay
#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
#undef APC_UPOVERLAY_OPERATING

#undef APC_UPDATE_ICON_COOLDOWN

/*Power module, used for APC construction*/
/obj/item/weapon/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
