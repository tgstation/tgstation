/obj/item/weapon/gun/projectile/automatic/pistol/white_only
	name = "traumatic pistol"
	desc = "A small, easily concealable traumatic pistol."
	icon_state = "aps"
	w_class = 2
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/white_only/traumatic
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/weapon/gun/projectile/automatic/pistol/white_only/elite
	name = "elite traumatic pistol"
	icon_state = "deagle"
	origin_tech = "combat=4;materials=3"
	mag_type = /obj/item/ammo_box/magazine/white_only/traumatic
	fire_delay = 3
	burst_size = 3
	actions_types = list(/datum/action/item_action/toggle_firemode)