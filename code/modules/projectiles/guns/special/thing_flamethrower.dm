//because i didn't want the flamers ruining my shit bro
/obj/item/gun/ballistic/flamethrower
	name = "\improper TX-82 incinerator unit"
	desc = "A chunky flame weapon used to incinerate things. It fires special fuel that doesn't pollute the air."
	icon = 'icons/obj/flamethrower.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	icon_state = "flamethrower_thing"
	inhand_icon_state = "flamethrower_0"
	magazine_wording = "tank"
	cartridge_wording = "fuel"
	round_wording = "fuel burst"
	casing_ejector = FALSE

	fire_sound = 'sound/weapons/gun/flamethrower/flamethrower_shoot.ogg'
	dry_fire_sound = 'sound/weapons/gun/flamethrower/flamethrower_empty.ogg'
	eject_sound = 'sound/weapons/gun/flamethrower/flamethrower_unload.ogg'
	eject_empty_sound = 'sound/weapons/gun/flamethrower/flamethrower_unload.ogg'
	load_sound = 'sound/weapons/gun/flamethrower/flamethrower_reload.ogg'
	load_empty_sound = 'sound/weapons/gun/flamethrower/flamethrower_reload.ogg'
	rack_sound = 'sound/items/ratchet.ogg'

	bolt_type = BOLT_TYPE_OPEN
	mag_display = TRUE
	mag_type = /obj/item/ammo_box/magazine/flamer_fuel

/obj/item/ammo_box/magazine/flamer_fuel
	name = "flamer fuel"
	desc = "Burns things good. Burns clean, so the air is still safe after firing."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "fuel_basic"
	ammo_type = /obj/item/ammo_casing/flamer_fuel
	caliber = CALIBER_FUEL
	max_ammo = 10

/obj/item/ammo_casing/flamer_fuel
	projectile_type = /obj/projectile/bullet/incendiary/backblast
	pellets = 5
	variance = 25
	caliber = CALIBER_FUEL
