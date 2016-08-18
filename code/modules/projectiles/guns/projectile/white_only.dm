/obj/item/weapon/gun/projectile/automatic/pistol/white_only
	name = "traumatic pistol"
	desc = "A small, easily concealable traumatic pistol. Can be suppressed."
	icon = 'icons/obj/guns/white_only.dmi'
	icon_state = "secpistol"
	w_class = 2
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/white_only/traumatic
	can_suppress = 1
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/weapon/gun/projectile/automatic/pistol/white_only/elite
	name = "traumatic submachinegun gun"
	desc = "A HoS personal submachinegun gun. Can be suppressed."
	icon_state = "cycler"
	origin_tech = "combat=5;materials=4"
	w_class = 3
	mag_type = /obj/item/ammo_box/magazine/white_only/enhanced_traumatic
	fire_delay = 4
	burst_size = 5
	actions_types = list(/datum/action/item_action/toggle_firemode)