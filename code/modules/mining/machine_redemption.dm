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

	var/points = 0
	var/ore_multiplier = 1
	var/point_upgrade = 1
	var/list/ore_values = list(/datum/material/iron = 1, /datum/material/glass = 1,  /datum/material/plasma = 15,  /datum/material/silver = 16, /datum/material/gold = 18, /datum/material/titanium = 30, /datum/material/uranium = 30, /datum/material/diamond = 50, /datum/material/bluespace = 50, /datum/material/bananium = 60)
	/// Variable that holds a timer which is used for callbacks to `send_console_message()`. Used for preventing multiple calls to this proc while the ORM is eating a stack of ores.
	var/console_notify_timer
	var/datum/techweb/stored_research
	var/obj/item/disk/design_disk/inserted_disk
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/ore_redemption/Initialize(mapload)
	. = ..()
	stored_research = new /datum/techweb/specialized/autounlocking/smelter
	materials = AddComponent(/datum/component/remote_materials, "orm", mapload, mat_container_flags=BREAKDOWN_FLAGS_ORM)

/obj/machinery/mineral/ore_redemption/Destroy()
	QDEL_NULL(stored_research)
	materials = null
	return ..()

/obj/machinery/mineral/ore_redemption/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Smelting <b>[ore_multiplier]</b> sheet(s) per piece of ore.<br>Reward point generation at <b>[point_upgrade*100]%</b>.</span>"
	if(panel_open)
		. += "<span class='notice'>Alt-click to rotate the input and output direction.</span>"

/obj/machinery/mineral/ore_redemption/proc/smelt_ore(obj/item/stack/ore/O)
	if(QDELETED(O))
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		return

	if(O.refined_type == null)
		return

	if(O?.refined_type)
		points += O.points * point_upgrade * O.amount

	var/material_amount = mat_container.get_item_material_amount(O, BREAKDOWN_FLAGS_ORM)

	if(!material_amount)
		qdel(O) //no materials, incinerate it

	else if(!mat_container.has_space(material_amount * O.amount)) //if there is no space, eject it
		unload_mineral(O)

	else
		var/list/stack_mats = O.get_material_composition(BREAKDOWN_FLAGS_ORM)
		var/mats = stack_mats & mat_container.materials
		var/amount = O.amount
		mat_container.insert_item(O, ore_multiplier, breakdown_flags=BREAKDOWN_FLAGS_ORM) //insert it
		materials.silo_log(src, "smelted", amount, "someone", mats)
		qdel(O)

/obj/machinery/mineral/ore_redemption/proc/can_smelt_alloy(datum/design/D)
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || D.make_reagents.len)
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

/obj/machinery/mineral/ore_redemption/proc/process_ores(list/ores_to_process)
	for(var/ore in ores_to_process)
		smelt_ore(ore)

/obj/machinery/mineral/ore_redemption/proc/send_console_message()
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || !is_station_level(z))
		return

	console_notify_timer = null

	var/area/A = get_area(src)
	var/msg = "Now available in [A]:<br>"

	var/has_minerals = FALSE

	for(var/mat in mat_container.materials)
		var/datum/material/M = mat
		var/mineral_amount = mat_container.materials[mat] / MINERAL_MATERIAL_AMOUNT
		if(mineral_amount)
			has_minerals = TRUE
		msg += "[capitalize(M.name)]: [mineral_amount] sheets<br>"

	if(!has_minerals)
		return

	var/datum/signal/subspace/messaging/rc/signal = new(src, list(
		"ore_update" = TRUE,
		"sender" = "Ore Redemption Machine",
		"message" = msg,
		"verified" = "<font color='green'><b>Verified by Ore Redemption Machine</b></font>",
		"priority" = REQ_NORMAL_MESSAGE_PRIORITY
	))
	signal.send_to_receivers()

/obj/machinery/mineral/ore_redemption/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
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
		console_notify_timer = addtimer(CALLBACK(src, .proc/send_console_message), 5 SECONDS)

/obj/machinery/mineral/ore_redemption/default_unfasten_wrench(mob/user, obj/item/I)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	if(anchored)
		register_input_turf() // someone just wrenched us down, re-register the turf
	else
		unregister_input_turf() // someone just un-wrenched us, unregister the turf

/obj/machinery/mineral/ore_redemption/attackby(obj/item/W, mob/user, params)
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return ..()

	if(istype(W, /obj/item/disk/design_disk))
		if(user.transferItemToLoc(W, src))
			inserted_disk = W
			return TRUE

	var/obj/item/stack/ore/O = W
	if(istype(O))
		if(O.refined_type == null)
			to_chat(user, "<span class='warning'>[O] has already been refined!</span>")
			return

	return ..()

/obj/machinery/mineral/ore_redemption/AltClick(mob/living/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(panel_open)
		input_dir = turn(input_dir, -90)
		output_dir = turn(output_dir, -90)
		to_chat(user, "<span class='notice'>You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)].</span>")
		unregister_input_turf() // someone just rotated the input and output directions, unregister the old turf
		register_input_turf() // register the new one
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
		for(var/mat in mat_container.materials)
			var/datum/material/M = mat
			var/amount = mat_container.materials[M]
			var/sheet_amount = amount / MINERAL_MATERIAL_AMOUNT
			var/ref = REF(M)
			data["materials"] += list(list("name" = M.name, "id" = ref, "amount" = sheet_amount, "value" = ore_values[M.type]))

		data["alloys"] = list()
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			data["alloys"] += list(list("name" = D.name, "id" = D.id, "amount" = can_smelt_alloy(D)))

	if (!mat_container)
		data["disconnected"] = "local mineral storage is unavailable"
	else if (!materials.silo)
		data["disconnected"] = "no ore silo connection is available; storing locally"
	else if (materials.on_hold())
		data["disconnected"] = "mineral withdrawal is on hold"

	data["diskDesigns"] = list()
	data["hasDisk"] = FALSE
	if(inserted_disk)
		data["hasDisk"] = TRUE
		if(inserted_disk.blueprints.len)
			var/index = 1
			for (var/datum/design/thisdesign in inserted_disk.blueprints)
				if(thisdesign)
					data["diskDesigns"] += list(list("name" = thisdesign.name, "index" = index, "canupload" = thisdesign.build_type&SMELTER))
				index++
	return data

/obj/machinery/mineral/ore_redemption/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	switch(action)
		if("Claim")
			var/obj/item/card/id/I
			if(isliving(usr))
				var/mob/living/L = usr
				I = L.get_idcard(TRUE)
			if(points)
				if(I)
					I.mining_points += points
					points = 0
				else
					to_chat(usr, "<span class='warning'>No valid ID detected.</span>")
			else
				to_chat(usr, "<span class='warning'>No points to claim.</span>")
			return TRUE
		if("Release")
			if(!mat_container)
				return
			if(materials.on_hold())
				to_chat(usr, "<span class='warning'>Mineral access is on hold, please contact the quartermaster.</span>")
			else if(!allowed(usr)) //Check the ID inside, otherwise check the user
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
			else
				var/datum/material/mat = locate(params["id"])

				var/amount = mat_container.materials[mat]
				if(!amount)
					return

				var/stored_amount = CEILING(amount / MINERAL_MATERIAL_AMOUNT, 0.1)

				if(!stored_amount)
					return

				var/desired = 0
				if (params["sheets"])
					desired = text2num(params["sheets"])
				else
					desired = input("How many sheets?", "How many sheets would you like to smelt?", 1) as null|num

				var/sheets_to_remove = round(min(desired,50,stored_amount))

				var/count = mat_container.retrieve_sheets(sheets_to_remove, mat, get_step(src, output_dir))
				var/list/mats = list()
				mats[mat] = MINERAL_MATERIAL_AMOUNT
				materials.silo_log(src, "released", -count, "sheets", mats)
				//Logging deleted for quick coding
			return TRUE
		if("diskInsert")
			var/obj/item/disk/design_disk/disk = usr.get_active_held_item()
			if(istype(disk))
				if(!usr.transferItemToLoc(disk,src))
					return
				inserted_disk = disk
			else
				to_chat(usr, "<span class='warning'>Not a valid Design Disk!</span>")
			return TRUE
		if("diskEject")
			if(inserted_disk)
				usr.put_in_hands(inserted_disk)
				inserted_disk = null
			return TRUE
		if("diskUpload")
			var/n = text2num(params["design"])
			if(inserted_disk && inserted_disk.blueprints && inserted_disk.blueprints[n])
				stored_research.add_design(inserted_disk.blueprints[n])
			return TRUE
		if("Smelt")
			if(!mat_container)
				return
			if(materials.on_hold())
				to_chat(usr, "<span class='warning'>Mineral access is on hold, please contact the quartermaster.</span>")
				return
			var/alloy_id = params["id"]
			var/datum/design/alloy = stored_research.isDesignResearchedID(alloy_id)
			var/obj/item/card/id/I
			if(isliving(usr))
				var/mob/living/L = usr
				I = L.get_idcard(TRUE)
			if((check_access(I) || allowed(usr)) && alloy)
				var/smelt_amount = can_smelt_alloy(alloy)
				var/desired = 0
				if (params["sheets"])
					desired = text2num(params["sheets"])
				else
					desired = input("How many sheets?", "How many sheets would you like to smelt?", 1) as null|num
				var/amount = round(min(desired,50,smelt_amount))
				mat_container.use_materials(alloy.materials, amount)
				materials.silo_log(src, "released", -amount, "sheets", alloy.materials)
				var/output
				if(ispath(alloy.build_path, /obj/item/stack/sheet))
					output = new alloy.build_path(src, amount)
				else
					output = new alloy.build_path(src)
				unload_mineral(output)
			else
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
			return TRUE

/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	..()

/obj/machinery/mineral/ore_redemption/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()
