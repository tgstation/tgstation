/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

/obj/machinery/r_n_d/fabricator/pod
	name = "Spacepod Fabricator"
	desc = "Used for producing all the spacepod goodies."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"
	build_number = 32
	nano_file = "podfab.tmpl"
	research_flags = NANOTOUCH | HASOUTPUT | HASMAT_OVER | TAKESMATIN | ACCESS_EMAG | LOCKBOXES


/obj/machinery/r_n_d/fabricator/pod/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/podfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()