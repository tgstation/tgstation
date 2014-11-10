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
	part_sets = list( //set names must be unique
	"Pod_Frame" = list(
						/obj/item/pod_parts/pod_frame/fore_port,
						/obj/item/pod_parts/pod_frame/fore_starboard,
						/obj/item/pod_parts/pod_frame/aft_port,
						/obj/item/pod_parts/pod_frame/aft_starboard
						),
	"Pod_Armor" = list(
						/obj/item/pod_parts/armor
						),
	"Pod_Parts" = list(
						/obj/item/pod_parts/core
						),
	"Pod_Weaponry" = list(
						/obj/item/device/spacepod_equipment/weaponry/taser
						),
	"Misc" = list(
						)
	)

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