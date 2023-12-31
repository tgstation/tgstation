/obj/structure/chemical_tank/smoke
	name = "remote smoke machine"
	desc = "A machine with a centrifuge installed into it. It produces smoke with any reagents its given."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "smoke0"
	base_icon_state = "smoke"
	component_name = "Smoke Machine Output"

	reagent_flags =  TRANSPARENT

/obj/structure/chemical_tank/smoke/after_reagent_add()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	smoke.attach(get_turf(src))
	smoke.set_up(amount = reagents.total_volume, holder = src, location = get_turf(src), carry = reagents, silent = TRUE)
	smoke.start(log = FALSE)

	reagents.remove_all(100000)

