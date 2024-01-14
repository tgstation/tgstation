/obj/structure/chemical_tank/liquid
	name = "remote liquid pump"
	desc = "An industrial grade pump, capable of either siphoning or spewing liquids. Needs to be anchored first to work. Has a limited capacity internal storage."
	icon = 'monkestation/icons/obj/structures/liquid_pump.dmi'
	icon_state = "liquid_pump"
	component_name = "Liquid Pump Output"

	reagent_flags =  TRANSPARENT

/obj/structure/chemical_tank/liquid/after_reagent_add()
	var/turf/turf = get_turf(src)
	turf.add_liquid_from_reagents(reagents)
	reagents.remove_all(100000)

