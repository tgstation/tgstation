
//chemistry stuff here so that it can be easily viewed/modified
datum
	reagent
		tungsten
			name = "Tungsten"
			id = "tungsten"
			description = "A chemical element, and a strong oxidising agent."
			reagent_state = SOLID
			color = "#808080"	// rgb: 128, 128, 128
								//todo: make this silvery grey

		lithiumsodiumtungstate
			name = "Lithium Sodium Tungstate"
			id = "lithiumsodiumtungstate"
			description = "A reducing agent for geological compounds."
			reagent_state = LIQUID
			color = "#808080"	// rgb: 128, 128, 128
								//todo: make this silvery grey

		ground_rock
			name = "Ground Rock"
			id = "ground_rock"
			description = "A fine dust made of ground up rock."
			reagent_state = SOLID
			color = "#C81040" 	//rgb: 200, 16, 64
								//todo: make this brown

		density_separated_sample
			name = "Density separated sample"
			id = "density_separated_sample"
			description = "A watery paste used in chemical analysis, there are some chunks floating in it."
			reagent_state = LIQUID
			color = "#C81040" 	//rgb: 200, 16, 64
								//todo: make this browny-white

		analysis_sample
			name = "Analysis liquid"
			id = "analysis_sample"
			description = "A watery paste used in chemical analysis."
			reagent_state = LIQUID
			color = "#C81040" 	//rgb: 200, 16, 64
								//todo: make this white

		chemical_waste
			name = "Chemical Waste"
			id = "chemical_waste"
			description = "A viscous, toxic liquid left over from many chemical processes."
			reagent_state = LIQUID
			color = "#C81040" 	//rgb: 200, 16, 64
								//todo: make this fluoro/bright green

datum
	chemical_reaction
		lithiumsodiumtungstate	//LiNa2WO4, not the easiest chem to mix
			name = "Lithium Sodium Tungstate"
			id = "lithiumsodiumtungstate"
			result = "lithiumsodiumtungstate"
			required_reagents = list("lithium" = 1, "sodium" = 2, "tungsten" = 1, "oxygen" = 4)
			result_amount = 8

		density_separated_liquid
			name = "Density separated sample"
			id = "density_separated_sample"
			result = "density_separated_sample"
			secondary_results = list("chemical_waste" = 1)
			required_reagents = list("ground_rock" = 1, "lithiumsodiumtungstate" = 2)
			result_amount = 2

		analysis_liquid
			name = "Analysis sample"
			id = "analysis_sample"
			result = "analysis_sample"
			secondary_results = list("chemical_waste" = 1)
			required_reagents = list("density_separated_sample" = 5)
			result_amount = 4
			requires_heating = 1

/obj/item/weapon/reagent_containers/glass/solution_tray
	name = "solution tray"
	desc = "A small, open-topped glass container for delicate research samples. It sports a re-useable strip for labelling with a pen."
	icon = 'icons/obj/device.dmi'
	icon_state = "solution_tray"
	m_amt = 0
	g_amt = 5
	w_class = 1.0
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 2)
	volume = 2
	flags = FPRINT | OPENCONTAINER

obj/item/weapon/reagent_containers/glass/solution_tray/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		var/new_label = input("What should the new label be?","Label solution tray")
		if(new_label)
			name = "solution tray ([new_label])"
			user << "\blue You write on the label of the solution tray."
	else
		..(W, user)

/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays"

	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )
		new /obj/item/weapon/reagent_containers/glass/solution_tray( src )

/obj/item/weapon/reagent_containers/glass/beaker/tungsten
	name = "beaker 'tungsten'"
	New()
		..()
		reagents.add_reagent("tungsten",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/oxygen
	name = "beaker 'oxygen'"
	New()
		..()
		reagents.add_reagent("oxygen",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sodium
	name = "beaker 'sodium'"
	New()
		..()
		reagents.add_reagent("sodium",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/lithium
	name = "beaker 'lithium'"

	New()
		..()
		reagents.add_reagent("lithium",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"

	New()
		..()
		reagents.add_reagent("water",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/water
	name = "beaker 'water'"

	New()
		..()
		reagents.add_reagent("water",50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/fuel
	name = "beaker 'fuel'"

	New()
		..()
		reagents.add_reagent("fuel",50)
		update_icon()
