/obj/item/weapon/gun/projectile/rocketlauncher
	name = "rocket launcher"
	desc = "Ranged explosions, science marches on."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "rpg"
	item_state = "rpg"
	max_shells = 1
	w_class = 4.0
	force = 10
	ejectshell = 0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BACK
	caliber = "rpg"
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg"

	attack_self(mob/living/user as mob)
		update_icon()

	update_icon()
		if(empty_mag)
			icon_state = "rpg_e"
		else
			icon_state = "rpg"
		return