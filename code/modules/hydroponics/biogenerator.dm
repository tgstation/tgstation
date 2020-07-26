/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	circuit = /obj/item/circuitboard/machine/biogenerator
	var/processing = FALSE
	var/obj/item/reagent_containers/glass/beaker = null
	var/points = 0
	var/efficiency = 0
	var/productivity = 0
	var/max_items = 40
	var/datum/techweb/stored_research
	var/list/show_categories = list("Food", "Botany Chemicals", "Organic Materials")
	/// Currently selected category in the UI
	var/selected_cat

/obj/machinery/biogenerator/Initialize()
	. = ..()
	stored_research = new /datum/techweb/specialized/autounlocking/biogenerator
	create_reagents(1000)

/obj/machinery/biogenerator/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/biogenerator/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highobj += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.medobj += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.lowobj += beaker

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/biogenerator/RefreshParts()
	var/E = 0
	var/P = 0
	var/max_storage = 40
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		P += B.rating
		max_storage = 40 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
	productivity = P
	max_items = max_storage

/obj/machinery/biogenerator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Productivity at <b>[productivity*100]%</b>.<br>Matter consumption reduced by <b>[(efficiency*25)-25]</b>%.<br>Machine can hold up to <b>[max_items]</b> pieces of produce.</span>"

/obj/machinery/biogenerator/on_reagent_change(changetype)			//When the reagents change, change the icon as well.
	update_icon()

/obj/machinery/biogenerator/update_icon_state()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!src.beaker)
		icon_state = "biogen-empty"
	else if(!src.processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"

/obj/machinery/biogenerator/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
		return

	if(default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", O))
		if(beaker)
			var/obj/item/reagent_containers/glass/B = beaker
			B.forceMove(drop_location())
			beaker = null
		update_icon()
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
		if(!panel_open)
			if(beaker)
				to_chat(user, "<span class='warning'>A container is already loaded into the machine.</span>")
			else
				if(!user.transferItemToLoc(O, src))
					return
				beaker = O
				to_chat(user, "<span class='notice'>You add the container to the machine.</span>")
				update_icon()
		else
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		return

	else if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/PB = O
		var/i = 0
		for(var/obj/item/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
		else
			for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)
				if(i >= max_items)
					break
				if(SEND_SIGNAL(PB, COMSIG_TRY_STORAGE_TAKE, G, src))
					i++
			if(i<max_items)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator.</span>")
			else if(PB.contents.len == 0)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator, filling it to its capacity.</span>")
			else
				to_chat(user, "<span class='info'>You fill the biogenerator to its capacity.</span>")
		return TRUE //no afterattack

	else if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		var/i = 0
		for(var/obj/item/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
		else
			if(user.transferItemToLoc(O, src))
				to_chat(user, "<span class='info'>You put [O.name] in [src.name]</span>")
		return TRUE //no afterattack
	else if (istype(O, /obj/item/disk/design_disk))
		user.visible_message("<span class='notice'>[user] begins to load \the [O] in \the [src]...</span>",
			"<span class='notice'>You begin to load a design from \the [O]...</span>",
			"<span class='hear'>You hear the chatter of a floppy drive.</span>")
		processing = TRUE
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 10, target = src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
		processing = FALSE
		return TRUE
	else
		to_chat(user, "<span class='warning'>You cannot put this in [src.name]!</span>")

/obj/machinery/biogenerator/AltClick(mob/living/user)
	. = ..()
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) && can_interact(user))
		detach(user)

/**
  * activate: Activates biomass processing and converts all inserted grown products into biomass
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
		to_chat(user, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return
	var/S = 0
	for(var/obj/item/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) < 0.1)
			points += 1 * productivity
		else
			points += I.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 10 * productivity
		qdel(I)
	if(S)
		processing = TRUE
		update_icon()
		playsound(loc, 'sound/machines/blender.ogg', 50, TRUE)
		use_power(S * 30)
		sleep(S + 15 / productivity)
		processing = FALSE
		update_icon()

/obj/machinery/biogenerator/proc/check_cost(list/materials, multiplier = 1, remove_points = TRUE)
	if(materials.len != 1 || materials[1] != SSmaterials.GetMaterialRef(/datum/material/biomass))
		return FALSE
	if (materials[SSmaterials.GetMaterialRef(/datum/material/biomass)]*multiplier/efficiency > points)
		return FALSE
	else
		if(remove_points)
			points -= materials[SSmaterials.GetMaterialRef(/datum/material/biomass)]*multiplier/efficiency
		update_icon()
		return TRUE

/obj/machinery/biogenerator/proc/check_container_volume(list/reagents, multiplier = 1)
	var/sum_reagents = 0
	for(var/R in reagents)
		sum_reagents += reagents[R]
	sum_reagents *= multiplier

	if(beaker.reagents.total_volume + sum_reagents > beaker.reagents.maximum_volume)
		return FALSE

	return TRUE

/obj/machinery/biogenerator/proc/create_product(datum/design/D, amount)
	if(!beaker || !loc)
		return FALSE

	if(ispath(D.build_path, /obj/item/stack))
		if(!check_container_volume(D.make_reagents, amount))
			return FALSE
		if(!check_cost(D.materials, amount))
			return FALSE

		new D.build_path(drop_location(), amount)
		for(var/R in D.make_reagents)
			beaker.reagents.add_reagent(R, D.make_reagents[R]*amount)
	else
		var/i = amount
		while(i > 0)
			if(!check_container_volume(D.make_reagents))
				say("Warning: Attached container does not have enough free capacity!")
				return .
			if(!check_cost(D.materials))
				return .
			if(D.build_path)
				new D.build_path(loc)
			for(var/R in D.make_reagents)
				beaker.reagents.add_reagent(R, D.make_reagents[R])
			. = 1
			--i
	update_icon()
	return .

/obj/machinery/biogenerator/proc/detach(mob/living/user)
	if(beaker)
		if(can_interact(user))
			user.put_in_hands(beaker)
		else
			beaker.drop_location(get_turf(src))
		beaker = null
		update_icon()

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
	data["biomass"] = points
	data["processing"] = processing
	if(locate(/obj/item/reagent_containers/food/snacks/grown) in contents)
		data["can_process"] = TRUE
	else
		data["can_process"] = FALSE
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
				"cost" = D.materials[SSmaterials.GetMaterialRef(/datum/material/biomass)]/efficiency,
			))
		data["categories"] += list(cat)

	return data

/obj/machinery/biogenerator/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("activate")
			activate(usr)
			return TRUE
		if("detach")
			detach(usr)
			return TRUE
		if("create")
			var/amount = text2num(params["amount"])
			amount = clamp(amount, 1, 10)
			if(!amount)
				return
			var/id = params["id"]
			if(!stored_research.researched_designs.Find(id))
				stack_trace("ID did not map to a researched datum [id]")
				return
			var/datum/design/D = SSresearch.techweb_design_by_id(id)
			if(D && !istype(D, /datum/design/error_design))
				create_product(D, amount)
			else
				stack_trace("ID could not be turned into a valid techweb design datum [id]")
				return
			return TRUE
		if("select")
			selected_cat = params["category"]
			return TRUE
