/obj/vehicle/sealed/mecha/update_overlays()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/gear1 = equip_by_category[MECHA_L_ARM]
	var/obj/item/mecha_parts/mecha_equipment/gear2 = equip_by_category[MECHA_R_ARM]

	if(gear1 && gear1.get_integrity() < gear1.max_integrity )
		. += mutable_appearance('icons/mob/rideables/mecha.dmi', "sparks_arms")
	else if(gear2 && gear2.get_integrity() < gear2.max_integrity)
		. += mutable_appearance('icons/mob/rideables/mecha.dmi', "sparks_arms")
