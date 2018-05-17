GLOBAL_DATUM(ore_silo, /obj/machinery/ore_silo)
GLOBAL_LIST_INIT(silo_access_lathes, list())

/obj/machinery/ore_silo
	name = "ore silo" // construct additional silos, commander
	desc = "Stores the station's ore. "
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_silo"
	density = TRUE
	anchored = TRUE

/obj/machinery/ore_silo/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),INFINITY, FALSE, list(/obj/item/stack))
	GLOB.ore_silo = src

/obj/machinery/ore_silo/on_deconstruction()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	. = ..()