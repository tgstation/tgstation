// APC electronics status:
/// There are no electronics in the APC.
#define APC_ELECTRONICS_MISSING 0
/// The electronics are installed but not secured.
#define APC_ELECTRONICS_INSTALLED 1
/// The electronics are installed and secured.
#define APC_ELECTRONICS_SECURED 2

// APC cover status:
/// The APCs cover is closed.
#define APC_COVER_CLOSED 0
/// The APCs cover is open.
#define APC_COVER_OPENED 1
/// The APCs cover is missing.
#define APC_COVER_REMOVED 2

// APC visuals
/// Pixel offset of the APC from the floor turf
#define APC_PIXEL_OFFSET 25

// APC charging status:
/// The APC is not charging.
#define APC_NOT_CHARGING 0
/// The APC is charging.
#define APC_CHARGING 1
/// The APC is fully charged.
#define APC_FULLY_CHARGED 2

// APC channel status:
/// The APCs power channel is manually set off.
#define APC_CHANNEL_OFF 0
/// The APCs power channel is automatically off.
#define APC_CHANNEL_AUTO_OFF 1
/// The APCs power channel is manually set on.
#define APC_CHANNEL_ON 2
/// The APCs power channel is automatically on.
#define APC_CHANNEL_AUTO_ON 3

#define APC_CHANNEL_IS_ON(channel) (channel >= APC_CHANNEL_ON)

// APC autoset enums:
/// The APC turns automated and manual power channels off.
#define AUTOSET_FORCE_OFF 0
/// The APC turns automated power channels off.
#define AUTOSET_OFF 2
/// The APC turns automated power channels on.
#define AUTOSET_ON 1

// External power status:
/// The APC either isn't attached to a powernet or there is no power on the external powernet.
#define APC_NO_POWER 0
/// The APCs external powernet does not have enough power to charge the APC.
#define APC_LOW_POWER 1
/// The APCs external powernet has enough power to charge the APC.
#define APC_HAS_POWER 2

// Ethereals:
/// How long it takes an ethereal to drain or charge APCs. Also used as a spam limiter.
#define APC_DRAIN_TIME (7.5 SECONDS)
/// How much power ethereals gain/drain from APCs.
#define APC_POWER_GAIN 200

// Wires & EMPs:
/// The wire value used to reset the APCs wires after one's EMPed.
#define APC_RESET_EMP "emp"

// update_state
// Bitshifts: (If you change the status values to be something other than an int or able to exceed 3 you will need to change these too)
/// The bit shift for the APCs cover status.
#define UPSTATE_COVER_SHIFT (0)
	/// The bitflag representing the APCs cover being open for icon purposes.
	#define UPSTATE_OPENED1 (APC_COVER_OPENED << UPSTATE_COVER_SHIFT)
	/// The bitflag representing the APCs cover being missing for icon purposes.
	#define UPSTATE_OPENED2 (APC_COVER_REMOVED << UPSTATE_COVER_SHIFT)

// Bitflags:
/// The APC has a power cell.
#define UPSTATE_CELL_IN (1<<2)
/// The APC is broken or damaged.
#define UPSTATE_BROKE (1<<3)
/// The APC is undergoing maintenance.
#define UPSTATE_MAINT (1<<4)
/// The APC is emagged or malfed.
#define UPSTATE_BLUESCREEN (1<<5)
/// The APCs wires are exposed.
#define UPSTATE_WIREEXP (1<<6)

// update_overlay
// Bitflags:
/// Bitflag indicating that the APCs operating status overlay should be shown.
#define UPOVERLAY_OPERATING (1<<0)
/// Bitflag indicating that the APCs locked status overlay should be shown.
#define UPOVERLAY_LOCKED (1<<1)

// Bitshifts: (If you change the status values to be something other than an int or able to exceed 3 you will need to change these too)
/// Bit shift for the charging status of the APC.
#define UPOVERLAY_CHARGING_SHIFT (2)
/// Bit shift for the equipment status of the APC.
#define UPOVERLAY_EQUIPMENT_SHIFT (4)
/// Bit shift for the lighting channel status of the APC.
#define UPOVERLAY_LIGHTING_SHIFT (6)
/// Bit shift for the environment channel status of the APC.
#define UPOVERLAY_ENVIRON_SHIFT (8)

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire connection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area's electrical systems."

	icon_state = "apc0"
	use_power = NO_POWER_USE
	req_access = null
	max_integrity = 200
	integrity_failure = 0.25
	damage_deflection = 10
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON

	var/lon_range = 1.5
	var/area/area
	var/areastring = null
	var/obj/item/stock_parts/cell/cell
	var/start_charge = 90 // initial cell charge %
	var/cell_type = /obj/item/stock_parts/cell/upgraded //Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/opened = APC_COVER_CLOSED
	var/shorted = FALSE
	var/lighting = APC_CHANNEL_AUTO_ON
	var/equipment = APC_CHANNEL_AUTO_ON
	var/environ = APC_CHANNEL_AUTO_ON
	var/operating = TRUE
	var/charging = APC_NOT_CHARGING
	var/chargemode = TRUE
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/aidisabled = FALSE
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	powernet = FALSE // set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = FALSE //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/has_electronics = APC_ELECTRONICS_MISSING // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/transfer_in_progress = FALSE //Is there an AI being transferred out of us?
	///buffer state that makes apcs not shut off channels immediately as long as theres some power left, effect visible in apcs only slowly losing power
	var/longtermpower = 10
	var/auto_name = FALSE
	var/failure_timer = 0
	var/force_update = FALSE
	var/emergency_lights = FALSE
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0
	var/update_state = -1
	var/update_overlay = -1
	var/icon_update_needed = FALSE
	var/obj/machinery/computer/apc_control/remote_control = null
	///Represents a signel source of power alarms for this apc
	var/datum/alarm_handler/alarm_manager

/obj/machinery/power/apc/unlocked
	locked = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/power/apc/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

/obj/machinery/power/apc/highcap/five_k
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/machinery/power/apc/highcap/ten_k
	cell_type = /obj/item/stock_parts/cell/high

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name, APC_PIXEL_OFFSET)

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, ndir, building=0)
	if (!req_access)
		req_access = list(ACCESS_ENGINE_EQUIP)
	if (!armor)
		armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 100, BOMB = 30, BIO = 100, FIRE = 90, ACID = 50)
	..()
	GLOB.apcs_list += src

	wires = new /datum/wires/apc(src)

	if (building)
		area = get_area(src)
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [get_area_name(area, TRUE)] APC"
		set_machine_stat(machine_stat | MAINT)
		update_appearance()
		addtimer(CALLBACK(src, .proc/update), 5)
		dir = ndir

	// offset APC_PIXEL_OFFSET pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	var/offset_old
	switch(dir)
		if(NORTH)
			offset_old = pixel_y
			pixel_y = APC_PIXEL_OFFSET
		if(SOUTH)
			offset_old = pixel_y
			pixel_y = -APC_PIXEL_OFFSET
		if(EAST)
			offset_old = pixel_x
			pixel_x = APC_PIXEL_OFFSET
		if(WEST)
			offset_old = pixel_x
			pixel_x = -APC_PIXEL_OFFSET
	if(abs(offset_old) != APC_PIXEL_OFFSET && !building)
		log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([dir] | [uppertext(dir2text(dir))]) has pixel_[dir & (WEST|EAST) ? "x" : "y"] value [offset_old] - should be [dir & (SOUTH|EAST) ? "-" : ""][APC_PIXEL_OFFSET]. Use the directional/ helpers!")

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	if(area)
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
		area.power_change()
		area.apc = null
	QDEL_NULL(alarm_manager)
	if(occupier)
		malfvacate(TRUE)
	if(wires)
		QDEL_NULL(wires)
	if(cell)
		QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	. = ..()

/obj/machinery/power/apc/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_appearance()
		updateUsrDialog()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(loc)
	terminal.setDir(dir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)
	alarm_manager = new(src)

	if(!mapload)
		return
	has_electronics = APC_ELECTRONICS_SECURED
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new cell_type
		cell.charge = start_charge * cell.maxcharge / 100 // (convert percentage to actual value)

	var/area/A = loc.loc

	//if area isn't specified use current
	if(areastring)
		area = get_area_instance_from_text(areastring)
		if(!area)
			area = A
			stack_trace("Bad areastring path for [src], [areastring]")
	else if(isarea(A) && areastring == null)
		area = A

	if(auto_name)
		name = "\improper [get_area_name(area, TRUE)] APC"

	if (area)
		if (area.apc)
			log_mapping("Duplicate APC created at [AREACOORD(src)]")
		area.apc = src

	update_appearance()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > 2000)

/obj/machinery/power/apc/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(min(exposed_temperature/100, 10), BURN)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		return
	if(opened)
		if(has_electronics && terminal)
			. += "The cover is [opened==APC_COVER_REMOVED?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
		else
			. += {"It's [ !terminal ? "not" : "" ] wired up.\n
			The electronics are[!has_electronics?"n't":""] installed."}
	else
		if (machine_stat & MAINT)
			. += "The cover is closed. Something is wrong with it. It doesn't work."
		else if (malfhack)
			. += "The cover is broken. It may be hard to force it open."
		else
			. += "The cover is closed."

	. += span_notice("Right-click the APC to [ locked ? "unlock" : "lock"] the interface.")

	if(issilicon(user))
		. += span_notice("Ctrl-Click the APC to switch the breaker [ operating ? "off" : "on"].")

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(!update_state)
		switch(charging)
			if(APC_NOT_CHARGING)
				set_light_color(COLOR_SOFT_RED)
			if(APC_CHARGING)
				set_light_color(LIGHT_COLOR_BLUE)
			if(APC_FULLY_CHARGED)
				set_light_color(LIGHT_COLOR_GREEN)
		set_light(lon_range)
		return

	if(update_state & UPSTATE_BLUESCREEN)
		set_light_color(LIGHT_COLOR_BLUE)
		set_light(lon_range)
		return

	set_light(0)

/obj/machinery/power/apc/update_icon_state()
	if(!update_state)
		icon_state = "apc0"
		return ..()
	if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[cell ? 2 : 1]"
		if(update_state & UPSTATE_OPENED1)
			icon_state = (update_state & (UPSTATE_MAINT|UPSTATE_BROKE)) ? "apcmaint" : basestate
		else if(update_state & UPSTATE_OPENED2)
			icon_state = "[basestate][((update_state & UPSTATE_BROKE) || malfhack) ? "-b" : null]-nocover"
		return ..()
	if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
		return ..()
	if(update_state & UPSTATE_BLUESCREEN)
		icon_state = "apcemag"
		return ..()
	if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"
		return ..()
	if(update_state & UPSTATE_MAINT)
		icon_state = "apc0"
	return ..()

/obj/machinery/power/apc/update_overlays()
	. = ..()
	if((machine_stat & (BROKEN|MAINT)) || update_state)
		return

	. += mutable_appearance(icon, "apcox-[locked]")
	. += emissive_appearance(icon, "apcox-[locked]")
	. += mutable_appearance(icon, "apco3-[charging]")
	. += emissive_appearance(icon, "apco3-[charging]")
	if(!operating)
		return

	. += mutable_appearance(icon, "apco0-[equipment]")
	. += emissive_appearance(icon, "apco0-[equipment]")
	. += mutable_appearance(icon, "apco1-[lighting]")
	. += emissive_appearance(icon, "apco1-[lighting]")
	. += mutable_appearance(icon, "apco2-[environ]")
	. += emissive_appearance(icon, "apco2-[environ]")

/// Checks for what icon updates we will need to handle
/obj/machinery/power/apc/proc/check_updates()
	SIGNAL_HANDLER
	. = NONE

	// Handle icon status:
	var/new_update_state = NONE
	if(machine_stat & BROKEN)
		new_update_state |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		new_update_state |= UPSTATE_MAINT

	if(opened)
		new_update_state |= (opened << UPSTATE_COVER_SHIFT)
		if(cell)
			new_update_state |= UPSTATE_CELL_IN

	else if((obj_flags & EMAGGED) || malfai)
		new_update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		new_update_state |= UPSTATE_WIREEXP

	if(new_update_state != update_state)
		update_state = new_update_state
		. |= UPDATE_ICON_STATE

	// Handle overlay status:
	var/new_update_overlay = NONE
	if(operating)
		new_update_overlay |= UPOVERLAY_OPERATING

	if(!update_state)
		if(locked)
			new_update_overlay |= UPOVERLAY_LOCKED

		new_update_overlay |= (charging << UPOVERLAY_CHARGING_SHIFT)
		new_update_overlay |= (equipment << UPOVERLAY_EQUIPMENT_SHIFT)
		new_update_overlay |= (lighting << UPOVERLAY_LIGHTING_SHIFT)
		new_update_overlay |= (environ << UPOVERLAY_ENVIRON_SHIFT)

	if(new_update_overlay != update_overlay)
		update_overlay = new_update_overlay
		. |= UPDATE_OVERLAYS


// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/W)
	. = TRUE
	if (opened)
		if (has_electronics == APC_ELECTRONICS_INSTALLED)
			if (terminal)
				to_chat(user, span_warning("Disconnect the wires first!"))
				return
			W.play_tool_sound(src)
			to_chat(user, span_notice("You attempt to remove the power control board...") )
			if(W.use_tool(src, user, 50))
				if (has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if (machine_stat & BROKEN)
						user.visible_message(span_notice("[user.name] breaks the power control board inside [src.name]!"),\
							span_notice("You break the charred power control board and remove the remains."),
							span_hear("You hear a crack."))
						return
					else if (obj_flags & EMAGGED)
						obj_flags &= ~EMAGGED
						user.visible_message(span_notice("[user.name] discards an emagged power control board from [src.name]!"),\
							span_notice("You discard the emagged power control board."))
						return
					else if (malfhack)
						user.visible_message(span_notice("[user.name] discards a strangely programmed power control board from [src.name]!"),\
							span_notice("You discard the strangely programmed board."))
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(span_notice("[user.name] removes the power control board from [src.name]!"),\
							span_notice("You remove the power control board."))
						new /obj/item/electronics/apc(loc)
						return
		else if (opened!=APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_appearance()
			return
	else if (!(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			to_chat(user, span_warning("The cover is locked and cannot be opened!"))
			return
		else if (panel_open)
			to_chat(user, span_warning("Exposed wires prevents you from opening it!"))
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), span_notice("You remove \the [cell]."))
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_appearance()
			cell = null
			charging = APC_NOT_CHARGING
			update_appearance()
			return
		else
			switch (has_electronics)
				if (APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					set_machine_stat(machine_stat & ~MAINT)
					W.play_tool_sound(src)
					to_chat(user, span_notice("You screw the circuit electronics into place."))
				if (APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					set_machine_stat(machine_stat | MAINT)
					W.play_tool_sound(src)
					to_chat(user, span_notice("You unfasten the electronics."))
				else
					to_chat(user, span_warning("There is nothing to secure!"))
					return
			update_appearance()
	else if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
		return
	else
		panel_open = !panel_open
		to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
		update_appearance()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	. = ..()
	if (terminal && opened)
		terminal.dismantle(user, W)
		return TRUE


/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/W)
	. = ..()
	if (opened && !has_electronics && !terminal)
		if(!W.tool_start_check(user, amount=3))
			return
		user.visible_message(span_notice("[user.name] welds [src]."), \
							span_notice("You start welding the APC frame..."), \
							span_hear("You hear welding."))
		if(W.use_tool(src, user, 50, volume=50, amount=3))
			if ((machine_stat & BROKEN) || opened==APC_COVER_REMOVED)
				new /obj/item/stack/sheet/iron(loc)
				user.visible_message(span_notice("[user.name] cuts [src] apart with [W]."),\
					span_notice("You disassembled the broken APC frame."))
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(span_notice("[user.name] cuts [src] from the wall with [W]."),\
					span_notice("You cut the APC frame from the wall."))
			qdel(src)
			return TRUE

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)
	if(HAS_TRAIT(W, TRAIT_APC_SHOCKING))
		var/metal = 0
		var/shock_source = null
		metal += LAZYACCESS(W.custom_materials, GET_MATERIAL_REF(/datum/material/iron))//This prevents wooden rolling pins from shocking the user

		if(cell || terminal) //The mob gets shocked by whichever powersource has the most electricity
			if(cell && terminal)
				shock_source = cell.charge > terminal.powernet.avail ? cell : terminal.powernet
			else
				shock_source = terminal?.powernet || cell

		if(shock_source && metal && (panel_open || opened)) //Now you're cooking with electricity
			if(electrocute_mob(user, shock_source, src, siemens_coeff = 1, dist_check = TRUE))//People with insulated gloves just attack the APC normally. They're just short of magical anyway
				do_sparks(5, TRUE, src)
				user.visible_message(span_notice("[user.name] shoves [W] into the internal components of [src], erupting into a cascade of sparks!"))
				if(shock_source == cell)//If the shock is coming from the cell just fully discharge it, because it's funny
					cell.use(cell.charge)
				return

	if(issilicon(user) && get_dist(src,user)>1)
		return attack_hand(user)

	if (istype(W, /obj/item/stock_parts/cell) && opened)
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
			return
		else
			if (machine_stat & MAINT)
				to_chat(user, span_warning("There is no connector for your power cell!"))
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			user.visible_message(span_notice("[user.name] inserts the power cell to [src.name]!"),\
				span_notice("You insert the power cell."))
			chargecount = 0
			update_appearance()
	else if (W.GetID())
		togglelock(user)
	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if (host_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, span_warning("You must remove the floor plating in front of the APC first!"))
			return
		else if (terminal)
			to_chat(user, span_warning("This APC is already wired!"))
			return
		else if (!has_electronics)
			to_chat(user, span_warning("There is nothing to wire!"))
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, span_warning("You need ten lengths of cable for APC!"))
			return
		user.visible_message(span_notice("[user.name] adds cables to the APC frame."), \
							span_notice("You start adding cables to the APC frame..."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(do_after(user, 20, target = src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, span_notice("You add cables to the APC frame."))
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/electronics/apc) && opened)
		if (has_electronics)
			to_chat(user, span_warning("There is already a board inside the [src]!"))
			return
		else if (machine_stat & BROKEN)
			to_chat(user, span_warning("You cannot put the board inside, the frame is damaged!"))
			return

		user.visible_message(span_notice("[user.name] inserts the power control board into [src]."), \
							span_notice("You start to insert the power control board into the frame..."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(do_after(user, 10, target = src))
			if(!has_electronics)
				has_electronics = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				to_chat(user, span_notice("You place the power control board inside the frame."))
				qdel(W)
	else if(istype(W, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/P = W
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return
			if(!P.adapt_circuit(user, 50))
				return
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a power control board and click it into place in [src]'s guts."))
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return
			if(!P.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/C = new(src)
			C.forceMove(src)
			cell = C
			chargecount = 0
			user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
			span_warning("Your [P.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
			update_appearance()
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(machine_stat & BROKEN || opened==APC_COVER_REMOVED || atom_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, span_warning("You found no reason for repairing this APC!"))
			return
		if (!(machine_stat & BROKEN) && opened==APC_COVER_REMOVED) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message(span_notice("[user.name] replaces missing APC's cover."), \
							span_notice("You begin to replace APC's cover..."))
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, span_notice("You replace missing APC's cover."))
				qdel(W)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if (has_electronics)
			to_chat(user, span_warning("You cannot repair this APC until you remove the electronics still inside!"))
			return
		user.visible_message(span_notice("[user.name] replaces the damaged APC frame with a new one."), \
							span_notice("You begin to replace the damaged APC frame..."))
		if(do_after(user, 50, target = src))
			to_chat(user, span_notice("You replace the damaged APC frame with a new one."))
			qdel(W)
			set_machine_stat(machine_stat & ~BROKEN)
			atom_integrity = max_integrity
			if (opened==APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_appearance()
		return
	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, span_warning("There's no connector for a power cell."))
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 50, "cost" = 10) //16 for a wall
		else
			to_chat(user, span_warning("[src] has both electronics and a cell."))
			return FALSE
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			if(!has_electronics)
				if(machine_stat & BROKEN)
					to_chat(user, span_warning("[src]'s frame is too damaged to support a circuit."))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt a power control board and click it into place in [src]'s guts."))
				has_electronics = TRUE
				locked = TRUE
				return TRUE
			else if(!cell)
				if(machine_stat & MAINT)
					to_chat(user, span_warning("There's no connector for a power cell."))
					return FALSE
				var/obj/item/stock_parts/cell/crap/empty/C = new(src)
				C.forceMove(src)
				cell = C
				chargecount = 0
				user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
				span_warning("Your [the_rcd.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
				update_appearance()
				return TRUE
			else
				to_chat(user, span_warning("[src] has both electronics and a cell."))
				return FALSE
	return FALSE

/obj/machinery/power/apc/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/apc_interactor = user
	var/obj/item/organ/stomach/ethereal/maybe_ethereal_stomach = apc_interactor.getorganslot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_ethereal_stomach))
		togglelock(user)
	else
		if(maybe_ethereal_stomach.crystal_charge >= ETHEREAL_CHARGE_NORMAL)
			togglelock(user)
		ethereal_interact(user,modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/power/apc/proc/ethereal_interact(mob/living/user,list/modifiers)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/ethereal = user
	var/obj/item/organ/stomach/maybe_stomach = ethereal.getorganslot(ORGAN_SLOT_STOMACH)

	if(!istype(maybe_stomach, /obj/item/organ/stomach/ethereal))
		return
	var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - APC_POWER_GAIN
	var/obj/item/organ/stomach/ethereal/stomach = maybe_stomach
	if(!((stomach?.drain_time < world.time) && LAZYACCESS(modifiers, RIGHT_CLICK)))
		return
	if(ethereal.combat_mode)
		if(cell.charge <= (cell.maxcharge / 2)) // ethereals can't drain APCs under half charge, this is so that they are forced to look to alternative power sources if the station is running low
			to_chat(ethereal, span_warning("The APC's syphon safeties prevent you from draining power!"))
			return
		if(stomach.crystal_charge > charge_limit)
			to_chat(ethereal, span_warning("Your charge is full!"))
			return
		stomach.drain_time = world.time + APC_DRAIN_TIME
		to_chat(ethereal, span_notice("You start channeling some power through the APC into your body."))
		if(do_after(user, APC_DRAIN_TIME, target = src))
			if(cell.charge <= (cell.maxcharge / 2) || (stomach.crystal_charge > charge_limit))
				return
			to_chat(ethereal, span_notice("You receive some charge from the APC."))
			stomach.adjust_charge(APC_POWER_GAIN)
			cell.charge -= APC_POWER_GAIN
	else
		if(cell.charge >= cell.maxcharge - APC_POWER_GAIN)
			to_chat(ethereal, span_warning("The APC can't receive anymore power!"))
			return
		if(stomach.crystal_charge < APC_POWER_GAIN)
			to_chat(ethereal, span_warning("Your charge is too low!"))
			return
		stomach.drain_time = world.time + APC_DRAIN_TIME
		to_chat(ethereal, span_notice("You start channeling power through your body into the APC."))
		if(do_after(user, APC_DRAIN_TIME, target = src))
			if((cell.charge >= (cell.maxcharge - APC_POWER_GAIN)) || (stomach.crystal_charge < APC_POWER_GAIN))
				to_chat(ethereal, span_warning("You can't transfer power to the APC!"))
				return
			if(istype(stomach))
				to_chat(ethereal, span_notice("You transfer some power to the APC."))
				stomach.adjust_charge(-APC_POWER_GAIN)
				cell.charge += APC_POWER_GAIN
			else
				to_chat(ethereal, span_warning("You can't transfer power to the APC!"))

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
	else if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else if(panel_open)
		to_chat(user, span_warning("You must close the panel!"))
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the APC interface."))
			update_appearance()
			updateUsrDialog()
		else
			to_chat(user, span_warning("Access denied."))

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 100) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, span_warning("[src]'s night lighting circuit breaker is still cycling!"))
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(machine_stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_REMOVED
			coverlocked = FALSE
			visible_message(span_warning("The APC cover is knocked down!"))
			update_appearance()

/obj/machinery/power/apc/emag_act(mob/user)
	if(!(obj_flags & EMAGGED) && !malfhack)
		if(opened)
			to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
		else if(panel_open)
			to_chat(user, span_warning("You must close the panel first!"))
		else if(machine_stat & (BROKEN|MAINT))
			to_chat(user, span_warning("Nothing happens!"))
		else
			flick("apc-spark", src)
			playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			obj_flags |= EMAGGED
			locked = FALSE
			to_chat(user, span_notice("You emag the APC interface."))
			update_appearance()


// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), span_notice("You remove \the [cell]."))
			user.put_in_hands(cell)
			cell.update_appearance()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = display_power(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = user.has_unlimited_silicon_privilege || user.using_power_flow_console(),
		"malfStatus" = get_malf_status(user),
		"emergencyLights" = !emergency_lights,
		"nightshiftLights" = nightshift_lights,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = display_power(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on" = list("eqp" = 2),
					"off" = list("eqp" = 1),
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = display_power(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on" = list("lgt" = 2),
					"off" = list("lgt" = 1),
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = display_power(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on" = list("env" = 2),
					"off" = list("env" = 1),
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
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_total]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > APC_CHANNEL_AUTO_OFF)
		area.power_equip = (equipment > APC_CHANNEL_AUTO_OFF)
		area.power_environ = (environ > APC_CHANNEL_AUTO_OFF)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(isAdminGhostAI(user))
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
				to_chat(user, span_danger("\The [src] has been disabled!"))
			return FALSE
	return TRUE

/obj/machinery/power/apc/can_interact(mob/user)
	. = ..()
	if (!. && !QDELETED(remote_control))
		. = remote_control.can_interact(user)

/obj/machinery/power/apc/ui_status(mob/user)
	. = ..()
	if (!QDELETED(remote_control) && user == remote_control.operator)
		. = UI_INTERACTIVE

/obj/machinery/power/apc/ui_act(action, params)
	. = ..()

	if(. || !can_use(usr, 1) || (locked && !usr.has_unlimited_silicon_privilege && !failure_timer && action != "toggle_nightshift"))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((obj_flags & EMAGGED) || (machine_stat & (BROKEN|MAINT)))
					to_chat(usr, span_warning("The APC does not respond to the command!"))
				else
					locked = !locked
					update_appearance()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("toggle_nightshift")
			toggle_nightshift_lights()
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_appearance()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_appearance()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_appearance()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_appearance()
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
			update_appearance()
			update()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/L in area)
				if(!initial(L.no_emergency)) //If there was an override set on creation, keep that override
					L.no_emergency = emergency_lights
					INVOKE_ASYNC(L, /obj/machinery/light/.proc/update, FALSE)
				CHECK_TICK
	return TRUE

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(!is_operational || failure_timer)
		return
	operating = !operating
	add_hiddenprint(user)
	log_game("[key_name(user)] turned [operating ? "on" : "off"] the [src] in [AREACOORD(src)]")
	update()
	update_appearance()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != 1)
		return
	if(malf.malfhacking)
		to_chat(malf, span_warning("You are already hacking an APC!"))
		return
	to_chat(malf, span_notice("Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process."))
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, /mob/living/silicon/ai/.proc/malfhacked, src), 600, TIMER_STOPPABLE)

	var/atom/movable/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /atom/movable/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, span_warning("You must evacuate your current APC first!"))
		return
	if(!malf.can_shunt)
		to_chat(malf, span_warning("You cannot shunt!"))
		return
	if(!is_station_level(z))
		return
	malf.ShutOffDoomsdayDevice()
	occupier = new /mob/living/silicon/ai(src, malf.laws, malf) //DEAR GOD WHY? //IKR????
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = TRUE
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
		disk_pinpointers.switch_mode_to(TRACK_MALF_AI) //Pinpointer will track the shunted AI
	var/datum/action/innate/core_return/CR = new
	CR.Grant(occupier)
	occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = FALSE
		occupier.parent.setOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		qdel(occupier)
	else
		to_chat(occupier, span_danger("Primary core damaged, unable to return core processes."))
		if(forced)
			occupier.forceMove(drop_location())
			INVOKE_ASYNC(occupier, /mob/living/proc/death)
			occupier.gib()

	if(!occupier.nuking) //Pinpointers go back to tracking the nuke disk, as long as the AI (somehow) isn't mid-nuking.
		for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
			disk_pinpointers.switch_mode_to(TRACK_NUKE_DISK)
			disk_pinpointers.alert = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(card.AI)
		to_chat(user, span_warning("[card] is already occupied!"))
		return
	if(!occupier)
		to_chat(user, span_warning("There's nothing in [src] to transfer!"))
		return
	if(!occupier.mind || !occupier.client)
		to_chat(user, span_warning("[occupier] is either inactive or destroyed!"))
		return
	if(!occupier.parent.stat)
		to_chat(user, span_warning("[occupier] is refusing all attempts at transfer!") )
		return
	if(transfer_in_progress)
		to_chat(user, span_warning("There's already a transfer in progress!"))
		return
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return
	var/turf/T = get_turf(user)
	if(!T)
		return
	transfer_in_progress = TRUE
	user.visible_message(span_notice("[user] slots [card] into [src]..."), span_notice("Transfer process initiated. Sending request for AI approval..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SEND_SOUND(occupier, sound('sound/misc/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(tgui_alert(occupier, "[user] is attempting to transfer you to \a [card.name]. Do you consent to this?", "APC Transfer", list("Yes - Transfer Me", "No - Keep Me Here")) == "No - Keep Me Here")
		to_chat(user, span_danger("AI denied transfer request. Process terminated."))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		transfer_in_progress = FALSE
		return
	if(user.loc != T)
		to_chat(user, span_danger("Location changed. Process terminated."))
		to_chat(occupier, span_warning("[user] moved away! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	to_chat(user, span_notice("AI accepted request. Transferring stored intelligence to [card]..."))
	to_chat(occupier, span_notice("Transfer starting. You will be moved to [card] shortly."))
	if(!do_after(user, 50, target = src))
		to_chat(occupier, span_warning("[user] was interrupted! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return
	user.visible_message(span_notice("[user] transfers [occupier] to [card]!"), span_notice("Transfer complete! [occupier] is now stored in [card]."))
	to_chat(occupier, span_notice("Transfer complete! You've been stored in [user]'s [card.name]."))
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
	if(terminal?.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail(amount)
	if(terminal)
		return terminal.avail(amount)
	else
		return 0

/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_appearance()
	if(machine_stat & (BROKEN|MAINT))
		return
	if(!area || !area.requires_power)
		return
	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = TRUE
		return

	//dont use any power from that channel if we shut that power channel off
	lastused_light = APC_CHANNEL_IS_ON(lighting) ? area.power_usage[AREA_USAGE_LIGHT] + area.power_usage[AREA_USAGE_STATIC_LIGHT] : 0
	lastused_equip = APC_CHANNEL_IS_ON(equipment) ? area.power_usage[AREA_USAGE_EQUIP] + area.power_usage[AREA_USAGE_STATIC_EQUIP] : 0
	lastused_environ = APC_CHANNEL_IS_ON(environ) ? area.power_usage[AREA_USAGE_ENVIRON] + area.power_usage[AREA_USAGE_STATIC_ENVIRON] : 0
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!avail())
		main_status = APC_NO_POWER
	else if(excess < 0)
		main_status = APC_LOW_POWER
	else
		main_status = APC_HAS_POWER

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, lastused_total JOULES) // clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total) // if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused WATTS) // add the load used to recharge the cell


		else // no excess, and not enough per-apc
			if((cell.charge WATTS + excess) >= lastused_total) // can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + excess JOULES) //recharge with what we can
				add_load(excess) // so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else // not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, AUTOSET_FORCE_OFF)
				lighting = autoset(lighting, AUTOSET_FORCE_OFF)
				environ = autoset(environ, AUTOSET_FORCE_OFF)


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge <= 0) // zero charge, turn all off
			equipment = autoset(equipment, AUTOSET_FORCE_OFF)
			lighting = autoset(lighting, AUTOSET_FORCE_OFF)
			environ = autoset(environ, AUTOSET_FORCE_OFF)
			alarm_manager.send_alarm(ALARM_POWER)
		else if(cell.percent() < 15 && longtermpower < 0) // <15%, turn off lighting & equipment
			equipment = autoset(equipment, AUTOSET_OFF)
			lighting = autoset(lighting, AUTOSET_OFF)
			environ = autoset(environ, AUTOSET_ON)
			alarm_manager.send_alarm(ALARM_POWER)
		else if(cell.percent() < 30 && longtermpower < 0) // <30%, turn off equipment
			equipment = autoset(equipment, AUTOSET_OFF)
			lighting = autoset(lighting, AUTOSET_ON)
			environ = autoset(environ, AUTOSET_ON)
			alarm_manager.send_alarm(ALARM_POWER)
		else // otherwise all can be on
			equipment = autoset(equipment, AUTOSET_ON)
			lighting = autoset(lighting, AUTOSET_ON)
			environ = autoset(environ, AUTOSET_ON)
			if(cell.percent() > 75)
				alarm_manager.clear_alarm(ALARM_POWER)


		// now trickle-charge the cell
		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0) // check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess JOULES, cell.maxcharge JOULES)
				add_load(ch WATTS) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING // stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else // chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

	else // no cell, switch everything off

		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, AUTOSET_FORCE_OFF)
		lighting = autoset(lighting, AUTOSET_FORCE_OFF)
		environ = autoset(environ, AUTOSET_FORCE_OFF)
		alarm_manager.send_alarm(ALARM_POWER)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

/**
 * Returns the new status value for an APC channel.
 *
 * // val 0=off, 1=off(auto) 2=on 3=on(auto)
 * // on 0=off, 1=on, 2=autooff
 * TODO: Make this use bitflags instead. It should take at most three lines, but it's out of scope for now.
 *
 * Arguments:
 * - val: The current status of the power channel.
 *   - [APC_CHANNEL_OFF]: The APCs channel has been manually set to off. This channel will not automatically change.
 *   - [APC_CHANNEL_AUTO_OFF]: The APCs channel is running on automatic and is currently off. Can be automatically set to [APC_CHANNEL_AUTO_ON].
 *   - [APC_CHANNEL_ON]: The APCs channel has been manually set to on. This will be automatically changed only if the APC runs completely out of power or is disabled.
 *   - [APC_CHANNEL_AUTO_ON]: The APCs channel is running on automatic and is currently on. Can be automatically set to [APC_CHANNEL_AUTO_OFF].
 * - on: An enum dictating how to change the channel's status.
 *   - [AUTOSET_FORCE_OFF]: The APC forces the channel to turn off. This includes manually set channels.
 *   - [AUTOSET_ON]: The APC allows automatic channels to turn back on.
 *   - [AUTOSET_OFF]: The APC turns automatic channels off.
 */
/obj/machinery/power/apc/proc/autoset(val, on)
	switch(on)
		if(AUTOSET_FORCE_OFF)
			if(val == APC_CHANNEL_ON) // if on, return off
				return APC_CHANNEL_OFF
			else if(val == APC_CHANNEL_AUTO_ON) // if auto-on, return auto-off
				return APC_CHANNEL_AUTO_OFF
		if(AUTOSET_ON)
			if(val == APC_CHANNEL_AUTO_OFF) // if auto-off, return auto-on
				return APC_CHANNEL_AUTO_ON
		if(AUTOSET_OFF)
			if(val == APC_CHANNEL_AUTO_ON) // if auto-on, return auto-off
				return APC_CHANNEL_AUTO_OFF
	return val

/**
 * Used by external forces to set the APCs channel status's.
 *
 * Arguments:
 * - val: The desired value of the subsystem:
 *   - 1: Manually sets the APCs channel to be [APC_CHANNEL_OFF].
 *   - 2: Manually sets the APCs channel to be [APC_CHANNEL_AUTO_ON]. If the APC doesn't have any power this defaults to [APC_CHANNEL_OFF] instead.
 *   - 3: Sets the APCs channel to be [APC_CHANNEL_AUTO_ON]. If the APC doesn't have enough power this defaults to [APC_CHANNEL_AUTO_OFF] instead.
 */
/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val == 1) ? APC_CHANNEL_OFF : val
	if(val == 3)
		return APC_CHANNEL_AUTO_OFF
	return APC_CHANNEL_OFF

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
			equipment = APC_CHANNEL_AUTO_ON
			environ = APC_CHANNEL_AUTO_ON
			update_appearance()
			update()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_CONTENTS))
		if(cell)
			cell.emp_act(severity)
		if(occupier)
			occupier.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	lighting = APC_CHANNEL_OFF
	equipment = APC_CHANNEL_OFF
	environ = APC_CHANNEL_OFF
	update_appearance()
	update()
	addtimer(CALLBACK(src, .proc/reset, APC_RESET_EMP), 600)

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	operating = FALSE
	atom_break()
	if(occupier)
		malfvacate(TRUE)
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, .proc/break_lights)

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in area)
		L.on = TRUE
		L.break_light_tube()
		stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return FALSE
	if(electrocute_mob(user, src, src, 1, TRUE))
		return TRUE
	else
		return FALSE


/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/M in area.contents)
		if(M.critical_machine)
			return
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/I = A
		if(get_area(I) == area)
			return

	failure_timer = max(failure_timer, round(duration))

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	// APC being at 0 integrity doesnt delete it outright. Combined with take_damage this might cause runtimes.
	if(machine_stat & BROKEN && atom_integrity <= 0)
		if(sound_effect)
			play_attack_sound(damage_amount, damage_type, damage_flag)
		return
	return ..()

#undef APC_CHANNEL_OFF
#undef APC_CHANNEL_AUTO_OFF
#undef APC_CHANNEL_ON
#undef APC_CHANNEL_AUTO_ON

#undef AUTOSET_FORCE_OFF
#undef AUTOSET_OFF
#undef AUTOSET_ON

#undef APC_PIXEL_OFFSET

#undef APC_NO_POWER
#undef APC_LOW_POWER
#undef APC_HAS_POWER

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED

#undef APC_DRAIN_TIME
#undef APC_POWER_GAIN

#undef APC_RESET_EMP

// update_state
#undef UPSTATE_CELL_IN
#undef UPSTATE_COVER_SHIFT
#undef UPSTATE_BROKE
#undef UPSTATE_MAINT
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP

//update_overlay
#undef UPOVERLAY_OPERATING
#undef UPOVERLAY_LOCKED
#undef UPOVERLAY_CHARGING_SHIFT
#undef UPOVERLAY_EQUIPMENT_SHIFT
#undef UPOVERLAY_LIGHTING_SHIFT
#undef UPOVERLAY_ENVIRON_SHIFT

/*Power module, used for APC construction*/
/obj/item/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
