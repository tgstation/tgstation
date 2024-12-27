/obj/machinery/chem_dispenser/chem_synthesizer //formerly SCP-294 made by mrty, but now only for testing purposes
	name = "\improper debug chemical synthesizer"
	desc = "If you see this, yell at adminbus."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	amount = 10
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	use_power = NO_POWER_USE

	///The temperature of the added reagents
	var/temperature = DEFAULT_REAGENT_TEMPERATURE
	///The purity of the created reagent in % (purity uses 0-1 values)
	var/purity = 100

/obj/machinery/chem_dispenser/chem_synthesizer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_dispenser/chem_synthesizer/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/chem_dispenser/chem_synthesizer/crowbar_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/chem_dispenser/chem_synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDebugSynthesizer", name)
		ui.open()


/obj/machinery/chem_dispenser/chem_synthesizer/ui_data(mob/user)
	. = ..()
	.["purity"] = purity
	.["temp"] = temperature

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

			beaker.reagents.add_reagent(input_reagent, amount, reagtemp = temperature, added_purity = (purity / 100))
			return TRUE

		if("makecup")
			if(beaker)
				return
			beaker = new /obj/item/reagent_containers/cup/beaker/bluespace(src)
			visible_message(span_notice("[src] dispenses a bluespace beaker."))
			return TRUE

		if("amount")
			var/input = params["amount"]
			if(isnull(input))
				return FALSE

			input = text2num(input)
			if(isnull(input))
				return FALSE

			amount = input
			return TRUE

		if("temp")
			var/input = params["amount"]
			if(isnull(input))
				return FALSE

			input = text2num(input)
			if(isnull(input))
				return FALSE

			temperature = input
			return TRUE

		if("purity")
			var/input = params["amount"]
			if(isnull(input))
				return FALSE

			input = text2num(input)
			if(isnull(input))
				return FALSE

			purity = input
			return TRUE

	update_appearance()
