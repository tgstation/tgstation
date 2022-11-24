/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogenerator"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/biogenerator
	light_power = 1
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	var/processing = FALSE
	var/obj/item/reagent_containers/cup/beaker = null
	var/biomass = 0
	var/efficiency = 0
	var/productivity = 0
	var/max_items = 20
	var/max_biomass = 500
	var/max_output = 50
	var/datum/techweb/stored_research
	var/list/show_categories = list(RND_CATEGORY_BIO_FOOD, RND_CATEGORY_BIO_CHEMICALS, RND_CATEGORY_BIO_MATERIALS)
	var/selected_cat
	var/datum/looping_sound/generator/soundloop

/obj/machinery/biogenerator/Initialize(mapload)
	. = ..()
	stored_research = new /datum/techweb/specialized/autounlocking/biogenerator
	soundloop = new(src, processing)

/obj/machinery/biogenerator/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/biogenerator/contents_explosion(severity, target)
	. = ..()
	if(!beaker)
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += beaker
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += beaker
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += beaker

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_appearance()

/obj/machinery/biogenerator/RefreshParts()
	. = ..()
	var/E = 0
	var/P = 0
	var/I = 10
	var/V = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		I += 10 * B.rating
		V += 500 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		P += M.rating
		E += M.rating
	efficiency = E
	productivity = P
	max_items = I
	max_biomass = V
	update_appearance()

/obj/machinery/biogenerator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Productivity at <b>[productivity*100]%</b>.<br>Matter consumption reduced by <b>[(efficiency*25)-25]</b>%.<br>Machine can hold up to <b>[max_items]</b> pieces of produce.<br>And up to <b>[max_biomass]</b> units of biomass.")

/obj/machinery/biogenerator/update_appearance()
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || panel_open)
		luminosity = 0
		return
	luminosity = 1 + ROUND_UP(2 * biomass / max_biomass) + (processing & 1)

/obj/machinery/biogenerator/update_overlays()
	. = ..()
	if(panel_open)
		. += mutable_appearance(icon, "[icon_state]_o_panel", alpha = alpha)
	if(beaker)
		. += mutable_appearance(icon, "[icon_state]_o_container", alpha = alpha)
	if(biomass > 0)
		var/biomass_level = min(ROUND_UP(7 * biomass / max_biomass), 7)
		. += mutable_appearance(icon, "[icon_state]_o_biomass_[biomass_level]", alpha = alpha)
		. += emissive_appearance(icon, "[icon_state]_o_biomass_[biomass_level]", src, alpha = alpha)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(processing)
		. += mutable_appearance(icon, "[icon_state]_o_process", alpha = alpha)
		. += emissive_appearance(icon, "[icon_state]_o_process", src, alpha = alpha)
	. += mutable_appearance(icon, "[icon_state]_o_screen", alpha = alpha)
	. += emissive_appearance(icon, "[icon_state]_o_screen", src, alpha = alpha)

/obj/machinery/biogenerator/attackby(obj/item/O, mob/living/user, params)
	if(user.combat_mode)
		return ..()

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		if(processing)
			processing = FALSE
			soundloop.stop()
		if(beaker)
			var/obj/item/reagent_containers/cup/B = beaker
			B.forceMove(drop_location())
			beaker = null
		update_appearance()
		return

	var/turf/drop_location = drop_location()
	if(default_deconstruction_crowbar(O))
		if(biomass > 0)
			drop_location.visible_message(span_warning("The biomass spills!"))
			playsound(drop_location, 'sound/effects/slosh.ogg', 25, vary = TRUE)
			new /obj/effect/decal/cleanable/greenglow(drop_location)
		return

	if(istype(O, /obj/item/reagent_containers/cup))
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first."))
		else
			insert_beaker(user, O)
		return TRUE

	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/bag/bag = O
		var/i = 0
		for(var/obj/item/food/item in contents)
			i++
		if(i >= max_items)
			to_chat(user, span_warning("The biogenerator is already full! Activate it."))
		else
			for(var/obj/item/food/item in bag.contents)
				if(i >= max_items)
					break
				if(bag.atom_storage.attempt_remove(item, src))
					i++
			if(bag.contents.len == 0)
				to_chat(user, span_info("You empty the bag into the biogenerator."))
			else if (i >= max_items)
				to_chat(user, span_info("You fill the biogenerator from the bag to its capacity."))
			else
				to_chat(user, span_info("You fill the biogenerator from the bag."))
		return TRUE //no afterattack

	else if(istype(O, /obj/item/food))
		var/i = 0
		for(var/obj/item/food/item in contents)
			i++
		if(i >= max_items)
			to_chat(user, span_warning("The biogenerator is full! Activate it."))
		else
			if(user.transferItemToLoc(O, src))
				to_chat(user, span_info("You put [O.name] in [src.name]"))
		return TRUE //no afterattack
	else if (istype(O, /obj/item/disk/design_disk))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."),
			span_notice("You begin to load a design from \the [O]..."),
			span_hear("You hear the chatter of a floppy drive."))
		processing = TRUE
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 10, target = src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
		processing = FALSE
		return TRUE
	else
		to_chat(user, span_warning("You cannot put this in [src.name]!"))

/obj/machinery/biogenerator/AltClick(mob/living/user)
	. = ..()
	if(user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE) && can_interact(user))
		eject_beaker(user)

/**
 * activate: Activates biomass processing and converts all inserted food products into biomass
 *
 * Arguments:
 * * user The mob starting the biomass processing
 */
/obj/machinery/biogenerator/proc/activate(mob/user)
	if(user.stat != CONSCIOUS)
		return
	if(machine_stat != NONE)
		return
	if(processing)
		to_chat(user, span_warning("The biogenerator is in the process of working."))
		return
	if(biomass >= max_biomass)
		say("Warning: The biomass storage is full!")
		return
	if(locate(/obj/item/food) in contents)
		processing = TRUE
		soundloop.start()
		update_appearance()
		for(var/obj/item/food/object in contents)
			var/nutriments = 0
			for(var/nutriment in typesof(/datum/reagent/consumable/nutriment))
				nutriments += object.reagents.get_reagent_amount(nutriment)
			qdel(object)
			var/potential_biomass = max(1, nutriments) * productivity
			while(processing && potential_biomass > 0)
				use_power(active_power_usage * (0.01 SECONDS)) // Seconds needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules)
				potential_biomass -= 1
				biomass += 1
				stoplag(2 / productivity)
				update_appearance(UPDATE_ICON)
		processing = FALSE
		soundloop.stop()
		update_appearance()

/obj/machinery/biogenerator/proc/use_biomass(list/materials, amount = 1, remove_biomass = TRUE)
	if(materials.len != 1 || materials[1] != GET_MATERIAL_REF(/datum/material/biomass))
		return FALSE
	if (ROUND_UP(materials[GET_MATERIAL_REF(/datum/material/biomass)]*amount/efficiency) > biomass)
		return FALSE
	else
		if(remove_biomass)
			biomass -= ROUND_UP(materials[GET_MATERIAL_REF(/datum/material/biomass)]*amount/efficiency)
		update_appearance()
		return TRUE

/obj/machinery/biogenerator/proc/create_product(datum/design/D, amount)
	if(D.make_reagents.len > 0)
		if(!beaker)
			return FALSE
		if(beaker.reagents.maximum_volume - beaker.reagents.total_volume < amount)
			say("Warning: Attached container does not have enough free capacity!")
			return FALSE
		if(!use_biomass(D.materials, amount))
			return FALSE
		beaker.reagents.add_reagent(D.make_reagents[1], amount)
	if(D.build_path)
		if(!use_biomass(D.materials, amount))
			return FALSE
		new D.build_path(drop_location(), amount)
	return TRUE

/*
 * Insert a new beaker into the biogenerator, replacing/swapping our current beaker if there is one.
 *
 * user - the mob inserting the beaker
 * inserted_beaker - the beaker we're inserting into the biogen
 */
/obj/machinery/biogenerator/proc/insert_beaker(mob/living/user, obj/item/reagent_containers/cup/inserted_beaker)
	if(!can_interact(user))
		return

	if(!user.transferItemToLoc(inserted_beaker, src))
		return

	if(beaker)
		to_chat(user, span_notice("You swap out [beaker] in [src] for [inserted_beaker]."))
		eject_beaker(user, silent = TRUE)
	else
		to_chat(user, span_notice("You add [inserted_beaker] to [src]."))

	beaker = inserted_beaker
	update_appearance()

/*
 * Eject the current stored beaker either into the user's hands or onto the ground.
 *
 * user - the mob ejecting the beaker
 * silent - whether to give a message to the user that the beaker was ejected.
 */
/obj/machinery/biogenerator/proc/eject_beaker(mob/living/user, silent = FALSE)
	if(!beaker)
		return

	if(!can_interact(user))
		return

	if(user.put_in_hands(beaker))
		if(!silent)
			to_chat(user, span_notice("You eject [beaker] from [src]."))
	else
		if(!silent)
			to_chat(user, span_notice("You eject [beaker] from [src] onto the ground."))
		beaker.forceMove(drop_location())

	beaker = null
	update_appearance()

/obj/machinery/biogenerator/ui_status(mob/user)
	if(machine_stat & BROKEN || panel_open)
		return UI_CLOSE
	return ..()

/obj/machinery/biogenerator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/biogenerator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Biogenerator", name)
		ui.open()

/obj/machinery/biogenerator/ui_data(mob/user)
	var/list/data = list()
	data["beaker"] = beaker ? TRUE : FALSE
	data["biomass"] = biomass
	data["max_biomass"] = max_biomass
	data["processing"] = processing
	data["max_output"] = max_output
	data["efficiency"] = efficiency
	if((locate(/obj/item/food) in contents) && biomass < max_biomass)
		data["can_process"] = TRUE
	else
		data["can_process"] = FALSE
	if(beaker)
		data["beakerCurrentVolume"] = round(beaker.reagents.total_volume, 0.01)
		data["beakerMaxVolume"] = beaker.volume
		data["reagent_color"] = mix_color_from_reagents(beaker.reagents.reagent_list)
	return data

/obj/machinery/biogenerator/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()

	var/categories = show_categories.Copy()
	for(var/V in categories)
		categories[V] = list()
	for(var/V in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(V)
		for(var/C in categories)
			if(C in D.category)
				categories[C] += D

	for(var/category in categories)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/item in categories[category])
			var/datum/design/D = item
			cat["items"] += list(list(
				"id" = D.id,
				"name" = D.name,
				"is_reagent" = D.make_reagents.len > 0,
				"cost" = D.materials[GET_MATERIAL_REF(/datum/material/biomass)]/efficiency,
			))
		data["categories"] += list(cat)

	return data

/obj/machinery/biogenerator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("activate")
			activate(usr)
			return TRUE
		if("eject")
			eject_beaker(usr)
			return TRUE
		if("create")
			var/amount = text2num(params["amount"])
			if(!amount)
				return
			var/id = params["id"]
			if(!stored_research.researched_designs.Find(id))
				stack_trace("ID did not map to a researched datum [id]")
				return
			var/datum/design/D = SSresearch.techweb_design_by_id(id)
			amount = clamp(amount, 1, (D.make_reagents.len > 0 && beaker ? beaker.reagents.maximum_volume - beaker.reagents.total_volume : max_output))
			if(D && !istype(D, /datum/design/error_design))
				create_product(D, amount)
			else
				stack_trace("ID could not be turned into a valid techweb design datum [id]")
				return
			return TRUE
		if("select")
			selected_cat = params["category"]
			return TRUE
