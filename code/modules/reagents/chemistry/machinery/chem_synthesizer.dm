/obj/machinery/chem_dispenser/chem_synthesizer //formerly SCP-294 made by mrty, but now only for testing purposes
	name = "\improper debug chemical synthesizer"
	desc = "If you see this, yell at adminbus."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	amount = 10
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	obj_flags = NO_DECONSTRUCTION
	use_power = NO_POWER_USE
	var/static/list/shortcuts = list(
		"meth" = /datum/reagent/drug/methamphetamine
	)
	///The purity of the created reagent in % (purity uses 0-1 values)
	var/purity = 100

/obj/machinery/chem_dispenser/chem_synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDebugSynthesizer", name)
		ui.open()

/obj/machinery/chem_dispenser/chem_synthesizer/handle_ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("input")
			if(QDELETED(beaker))
				return FALSE

			var/selected_reagent = tgui_input_list(ui.user, "Select reagent", "Reagent", GLOB.name2reagent)
			if(!selected_reagent)
				return FALSE

			var/datum/reagent/input_reagent = GLOB.name2reagent[selected_reagent]
			if(!input_reagent)
				return FALSE

			beaker.reagents.add_reagent(input_reagent, amount, added_purity = (purity / 100))
			return TRUE

		if("makecup")
			if(beaker)
				return
			beaker = new /obj/item/reagent_containers/cup/beaker/bluespace(src)
			visible_message(span_notice("[src] dispenses a bluespace beaker."))
			return TRUE

		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				amount = input
			return FALSE

		if("purity")
			var/input = text2num(params["amount"])
			if(input)
				purity = input
			return FALSE

	update_appearance()

/obj/machinery/chem_dispenser/chem_synthesizer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_dispenser/chem_synthesizer/ui_data(mob/user)
	. = ..()
	.["purity"] = purity
