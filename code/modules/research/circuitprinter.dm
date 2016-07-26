/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/

#define IMPRINTER_BUILD_TIME	1

/obj/machinery/r_n_d/fabricator/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	desc = "A fabricator capable of etching circuit designs onto glass and minerals."
	flags = OPENCONTAINER

	max_material_storage = 75000
	build_time = IMPRINTER_BUILD_TIME
	build_number = 1

	research_flags = HASOUTPUT | TAKESMATIN | CONSOLECONTROL | LOCKBOXES

	// Don't log reagent transfers.  They're just spammy.
	log_reagents = 0

	part_sets = list(
		"Machine Boards" = list(),
		"Console Boards" = list(),
		"Mecha Boards" = list(),
		"Module Boards" = list(),
		"Engineering Boards" = list(),
		"Misc" = list()
	)

	allowed_materials = list(
						MAT_GLASS,
						MAT_GOLD,
						MAT_DIAMOND,
						MAT_URANIUM,
						MAT_PLASMA
	)

/obj/machinery/r_n_d/fabricator/circuit_imprinter/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/circuit_imprinter,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/circuit_imprinter/Destroy()
	if(linked_console && linked_console.linked_imprinter == src)
		linked_console.linked_imprinter = null	//Clearing of the rest is handled in the parent.

	. = ..()


/obj/machinery/r_n_d/fabricator/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		T += G.reagents.maximum_volume

	create_reagents(T) // Holder for the reagents used as materials.
	T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000

/obj/machinery/r_n_d/fabricator/circuit_imprinter/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (O.is_open_container())
		return 0
