///chemical plumbing filter. If it's not filtered by left and right, it goes straight.
/obj/machinery/plumbing/filter
	name = "chemical filter"
	desc = "A chemical filter for filtering chemicals. The left and right outputs appear to be from the perspective of the input port."
	icon_state = "filter"
	density = FALSE
	reagents = /datum/reagents/plumbing/filter

	///whitelist of chems id's that go to the left side. Empty to disable port
	var/list/left = list()
	///whitelist of chem id's that go to the right side. Empty to disable port
	var/list/right = list()

/obj/machinery/plumbing/filter/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/multidirectional/filter, layer)

/obj/machinery/plumbing/filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemFilter", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/plumbing/filter/ui_data(mob/user)
	. = ..()

	.["left"] = list()
	for(var/datum/reagent/id as anything in left)
		.["left"] += id::name

	.["right"] = list()
	for(var/datum/reagent/id as anything in right)
		.["right"] += id::name

/obj/machinery/plumbing/filter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("add")
			var/which = params["which"]

			var/selected_reagent = tgui_input_list(usr, "Select [which] reagent", "Reagent", GLOB.name2reagent)
			if(!selected_reagent)
				return
			if(QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return

			var/datum/reagent/chem_id = GLOB.name2reagent[selected_reagent]
			if(!chem_id)
				return FALSE

			switch(which)
				if("left")
					left |= chem_id
					return TRUE

				if("right")
					right |= chem_id
					return TRUE

		if("remove")
			var/chem_id = GLOB.name2reagent[params["reagent"]]
			if(!chem_id)
				return FALSE

			switch(params["which"])
				if("left")
					left -= chem_id
					return TRUE

				if("right")
					right -= chem_id
					return TRUE
