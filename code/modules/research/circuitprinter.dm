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

	research_flags = HASOUTPUT | TAKESMATIN | CONSOLECONTROL

	allowed_materials=list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/pharosium,
		/obj/item/stack/sheet/mineral/char,
		/obj/item/stack/sheet/mineral/claretine,
		/obj/item/stack/sheet/mineral/bohrum,
		/obj/item/stack/sheet/mineral/syreline,
		/obj/item/stack/sheet/mineral/erebite,
		/obj/item/stack/sheet/mineral/cytine,
		/obj/item/stack/sheet/mineral/telecrystal,
		/obj/item/stack/sheet/mineral/mauxite,
		/obj/item/stack/sheet/mineral/cobryl,
		/obj/item/stack/sheet/mineral/cerenkite,
		/obj/item/stack/sheet/mineral/molitz,
		/obj/item/stack/sheet/mineral/uqill
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

	// Don't log reagent transfers.  They're just spammy.
	reagents_to_log=0

	RefreshParts()

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
