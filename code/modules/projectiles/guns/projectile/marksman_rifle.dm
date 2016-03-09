/obj/item/weapon/gun/projectile/marksman_rifle
	name = "marksman rifle"
	desc = "A cross between WT auto-rifle and sniper rifle. Optimised for eliminating multiple targets in quick succession"
	icon_state = "marksmanrifle"
	item_state = "marksmanrifle"
	recoil = 2
	heavy_weapon = 1
	mag_type = /obj/item/ammo_box/magazine/m762dmr
	fire_delay = 4
	origin_tech = "combat=6"
	can_unsuppress = 1
	can_suppress = 1
	w_class = 3
	zoomable = TRUE
	zoom_amt = 7 //same scope as the sniper

/obj/item/weapon/gun/projectile/marksman_rifle/update_icon()
	..()
	icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/marksman_rifle/update_icon()
	if(magazine)
		icon_state = "marksmanrifle-mag"
	else
		icon_state = "marksmanrifle"

/obj/item/weapon/gun/projectile/marksman_rifle/syndicate
	name = "syndicate marksman rifle"
	desc = "syndicate sporterized marksman rifle, designed for precision elimination and suppression of multiple targets"
	pin = /obj/item/device/firing_pin/implant/pindicate
	origin_tech = "combat=6;syndicate=4"