///chemical plumbing filter. If it's not filtered by left and right, it goes straight.
/obj/machinery/plumbing/filter
	name = "chemical filter"
	desc = "A chemical filter for filtering chemicals. The left and right outputs appear to be from the perspective of the input port."
	icon_state = "filter"
	density = FALSE

	///whitelist of chems id's that go to the left side. Empty to disable port
	var/list/left = list()
	///whitelist of chem id's that go to the right side. Empty to disable port
	var/list/right = list()
	///whitelist of chems but their name instead of path
	var/list/english_left = list()
	///whitelist of chems but their name instead of path
	var/list/english_right = list()

/obj/machinery/plumbing/filter/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/filter, bolt, layer)

/obj/machinery/plumbing/filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemFilter", name)
		ui.open()

/obj/machinery/plumbing/filter/ui_data(mob/user)
	var/list/data = list()
	data["left"] = english_left
	data["right"] = english_right
	return data

/obj/machinery/plumbing/filter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("add")
			var/which = params["which"]

			var/selected_reagent = tgui_input_list(usr, "Select [which] reagent", "Reagent", GLOB.name2reagent)
			if(!selected_reagent)
				return TRUE
			if(QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return FALSE

			var/datum/reagent/chem_id = GLOB.name2reagent[selected_reagent]
			if(!chem_id)
				return TRUE

			switch(which)
				if("left")
					if(!left.Find(chem_id))
						english_left += selected_reagent
						left += chem_id
				if("right")
					if(!right.Find(chem_id))
						english_right += selected_reagent
						right += chem_id

		if("remove")
			var/chem_name = params["reagent"]
			var/chem_id = get_chem_id(chem_name)
			switch(params["which"])
				if("left")
					if(english_left.Find(chem_name))
						english_left -= chem_name
						left -= chem_id
				if("right")
					if(english_right.Find(chem_name))
						english_right -= chem_name
						right -= chem_id
