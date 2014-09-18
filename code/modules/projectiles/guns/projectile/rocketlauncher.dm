/obj/item/weapon/gun/projectile/rocketlauncher
	name = "rocket launcher"
	desc = "Ranged explosions, science marches on."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "rpg"
	item_state = "rpg"
	max_shells = 1
	empty_casings = 0
	w_class = 4.0
	m_amt = 5000
	w_type = RECYK_METAL
	force = 10
	recoil = 5
	throw_speed = 4
	throw_range = 3
	fire_delay = 5
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BACK
	caliber = list("rpg" = 1)
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = /obj/item/ammo_casing/rocket_rpg
	attack_verb = list("struck", "hit", "bashed")

/obj/item/weapon/gun/projectile/rocketlauncher/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/rocketlauncher/update_icon()
	if(!loaded.len)
		icon_state = "rpg_e"
		item_state = "rpg_e"
	else
		icon_state = "rpg"
		item_state = "rpg"
