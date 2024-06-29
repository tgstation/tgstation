/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/machines/button.dmi'
	base_icon_state = "button"
	icon_state = "button"
	power_channel = AREA_USAGE_ENVIRON
	/// How long to animate our success for
	var/success_delay = 1 SECONDS
	/// How long to animate failure to activate for
	var/deny_delay = 3 SECONDS
	/// Mutable appearance that holds our current emissive state
	var/mutable_appearance/glow
	/// Timer id of the current animation that's running, if any exists
	var/anim_timer
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
	var/initialized_button = 0
	var/silicon_access_disabled = FALSE
	// Is this button meant to draw on a table
	var/on_table = FALSE

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button)

/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/indestructible)

/datum/armor/machinery_button
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 10
	fire = 90
	acid = 70

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
	update_glow()
	if(!on_table)
		find_and_hang_on_wall()

/obj/machinery/button/Destroy()
	QDEL_NULL(device)
	QDEL_NULL(board)
	return ..()

/obj/machinery/button/update_icon_state()
	if(!(panel_open && machine_stat & (NOPOWER|BROKEN)))
		return ..()
	halt_animation()
	icon_state = "[base_icon_state]"
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
		. += "[base_icon_state]-board"
	if(panel_open && device)
		if(istype(device, /obj/item/assembly/signaler))
			. += "[base_icon_state]-signaler"
		else
			. += "[base_icon_state]-device"

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += glow

/obj/machinery/button/proc/update_glow()
	make_glow()
	update_appearance()

/obj/machinery/button/proc/make_glow()
	// Icon state so this works for success/failure cases. The sprites finish forever on the base sprite so it's... fine this way
	glow = emissive_appearance(icon, "[icon_state]-mask", src, alpha = src.alpha)

/obj/machinery/button/proc/start_animation(delay)
	halt_animation()
	anim_timer = addtimer(CALLBACK(src, PROC_REF(halt_animation)), delay, TIMER_CLIENT_TIME|TIMER_STOPPABLE|TIMER_UNIQUE)

/obj/machinery/button/proc/halt_animation()
	if(!anim_timer)
		return
	deltimer(anim_timer)
	anim_timer = null
	icon_state = base_icon_state
	update_glow()
	update_appearance()

/obj/machinery/button/screwdriver_act(mob/living/user, obj/item/tool)
	if(panel_open || allowed(user))
		default_deconstruction_screwdriver(user, "[base_icon_state]-open", base_icon_state, tool)
		update_appearance()
	else
		balloon_alert(user, "access denied")
		icon_state = "[base_icon_state]-denied"
		update_glow()
		start_animation(deny_delay)

	return TRUE

/obj/machinery/button/attackby(obj/item/W, mob/living/user, params)
	if(panel_open)
		if(!device && isassembly(W))
			if(!user.transferItemToLoc(W, src))
				to_chat(user, span_warning("\The [W] is stuck to you!"))
				return
			device = W
			to_chat(user, span_notice("You add [W] to the button."))

		if(!board && istype(W, /obj/item/electronics/airlock))
			if(!user.transferItemToLoc(W, src))
				to_chat(user, span_warning("\The [W] is stuck to you!"))
				return
			board = W
			if(board.one_access)
				req_one_access = board.accesses
			else
				req_access = board.accesses
			balloon_alert(user, "electronics added")
			to_chat(user, span_notice("You add [W] to the button."))

		if(!device && !board && W.tool_behaviour == TOOL_WRENCH)
			to_chat(user, span_notice("You start unsecuring the button frame..."))
			W.play_tool_sound(src)
			if(W.use_tool(src, user, 40))
				to_chat(user, span_notice("You unsecure the button frame."))
				transfer_fingerprints_to(new /obj/item/wallframe/button(get_turf(src)))
				playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
				qdel(src)

		update_appearance()
		return

	if(!user.combat_mode && !(W.item_flags & NOBLUDGEON))
		return attack_hand(user)
	else
		return ..()

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
		return attack_hand(user)

/obj/machinery/button/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/button/examine(mob/user)
	. = ..()
	if(!panel_open)
		return
	if(device)
		. += span_notice("There is \a [device] inside, which could be removed with an <b>empty hand</b>.")
	if(board)
		. += span_notice("There is \a [board] inside, which could be removed with an <b>empty hand</b>.")
	if(!board && !device)
		. += span_notice("There is nothing currently installed in \the [src].")

/obj/machinery/button/proc/setup_device()
	if(id && istype(device, /obj/item/assembly/control))
		var/obj/item/assembly/control/A = device
		A.id = id
	initialized_button = 1

/obj/machinery/button/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(id)
		id = "[port.shuttle_id]_[id]"
		setup_device()

/obj/machinery/button/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!initialized_button)
		setup_device()
	add_fingerprint(user)
	if(panel_open)
		if(device || board)
			if(device)
				user.put_in_hands(device)
				device = null
			if(board)
				user.put_in_hands(board)
				req_access = list()
				req_one_access = list()
				board = null
			update_appearance(UPDATE_ICON)
			balloon_alert(user, "electronics removed")
			to_chat(user, span_notice("You remove electronics from the button frame."))

		else if(can_alter_skin)
			if(base_icon_state == "button")
				base_icon_state = "launcher"
				icon_state = "launcher"
				to_chat(user, span_notice("You change the button frame's front panel to be trimmer."))
			else if (base_icon_state == "launcher")
				base_icon_state = "button"
				icon_state = "button"
				to_chat(user, span_notice("You change the button frame's front panel to default."))
			update_glow()
			balloon_alert(user, "swapped style")

	if((machine_stat & (NOPOWER|BROKEN)))
		return

	if(device && device.next_activate > world.time)
		return

	if(!allowed(user))
		balloon_alert(user, "access denied")
		icon_state = "[base_icon_state]-denied"
		update_glow()
		start_animation(deny_delay)
		return

	use_energy(5 JOULES)
	start_animation(success_delay)

	if(device)
		device.pulsed(user)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BUTTON_PRESSED,src)

/**
 * Called when the mounted button's wall is knocked down.
 */
/obj/machinery/button/proc/knock_down()
	if(device)
		device.forceMove(get_turf(src))
		device = null
	if(board)
		board.forceMove(get_turf(src))
		req_access = list()
		req_one_access = list()
		board = null
	qdel(src)

/obj/machinery/button/door
	name = "door button"
	desc = "A door remote control switch."
	var/normaldoorcontrol = FALSE
	var/specialfunctions = OPEN // Bitflag, see assembly file
	var/sync_doors = TRUE

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door)

/obj/machinery/button/door/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/indestructible)

/obj/machinery/button/door/setup_device()
	if(!device)
		if(normaldoorcontrol)
			var/obj/item/assembly/control/airlock/A = new(src)
			A.specialfunctions = specialfunctions
			device = A
		else
			var/obj/item/assembly/control/C = new(src)
			C.sync_doors = sync_doors
			device = C
	..()

/obj/machinery/button/door/incinerator_vent_ordmix
	name = "combustion chamber vent control"
	id = INCINERATOR_ORDMIX_VENT
	req_access = list(ACCESS_ORDNANCE)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/incinerator_vent_ordmix)

/obj/machinery/button/door/incinerator_vent_atmos_main
	name = "turbine vent control"
	id = INCINERATOR_ATMOS_MAINVENT
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/incinerator_vent_atmos_main)

/obj/machinery/button/door/incinerator_vent_atmos_aux
	name = "combustion chamber vent control"
	id = INCINERATOR_ATMOS_AUXVENT
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/incinerator_vent_atmos_aux)

/obj/machinery/button/door/atmos_test_room_mainvent_1
	name = "test chamber 1 vent control"
	id = TEST_ROOM_ATMOS_MAINVENT_1
	req_one_access = list(ACCESS_ATMOSPHERICS)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/atmos_test_room_mainvent_1)

/obj/machinery/button/door/atmos_test_room_mainvent_2
	name = "test chamber 2 vent control"
	id = TEST_ROOM_ATMOS_MAINVENT_2
	req_one_access = list(ACCESS_ATMOSPHERICS)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/atmos_test_room_mainvent_2)

/obj/machinery/button/door/incinerator_vent_syndicatelava_main
	name = "turbine vent control"
	id = INCINERATOR_SYNDICATELAVA_MAINVENT
	req_access = list(ACCESS_SYNDICATE)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/incinerator_vent_syndicatelava_main)

/obj/machinery/button/door/incinerator_vent_syndicatelava_aux
	name = "combustion chamber vent control"
	id = INCINERATOR_SYNDICATELAVA_AUXVENT
	req_access = list(ACCESS_SYNDICATE)

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/door/incinerator_vent_syndicatelava_aux)

/obj/machinery/button/massdriver
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon_state = "launcher"
	base_icon_state = "launcher"
	device_type = /obj/item/assembly/control/massdriver

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/massdriver)

/obj/machinery/button/massdriver/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/massdriver/indestructible)

/obj/machinery/button/ignition
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."
	icon_state = "launcher"
	base_icon_state = "launcher"
	device_type = /obj/item/assembly/control/igniter

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition)

/obj/machinery/button/ignition/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition/indestructible)

/obj/machinery/button/ignition/incinerator
	name = "combustion chamber ignition switch"
	desc = "A remote control switch for the combustion chamber's igniter."

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition/incinerator)

/obj/machinery/button/ignition/incinerator/ordmix
	id = INCINERATOR_ORDMIX_IGNITER

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition/incinerator/ordmix)

/obj/machinery/button/ignition/incinerator/atmos
	id = INCINERATOR_ATMOS_IGNITER

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition/incinerator/atmos)

/obj/machinery/button/ignition/incinerator/syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/ignition/incinerator/syndicatelava)

/obj/machinery/button/flasher
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon_state = "launcher"
	base_icon_state = "launcher"
	device_type = /obj/item/assembly/control/flasher

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/flasher)

/obj/machinery/button/flasher/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/flasher/indestructible)

/obj/machinery/button/curtain
	name = "curtain button"
	desc = "A remote control switch for a mechanical curtain."
	icon_state = "launcher"
	base_icon_state = "launcher"
	device_type = /obj/item/assembly/control/curtain
	var/sync_doors = TRUE

/obj/machinery/button/curtain/setup_device()
	var/obj/item/assembly/control/curtain = device
	curtain.sync_doors = sync_doors
	return ..()

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/curtain)

/obj/machinery/button/crematorium
	name = "crematorium igniter"
	desc = "Burn baby burn!"
	icon_state = "launcher"
	base_icon_state = "launcher"
	device_type = /obj/item/assembly/control/crematorium
	req_access = list()
	id = 1

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/crematorium)

/obj/machinery/button/crematorium/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

BUTTON_DIRECTIONAL_HELPERS(/obj/machinery/button/crematorium/indestructible)

/obj/item/wallframe/button
	name = "button frame"
	desc = "Used for building buttons."
	icon = 'icons/obj/machines/button.dmi'
	icon_state = "button"
	result_path = /obj/machinery/button
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 24
