
/obj/item/storage/belt/fannypack/yellow/bee_terrorist/PopulateContents()
	new /obj/item/grenade/c4 (src)
	new /obj/item/reagent_containers/applicator/pill/cyanide(src)
	new /obj/item/grenade/chem_grenade/facid(src)

/obj/item/paper/fluff/bee_objectives
	name = "Objectives of a Bee Liberation Front Operative"
	default_raw_text = "<b>Objective #1</b>. Liberate all bees on the NT transport vessel 2416/B. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/machinery/syndicatebomb/shuttle_loan
	add_boom_wires = FALSE

/obj/machinery/syndicatebomb/shuttle_loan/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)
	timer_set = rand(480, 600) //once the supply shuttle docks (after 5 minutes travel time), players have between 3-5 minutes to defuse the bomb
	activate()
	update_appearance()

/obj/item/paper/fluff/cargo/bomb
	name = "hastly scribbled note"
	default_raw_text = "GOOD LUCK!"

/obj/item/paper/fluff/cargo/bomb/allyourbase
	default_raw_text = "Somebody set us up the bomb!"
