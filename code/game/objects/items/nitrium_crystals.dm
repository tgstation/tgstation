/obj/item/nitrium_crystal
	desc = "A weird brown crystal, it smokes when broken"
	name = "nitrium crystal"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "nitrium_crystal"
	var/cloud_size = 1

/obj/item/nitrium_crystal/attack_self(mob/user)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	var/turf/location = get_turf(src)
	create_reagents(5)
	reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, 3)
	reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, 2)
	smoke.attach(location)
	smoke.set_up(cloud_size, holder = src, location = location, carry = reagents, silent = TRUE)
	smoke.start()
	qdel(src)
