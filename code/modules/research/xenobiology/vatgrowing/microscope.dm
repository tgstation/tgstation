/obj/structure/microscope
	name = "Microscope"
	desc = "A simple microscope, allowing you to examine micro-organisms."
	var/obj/item/petri_dish/current_dish


/obj/structure/microscope/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/petri_dish))
		return ..()
	if(current_dish)
		to_chat(user, "<span class='warning'>There is already a petridish in \the [src].</span>")
		return
	to_chat(user, "<span class='notice'>You put [I] into \the [src].</span>")
	current_dish = I
	current_dish.forceMove(src)

/obj/structure/microscope/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "microscope", name, 400, 800, master_ui, state)
		ui.open()

/obj/structure/microscope/ui_data(mob/user)
	var/list/data = list()

	data["cell_lines"] = list()
	data["viruses"] = list()

	for(var/organism in current_dish.sample.micro_organisms) //All the microorganisms in the dish
		var/list/organism_information = list()
		if(istype(organism, /datum/micro_organism/cell_line))
			var/datum/micro_organism/cell_line/cell_line = organism
			organism_information["type"] = "cell line"
			organism_information["name"] = cell_line.name
			organism_information["desc"] = cell_line.desc
			organism_information["growth_rate"] = cell_line.growth_rate
			organism_information["suspectibility"] = cell_line.virus_suspectibility
			organism_information["requireds"] = get_reagent_list(cell_line.required_reagents)
			organism_information["supplementaries"] = get_reagent_list(cell_line.supplementary_reagents)
			organism_information["suppressives"] = get_reagent_list(cell_line.suppressive_reagents)
			data["cell_lines"] += organism_information

		if(istype(organism, /datum/micro_organism/virus))
			var/datum/micro_organism/virus/virus = organism
			organism_information["type"] = "virus"
			organism_information["name"] = virus.name
			organism_information["desc"] = virus.desc
			data["viruses"] += organism_information

	return data

/obj/structure/microscope/proc/get_reagent_list(list/reagents)
	var/reagent_list = list()
	for(var/i in reagents) //Convert from assoc to normal. Yeah very shit.
		reagent_list = i
	reagent_list.Join(", ")


/obj/structure/microscope/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject petridish")
			if(!current_dish)
				return FALSE
			current_dish.forceMove(get_turf(src))
			current_dish = null
			. = TRUE
	update_icon()
