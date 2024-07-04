/obj/structure/microscope
	name = "Microscope"
	desc = "A simple microscope, allowing you to examine micro-organisms."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "microscope"
	///Analyzed dish
	var/obj/item/petri_dish/current_dish

/obj/structure/microscope/Initialize(mapload)
	. = ..()
	var/static/list/hovering_item_typechecks = list(
		/obj/item/petri_dish = list(
			SCREENTIP_CONTEXT_LMB = "Add petri dish",
		),
	)
	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Remove petri dish")

/obj/structure/microscope/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/petri_dish))
		return add_dish(user, tool)

/obj/structure/microscope/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(current_dish)
		return remove_dish(user)

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

	for(var/organism in current_dish.sample.micro_organisms)
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
			if(current_dish)
				remove_dish(ui.user)
				. = TRUE
	update_appearance()

///Insert a new dish, swapping the inserted one
/obj/structure/microscope/proc/add_dish(mob/living/user, obj/item/petri_dish/new_dish)
	var/obj/item/petri_dish/old_dish
	if(current_dish)
		old_dish = current_dish
	if(!user.transferItemToLoc(new_dish, src))
		balloon_alert(user, "couldn't add!")
		return ITEM_INTERACT_FAILURE
	current_dish = new_dish
	update_static_data_for_all_viewers()
	if(old_dish)
		if(!user.put_in_hands(old_dish))
			old_dish.forceMove(get_turf(src))
		balloon_alert(user, "dish swapped")
	else
		balloon_alert(user, "dish added")
	return ITEM_INTERACT_SUCCESS

///Take the inserted dish, or drop it on the floor
/obj/structure/microscope/proc/remove_dish(mob/living/user)
	if(!current_dish)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(!user.put_in_hands(current_dish))
		current_dish.forceMove(get_turf(src))
	current_dish = null
	update_static_data_for_all_viewers()
	balloon_alert(user, "dish removed")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/crafting_recipe/microscope
	name = "Microscope"
	result = /obj/structure/microscope
	time = 30
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/sheet/plastic = 1,
	)
	category = CAT_CHEMISTRY
