/obj/item/gun/energy/laser/musket
	name = "laser musket"
	desc = "A hand-crafted laser weapon, it has a hand crank on the side to charge it up."
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "las_musket"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket)
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	can_bayonet = TRUE
	knife_x_offset = 22
	knife_y_offset = 11
	var/is_charging = FALSE

/obj/item/gun/energy/laser/musket/attack_self(mob/living/user as mob)
	var/obj/item/stock_parts/cell/charging_cell = get_cell()
	if(charging_cell.charge >= charging_cell.maxcharge)
		balloon_alert(user, "already charged!")
		return
	if(is_charging == FALSE)
		is_charging = TRUE
		playsound(src, 'sound/weapons/laser_crank.ogg', 40)
	balloon_alert(user, "charging...")
	if(do_after(user, 2 SECONDS, src, interaction_key = DOAFTER_SOURCE_CHARGE_MUSKET))
		charging_cell.give(500)
		update_appearance()
		is_charging = FALSE
		balloon_alert(user, "charged")	

/obj/item/gun/energy/laser/musket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_wielded=10)
