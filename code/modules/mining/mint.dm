/**********************Mint**************************/ // yes that's the name of the file sweetie


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"
	density = TRUE
	input_dir = EAST

	var/produced_coins = 0 // how many coins the machine has made in it's last cycle
	var/processing = FALSE
	var/chosen = /datum/material/iron //which material will be used to make coins
	speed_process = FALSE

/obj/machinery/mineral/mint/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/plasma, /datum/material/silver, /datum/material/gold, /datum/material/uranium, /datum/material/diamond, /datum/material/bananium), MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack)
	chosen = getmaterialref(chosen)

/obj/machinery/mineral/mint/process()
	var/turf/T = get_step(src, input_dir)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(T)
		for(var/obj/item/stack/sheet/O in T)
			materials.insert_stack(O, O.amount)
		for(var/obj/item/stack/ore/O in T)
			materials.insert_stack(O, O.amount)

	if (processing)
		var/datum/material/M = chosen

		if(!M || !M.coin_type)
			processing = FALSE
			icon_state = "coinpress0"
			return

		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT

		for (var/sheets = 0; sheets < 2; sheets++)
			if (materials.use_amount_mat(coin_mat, chosen))
				for (var/coin_to_make = 0; coin_to_make < 5; coin_to_make++)
					create_coins(M.coin_type)
					produced_coins++
			else 
				var/found_new = FALSE
				for(var/datum/material/inserted_material in materials.materials)
					var/amount = materials.get_material_amount(inserted_material)

					if (amount)
						chosen = inserted_material
						found_new = TRUE
				
				if (!found_new)
					processing = FALSE
	else
		icon_state = "coinpress0"

/obj/machinery/mineral/mint/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mint", name, 500, 450, master_ui, state)
		ui.open()

/obj/machinery/mineral/mint/ui_data()
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/datum/material/inserted_material in materials.materials)
		var/amount = materials.get_material_amount(inserted_material)
		
		if(!amount)
			continue

		data["inserted_materials"] += list(list(
			"material" = inserted_material.name,
			"amount" = amount
		))

		if (chosen == inserted_material)
			data["chosen_material"] = inserted_material.name

	data["produced_coins"] = produced_coins
	data["processing"] = processing

	return data;

/obj/machinery/mineral/mint/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if ("startpress")
			if (!processing)
				produced_coins = 0
			processing = TRUE
		if ("stoppress")
			processing = FALSE
		if ("changematerial")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			for(var/datum/material/mat in materials.materials)
				if (params["material_name"] == mat.name)
					chosen = mat

/obj/machinery/mineral/mint/proc/create_coins(P)
	var/turf/T = get_step(src,output_dir)
	if(T)
		var/obj/item/O = new P(src)
		var/obj/item/storage/bag/money/M = locate(/obj/item/storage/bag/money, T)
		if(!M)
			M = new /obj/item/storage/bag/money(src)
			unload_mineral(M)
		O.forceMove(M)
