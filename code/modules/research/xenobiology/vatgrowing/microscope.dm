/obj/structure/microscope
	name = "Microscope"
	desc = "A simple microscope, allowing you to examine micro-organisms."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "microscope"
	var/obj/item/petri_dish/current_dish

/obj/structure/microscope/attacked_by(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You begin to [anchored ? "unwrench" : "wrench"] [src].</span>")
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>You successfully [anchored ? "unwrench" : "wrench"] [src].</span>")
			set_anchored(!anchored)

	else if(istype(I, /obj/item/petri_dish))
		if(current_dish)
			to_chat(user, "<span class='warning'>There is already a petridish in \the [src].</span>")
			return
		to_chat(user, "<span class='notice'>You put [I] into \the [src].</span>")
		current_dish = I
		current_dish.forceMove(src)
	else
		return ..()

/obj/structure/microscope/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Microscope")
		ui.open()

/obj/structure/microscope/ui_data(mob/user)
	var/list/data = list()

	data["has_dish"] = current_dish ? TRUE : FALSE
	data["cell_lines"] = list()
	data["viruses"] = list()

	if(!current_dish)
		return data
	if(!current_dish.sample)
		return data

	for(var/organism in current_dish.sample.micro_organisms) //All the microorganisms in the dish
		if(istype(organism, /datum/micro_organism/cell_line))
			var/datum/micro_organism/cell_line/cell_line = organism
			var/list/organism_data = list(
				type = "cell line",
				name = cell_line.name,
				desc = cell_line.desc,
				growth_rate = cell_line.growth_rate,
				suspectibility = cell_line.virus_suspectibility,
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
			data["viruses"] += list(virus_data)

	return data

/obj/structure/microscope/proc/get_reagent_list(list/reagents)
	var/list/reagent_list = list()
	for(var/i in reagents) //Convert from assoc to normal. Yeah very shit.
		var/datum/reagent/reagent = i
		reagent_list += initial(reagent.name)
	return reagent_list.Join(", ")


/obj/structure/microscope/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_petridish")
			if(!current_dish)
				return FALSE
			current_dish.forceMove(get_turf(src))
			current_dish = null
			. = TRUE
	update_icon()
