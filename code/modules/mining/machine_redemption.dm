/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets. Points for ore are generated based on type and can be redeemed at a mining equipment vendor."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = TRUE
	input_dir = NORTH
	output_dir = SOUTH
	req_access = list(ACCESS_MINERAL_STOREROOM)
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/ore_redemption
	needs_item_input = TRUE
	processing_flags = START_PROCESSING_MANUALLY
	/// Whether the smartfridge is welded down to the floor disabling unwrenching
	var/welded_down = TRUE

	///Boolean on whether the ORM can claim points without being connected to an ore silo.
	var/requires_silo = TRUE
	/// The current amount of unclaimed points in the machine
	var/points = 0
	/// Smelted ore's amount is multiplied by this
	var/ore_multiplier = 1
	/// Increases the amount of points the miners gain
	var/point_upgrade = 1
	/// Details how many credits each smelted ore is worth
	var/static/list/ore_values = list(
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 15,
		/datum/material/silver = 16,
		/datum/material/gold = 18,
		/datum/material/titanium = 30,
		/datum/material/uranium = 30,
		/datum/material/diamond = 50,
		/datum/material/bluespace = 50,
		/datum/material/bananium = 60,
	)
	/// Variable that holds a timer which is used for callbacks to `send_console_message()`. Used for preventing multiple calls to this proc while the ORM is eating a stack of ores.
	var/console_notify_timer
	/// References the alloys the smelter can create
	var/datum/techweb/stored_research
	/// Linkage to the ORM silo
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/ore_redemption/offstation
	circuit = /obj/item/circuitboard/machine/ore_redemption/offstation
	requires_silo = FALSE

/obj/machinery/mineral/ore_redemption/Initialize(mapload)
	. = ..()
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter] = new /datum/techweb/autounlocking/smelter
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter]
	materials = AddComponent(
		/datum/component/remote_materials, \
		mapload, \
		mat_container_flags = BREAKDOWN_FLAGS_ORM \
	)

/obj/machinery/mineral/ore_redemption/Destroy()
	stored_research = null
	materials = null
	return ..()

/obj/machinery/mineral/ore_redemption/examine(mob/user)
	. = ..()
	if(welded_down)
		. += span_info("It's moored firmly to the floor. You can unsecure its moorings with a <b>welder</b>.")
	else if(anchored)
		. += span_info("It's currently anchored to the floor. You can secure its moorings with a <b>welder</b>, or remove it with a <b>wrench</b>.")
	else
		. += span_info("It's not anchored to the floor. You can secure it in place with a <b>wrench</b>.")
	if(panel_open)
		. += span_notice("Alt-click to rotate the input and output direction.")

/// Turns ore into its refined type, and sends it to its material container
/obj/machinery/mineral/ore_redemption/proc/smelt_ore(obj/item/stack/ore/gathered_ore)
	if(QDELETED(gathered_ore))
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		return

	if(gathered_ore.refined_type == null)
		return

	var/material_amount = mat_container.get_item_material_amount(gathered_ore, BREAKDOWN_FLAGS_ORM)

	if(!material_amount)
		qdel(gathered_ore) //no materials, incinerate it

	else if(!mat_container.has_space(material_amount * gathered_ore.amount)) //if there is no space, eject it
		unload_mineral(gathered_ore)

	else
		var/ore_amount = gathered_ore.amount
		var/ore_points= gathered_ore.points
		var/refined_type = gathered_ore?.refined_type
		if(mat_container.insert_item(gathered_ore, ore_multiplier, breakdown_flags = BREAKDOWN_FLAGS_ORM, context = src) > 0) //increase points only if insertion was successfull
			if(refined_type)
				points += ore_points * point_upgrade * ore_amount

	SEND_SIGNAL(src, COMSIG_ORM_COLLECTED_ORE)

/// Returns the amount of a specific alloy design, based on the accessible materials
/obj/machinery/mineral/ore_redemption/proc/can_smelt_alloy(datum/design/D)
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || D.make_reagent)
		return FALSE

	var/build_amount = 0

	for(var/mat in D.materials)
		var/amount = D.materials[mat]
		var/datum/material/redemption_mat_amount = mat_container.materials[mat]

		if(!amount || !redemption_mat_amount)
			return FALSE

		var/smeltable_sheets = FLOOR(redemption_mat_amount / amount, 1)

		if(!smeltable_sheets)
			return FALSE

		if(!build_amount)
			build_amount = smeltable_sheets

		build_amount = min(build_amount, smeltable_sheets)

	return build_amount

/// Smelts the passed ores one by one
/obj/machinery/mineral/ore_redemption/proc/process_ores(list/ores_to_process)
	for(var/ore in ores_to_process)
		smelt_ore(ore)

/// Sends a message to the request consoles that signed up for ore updates
/obj/machinery/mineral/ore_redemption/proc/send_console_message()
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || !is_station_level(z))
		return

	console_notify_timer = null

	var/area/our_area = get_area(src)
	var/message = "Now available in [our_area]:"

	var/has_minerals = FALSE
	var/list/appended_list = list()

	for(var/current_material in mat_container.materials)
		var/datum/material/material_datum = current_material
		var/mineral_amount = mat_container.materials[current_material] / SHEET_MATERIAL_AMOUNT
		if(mineral_amount)
			has_minerals = TRUE
		appended_list["[capitalize(material_datum.name)]"] = "[mineral_amount] sheets"

	if(!has_minerals)
		return

	var/datum/signal/subspace/messaging/rc/signal = new(src, list(
		"ore_update" = TRUE,
		"sender_department" = "Ore Redemption Machine",
		"message" = message,
		"verified" = "Ore Redemption Machine",
		"priority" = REQ_NORMAL_MESSAGE_PRIORITY,
		"appended_list" = appended_list,
	))
	signal.send_to_receivers()

/obj/machinery/mineral/ore_redemption/pickup_item(datum/source, atom/movable/target, direction)
	if(QDELETED(target))
		return
	if(!materials.mat_container || panel_open || !powered())
		return

	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/box = target
		process_ores(box.contents)
	else if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/O = target
		smelt_ore(O)
	else
		return

	if(!console_notify_timer)
		// gives 5 seconds for a load of ores to be sucked up by the ORM before it sends out request console notifications. This should be enough time for most deposits that people make
		console_notify_timer = addtimer(CALLBACK(src, PROC_REF(send_console_message)), 5 SECONDS)

/obj/machinery/mineral/ore_redemption/default_unfasten_wrench(mob/user, obj/item/I)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	if(anchored)
		register_input_turf() // someone just wrenched us down, re-register the turf
	else
		unregister_input_turf() // someone just un-wrenched us, unregister the turf

/obj/machinery/mineral/ore_redemption/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/mineral/ore_redemption/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return ..()

	var/obj/item/stack/ore/O = W
	if(istype(O))
		if(isnull(O.refined_type))
			to_chat(user, span_warning("[O] has already been refined!"))
			return
		smelt_ore(O)
		return TRUE
	return ..()

/obj/machinery/mineral/ore_redemption/AltClick(mob/living/user)
	. = ..()
	if(!user.can_perform_action(src))
		return
	if(panel_open)
		input_dir = turn(input_dir, -90)
		output_dir = turn(output_dir, -90)
		to_chat(user, span_notice("You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)]."))
		unregister_input_turf() // someone just rotated the input and output directions, unregister the old turf
		register_input_turf() // register the new one
		update_appearance(UPDATE_OVERLAYS)
		return TRUE

/obj/machinery/mineral/ore_redemption/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreRedemptionMachine")
		ui.open()

/obj/machinery/mineral/ore_redemption/ui_data(mob/user)
	var/list/data = list()
	data["unclaimedPoints"] = points
	data["materials"] = list()
	var/datum/component/material_container/mat_container = materials.mat_container
	if (mat_container)
		for(var/datum/material/material as anything in mat_container.materials)
			var/amount = mat_container.materials[material]
			var/sheet_amount = amount / SHEET_MATERIAL_AMOUNT
			data["materials"] += list(list(
				"name" = material.name,
				"id" = REF(material),
				"amount" = sheet_amount,
				"category" = "material",
				"value" = ore_values[material.type],
			))

		for(var/research in stored_research.researched_designs)
			var/datum/design/alloy = SSresearch.techweb_design_by_id(research)
			data["materials"] += list(list(
				"name" = alloy.name,
				"id" = alloy.id,
				"category" = "alloy",
				"amount" = can_smelt_alloy(alloy),
			))

	data["disconnected"] = null
	if (!mat_container)
		data["disconnected"] = "Local mineral storage is unavailable"
	else if (!materials.silo && requires_silo)
		data["disconnected"] = "No ore silo connection is available; storing locally"
	else if (!materials.check_z_level() && requires_silo)
		data["disconnected"] = "Unable to connect to ore silo, too far away"
	else if (materials.on_hold())
		data["disconnected"] = "Mineral withdrawal is on hold"

	var/obj/item/card/id/card
	if(isliving(user))
		var/mob/living/customer = user
		card = customer.get_idcard(hand_first = TRUE)
		if(card?.registered_account)
			data["user"] = list(
				"name" = card.registered_account.account_holder,
				"cash" = card.registered_account.account_balance,
			)

		else if(issilicon(user))
			var/mob/living/silicon/silicon_player = user
			data["user"] = list(
				"name" = silicon_player.name,
				"cash" = "No valid account",
			)
	return data

/obj/machinery/mineral/ore_redemption/ui_static_data(mob/user)
	var/list/data = list()

	var/datum/component/material_container/mat_container = materials.mat_container
	if (mat_container)
		for(var/datum/material/material as anything in mat_container.materials)
			var/obj/material_display = initial(material.sheet_type)
			data["material_icons"] += list(list(
				"id" = REF(material),
				"product_icon" = icon2base64(getFlatIcon(image(icon = initial(material_display.icon), icon_state = initial(material_display.icon_state)), no_anim=TRUE)),
			))

	for(var/research in stored_research.researched_designs)
		var/datum/design/alloy = SSresearch.techweb_design_by_id(research)
		var/obj/alloy_display = initial(alloy.build_path)
		data["material_icons"] += list(list(
			"id" = alloy.id,
			"product_icon" = icon2base64(getFlatIcon(image(icon = initial(alloy_display.icon), icon_state = initial(alloy_display.icon_state)), no_anim=TRUE)),
		))

	return data


/obj/machinery/mineral/ore_redemption/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	switch(action)
		if("Claim")
			var/obj/item/card/id/user_id_card
			if(isliving(usr))
				var/mob/living/user = usr
				user_id_card = user.get_idcard(TRUE)
			if(!materials.check_z_level() && (requires_silo || !user_id_card.registered_account.replaceable))
				return TRUE
			if(points)
				if(user_id_card)
					user_id_card.registered_account.mining_points += points
					points = 0
				else
					to_chat(usr, span_warning("No valid ID detected."))
			else
				to_chat(usr, span_warning("No points to claim."))
			return TRUE
		if("Release")
			if(!mat_container)
				return
			if(materials.on_hold())
				to_chat(usr, span_warning("Mineral access is on hold, please contact the quartermaster."))
			else if(!allowed(usr)) //Check the ID inside, otherwise check the user
				to_chat(usr, span_warning("Required access not found."))
			else
				var/datum/material/mat = locate(params["id"])

				var/amount = mat_container.materials[mat]
				if(!amount)
					return

				var/stored_amount = CEILING(amount / SHEET_MATERIAL_AMOUNT, 0.1)
				if(!stored_amount)
					return

				var/desired = text2num(params["sheets"])
				var/sheets_to_remove = round(min(desired, 50, stored_amount))
				materials.eject_sheets(mat, sheets_to_remove, get_step(src, output_dir))
			return TRUE
		if("Smelt")
			if(!mat_container)
				return
			if(materials.on_hold())
				to_chat(usr, span_warning("Mineral access is on hold, please contact the quartermaster."))
				return
			var/alloy_id = params["id"]
			var/datum/design/alloy = stored_research.isDesignResearchedID(alloy_id)
			var/obj/item/card/id/user_id_card
			if(isliving(usr))
				var/mob/living/user = usr
				user_id_card = user.get_idcard(TRUE)
			if((check_access(user_id_card) || allowed(usr)) && alloy)
				var/amount = round(min(text2num(params["sheets"]), 50, can_smelt_alloy(alloy)))
				if(amount < 1) //no negative mats
					return
				materials.use_materials(alloy.materials, multiplier = amount, action = "released", name = "sheets")
				var/output
				if(ispath(alloy.build_path, /obj/item/stack/sheet))
					output = new alloy.build_path(src, amount)
				else
					output = new alloy.build_path(src)
				unload_mineral(output)
			else
				to_chat(usr, span_warning("Required access not found."))
			return TRUE

/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	return ..()

/obj/machinery/mineral/ore_redemption/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()

/obj/machinery/mineral/ore_redemption/update_overlays()
	. = ..()
	if((machine_stat & NOPOWER))
		return
	var/image/ore_input = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_[input_dir]")
	var/image/ore_output = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_[REVERSE_DIR(input_dir)]")

	switch(input_dir)
		if(NORTH)
			ore_input.pixel_y = 32
			ore_output.pixel_y = -32
		if(SOUTH)
			ore_input.pixel_y = -32
			ore_output.pixel_y = 32
		if(EAST)
			ore_input.pixel_x = 32
			ore_output.pixel_x = -32
		if(WEST)
			ore_input.pixel_x = -32
			ore_output.pixel_x = 32

	ore_input.color = COLOR_MODERATE_BLUE
	ore_output.color = COLOR_SECURITY_RED
	var/mutable_appearance/light_in = emissive_appearance(ore_input.icon, ore_input.icon_state, offset_spokesman = src, alpha = ore_input.alpha)
	light_in.pixel_y = ore_input.pixel_y
	light_in.pixel_x = ore_input.pixel_x
	var/mutable_appearance/light_out = emissive_appearance(ore_output.icon, ore_output.icon_state, offset_spokesman = src, alpha = ore_output.alpha)
	light_out.pixel_y = ore_output.pixel_y
	light_out.pixel_x = ore_output.pixel_x
	. += ore_input
	. += ore_output
	. += light_in
	. += light_out

// welding code

/obj/machinery/mineral/ore_redemption/can_be_unfasten_wrench(mob/user, silent)
	if(welded_down)
		to_chat(user, span_warning("[src] is welded to the floor!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/mineral/ore_redemption/set_anchored(anchorvalue)
	. = ..()
	if(!anchored && welded_down) //make sure they're keep in sync in case it was forcibly unanchored by badmins or by a megafauna.
		welded_down = FALSE
	can_atmos_pass = anchorvalue ? ATMOS_PASS_NO : ATMOS_PASS_YES
	air_update_turf(TRUE, anchorvalue)

/obj/machinery/mineral/ore_redemption/welder_act(mob/living/user, obj/item/tool)
	..()
	if(welded_down)
		if(!tool.tool_start_check(user, amount=2))
			return TRUE
		user.visible_message(
			span_notice("[user.name] starts to cut the [name] free from the floor."),
			span_notice("You start to cut [src] free from the floor..."),
			span_hear("You hear welding."),
		)
		if(!tool.use_tool(src, user, delay=100, volume=100))
			return FALSE
		welded_down = FALSE
		to_chat(user, span_notice("You cut [src] free from the floor."))
		return TRUE
	if(!anchored)
		to_chat(user, span_warning("[src] needs to be wrenched to the floor!"))
		return TRUE
	if(!tool.tool_start_check(user, amount=2))
		return TRUE
	user.visible_message(
		span_notice("[user.name] starts to weld the [name] to the floor."),
		span_notice("You start to weld [src] to the floor..."),
		span_hear("You hear welding."),
	)
	if(!tool.use_tool(src, user, delay=100, volume=100))
		balloon_alert(user, "cancelled!")
		return FALSE
	welded_down = TRUE
	to_chat(user, span_notice("You weld [src] to the floor."))
	return TRUE

/obj/machinery/mineral/ore_redemption/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(machine_stat & BROKEN)
		if(!tool.tool_start_check(user, amount=1))
			return FALSE
		user.visible_message(
			span_notice("[user] is repairing [src]."),
			span_notice("You begin repairing [src]..."),
			span_hear("You hear welding."),
		)
		if(tool.use_tool(src, user, delay=40, volume=50))
			if(!(machine_stat & BROKEN))
				return FALSE
			balloon_alert(user, "repaired")
			atom_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			update_icon()
			return TRUE
	else
		balloon_alert(user, "no repair needed!")
		return FALSE

/obj/machinery/mineral/ore_redemption/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE
	if(held_item.tool_behaviour == TOOL_WELDER && !istype(src, /obj/machinery/mineral/ore_redemption))
		if(welded_down)
			context[SCREENTIP_CONTEXT_LMB] = "Unweld"
			tool_tip_set = TRUE
		else if (!welded_down && anchored)
			context[SCREENTIP_CONTEXT_LMB] = "Weld down"
			tool_tip_set = TRUE
		if(machine_stat & BROKEN)
			context[SCREENTIP_CONTEXT_RMB] = "Repair"
			tool_tip_set = TRUE
	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE