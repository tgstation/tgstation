/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/machines/wallmounts.dmi'
	base_icon_state = "button"
	icon_state = "button"
	power_channel = AREA_USAGE_ENVIRON
	light_power = 0.5 // Minimums, we want the button to glow if it has a mask, not light an area
	light_range = 1.5
	light_color = LIGHT_COLOR_VIVID_GREEN
	armor_type = /datum/armor/machinery_button
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_OPEN
	///Icon suffix for the skin of the front pannel that is added to base_icon_state
	var/skin = ""
	///Whether it is possible to change the panel skin
	var/can_alter_skin = TRUE

	var/obj/item/assembly/device
	var/obj/item/electronics/airlock/board
	var/device_type = null
	var/id = null
	var/initialized_button = FALSE
	var/silicon_access_disabled = FALSE

/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/datum/armor/machinery_button
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 10
	fire = 90
	acid = 70

/**
 * INITIALIZATION
 */

/obj/machinery/button/Initialize(mapload, ndir = 0, built = 0)
	. = ..()
	if(built)
		setDir(ndir)
		set_panel_open(TRUE)
		update_appearance()

	if(!built && !device && device_type)
		device = new device_type(src)

	check_access(null)

	if(length(req_access) || length(req_one_access))
		board = new(src)
		if(length(req_access))
			board.accesses = req_access
		else
			board.one_access = 1
			board.accesses = req_one_access

	setup_device()
	find_and_hang_on_wall()
	register_context()

/obj/machinery/button/proc/setup_device()
	if(id && istype(device, /obj/item/assembly/control))
		var/obj/item/assembly/control/control_device = device
		control_device.id = id
	initialized_button = TRUE

/obj/machinery/button/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(id)
		id = "[port.shuttle_id]_[id]"
		setup_device()


/**
 * APPEARANCE
 */

/obj/machinery/button/update_icon_state()
	icon_state = "[base_icon_state][skin]"
	if(panel_open)
		icon_state += "-open"
	else if(machine_stat & (NOPOWER|BROKEN))
		icon_state += "-nopower"
	return ..()

/obj/machinery/button/update_appearance()
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)))
		set_light(0)
	else
		set_light(initial(light_range), light_power, light_color)

/obj/machinery/button/update_overlays()
	. = ..()

	if(panel_open && board)
		. += "[base_icon_state]-overlay-board"
	if(panel_open && device)
		if(istype(device, /obj/item/assembly/signaler))
			. += "[base_icon_state]-overlay-signaler"
		else
			. += "[base_icon_state]-overlay-device"

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, "[base_icon_state]-light-mask", src, alpha = src.alpha)

/obj/machinery/button/on_set_panel_open(old_value)
	if(panel_open) // Only allow renaming while the panel is open
		obj_flags |= UNIQUE_RENAME
	else
		obj_flags &= ~UNIQUE_RENAME


/**
 * INTERACTION
 */

/obj/machinery/button/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!panel_open)
		return NONE

	if(isassembly(tool))
		return assembly_act(user, tool)
	else if(istype(tool, /obj/item/electronics/airlock))
		return airlock_electronics_act(user, tool)

/obj/machinery/button/proc/assembly_act(mob/living/user, obj/item/assembly/new_device)
	if(device)
		to_chat(user, span_warning("The button already contains a device!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_device, src, silent = FALSE))
		to_chat(user, span_warning("\The [new_device] is stuck to you!"))
		return ITEM_INTERACT_BLOCKING

	device = new_device
	to_chat(user, span_notice("You add \the [new_device] to the button."))

	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/button/proc/airlock_electronics_act(mob/living/user, obj/item/electronics/airlock/new_board)
	if(board)
		to_chat(user, span_warning("The button already contains a board!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_board, src, silent = FALSE))
		to_chat(user, span_warning("\The [new_board] is stuck to you!"))
		return ITEM_INTERACT_BLOCKING

	board = new_board
	if(board.one_access)
		req_one_access = board.accesses
	else
		req_access = board.accesses
	to_chat(user, span_notice("You add \the [new_board] to the button."))

	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/button/screwdriver_act(mob/living/user, obj/item/tool)
	if(panel_open || allowed(user))
		default_deconstruction_screwdriver(user, "[base_icon_state][skin]-open", "[base_icon_state][skin]", tool)
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "access denied")
	flick_overlay_view("[base_icon_state]-overlay-error", 1 SECONDS)
	return ITEM_INTERACT_BLOCKING

/obj/machinery/button/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open button first!")
		return ITEM_INTERACT_BLOCKING

	if(device || board)
		balloon_alert(user, "empty button first!")
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You start unsecuring the button frame..."))
	if(tool.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You unsecure the button frame."))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/machinery/button/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	// This is in here so it's called only after every other item interaction.
	if(!user.combat_mode && !(tool.item_flags & NOBLUDGEON) && !panel_open)
		return attempt_press(user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING


/obj/machinery/button/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	req_access = list()
	req_one_access = list()
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	obj_flags |= EMAGGED

	// The device inside can be emagged by swiping the button
	// returning TRUE will prevent feedback (so we can do our own)
	if(!device?.emag_act(user, emag_card))
		balloon_alert(user, "access overridden")
	return TRUE


/obj/machinery/button/attack_ai(mob/user)
	if(!silicon_access_disabled && !panel_open)
		return attempt_press(user)

/obj/machinery/button/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/button/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!initialized_button)
		setup_device()
	add_fingerprint(user)

	if(!panel_open)
		attempt_press(user)
		return

	if(board)
		remove_airlock_electronics(user)
		return
	if(device)
		remove_assembly(user)
		return

	if(can_alter_skin)
		if(skin == "")
			skin = "-warning"
			to_chat(user, span_notice("You change the button frame's front panel to warning lines."))
		else
			skin = ""
			to_chat(user, span_notice("You change the button frame's front panel to default."))
		update_appearance(UPDATE_ICON)
		balloon_alert(user, "style swapped")

/obj/machinery/button/attack_hand_secondary(mob/user, list/modifiers)
	if(!initialized_button)
		setup_device()
	add_fingerprint(user)

	if(!panel_open)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(device)
		remove_assembly(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(board)
		remove_airlock_electronics(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/machinery/button/proc/remove_assembly(mob/user)
	user.put_in_hands(device)
	to_chat(user, span_notice("You remove \the [device] from the button frame."))
	device = null
	update_appearance(UPDATE_ICON)

/obj/machinery/button/proc/remove_airlock_electronics(mob/user)
	user.put_in_hands(board)
	to_chat(user, span_notice("You remove the board from the button frame."))
	req_access = list()
	req_one_access = list()
	board = null
	update_appearance(UPDATE_ICON)

/obj/machinery/button/proc/attempt_press(mob/user)
	if((machine_stat & (NOPOWER|BROKEN)))
		return FALSE

	if(device && device.next_activate > world.time)
		return FALSE

	if(!allowed(user))
		balloon_alert(user, "access denied")
		flick_overlay_view("[base_icon_state]-overlay-error", 1 SECONDS)
		return FALSE

	use_energy(5 JOULES)
	flick_overlay_view("[base_icon_state]-overlay-success", 1 SECONDS)

	if(device)
		device.pulsed(user)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BUTTON_PRESSED, src)
	return TRUE


/**
 * DECONSTRUCTION
 */

/obj/machinery/button/on_deconstruction(disassembled)
	var/obj/item/wallframe/button/dropped_frame = new /obj/item/wallframe/button(drop_location())
	transfer_fingerprints_to(dropped_frame)

/obj/machinery/button/dump_inventory_contents(list/subset)
	. = ..()
	device = null
	board = null
	req_access = list()
	req_one_access = list()


/**
 * INFORMATION
 */

/obj/machinery/button/examine(mob/user)
	. = ..()
	if(!panel_open)
		return
	if(device)
		. += span_notice("There is \a [device] inside, which could be removed with an <b>empty hand</b>.")
	if(board)
		. += span_notice("There is \a [board] inside, which could be removed with an <b>empty hand</b>.")
	if(isnull(board) && isnull(device))
		. += span_notice("There is nothing currently installed in \the [src].")

/obj/machinery/button/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(panel_open)
		if(isnull(held_item))
			if(board && device)
				context[SCREENTIP_CONTEXT_LMB] = "Remove Board"
				context[SCREENTIP_CONTEXT_RMB] = "Remove Device"
				return CONTEXTUAL_SCREENTIP_SET
			else if(board)
				context[SCREENTIP_CONTEXT_LMB] = "Remove Board"
				return CONTEXTUAL_SCREENTIP_SET
			else if(device)
				context[SCREENTIP_CONTEXT_LMB] = "Remove Device"
				return CONTEXTUAL_SCREENTIP_SET
			else if(can_alter_skin)
				context[SCREENTIP_CONTEXT_LMB] = "Swap Style"
				return CONTEXTUAL_SCREENTIP_SET
		else if(isassembly(held_item))
			context[SCREENTIP_CONTEXT_LMB] = "Install Device"
			return CONTEXTUAL_SCREENTIP_SET
		else if(istype(held_item, /obj/item/electronics/airlock))
			context[SCREENTIP_CONTEXT_LMB] = "Install Board"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct Button"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Close Button"
			return CONTEXTUAL_SCREENTIP_SET
	else
		if(isnull(held_item))
			context[SCREENTIP_CONTEXT_LMB] = "Press Button"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Open Button"
			return CONTEXTUAL_SCREENTIP_SET

	return NONE


/**
 * MAPPING PRESETS
 */

/obj/machinery/button/door
	name = "door button"
	desc = "A door remote control switch."
	var/normaldoorcontrol = FALSE
	var/specialfunctions = OPEN // Bitflag, see assembly file
	var/sync_doors = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/door, 24)

/obj/machinery/button/door/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button/door/setup_device()
	if(!device)
		if(normaldoorcontrol)
			var/obj/item/assembly/control/airlock/airlock_device = new(src)
			airlock_device.specialfunctions = specialfunctions
			device = airlock_device
		else
			var/obj/item/assembly/control/control_device = new(src)
			control_device.sync_doors = sync_doors
			device = control_device
	..()

/obj/machinery/button/door/incinerator_vent_ordmix
	name = "combustion chamber vent control"
	id = INCINERATOR_ORDMIX_VENT
	req_access = list(ACCESS_ORDNANCE)

/obj/machinery/button/door/incinerator_vent_atmos_main
	name = "turbine vent control"
	id = INCINERATOR_ATMOS_MAINVENT
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS)

/obj/machinery/button/door/incinerator_vent_atmos_aux
	name = "combustion chamber vent control"
	id = INCINERATOR_ATMOS_AUXVENT
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS)

/obj/machinery/button/door/atmos_test_room_mainvent_1
	name = "test chamber 1 vent control"
	id = TEST_ROOM_ATMOS_MAINVENT_1
	req_one_access = list(ACCESS_ATMOSPHERICS)

/obj/machinery/button/door/atmos_test_room_mainvent_2
	name = "test chamber 2 vent control"
	id = TEST_ROOM_ATMOS_MAINVENT_2
	req_one_access = list(ACCESS_ATMOSPHERICS)

/obj/machinery/button/door/incinerator_vent_syndicatelava_main
	name = "turbine vent control"
	id = INCINERATOR_SYNDICATELAVA_MAINVENT
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/button/door/incinerator_vent_syndicatelava_aux
	name = "combustion chamber vent control"
	id = INCINERATOR_SYNDICATELAVA_AUXVENT
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/button/massdriver
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/massdriver

/obj/machinery/button/massdriver/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button/ignition
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/igniter

/obj/machinery/button/ignition/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button/ignition/incinerator
	name = "combustion chamber ignition switch"
	desc = "A remote control switch for the combustion chamber's igniter."

/obj/machinery/button/ignition/incinerator/ordmix
	id = INCINERATOR_ORDMIX_IGNITER

/obj/machinery/button/ignition/incinerator/atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/button/ignition/incinerator/syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/button/flasher
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/flasher

/obj/machinery/button/flasher/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button/curtain
	name = "curtain button"
	desc = "A remote control switch for a mechanical curtain."
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/curtain
	var/sync_doors = TRUE

/obj/machinery/button/curtain/setup_device()
	var/obj/item/assembly/control/curtain = device
	curtain.sync_doors = sync_doors
	return ..()

/obj/machinery/button/crematorium
	name = "crematorium igniter"
	desc = "Burn baby burn!"
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/crematorium
	req_access = list()
	id = 1

/obj/machinery/button/crematorium/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/wallframe/button
	name = "button frame"
	desc = "Used for building buttons."
	icon_state = "button"
	result_path = /obj/machinery/button
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 24
