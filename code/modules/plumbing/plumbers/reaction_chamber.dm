///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents seperated and only reacts under your given terms
/obj/machinery/plumbing/reaction_chamber
	name = "reaction chamber"
	desc = "Keeps chemicals seperated until given conditions are met."
	icon_state = "reaction_chamber"

	buffer = 100
	reagent_flags = TRANSPARENT | NOREACT
	/**list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/oil = 50)
	*//
	var/list/required_reagents = list()
	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE


/obj/machinery/plumbing/reaction_chamber/Initialize()
	. = ..()

/obj/machinery/plumbing/reaction_chamber/on_reagent_change()
	if(reagents.total_volume == 0 && RC.emptying) //we were emptying, but now we aren't
		emptying = FALSE

/obj/machinery/plumbing/reaction_chamber/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_reactor", name, 500, 500, master_ui, state)
		ui.open()

/obj/machinery/plumbing/reaction_chamber/ui_data(mob/user)
	var/list/data = list()
	data["reagents"] = required_reagents
	data["emptying"] = emptying
	return data

/obj/machinery/plumbing/reaction_chamber/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("remove")
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
		if("add")
