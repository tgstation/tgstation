/obj/item/ammo_casing/reagent
	name = "pressurized liquid"
	desc = "You shouldn't be seeing this!"
	projectile_type = /obj/projectile/reagent
	firing_effect_type = null

/obj/item/ammo_casing/reagent/Initialize(mapload)
	. = ..()
	create_reagents(10, OPENCONTAINER)

/obj/item/ammo_casing/reagent/newshot(new_volume)
	if(!isnull(new_volume))
		reagents.maximum_volume = new_volume
	return ..()


/obj/item/ammo_casing/reagent/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	var/obj/item/gun/gun = loc
	if(gun.reagents && !reagents.total_volume)
		gun.reagents.trans_to(src, reagents.maximum_volume, transferred_by = user)
	return ..()

/obj/item/ammo_casing/reagent/water
	projectile_type = /obj/projectile/reagent/water
