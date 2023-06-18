/obj/item/gun/energy/laser/musket
	name = "laser musket"
	desc = "A rudimentary laser weapon, it's crude systems incapable of holding more than a single shot."
	icon_state = "musket" //set to musket
	inhand_icon_state = "laser"//set to musket
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket)
	var/is_charging = FALSE

/obj/item/gun/energy/laser/musket/attack_self(mob/living/user as mob)
	var/obj/item/stock_parts/cell/charging_cell = get_cell()
	if(charging_cell.charge < charging_cell.maxcharge)
		if(is_charging == FALSE)
			is_charging = TRUE
			playsound(src, 'sound/weapons/laser_crank.ogg', 40)
		balloon_alert(user, "charging...")
		if(do_after(user, 4.5 SECONDS, src, interaction_key = DOAFTER_SOURCE_CHARGE_MUSKET))
			charging_cell.give(charging_cell.maxcharge - charging_cell.charge)
			update_appearance()
			balloon_alert(user, "recharged")
			is_charging = FALSE
	else
		balloon_alert(user, "already charged!")
