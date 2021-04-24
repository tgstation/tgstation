/obj/machinery/chem_dispenser/chem_synthesizer //formerly SCP-294 made by mrty, but now only for testing purposes
	name = "\improper debug chemical synthesizer"
	desc = "If you see this, yell at adminbus."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	amount = 10
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	flags_1 = NODECONSTRUCT_1
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

/obj/machinery/chem_dispenser/chem_synthesizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("ejectBeaker")
			if(beaker)
				try_put_in_hand(beaker, usr)
				beaker = null
				. = TRUE
		if("input")
			var/input_reagent = (input("Enter the name of any reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			if(!input_reagent)
				say("REAGENT NOT FOUND")
				return
			else
				if(!beaker)
					return
				else if(!beaker.reagents && !QDELETED(beaker))
					beaker.create_reagents(beaker.volume)
				beaker.reagents.add_reagent(input_reagent, amount, added_purity = (purity/100))
		if("makecup")
			if(beaker)
				return
			beaker = new /obj/item/reagent_containers/glass/beaker/bluespace(src)
			visible_message("<span class='notice'>[src] dispenses a bluespace beaker.</span>")
		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				amount = input
		if("purity")
			var/input = text2num(params["amount"])
			if(input)
				purity = input
	update_appearance()

/obj/machinery/chem_dispenser/chem_synthesizer/ui_data(mob/user)
	. = ..()
	.["purity"] = purity
	return .

/obj/machinery/chem_dispenser/chem_synthesizer/proc/find_reagent(input)
	. = FALSE
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return input
	else
		return get_chem_id(input)
