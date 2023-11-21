///////////////////////
///// Power stuff /////
///////////////////////
/obj/vehicle/sealed/mecha/proc/has_charge(amount)
	return (get_charge() >= amount)

/obj/vehicle/sealed/mecha/proc/get_charge()
	return cell?.charge

/obj/vehicle/sealed/mecha/proc/use_power(amount)
	return (get_charge() && cell.use(amount))

/obj/vehicle/sealed/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return TRUE
	return FALSE

//////////////////////
///// Ammo stuff /////
//////////////////////

///Max the ammo stored in all ballistic weapons for this mech
/obj/vehicle/sealed/mecha/proc/max_ammo()
	for(var/obj/item/I as anything in flat_equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = I
			gun.projectiles_cache = gun.projectiles_cache_max
