/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

/obj/machinery/r_n_d/fabricator/pod
	name = "Spacepod Fabricator"
	desc = "Nothing is being built."
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
						),
	"Misc" = list(
						)
	)

	locked_parts = list(
		/obj/item/device/spacepod_equipment/weaponry //lock up the guns, yeah
	)

/obj/machinery/mecha_part_fabricator/New()
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