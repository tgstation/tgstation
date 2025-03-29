/// Quartic Reliquary board
/obj/item/circuitboard/machine/quartic_reliquary
	name = "Quartic Reliquary"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/quartic_reliquary
	req_components = list(
		/datum/stock_part/servo = 3,
		/datum/stock_part/scanning_module = 3,
		/obj/item/stack/sheet/cardboard = 9)

/// Here so it doesn't mess with any other actually important node files
/datum/design/board/quartic_reliquary
	name = "Quartic Reliquary Board"
	desc = "The circuit board for a quartic reliquary."
	id = "quartic_reliquary"
	build_path = /obj/item/circuitboard/machine/quartic_reliquary
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/techweb_node/cuboids
	id = TECHWEB_NODE_CUBOIDS
	display_name = "Applied 4th-Dimensional Calculus"
	description = "A machine capable of utilizing abstract and arcane 4th-dimensional mathematical formulas to rearrange the fabric of volumetric entities."
	design_ids = list(
		"quartic_reliquary",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	prereq_ids = list(TECHWEB_NODE_APPLIED_BLUESPACE)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)
	show_on_wiki = FALSE
	autounlock_by_boost = FALSE



/// The Quartic Reliquary takes in 3 cubes of the same rarity and outputs one cube a rarity higher.
/obj/machinery/quartic_reliquary
	name = "quartic reliquary"
	desc = "A machine capable of utilizing 4th-dimensional mathematical formulas to fold some 3rd dimensional objects into higher quality ones."
	icon = 'icons/obj/machines/quartic_reliquary.dmi'
	base_icon_state = "quartic_reliquary"
	icon_state = "quartic_reliquary_display"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/quartic_reliquary
	light_system = OVERLAY_LIGHT
	light_on = FALSE
	/// Reference for the possible items we'll get when we create a new cube. Common is there just in case someone SOMEHOW combines something with 0 rarity
	var/static/list/all_possible_cube_returns = list(
		GLOB.common_cubes,
		GLOB.uncommon_cubes,
		GLOB.rare_cubes,
		GLOB.epic_cubes,
		GLOB.legendary_cubes,
		GLOB.mythical_cubes,
		)
	/// The speed at which we upgrade our cube. Affected by servos.
	var/upgrade_speed = 2 MINUTES
	/// The added chance to get a cube 1 stage higher than we were going for. Affected by scanners.
	var/bonus_chance = 0
	/// The currently inserted cubes. Max of 3.
	var/list/current_cubes
	/// Cubes must all be of this specified rarity in order to be processed. Takes from the top slot in current_cubes. Update via update_current_rarity()
	var/current_rarity = null
	/// name of current_rarity
	var/current_rarity_name = null
	/// The rarity we are attempting to pull
	var/desired_rarity = null
	/// name of desired_rarity
	var/desired_rarity_name = null
	/// Atom acting as an overlay for the reliquary
	VAR_PRIVATE/obj/effect/abstract/quartic_cube/floating_cube
	/// sound we make when we fold
	var/datum/looping_sound/generator/soundloop
	///direction we output onto (if 0, on top of us)
	var/drop_direction = 0

	/// Even though we use a callback timer for the actual upgrading process, the cooldown lets us check the status of the timer easily
	COOLDOWN_DECLARE(cube_upgrade)
	COOLDOWN_DECLARE(cube_spin_flick)

/obj/machinery/quartic_reliquary/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = MYTHICAL_CUBE, ismapload = mapload)
	floating_cube = new(get_turf(src))
	icon_state = "quartic_reliquary"
	register_context()
	soundloop = new(src, FALSE)
	LAZYINITLIST(current_cubes)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/quartic_reliquary_data,
	))

/obj/machinery/quartic_reliquary/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(floating_cube)
	return ..()

/obj/item/circuit_component/quartic_reliquary_data
	display_name = "Quartic Reliquary Data"
	desc = "Outputs the cubes held inside of the Quaritic Reliquary, the current desired folding rarity, and all resulting cubes. \
		Can be used to start folding process & detect when it ends."

	/// Triggers the start of the folding process, if possible
	var/datum/port/output/begin_folding
	/// Trigger to pop a cube from the list
	var/datum/port/output/remove_cube

	/// Table of currently stored cubes
	var/datum/port/output/stored_cubes
	/// Current current_rarity
	var/datum/port/output/required_cube
	/// Current desired_rarity
	var/datum/port/output/target_cube
	/// If the contents of stored_cubes has been updated
	var/datum/port/output/updated_cubes

	/// The list of cubes that were output
	var/datum/port/output/output_cubes
	/// Trigger for when the reliquary finishes folding
	var/datum/port/output/finished_folding
	/// If folding the cubes failed, then why
	var/datum/port/output/why_fail
	var/datum/port/output/on_fail

	var/obj/machinery/quartic_reliquary/attatched_reliquary


/obj/item/circuit_component/quartic_reliquary_data/populate_ports()
	/// Input signals
	begin_folding = add_input_port("Begin Folding", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_fold))
	remove_cube = add_input_port("Eject Last Cube", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_eject))
	/// Pertains to the input cubes
	stored_cubes = add_output_port("Contained Cubes", PORT_TYPE_TABLE)
	required_cube = add_output_port("Required Rarity", PORT_TYPE_NUMBER)
	target_cube = add_output_port("Target Rarity", PORT_TYPE_NUMBER)
	updated_cubes = add_output_port("Contained Cubes Altered", PORT_TYPE_INSTANT_SIGNAL)
	/// Pertains to the output cubes
	output_cubes = add_output_port("Output Cubes", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	finished_folding = add_output_port("Finished Folding", PORT_TYPE_INSTANT_SIGNAL)
	/// Our inputs failed
	why_fail = add_output_port("Failure Reason", PORT_TYPE_STRING)
	on_fail = add_output_port("Action Failed", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/quartic_reliquary_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/quartic_reliquary))
		attatched_reliquary = shell
		RegisterSignal(attatched_reliquary, COMSIG_RELIQUARY_CONTENTS_UPDATED, PROC_REF(on_cubedate))
		RegisterSignal(attatched_reliquary, COMSIG_RELIQUARY_FOLDING_COMPLETE, PROC_REF(on_fold))

/obj/item/circuit_component/quartic_reliquary_data/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(attatched_reliquary, list(
		COMSIG_RELIQUARY_CONTENTS_UPDATED,
		COMSIG_RELIQUARY_FOLDING_COMPLETE
	))
	attatched_reliquary = null
	return ..()

/// When we update the cube's content we call this
/obj/item/circuit_component/quartic_reliquary_data/proc/on_cubedate(atom/movable/source, list/current_cubes, current_rarity, desired_rarity)
	SIGNAL_HANDLER

	var/list/new_table = list()
	for(var/atom/movable/cube as anything in current_cubes)
		var/list/entry = list()
		entry["cube"] = cube
		entry["rarity"] = current_cubes[cube]
		new_table += list(entry)

	stored_cubes.set_output(new_table)
	required_cube.set_output(current_rarity)
	target_cube.set_output(desired_rarity)
	updated_cubes.set_output(COMPONENT_SIGNAL)


/// When the cube finishes folding it outputs this
/obj/item/circuit_component/quartic_reliquary_data/proc/on_fold(atom/movable/source, list/all_output_cubes)
	SIGNAL_HANDLER

	output_cubes.set_output(all_output_cubes)
	finished_folding.set_output(COMPONENT_SIGNAL)

/// Start the folding process, if we fail then output why
/obj/item/circuit_component/quartic_reliquary_data/proc/trigger_fold()
	CIRCUIT_TRIGGER
	if(!attatched_reliquary)
		return
	var/list/cube_roll_results = attatched_reliquary.begin_cube_roll()
	if(cube_roll_results[1] & CLICK_ACTION_BLOCKING)
		why_fail.set_output(cube_roll_results[2])
		on_fail.set_output(COMPONENT_SIGNAL)

/// Pop the top cube from the stack
/obj/item/circuit_component/quartic_reliquary_data/proc/trigger_eject()
	CIRCUIT_TRIGGER
	if(!attatched_reliquary)
		return
	var/list/cube_eject_results = attatched_reliquary.remove_cube_hand(null)
	if(cube_eject_results[2] != "success!")
		why_fail.set_output(cube_eject_results[2])
		on_fail.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/quartic_reliquary_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list("cube", "rarity"))
	. += create_ui_notice("Rarity to Number Guide:", "orange")
	. += create_ui_notice("Common = 1", "white")
	. += create_ui_notice("Uncommon = 2", "green")
	. += create_ui_notice("Rare = 3", "blue")
	. += create_ui_notice("Epic = 4", "purple")
	. += create_ui_notice("Legendary = 5", "red")
	. += create_ui_notice("Mythical = 6", "pink")

/obj/machinery/quartic_reliquary/RefreshParts()
	. = ..()
	var/new_bonus_chance = 0
	for(var/datum/stock_part/scanning_module/new_scanner in component_parts)
		new_bonus_chance += new_scanner.tier
	bonus_chance = round(new_bonus_chance/2, 0.1)

	var/upgrade_speed_mod = 1
	for(var/datum/stock_part/servo/new_servo in component_parts)
		upgrade_speed_mod += new_servo.tier
	upgrade_speed = round(2 MINUTES / upgrade_speed_mod)

/obj/machinery/quartic_reliquary/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		return NONE
	if(!isnull(held_item))
		var/datum/component/cuboid/is_cube = held_item.GetComponent(/datum/component/cuboid)
		if(is_cube)
			if(is_cube.rarity < MYTHICAL_CUBE && LAZYLEN(current_cubes) < 3)
				context[SCREENTIP_CONTEXT_LMB] = "Insert Cube"
				. = CONTEXTUAL_SCREENTIP_SET
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_RMB] = "[panel_open ? "Close" : "Open"] panel"
			. = CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
			. = CONTEXTUAL_SCREENTIP_SET
	else
		if(drop_direction)
			context[SCREENTIP_CONTEXT_ALT_RMB] = "Reset Drop"
			. = CONTEXTUAL_SCREENTIP_SET
		var/cubelength = LAZYLEN(current_cubes)
		if(cubelength)
			context[SCREENTIP_CONTEXT_RMB] = "Remove [thtotext(cubelength)] Cube"
			. = CONTEXTUAL_SCREENTIP_SET
		if(cubelength >= 3)
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Activate"
			. = CONTEXTUAL_SCREENTIP_SET
	return . || NONE

/obj/machinery/quartic_reliquary/examine(mob/user)
	. += ..()
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"]")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart")
	if(!in_range(user, src) && !isobserver(user))
		. += span_notice("If you want any more information you'll need to get closer.")
		return
	. += span_notice("It is able to fold a cube in [EXAMINE_HINT(DisplayTimeText(upgrade_speed))].")
	. += span_notice("It has a [EXAMINE_HINT("[bonus_chance]%")] chance to give an even rarer cube!")
	if(drop_direction)
		. += span_notice("Currently configured to drop printed objects <b>[dir2text(drop_direction)]</b>.")
		. += span_notice("[EXAMINE_HINT("Alt-Right-click")] to reset.")
	else
		. += span_notice("[EXAMINE_HINT("Drag")] towards a direction (while next to it) to change drop direction.")
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		. += span_notice("It will finish folding its cubes in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_upgrade))].")
		return
	if(LAZYLEN(current_cubes))
		. += span_notice("It is holding [jointext(current_cubes, ", ")].")
		var/empty_slots = 3-LAZYLEN(current_cubes)
		. += span_notice("It can hold [empty_slots ? empty_slots : "no"] more cube[empty_slots!=1 ? "s" : ""].")
		if(current_rarity)
			. += "It will only process if all cubes are of [current_rarity_name] rarity."
			. += "The resulting cube will be [desired_rarity_name]."

/// Idk if it's the best idea to put this on a process but it's the only way I could think of to apply the filters without making a recursive callback
/obj/machinery/quartic_reliquary/process()
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		update_appearance()

/// Use secondaries since cubes can also be tools sometimes
/obj/machinery/quartic_reliquary/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(LAZYLEN(current_cubes))
		balloon_alert(user, "remove cubes first!")
		return ITEM_INTERACT_FAILURE
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		balloon_alert(user, "busy processing!")
		return ITEM_INTERACT_FAILURE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/quartic_reliquary/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/quartic_reliquary/on_set_panel_open()
	update_appearance()
	return ..()

/obj/machinery/quartic_reliquary/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]-open"
	if(LAZYLEN(current_cubes))
		var/cube_index = 0
		for(var/cube_in_list in current_cubes)
			cube_index++
			var/mutable_appearance/inserted_overlay = mutable_appearance(icon, "cube_[cube_index]")
			inserted_overlay.add_filter("overlay_color", 1, color_matrix_filter(GLOB.all_cubecolors[LAZYACCESS(current_cubes, cube_in_list)]))
			. += inserted_overlay
	if(desired_rarity)
		var/mutable_appearance/runic_pattern = mutable_appearance(icon, "runic_pattern")
		runic_pattern.add_filter("overlay_color", 1, color_matrix_filter(GLOB.all_cubecolors[desired_rarity]))
		. += runic_pattern
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		if(!COOLDOWN_FINISHED(src, cube_spin_flick))
			return
		if(COOLDOWN_TIMELEFT(src, cube_upgrade) <= 3 SECONDS)
			return
		floating_cube.animate_spin(GLOB.all_cubecolors[desired_rarity], upgrade_speed)
		COOLDOWN_START(src, cube_spin_flick, 3 SECONDS)

/// The big cube on top
/obj/effect/abstract/quartic_cube
	icon = 'icons/obj/machines/quartic_reliquary.dmi'
	icon_state = "idle"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blocks_emissive = EMISSIVE_BLOCK_NONE
	/// Since the color fading is a different duration than the spin animation, only trigger it once
	COOLDOWN_DECLARE(color_fade)
	/// Pass of upgrade_speed
	var/animation_length = null
	/// The rarity color
	var/color_to_use = COLOR_WHITE
	/// Because we can't seem to update our own damn lighting
	var/obj/item/flashlight/spotlight/glow

/obj/effect/abstract/quartic_cube/Initialize(mapload)
	. = ..()
	add_filter("new_rarity_pulse", 1, color_matrix_filter(COLOR_WHITE))
	add_filter("mythical_glow", 10, outline_filter(color = GLOB.all_cubecolors[MYTHICAL_CUBE], size = 1))
	glow = new(get_turf(src), 0, 1, COLOR_SILVER)
	glow.set_light_on(FALSE)
	glow.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	glow.resistance_flags |= SHUTTLE_CRUSH_PROOF

/obj/effect/abstract/quartic_cube/Destroy(force)
	QDEL_NULL(glow)
	return ..()

/// Animate the color of the cube over a set period of time
/obj/effect/abstract/quartic_cube/proc/animate_color_filter()
	var/halftime = round(animation_length/2)
	transition_filter("new_rarity_pulse", color_matrix_filter(color_to_use), halftime, easing = CUBIC_EASING)
	addtimer(CALLBACK(src, PROC_REF(handle_fadeout), halftime), halftime)
	glow.set_light_color = color_to_use
	START_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, color_fade, animation_length)

/// If I can't interpolate with an easy and clean proc I'll do it myself!
/obj/effect/abstract/quartic_cube/process(seconds_per_tick)
	if(animation_length && !COOLDOWN_FINISHED(src, color_fade))
		if(!glow.light_on)
			glow.set_light_on(TRUE)
		/// It works but for some reason the light turns white at the midpoint despite it being clamped at 1.
		/// Can't think of a fix for that but the fact it works at all is good enough for me
		/// We're basically just using a square function. f(X) = -((X/(A/2))-1)^2+1 where X is the remaining time and A is animation_length
		//// This doesn't have a good ease in-out but it works for what we're trying to do
		var/current_interp = clamp(round(-(((round(COOLDOWN_TIMELEFT(src, color_fade),0.01)/round(animation_length/2,0.01))-1)**2)+1, 0.01), 0, 1)
		glow.set_light_range_power_color(
			max(round(5*current_interp, 0.1), 1.4),
			max(round(3*current_interp, 0.1), 0.1),
			BlendRGB(COLOR_SILVER, color_to_use, clamp(current_interp, 0, 1)))

/// Second half of the fading color animation
/obj/effect/abstract/quartic_cube/proc/handle_fadeout(halftime)
	transition_filter("new_rarity_pulse", color_matrix_filter(COLOR_WHITE), halftime, easing = CUBIC_EASING)
	addtimer(CALLBACK(src, PROC_REF(finish_fadeout)), halftime)

/// Called to handle the end of the animation
/obj/effect/abstract/quartic_cube/proc/finish_fadeout()
	STOP_PROCESSING(SSfastprocess, src)
	animation_length = null
	glow.set_light_range_power_color(0,1,COLOR_SILVER)
	glow.set_light_on(FALSE)


/// Flicks both the icon_state and the emissive overlay
/obj/effect/abstract/quartic_cube/proc/animate_spin(mut_color = COLOR_WHITE, color_time = 3 SECONDS)
	if(COOLDOWN_FINISHED(src, color_fade))
		color_to_use = mut_color
		animation_length = color_time
		animate_color_filter()
	var/mutable_appearance/emissive_cube = emissive_appearance(icon, icon_state = "active_emissive", offset_spokesman = src, layer = src.layer + 1, alpha = 200)
	flick_overlay_view(emissive_cube, duration = 3 SECONDS)
	flick("active", src)

/obj/machinery/quartic_reliquary/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/usb_cable))
		return NONE
	return cube_insert(user, tool, TRUE)

/// Add the cube to the machine.
/obj/machinery/quartic_reliquary/proc/cube_insert(mob/living/user, obj/item/item_to_add)
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return NONE
	if(LAZYLEN(current_cubes) >= 3)
		balloon_alert(user, "already full!")
		return ITEM_INTERACT_FAILURE
	var/datum/component/cuboid/attempted_cube = item_to_add.GetComponent(/datum/component/cuboid)
	if(!attempted_cube)
		balloon_alert(user, "not a cube!")
		return NONE
	if(attempted_cube.rarity == MYTHICAL_CUBE)
		balloon_alert(user, "no mythical cubes!")
		return ITEM_INTERACT_FAILURE
	if(!user.transferItemToLoc(item_to_add, src))
		balloon_alert(user, "couldn't add!")
		return ITEM_INTERACT_FAILURE
	LAZYSET(current_cubes, item_to_add, attempted_cube.rarity)
	update_current_rarity()
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/// Updates both the rarity and the name of the required cubes.
/obj/machinery/quartic_reliquary/proc/update_current_rarity()
	var/new_rarity = LAZYACCESS(current_cubes, LAZYACCESS(current_cubes, 1))
	if(!new_rarity)
		current_rarity = null
		current_rarity_name = null
		desired_rarity = null
		desired_rarity_name = null
		update_appearance()
		return

	current_rarity = new_rarity
	current_rarity_name = GLOB.all_cubenames[current_rarity]
	desired_rarity = current_rarity+1
	desired_rarity_name = GLOB.all_cubenames[desired_rarity]
	SEND_SIGNAL(src, COMSIG_RELIQUARY_CONTENTS_UPDATED, current_cubes, current_rarity, desired_rarity)
	update_appearance()

/obj/machinery/quartic_reliquary/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(LAZYLEN(current_cubes))
		return remove_cube_hand(user)[1]

///Take the top cube from the stack
/obj/machinery/quartic_reliquary/proc/remove_cube_hand(mob/living/user)
	var/failtext = ""
	if(!LAZYLEN(current_cubes))
		failtext = "no cubes to eject!"
		return list(SECONDARY_ATTACK_CONTINUE_CHAIN, failtext)
	var/atom/movable/cube_to_remove = pop(current_cubes)
	if(!cube_to_remove)
		failtext = "failed to find a movable cube!"
		return list(SECONDARY_ATTACK_CONTINUE_CHAIN, failtext)
	/// Need to put an elseif even though they do effectively the same thing because of the circuit requirement not liking put_in_hands()
	//! Update: nevermind for some reason it just gets angry either way so fuck it who cares
	if(!user)
		cube_to_remove.forceMove(get_turf(src))
	else if(!user.put_in_hands(cube_to_remove))
		cube_to_remove.forceMove(get_turf(src))
	update_current_rarity()
	if(user)
		balloon_alert(user, "cube removed")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return list(SECONDARY_ATTACK_CONTINUE_CHAIN, "success!")

/obj/machinery/quartic_reliquary/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!can_interact(user) || (!HAS_SILICON_ACCESS(user) && !isAdminGhostAI(user)) && !Adjacent(user))
		return
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		balloon_alert(user, "busy!")
		return
	var/direction = get_dir(src, over_location)
	if(!direction)
		return
	drop_direction = direction
	balloon_alert(user, "dropping [dir2text(drop_direction)]")

/obj/machinery/quartic_reliquary/click_alt_secondary(mob/user)
	. = ..()
	if(drop_direction == 0)
		return CLICK_ACTION_BLOCKING
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		balloon_alert(user, "busy!")
		return CLICK_ACTION_BLOCKING
	balloon_alert(user, "drop direction reset")
	drop_direction = 0
	return CLICK_ACTION_SUCCESS

/obj/machinery/quartic_reliquary/click_alt(mob/user)
	. = ..()
	return begin_cube_roll(user)[1]

/// Gambling for cubes! Checks to see if we're able to run, and if we are then deletes our current cubes and starts our timers
/obj/machinery/quartic_reliquary/proc/begin_cube_roll(mob/user)
	var/fail_text = ""
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		fail_text = "already active!"
		if(user)
			balloon_alert(user, fail_text)
		return list(CLICK_ACTION_BLOCKING, fail_text)
	if(LAZYLEN(current_cubes) < 3)
		fail_text = "not enough cubes!"
		if(user)
			balloon_alert(user, fail_text)
		return list(CLICK_ACTION_BLOCKING, fail_text)
	for(var/cube_to_check in current_cubes)
		if(current_cubes[cube_to_check] != current_rarity)
			fail_text = "wrong rarities!"
			if(user)
				balloon_alert(user, fail_text)
			return list(CLICK_ACTION_BLOCKING, fail_text)
		if(current_cubes[cube_to_check] == MYTHICAL_CUBE)
			fail_text = "no mythical cubes!"
			if(user)
				balloon_alert(user, fail_text)
			return list(CLICK_ACTION_BLOCKING, fail_text)

	/// Try to stealthily cover up the cubes being removed using a fancy little animation
	var/mutable_appearance/collection = mutable_appearance(icon, "cube_collect", FLOAT_LAYER+0.1, src)
	QDEL_LAZYLIST(current_cubes)
	flick_overlay_view(collection, 7 DECISECONDS)
	playsound(src, 'sound/machines/lathe/lathe_print.ogg', 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom,update_appearance)), 6 DECISECONDS)
	/// Actually start the damn process itself
	COOLDOWN_START(src, cube_upgrade, upgrade_speed)
	addtimer(CALLBACK(src, PROC_REF(finish_cube_roll)), upgrade_speed)
	update_use_power(ACTIVE_POWER_USE)
	soundloop.start()
	return list(CLICK_ACTION_SUCCESS, "success!")

/// Handles the actual rolling of the cubes
/obj/machinery/quartic_reliquary/proc/finish_cube_roll()
	/// If we're able to, roll for the bonus chance
	if(prob(bonus_chance) && desired_rarity != MYTHICAL_CUBE)
		desired_rarity += 1
	update_use_power(IDLE_POWER_USE)

	var/list/all_picked_cubes = list()
	var/atom/movable/picked_cube = pick_weight_recursive(all_possible_cube_returns[desired_rarity])

	if(istype(picked_cube, /obj/effect/spawner/random/cube))
		handle_cube_reroll(picked_cube, all_picked_cubes)
	else
		all_picked_cubes.Add(picked_cube)
	/// We can finally get rid of desired_rarity
	update_current_rarity()
	/// Figure out if we drop on us or drop on a specified turf next to us
	var/turf/target_location
	if(drop_direction)
		target_location = get_step(src, drop_direction)
		if(isclosedturf(target_location))
			target_location = get_turf(src)
	else
		target_location = get_turf(src)
	/// Because effect/spawner objects are in the possible rewards, we use a list to hold all the rerolled results from `handle_cube_reroll`
	/// We don't want spawners since we're outputting the results to a USB
	var/list/atom/movable/all_outputs = list()
	for(var/our_cube in all_picked_cubes)
		all_outputs += new our_cube(target_location)
	SEND_SIGNAL(src, COMSIG_RELIQUARY_FOLDING_COMPLETE, all_outputs)
	soundloop.stop()
	playsound(src, 'sound/machines/machine_vend.ogg', 75, TRUE, extrarange = -3)

/// Snowflake for if people get spawner cubes, or even if those spawner cubes give spawner cubes.
/obj/machinery/quartic_reliquary/proc/handle_cube_reroll(obj/effect/spawner/random/cube/spawnercube, list/rerolled_cubes)
	var/atom/movable/picked_cube
	if(spawnercube.cube_rarity < desired_rarity)
		for(var/downgrade in 1 to 3)
			picked_cube = pick_weight_recursive(all_possible_cube_returns[spawnercube.cube_rarity])
			if(istype(picked_cube, /obj/effect/spawner/random/cube))
				handle_cube_reroll(picked_cube, rerolled_cubes)
			else
				rerolled_cubes.Add(picked_cube)
	else
		picked_cube = pick_weight_recursive(all_possible_cube_returns[desired_rarity])
		if(istype(picked_cube, /obj/effect/spawner/random/cube))
			handle_cube_reroll(picked_cube, rerolled_cubes)
		else
			rerolled_cubes.Add(picked_cube)
