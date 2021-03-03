/obj/item/nitryum_crystal
	desc = "A weird brown crystal, it smokes when broken"
	name = "nitryum crystal"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "nitryum_crystal"
	var/cloud_size = 1

/obj/item/nitryum_crystal/attack_self(mob/user)
	. = ..()
	var/datum/effect_system/smoke_spread/chem/smoke = new
	var/turf/location = get_turf(src)
	create_reagents(5)
	reagents.add_reagent(/datum/reagent/nitryum_low_metabolization, 3)
	reagents.add_reagent(/datum/reagent/nitryum_high_metabolization, 2)
	smoke.attach(location)
	smoke.set_up(reagents, cloud_size, location, silent = TRUE)
	smoke.start()
	qdel(src)
