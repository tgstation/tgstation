#define LIMBGROWER_MAIN_MENU       1
#define LIMBGROWER_CATEGORY_MENU   2
//use these for the menu system


/obj/machinery/limbgrower
	name = "limb grower"
	desc = "It grows new limbs using Synthflesh."
	icon = 'icons/obj/machines/limbgrower.dmi'
	icon_state = "limbgrower_idleoff"
	density = 1
	flags = OPENCONTAINER

	var/operating = 0
	anchored = 1
	use_power = 1
	var/disabled = 0
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff = 1

	var/datum/design/being_built
	var/datum/research/files
	var/list/datum/design/matching_designs
	var/selected_category
	var/screen = 1

	var/list/categories = list(
							"Human",
							"Lizard",
							)

	var/mob/living/carbon/human/human



/obj/machinery/limbgrower/New()
	..()
	create_reagents(0)
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/limbgrower(null)
	human = new /mob/living/carbon/human()
	B.apply_default_parts(src)


	reagents.add_reagent("synthflesh",100)

	files = new /datum/research/limbgrower(src)
	matching_designs = list()

/obj/item/weapon/circuitboard/machine/limbgrower
	name = "circuit board (Limb Grower)"
	build_path = /obj/machinery/limbgrower
	origin_tech = "engineering=1;programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/machinery/limbgrower/Destroy()
	return ..()

/obj/machinery/limbgrower/interact(mob/user)
	if(!is_operational())
		return

	var/dat = main_win(user)

	switch(screen)
		if(LIMBGROWER_MAIN_MENU)
			dat = main_win(user)
		if(LIMBGROWER_CATEGORY_MENU)
			dat = category_win(user,selected_category)
			/*
		if(LIMBGROWER_SEARCH_MENU)
			dat = search_win(user)
*/
	var/datum/browser/popup = new(user, "Limb Grower", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/limbgrower/deconstruction()
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)

/obj/machinery/limbgrower/attackby(obj/item/O, mob/user, params)
	if (busy)
		user << "<span class=\"alert\">The Limb Grower is busy. Please wait for completion of previous operation.</span>"
		return 1
/*
	if (ispath(O,/obj/item/weapon/reagent_containers))
		if(!O.reagents.hasreagent("synthflesh") && O.reagents.reagentlist.length!=1)
			user << "<span class=\"alert\">The Limb grower refuses the chemicals, perhaps it only accepts pure synthflesh?</span>"
*/
	if(default_deconstruction_screwdriver(user, "limbgrower_panelopen", "limbgrower_idleoff", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(O)
			return 1

	if(user.a_intent == "harm") //so we can hit the machine
		return ..()

	if(stat)
		return 1

	if(O.flags & HOLOGRAM)
		return 1

/obj/machinery/limbgrower/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		if(href_list["category"])
			selected_category = href_list["category"]

		if(href_list["make"])

			/////////////////
			//href protection
			being_built = files.FindDesignByID(href_list["make"]) //check if it's a valid design
			if(!being_built)
				return


			var/synth_cost = being_built.reagents["synthflesh"]*prod_coeff
			var/power = max(2000, synth_cost/5)

			if(reagents.has_reagent("synthflesh", being_built.reagents["synthflesh"]*prod_coeff))
				busy = 1
				use_power(power)
				flick("limbgrower_fill",src)
				icon_state = "limbgrower_idleon"
				spawn(32*prod_coeff)
					use_power(power)
					reagents.remove_reagent("synthflesh",being_built.reagents["synthflesh"]*prod_coeff)
					var/B = being_built.build_path
					world << "Starting creaton of a limb"
					if(ispath(B, /obj/item/bodypart))	//This feels like spatgheti code, but i need to initilise a limb somehow
						//i need to create a body part manually using a set specias dna
						var/obj/item/bodypart/L
						world << "category start"
						world << "[selected_category] is the current category"
						switch(selected_category)
							if("Human")
								//Human dna
								L = new B()
								world << "Trying to update limb"
								L.name = "Synthentic Human Limb"
								L.desc = "A synthentic human limb that will morph on its first use in surgery"
							else if("Lizard")
								//Lizard dna
								L = new B()
								world << "Trying to update lizard limb"
								L.name = "Synthentic Lizard Limb"
								L.desc = "A synthentic lizard limb that will morph on its first use in surgery"
						L.icon = "human_r_arm_s"
						L.loc = loc;
					busy = 0
					flick("limbgrower_unfill",src)
					icon_state = "limbgrower_idleoff"
					src.updateUsrDialog()

	else
		usr << "<span class=\"alert\">The limb grower is busy. Please wait for completion of previous operation.</span>"

	src.updateUsrDialog()

	return

/obj/machinery/limbgrower/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/T=1.2
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/limbgrower/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Limb Grower Menu:</h3><br>"
	dat += materials_printout()
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[LIMBGROWER_CATEGORY_MENU]'>[C]</A></td>"
		dat += "</tr><tr>"
		//one category per line

	dat += "</tr></table></div>"
	return dat

/obj/machinery/limbgrower/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=\ref[src];menu=[LIMBGROWER_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += materials_printout()

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[selected_category] [D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[selected_category] [D.name]</a>"
		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat

/obj/machinery/limbgrower/proc/materials_printout()
	var/dat = "<b>Total amount:></b> [reagents.total_volume] / [reagents.maximum_volume] cm<sup>3</sup><br>"
	return dat

/obj/machinery/limbgrower/proc/can_build(datum/design/D)
	return (reagents.has_reagent("synthflesh", D.reagents["synthflesh"]*prod_coeff)) //Return whether the machine has enough synthflesh to produce the design

/obj/machinery/limbgrower/proc/get_design_cost(datum/design/D)
	var/dat
	if(D.reagents["synthflesh"])
		dat += "[D.reagents["synthflesh"] * prod_coeff] Synthetic flesh "
	return dat