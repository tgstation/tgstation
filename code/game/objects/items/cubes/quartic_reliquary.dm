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
	icon_state = "quartic_reliquary"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/quartic_reliquary
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
	var/upgrade_speed = 10 SECONDS
	/// The added chance to get a cube 1 stage higher than we were going for. Affected by scanners.
	var/bonus_chance = 0
	/// The currently inserted cubes. Max of 3.
	var/list/current_cubes = list()
	/// If this isn't null, then cubes must be of this specified rarity to be placed inside
	var/current_rarity = null

	COOLDOWN_DECLARE(cube_upgrade)

/obj/machinery/quartic_reliquary/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = MYTHICAL_CUBE, ismapload = mapload)

/obj/machinery/quartic_reliquary/RefreshParts()
	. = ..()
	var/new_bonus_chance = 0
	for(var/datum/stock_part/scanning_module/new_scanner in component_parts)
		new_bonus_chance += new_scanner.tier
	bonus_chance = new_bonus_chance

	var/upgrade_speed_mod = 1
	for(var/datum/stock_part/servo/new_servo in component_parts)
		upgrade_speed_mod += new_servo.tier
	upgrade_speed = round(30 SECONDS / upgrade_speed_mod)

/obj/machinery/quartic_reliquary/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		return NONE
	if(!isnull(held_item))
		var/datum/component/cuboid/is_cube = held_item.GetComponent(/datum/component/cuboid)
		var/update_tip = NONE
		if(is_cube)
			context[SCREENTIP_CONTEXT_LMB] = "Insert Cube"
			update_tip = CONTEXTUAL_SCREENTIP_SET
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_RMB] = "[panel_open ? "Close" : "Open"] panel"
			update_tip = CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
			update_tip = CONTEXTUAL_SCREENTIP_SET
		return update_tip

/obj/machinery/quartic_reliquary/examine(mob/user)
	. += ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"]")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart")
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		. += span_notice("It will finish folding its cubes in [DisplayTimeText(COOLDOWN_TIMELEFT(src, cube_upgrade))].")
		return
	if(LAZYLEN(current_cubes))
		. += span_notice("It is holding [jointext(current_cubes, ",")].")
		var/empty_slots = 3-LAZYLEN(current_cubes)
		. += span_notice("It can hold [empty_slots ? empty_slots : "no more"] cubes.")
		if(current_rarity)
			. += span_notice("Only [] can be inserted.")

/// Use secondaries since cubes can also be tools sometimes
/obj/machinery/quartic_reliquary/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		return ITEM_INTERACT_FAILURE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/quartic_reliquary/on_set_panel_open()
	update_appearance()
	return ..()

/obj/machinery/quartic_reliquary/update_overlays()
	. = ..()
	if(panel_open)
		. += "[base_icon_state]-open"

/obj/machinery/quartic_reliquary/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(!COOLDOWN_FINISHED(src, cube_upgrade))
		return ITEM_INTERACT_FAILURE
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
