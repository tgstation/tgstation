// Tarkon M6 PDW //

/obj/item/gun/ballistic/automatic/m6pdw
	name = "\improper M6 Personal Defense Weapon"
	desc = "A PDW designed to be used within close to medium range. Its slide seems to stick a bit, having years of dust accumulation, And its manufacturer stamp and symbols have been scratched out."
	icon = 'modular_skyrat/modules/projectiles/icons/m6pdw.dmi'
	icon_state = "m6_pdw"
	inhand_icon_state = "m6_pdw"
	righthand_file = 'modular_skyrat/modules/projectiles/icons/inhands/righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/projectiles/icons/inhands/lefthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	spawnwithmagazine = FALSE
	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'
	projectile_damage_multiplier = 1
	burst_size = 2
	fire_delay = 1.9
