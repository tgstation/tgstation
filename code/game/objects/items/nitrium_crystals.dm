/obj/item/nitrium_crystal
	desc = "A weird brown crystal, it smokes when broken"
	name = "nitrium crystal"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "nitrium_crystal"
	var/cloud_size = 1

/obj/item/nitrium_crystal/attack_self(mob/user)
	. = ..()
	var/datum/effect_system/smoke_spread/chem/smoke = new
	var/turf/location = get_turf(src)
	create_reagents(5)
	reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, 3)
	reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, 2)
	smoke.attach(location)
	smoke.set_up(reagents, cloud_size, location, silent = TRUE)
	smoke.start()
	qdel(src)
