/**********************Ore Redemption Unit (ORM)**************************/
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

	//mat_container_signals is for reedeming points from local storage if silo is not required
	var/list/local_signals = null
	if(!requires_silo)
		local_signals = list(
			COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/mineral/ore_redemption, local_redeem_points)
		)
	materials = AddComponent( \
		/datum/component/remote_materials, \
		mapload, \
		mat_container_signals = local_signals \
	)

	//for reedeming points from items inserted into ore silo
	RegisterSignal(src, COMSIG_SILO_ITEM_CONSUMED, TYPE_PROC_REF(/obj/machinery/mineral/ore_redemption, silo_redeem_points))

/obj/machinery/mineral/ore_redemption/Destroy()
	stored_research = null
	materials = null
	return ..()

/obj/machinery/mineral/ore_redemption/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Alt-click to rotate the input and output direction.")


/obj/machinery/mineral/ore_redemption/proc/silo_redeem_points(obj/machinery/mineral/ore_redemption/machine, container, obj/item/stack/ore/gathered_ore)
	SIGNAL_HANDLER

	local_redeem_points(container, gathered_ore)

/obj/machinery/mineral/ore_redemption/proc/local_redeem_points(container, obj/item/stack/ore/gathered_ore)
	SIGNAL_HANDLER

	if(istype(gathered_ore) && gathered_ore.refined_type)
		points += gathered_ore.points * point_upgrade * gathered_ore.amount

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

/obj/machinery/mineral/ore_redemption/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!materials.mat_container || panel_open || !powered())
		return ..()

	var/list/obj/item/stack/ore/gathered_ores = list()
	if(istype(tool, /obj/item/stack/ore))
		gathered_ores += tool
	else if(tool.atom_storage && !tool.atom_storage.locked)
		tool.atom_storage.remove_type(/obj/item/stack/ore, src, check_adjacent = TRUE, user = user, inserted = gathered_ores)
	if(!gathered_ores.len)
		return ..()

	for(var/obj/item/stack/ore/gathered_ore as anything in gathered_ores)
		var/obj/item/smelted_ore = gathered_ore.on_orm_collection()
		if(isnull(smelted_ore))
			continue

		if(materials.insert_item(smelted_ore, ore_multiplier) <= 0)
			unload_mineral(smelted_ore)

	return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/ore_redemption/pickup_item(datum/source, atom/movable/target, direction)
	if(QDELETED(target))
		return
	if(!materials.mat_container || panel_open || !powered())
		return

	//gethering the ore
	var/list/obj/item/stack/ore/ore_list = list()
	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/box = target
		for(var/obj/item/stack/ore/ore_item in box.contents)
			ore_list += ore_item
	else if(istype(target, /obj/item/stack/ore))
		ore_list += target
	else
		return

	//smelting the ore
	for(var/obj/item/stack/ore/gathered_ore as anything in ore_list)
		var/obj/item/smelted_ore = gathered_ore.on_orm_collection()
		if(isnull(smelted_ore))
			continue

		if(materials.insert_item(smelted_ore, ore_multiplier) <= 0)
			unload_mineral(smelted_ore) //if rejected unload

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

/obj/machinery/mineral/ore_redemption/screwdriver_act(mob/living/user, obj/item/tool)
	default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/ore_redemption/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/ore_redemption/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/ore_redemption/click_alt(mob/living/user)
	if(!panel_open)
		return CLICK_ACTION_BLOCKING
	input_dir = turn(input_dir, -90)
	output_dir = turn(output_dir, -90)
	to_chat(user, span_notice("You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)]."))
	unregister_input_turf() // someone just rotated the input and output directions, unregister the old turf
	register_input_turf() // register the new one
	update_appearance(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS

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
			var/obj/sheet_type = material.sheet_type
			data["materials"] += list(list(
				"name" = material.name,
				"id" = REF(material),
				"amount" = sheet_amount,
				"category" = "material",
				"value" = ore_values[material.type],
				"icon" = sheet_type::icon,
				"icon_state" = sheet_type::icon_state,
			))

		for(var/research in stored_research.researched_designs)
			var/datum/design/alloy = SSresearch.techweb_design_by_id(research)
			var/obj/alloy_type = alloy.build_path
			data["materials"] += list(list(
				"name" = alloy.name,
				"id" = alloy.id,
				"category" = "alloy",
				"amount" = can_smelt_alloy(alloy),
				"icon" = alloy_type::icon,
				"icon_state" = alloy_type::icon_state,
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

/obj/machinery/mineral/ore_redemption/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	switch(action)
		if("Claim")
			//requires silo but silo not in range
			if(requires_silo && !materials.check_z_level())
				return FALSE

			//no ID
			var/obj/item/card/id/user_id_card
			if(isliving(usr))
				var/mob/living/user = usr
				user_id_card = user.get_idcard(TRUE)
			if(isnull(user_id_card))
				say("No ID card found.")
				return FALSE

			//we have points
			if(points)
				user_id_card.registered_account.mining_points += points
				points = 0
				return TRUE

			return FALSE
		if("Release")
			if(!mat_container)
				return
			if(!materials.can_use_resource(user_data = ID_DATA(usr)))
				return
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
				materials.eject_sheets(mat, sheets_to_remove, get_step(src, output_dir), user_data = ID_DATA(usr))
			return TRUE
		if("Smelt")
			if(!mat_container)
				return
			if(!materials.can_use_resource(user_data = ID_DATA(usr)))
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
				materials.use_materials(alloy.materials, multiplier = amount, action = "withdrawn", name = "sheets", user_data = ID_DATA(usr))
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
			ore_input.pixel_z = 32
			ore_output.pixel_z = -32
		if(SOUTH)
			ore_input.pixel_z = -32
			ore_output.pixel_z = 32
		if(EAST)
			ore_input.pixel_w = 32
			ore_output.pixel_w = -32
		if(WEST)
			ore_input.pixel_w = -32
			ore_output.pixel_w = 32

	ore_input.color = COLOR_MODERATE_BLUE
	ore_output.color = COLOR_SECURITY_RED
	var/mutable_appearance/light_in = emissive_appearance(ore_input.icon, ore_input.icon_state, offset_spokesman = src, alpha = ore_input.alpha)
	light_in.pixel_z = ore_input.pixel_z
	light_in.pixel_w = ore_input.pixel_w
	var/mutable_appearance/light_out = emissive_appearance(ore_output.icon, ore_output.icon_state, offset_spokesman = src, alpha = ore_output.alpha)
	light_out.pixel_z = ore_output.pixel_z
	light_out.pixel_w = ore_output.pixel_w
	. += ore_input
	. += ore_output
	. += light_in
	. += light_out
