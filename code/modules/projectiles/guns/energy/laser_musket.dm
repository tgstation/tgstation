/obj/item/gun/energy/laser/musket
	name = "laser musket"
	desc = "A rudimentary laser weapon, its crude systems are incapable of holding more than a single shot."
	icon_state = "musket"
	inhand_icon_state = "musket"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket)
	var/is_charging = FALSE

/obj/item/gun/energy/laser/musket/attack_self(mob/living/user as mob)
	var/obj/item/stock_parts/cell/charging_cell = get_cell()
	if(charging_cell.charge < charging_cell.maxcharge)
		if(is_charging == FALSE)
			is_charging = TRUE
			playsound(src, 'sound/weapons/laser_crank.ogg', 40)
		balloon_alert(user, "charging...")
		if(do_after(user, 5 SECONDS, src, interaction_key = DOAFTER_SOURCE_CHARGE_MUSKET))
			charging_cell.give(charging_cell.maxcharge - charging_cell.charge)
			update_appearance()
			balloon_alert(user, "recharged")
			is_charging = FALSE
	else
		balloon_alert(user, "already charged!")

/obj/item/gun/energy/laser/musket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_wielded=10)
