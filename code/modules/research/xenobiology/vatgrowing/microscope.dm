/obj/structure/microscope
	name = "Microscope"
	desc = "A simple microscope, allowing you to examine micro-organisms."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "microscope"
	var/obj/item/petri_dish/current_dish

/obj/structure/microscope/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/petri_dish))
		if(current_dish)
			balloon_alert(user, "already has a dish!")
			return ITEM_INTERACT_FAILURE
		if(!user.transferItemToLoc(tool, src))
			balloon_alert(user, "couldn't add!")
			return ITEM_INTERACT_FAILURE
		current_dish = tool
		update_static_data_for_all_viewers()
		balloon_alert(user, "dish added")
	return ..()

/obj/structure/microscope/attack_hand_secondary(mob/user, list/modifiers)
	if(current_dish && user.put_in_hands(current_dish))
		current_dish = null
		update_static_data_for_all_viewers()
		balloon_alert(user, "dish removed")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/microscope/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Microscope", name)
		ui.open()

/obj/structure/microscope/ui_static_data(mob/user)
	var/list/data = list()

	data["has_dish"] = current_dish ? TRUE : FALSE
	data["cell_lines"] = list()

	if(!current_dish)
		return data
	if(!current_dish.sample)
		return data

	for(var/organism in current_dish.sample.micro_organisms) //All the microorganisms in the dish
		if(istype(organism, /datum/micro_organism/cell_line))
			var/datum/micro_organism/cell_line/cell_line = organism
			var/atom/resulting_atom = cell_line.resulting_atom
			var/list/organism_data = list(
				type = "cell line",
				name = cell_line.name,
				desc = cell_line.desc,
				icon = resulting_atom ? initial(resulting_atom.icon) : "",
				icon_state = resulting_atom ? initial(resulting_atom.icon_state) : "",
				consumption_rate = cell_line.consumption_rate * SSMACHINES_DT,
				growth_rate = cell_line.growth_rate * SSMACHINES_DT,
				suspectibility = cell_line.virus_suspectibility * SSMACHINES_DT,
				requireds = get_reagent_list(cell_line.required_reagents),
				supplementaries = get_reagent_list(cell_line.supplementary_reagents),
				suppressives = get_reagent_list(cell_line.suppressive_reagents)
			)
			data["cell_lines"] += list(organism_data)

		if(istype(organism, /datum/micro_organism/virus))
			var/datum/micro_organism/virus/virus = organism
			var/list/virus_data = list(
				type = "virus",
				name = virus.name,
				desc = virus.desc
			)
			data["cell_lines"] += list(virus_data)

	return data

/obj/structure/microscope/proc/get_reagent_list(list/reagents)
	var/list/reagent_list = list()
	for(var/i in reagents) //Convert from assoc to normal. Yeah very shit.
		var/datum/reagent/reagent = i
		reagent_list["[initial(reagent.name)]"] = reagents[i] * SSMACHINES_DT
	return reagent_list

/obj/structure/microscope/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_petridish")
			if(!current_dish)
				return FALSE
			if(!ui.user.put_in_hands(current_dish))
				current_dish.forceMove(get_turf(src))
			current_dish = null
			update_static_data_for_all_viewers()
			. = TRUE
	update_appearance()

/datum/crafting_recipe/microscope
	name = "Microscope"
	result = /obj/structure/microscope
	time = 30
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/flashlight = 1,
	)
	category = CAT_CHEMISTRY
