#define ADD_TREADS_STEP 1
#define CONNECT_HYDRAULICS_STEP 2
#define ACTIVATE_HYDRAULICS_STEP 3
#define ADD_WIRING_STEP 4
#define ADJUST_WIRING_STEP 5
#define ADD_CONTROL_MODULE_STEP 6
#define SECURE_CONTROL_MODULE_STEP 7
#define ADD_PERIPHERALS_STEP 8
#define SECURE_PERIPHERALS_STEP 9
#define ADD_WEAPONS_CONTROLS_STEP 10
#define SECURE_WEAPONS_CONTROLS_STEP 11
#define ADD_SCANNING_MODULE_STEP 12
#define SECURE_SCANNING_MODULE_STEP 13
#define ADD_CAPACITOR_STEP 14
#define SECURE_CAPACITOR_STEP 15
#define INSTALL_BLUESPACE_STEP 16
#define CONNECT_BLUESPACE_STEP 17
#define ENGAGE_BLUESPACE_STEP 18
#define ADD_CELL_STEP 19
#define SECURE_CELL_STEP 20
#define ADD_INTERNAL_ARMOR_STEP 21
#define SECURE_INTERNAL_ARMOR_STEP 22
#define WELD_INTERNAL_ARMOR_STEP 23
#define ADD_EXTERNAL_ARMOR_STEP 24
#define SECURE_EXTERNAL_ARMOR_STEP 25
#define WELD_EXTERNAL_ARMOR_STEP 26
#define INSERT_ANOMALY_CORE_STEP 27

////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/component/construction/mecha
	var/base_icon

	/// What construction step we're on for displaying messages to viewers
	var/message_step = 1
	/// If this mech has treads (Clarke)
	var/has_treads = FALSE
	/// If this mech has a weapons control module (Gygax, Durand, etc.)
	var/has_weapons_module = FALSE
	/// If this mech has a bluespace crystal in construction (Phazon)
	var/has_bluespace_crystal = FALSE

	// Component typepaths.
	// most must be defined unless
	// get_steps is overriden.

	// Circuit board typepaths.
	// circuit_control and circuit_periph must be defined
	// unless get_circuit_steps is overriden.
	var/circuit_control
	var/circuit_periph
	var/circuit_weapon

	// Armor plating typepaths. both must be defined
	// unless relevant step procs are overriden. amounts
	// must be defined if using /obj/item/stack/sheet types
	var/inner_plating
	var/inner_plating_amount

	var/outer_plating
	var/outer_plating_amount

/datum/component/construction/mecha/spawn_result()
	if(!result)
		return
	// Remove default mech power cell, as we replace it with a new one.
	var/obj/vehicle/sealed/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)
	QDEL_NULL(M.scanmod)
	QDEL_NULL(M.capacitor)

	var/obj/item/mecha_parts/chassis/parent_chassis = parent
	M.CheckParts(parent_chassis.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(parent)

// Default proc to generate mech steps.
// Override if the mech needs an entirely custom process (See HONK mech)
// Otherwise override specific steps as needed (Ripley, Clarke, Phazon)
/datum/component/construction/mecha/proc/get_steps()
	return get_frame_steps() + get_circuit_steps() + (circuit_weapon ? get_circuit_weapon_steps() : list()) + get_stockpart_steps() + get_inner_plating_steps() + get_outer_plating_steps()

/datum/component/construction/mecha/update_parent(step_index)
	steps = get_steps()
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0"
	var/atom/parent_atom = parent
	if(!steps[index]["icon_state"] && base_icon)
		parent_atom.icon_state = "[base_icon][index - 1]"

/datum/component/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, parent)
	if(.)
		var/atom/parent_atom = parent
		user.balloon_alert_to_viewers("connected [I]")
		parent_atom.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/component/construction/unordered/mecha_chassis/spawn_result()
	var/atom/parent_atom = parent
	parent_atom.icon = 'icons/mecha/mech_construction.dmi'
	parent_atom.set_density(TRUE)
	parent_atom.cut_overlays()
	..()

// Default proc for the first steps of mech construction.
/datum/component/construction/mecha/proc/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		)
	)

// Default proc for the circuit board steps of a mech.
// Second set of steps by default.
/datum/component/construction/mecha/proc/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		)
	)

// Default proc for weapon circuitboard steps
// Used by combat mechs
/datum/component/construction/mecha/proc/get_circuit_weapon_steps()
	return list(
		list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapons control module is installed."
		)
	)

// Default proc for stock part installation
// Third set of steps by default
/datum/component/construction/mecha/proc/get_stockpart_steps()
	var/prevstep_text = circuit_weapon ? "Weapons control module is secured." : "Peripherals control module is secured."
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = prevstep_text
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		)
	)

// Default proc for inner armor plating
// Fourth set of steps by default
/datum/component/construction/mecha/proc/get_inner_plating_steps()
	var/list/first_step
	if(ispath(inner_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = inner_plating,
				"amount" = inner_plating_amount,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)
	else
		first_step = list(
			list(
				"key" = inner_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Inner plating is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Inner Plating is wrenched."
		)
	)

// Default proc for outer armor plating
// Fifth set of steps by default
/datum/component/construction/mecha/proc/get_outer_plating_steps()
	var/list/first_step
	if(ispath(outer_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = outer_plating,
				"amount" = outer_plating_amount,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)
	else
		first_step = list(
			list(
				"key" = outer_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		)
	)

/// Steps must be checked for sequentially, in case we skip into another state we don't want
/// However, if we're doing a deconstruction step (backwards) we need to check in a different order
/datum/component/construction/mecha/proc/skip_extra_steps(diff, forward)
	var/on_valid_step = FALSE

	while (!on_valid_step)
		// Offset the next number if it's a backwards step
		// to ensure we're checking the correct next step
		var/next_step = forward ? message_step : (message_step - 1)

		// Some variables for what step we're on to keep the if statements reasonably long
		var/on_weapons_step = next_step == ADD_WEAPONS_CONTROLS_STEP || next_step == SECURE_WEAPONS_CONTROLS_STEP
		var/on_bluespace_step = next_step == INSTALL_BLUESPACE_STEP || next_step == CONNECT_BLUESPACE_STEP || next_step == ENGAGE_BLUESPACE_STEP

		// Skip over steps we're not doing!
		if(!has_treads && next_step == ADD_TREADS_STEP)
			message_step += diff

		else if(!has_weapons_module && on_weapons_step)
			message_step += diff * 2

		else if(!has_bluespace_crystal && on_bluespace_step)
			message_step += diff * 3

		else
			on_valid_step = TRUE

/// Generic mech construction messages
/datum/component/construction/mecha/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	var/forward = (diff == FORWARD)

	skip_extra_steps(diff, forward)

	// An offset is used to condense the printing of messages:
	// When we advance a step, we display the message (i.e. step 1) and move to the next step (2)
	// When we move back a step, we decrement the step (step 2 to 1) and then print the backwards message for that step
	var/curr_step = forward ? message_step : (message_step - 1)

	switch(curr_step)
		if(ADD_TREADS_STEP)
			user.balloon_alert_to_viewers("[forward ? "added" : "removed"] tread systems")
		if(CONNECT_HYDRAULICS_STEP)
			user.balloon_alert_to_viewers("[forward ? "connected" : "disconnected"] hydraulic systems")
		if(ACTIVATE_HYDRAULICS_STEP)
			user.balloon_alert_to_viewers("[forward ? "activated" : "deactivated"] hydraulic systems")
		if(ADD_WIRING_STEP)
			user.balloon_alert_to_viewers("[forward ? "added" : "removed"] wiring")
		if(ADJUST_WIRING_STEP)
			user.balloon_alert_to_viewers("[forward ? "adjusted" : "disconnected"] wiring")
		if(ADD_CONTROL_MODULE_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] central control module")
		if(SECURE_CONTROL_MODULE_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] central control module")
		if(ADD_PERIPHERALS_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] peripherals control module")
		if(SECURE_PERIPHERALS_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] peripherals control module")
		if(ADD_WEAPONS_CONTROLS_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] weapons control module")
		if(SECURE_WEAPONS_CONTROLS_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] weapons control module")
		if(ADD_SCANNING_MODULE_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] scanner module")
		if(SECURE_SCANNING_MODULE_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] scanner module")
		if(ADD_CAPACITOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] capacitor")
		if(SECURE_CAPACITOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] capacitor")
		if(INSTALL_BLUESPACE_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] bluespace crystal")
		if(CONNECT_BLUESPACE_STEP)
			user.balloon_alert_to_viewers("[forward ? "connected" : "disconnected"] bluespace crystal")
		if(ENGAGE_BLUESPACE_STEP)
			user.balloon_alert_to_viewers("[forward ? "engaged" : "disengaged"] bluespace crystal")
		if(ADD_CELL_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "removed"] power cell")
		if(SECURE_CELL_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unsecured"] power cell")
		if(ADD_INTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "pried off"] internal armor layer")
		if(SECURE_INTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unfastened"] internal armor layer")
		if(WELD_INTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "welded" : "cut off"] internal armor layer")
		if(ADD_EXTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "installed" : "pried off"] external armor layer")
		if(SECURE_EXTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "secured" : "unfastened"] external armor layer")
		if(WELD_EXTERNAL_ARMOR_STEP)
			user.balloon_alert_to_viewers("[forward ? "welded" : "cut off"] external armor layer")

	message_step += diff
	return TRUE

//RIPLEY
/datum/component/construction/unordered/mecha_chassis/ripley
	result = /datum/component/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/component/construction/mecha/ripley
	result = /obj/vehicle/sealed/mecha/working/ripley
	base_icon = "ripley"

	circuit_control = /obj/item/circuitboard/mecha/ripley/main
	circuit_periph = /obj/item/circuitboard/mecha/ripley/peripherals

	inner_plating=/obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/stack/rods
	outer_plating_amount = 10

/datum/component/construction/mecha/ripley/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item/stack/rods,
			"amount" = 10,
			"back_key" = TOOL_WELDER,
			"desc" = "Outer Plating is welded."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "Cockpit wire screen is installed."
		),
	)

//GYGAX
/datum/component/construction/unordered/mecha_chassis/gygax
	result = /datum/component/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/component/construction/mecha/gygax
	result = /obj/vehicle/sealed/mecha/combat/gygax
	base_icon = "gygax"

	has_weapons_module = TRUE

	circuit_control = /obj/item/circuitboard/mecha/gygax/main
	circuit_periph = /obj/item/circuitboard/mecha/gygax/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/gygax/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/mecha_parts/part/gygax_armor
	outer_plating_amount=1

/datum/component/construction/mecha/gygax/action(datum/source, atom/used_atom, mob/user)
	return INVOKE_ASYNC(src, .proc/check_step, used_atom,user)

//CLARKE
/datum/component/construction/unordered/mecha_chassis/clarke
	result = /datum/component/construction/mecha/clarke
	steps = list(
		/obj/item/mecha_parts/part/clarke_torso,
		/obj/item/mecha_parts/part/clarke_left_arm,
		/obj/item/mecha_parts/part/clarke_right_arm,
		/obj/item/mecha_parts/part/clarke_head
	)

/datum/component/construction/mecha/clarke
	result = /obj/vehicle/sealed/mecha/working/clarke
	base_icon = "clarke"

	has_treads = TRUE

	circuit_control = /obj/item/circuitboard/mecha/clarke/main
	circuit_periph = /obj/item/circuitboard/mecha/clarke/peripherals

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/mineral/gold
	outer_plating_amount = 5

/datum/component/construction/mecha/clarke/get_frame_steps()
	return list(
		list(
			"key" = /obj/item/stack/conveyor,
			"amount" = 4,
			"desc" = "The treads are added."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The hydraulic systems are disconnected."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		)
	)

//HONKER
/datum/component/construction/unordered/mecha_chassis/honker
	result = /datum/component/construction/mecha/honker
	steps = list(
		/obj/item/mecha_parts/part/honker_torso,
		/obj/item/mecha_parts/part/honker_left_arm,
		/obj/item/mecha_parts/part/honker_right_arm,
		/obj/item/mecha_parts/part/honker_left_leg,
		/obj/item/mecha_parts/part/honker_right_leg,
		/obj/item/mecha_parts/part/honker_head
	)

/datum/component/construction/mecha/honker
	result = /obj/vehicle/sealed/mecha/combat/honker
	steps = list(
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/main,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/peripherals,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/targeting,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/mask/gas/clown_hat,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/shoes/clown_shoes,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
	)

/datum/component/construction/mecha/honker/get_steps()
	return steps

// HONK doesn't have any construction step icons, so we just set an icon once.
/datum/component/construction/mecha/honker/update_parent(step_index)
	if(step_index == 1)
		var/atom/parent_atom = parent
		parent_atom.icon = 'icons/mecha/mech_construct.dmi'
		parent_atom.icon_state = "honker_chassis"
	..()

/datum/component/construction/mecha/honker/custom_action(obj/item/I, mob/living/user, diff)
	if(istype(I, /obj/item/bikehorn))
		playsound(parent, 'sound/items/bikehorn.ogg', 50, TRUE)
		user.balloon_alert_to_viewers("HONK!")

	//TODO: better messages.
	switch(index)
		if(2, 4, 6, 8, 10, 12)
			user.balloon_alert_to_viewers("installed [I]")
		if(14, 16)
			user.balloon_alert_to_viewers("added [I]")
	return TRUE

//DURAND
/datum/component/construction/unordered/mecha_chassis/durand
	result = /datum/component/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/component/construction/mecha/durand
	result = /obj/vehicle/sealed/mecha/combat/durand
	base_icon = "durand"

	has_weapons_module = TRUE

	circuit_control = /obj/item/circuitboard/mecha/durand/main
	circuit_periph = /obj/item/circuitboard/mecha/durand/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/durand/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/durand_armor
	outer_plating_amount = 1

//PHAZON
/datum/component/construction/unordered/mecha_chassis/phazon
	result = /datum/component/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/component/construction/mecha/phazon
	result = /obj/vehicle/sealed/mecha/combat/phazon
	base_icon = "phazon"

	has_weapons_module = TRUE
	has_bluespace_crystal = TRUE

	circuit_control = /obj/item/circuitboard/mecha/phazon/main
	circuit_periph = /obj/item/circuitboard/mecha/phazon/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/phazon/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/phazon_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/phazon/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed.",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		)
	)

/datum/component/construction/mecha/phazon/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = 1,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
		list(
			"key" = /obj/item/assembly/signaler/anomaly/bluespace,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Bluespace anomaly core socket is open.",
			"icon_state" = "phazon24"
		)
	)

/datum/component/construction/mecha/phazon/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	// We've already advanced the message step in ..(), so we have to offset by one to make sure we're on the right message
	if((message_step - 1) == INSERT_ANOMALY_CORE_STEP)
		if(diff == FORWARD)
			user.balloon_alert_to_viewers("inserted bluespace anomaly core")
	return TRUE

//SAVANNAH-IVANOV
/datum/component/construction/unordered/mecha_chassis/savannah_ivanov
	result = /datum/component/construction/mecha/savannah_ivanov
	steps = list(
		/obj/item/mecha_parts/part/savannah_ivanov_torso,
		/obj/item/mecha_parts/part/savannah_ivanov_head,
		/obj/item/mecha_parts/part/savannah_ivanov_left_arm,
		/obj/item/mecha_parts/part/savannah_ivanov_right_arm,
		/obj/item/mecha_parts/part/savannah_ivanov_left_leg,
		/obj/item/mecha_parts/part/savannah_ivanov_right_leg
	)

/datum/component/construction/mecha/savannah_ivanov
	result = /obj/vehicle/sealed/mecha/combat/savannah_ivanov
	base_icon = "savannah_ivanov"

	has_weapons_module = TRUE

	circuit_control = /obj/item/circuitboard/mecha/savannah_ivanov/main
	circuit_periph = /obj/item/circuitboard/mecha/savannah_ivanov/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/savannah_ivanov/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 10

	outer_plating = /obj/item/mecha_parts/part/savannah_ivanov_armor
	outer_plating_amount = 1

//ODYSSEUS
/datum/component/construction/unordered/mecha_chassis/odysseus
	result = /datum/component/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/component/construction/mecha/odysseus
	result = /obj/vehicle/sealed/mecha/medical/odysseus
	base_icon = "odysseus"

	circuit_control = /obj/item/circuitboard/mecha/odysseus/main
	circuit_periph = /obj/item/circuitboard/mecha/odysseus/peripherals

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/plasteel
	outer_plating_amount = 5

#undef ADD_TREADS_STEP
#undef CONNECT_HYDRAULICS_STEP
#undef ACTIVATE_HYDRAULICS_STEP
#undef ADD_WIRING_STEP
#undef ADJUST_WIRING_STEP
#undef ADD_CONTROL_MODULE_STEP
#undef SECURE_CONTROL_MODULE_STEP
#undef ADD_PERIPHERALS_STEP
#undef SECURE_PERIPHERALS_STEP
#undef ADD_WEAPONS_CONTROLS_STEP
#undef SECURE_WEAPONS_CONTROLS_STEP
#undef ADD_SCANNING_MODULE_STEP
#undef SECURE_SCANNING_MODULE_STEP
#undef ADD_CAPACITOR_STEP
#undef SECURE_CAPACITOR_STEP
#undef INSTALL_BLUESPACE_STEP
#undef CONNECT_BLUESPACE_STEP
#undef ENGAGE_BLUESPACE_STEP
#undef ADD_CELL_STEP
#undef SECURE_CELL_STEP
#undef ADD_INTERNAL_ARMOR_STEP
#undef SECURE_INTERNAL_ARMOR_STEP
#undef WELD_INTERNAL_ARMOR_STEP
#undef ADD_EXTERNAL_ARMOR_STEP
#undef SECURE_EXTERNAL_ARMOR_STEP
#undef WELD_EXTERNAL_ARMOR_STEP
#undef INSERT_ANOMALY_CORE_STEP
