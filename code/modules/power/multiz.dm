/obj/structure/cable/multilayer/multiz //This bridges powernets betwen Z levels
	name = "multi z layer cable hub"
	desc = "A flexible, superconducting insulated multi Z layer hub for heavy-duty multi Z power transfer."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-on"
	cable_layer = CABLE_LAYER_1|CABLE_LAYER_2|CABLE_LAYER_3
	machinery_layer = null

/obj/structure/cable/multilayer/multiz/get_cable_connections(powernetless_only)
	. = ..()
	var/turf/T = get_turf(src)

	var/turf/below_turf = SSmapping.get_turf_below(T)
	var/turf/above_turf = SSmapping.get_turf_above(T)

	. += locate(/obj/structure/cable/multilayer/multiz) in (below_turf?.cable_nodes)
	. += locate(/obj/structure/cable/multilayer/multiz) in (above_turf?.cable_nodes)

/obj/structure/cable/multilayer/examine(mob/user)
	. += ..()
	var/turf/T = get_turf(src)

	var/turf/below_turf = SSmapping.get_turf_below(T)
	var/turf/above_turf = SSmapping.get_turf_above(T)

	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (below_turf?.cable_nodes) ? "Detected" : "Undetected"] hub UP.")
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (above_turf?.cable_nodes) ? "Detected" : "Undetected"] hub DOWN.")

