/obj/item/gun/energy/e_gun/lawbringer
	name = "\improper Lawbringer"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	cell_type = /obj/item/stock_parts/cell/lawbringer
	icon_state = "hoslaser" //placeholder
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/lawbringer/detain, \
	 /obj/item/ammo_casing/energy/lawbringer/execute, \
	 /obj/item/ammo_casing/energy/lawbringer/hotshot, \
	 /obj/item/ammo_casing/energy/lawbringer/smokeshot)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/owner_prints = null

/obj/item/gun/energy/e_gun/lawbringer/attack_self(mob/living/user as mob)
	return

/obj/item/stock_parts/cell/lawbringer
	name = "Lawbringer power cell"
	maxcharge = 300

/obj/item/ammo_casing/energy/lawbringer/detain //placeholder
	projectile_type = /obj/projectile/beam/disabler
	select_name = "detain"
	e_cost = 50
	pellets = 3
	variance = 15
	harmful = FALSE

 //psueudocode time
 /*
 /obj/item/ammo_casing/energy/lawbringer/execute
	projectile_type = /obj/projectile/lawbringer/execute
	select_name = "execute"
	e_cost = 30
	harmful = TRUE

/obj/projectile/lawbringer/execute
	name = "protomatter bullet"
	damage = 16
	wound_bonus = -25
	bare_wound_bonus = 10
*/
/*
 /obj/item/ammo_casing/energy/lawbringer/hotshot
	projectile_type = /obj/projectile/lawbringer/hotshot
	select_name = "hotshot"
	e_cost = 60
	harmful = TRUE

/obj/projectile/lawbringer/hotshot
	name = "proto-plasma"
	damage = 5
	fire_stacks = 2
	wound_bonus = -5
	damage_type = BRUN
*/
/*
 /obj/item/ammo_casing/energy/lawbringer/smokeshot
	projectile_type = /obj/projectile/lawbringer/smokeshot
	select_name = "smokeshot"
	e_cost = 50
	harmful = FALSE

/obj/projectile/lawbringer/smokeshot
	name = "proto-plasma"
	damage = 0
	damage_type = BRUTE
	//something that summons smoke
*/
/*
 /obj/item/ammo_casing/energy/lawbringer/bigshot
	projectile_type = /obj/projectile/lawbringer/bigshot
	select_name = "bigshot"
	e_cost = 170
	harmful = TRUE

/obj/projectile/lawbringer/bigshot
	name = "protomatter shell"
	damage = 55
	damage_type = BRUTE
	speed = 1
	pixel_speed_multiplier = 0.3
	//something that summons smoke
*/
