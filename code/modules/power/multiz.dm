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
	. += locate(/obj/structure/cable/multilayer/multiz) in (SSmapping.get_turf_below(T))
	. += locate(/obj/structure/cable/multilayer/multiz) in (SSmapping.get_turf_above(T))

/obj/structure/cable/multilayer/examine(mob/user)
	. += ..()
	var/turf/T = get_turf(src)
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (SSmapping.get_turf_below(T)) ? "Detected" : "Undetected"] hub UP.")
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (SSmapping.get_turf_above(T)) ? "Detected" : "Undetected"] hub DOWN.")

