//////////////////////////////////////////
//				SCP 294					//
//										//
//	This is a child of a chemistry		//
//	dispenser. Info of how it works at	//
//	http://www.scp-wiki.net/scp-294		//
//										//
//////////////////////////////////////////

/obj/machinery/chem_dispenser/scp_294
	name = "\improper strange coffee machine"
	desc = "It appears to be a standard coffee vending machine, the only noticeable difference being an entry touchpad with buttons corresponding to a Galactic Common QWERTY keyboard."
	icon = 'icons/obj/vending.dmi'
	icon_state = "coffee"
	amount = 10
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/static/list/shortcuts = list(
		"meth" = "methamphetamine",
		"tricord" = "tricordrazine"
	)

/obj/machinery/chem_dispenser/scp_294/Initialize()
	. = ..()
	GLOB.poi_list += src

/obj/machinery/chem_dispenser/scp_294/Destroy()
	. = ..()
	GLOB.poi_list -= src

/obj/machinery/chem_dispenser/scp_294/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "scp_294", name, 390, 315, master_ui, state)
		ui.open()

/obj/machinery/chem_dispenser/scp_294/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("ejectBeaker")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				cut_overlays()
				. = TRUE
		if("input")
			var/input_reagent = replacetext(lowertext(input("Enter the name of any liquid", "Input") as text), " ", "") //95% of the time, the reagent id is a lowercase/no spaces version of the name
			if(shortcuts[input_reagent])
				input_reagent = shortcuts[input_reagent]
			else
				input_reagent = find_reagent(input_reagent)
			if(!input_reagent || !GLOB.chemical_reagents_list[input_reagent])
				say("OUT OF RANGE")
				return
			else
				if(!beaker)
					return
				else if(!beaker.reagents && !QDELETED(beaker))
					beaker.create_reagents(beaker.volume)
				beaker.reagents.add_reagent(input_reagent, 10)
		if("makecup")
			if(beaker)
				return
			beaker = new /obj/item/reagent_containers/food/drinks/sillycup(src)
			visible_message("<span class='notice'>[src] dispenses a small, paper cup.</span>")

/obj/machinery/chem_dispenser/scp_294/proc/find_reagent(input)
	. = FALSE
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		var/datum/reagent/R = GLOB.chemical_reagents_list[input]
		if(R.can_synth)
			return input
	else
		for(var/X in GLOB.chemical_reagents_list)
			var/datum/reagent/R = GLOB.chemical_reagents_list[X]
			if(R.can_synth && input == replacetext(lowertext(R.name), " ", ""))
				return X