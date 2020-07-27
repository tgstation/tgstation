/obj/item/gun/energy/sniper
	name = "energy sniper rifle"
	desc = "An advanced piece of weaponry forged on Mars in 40th Millenia."
	icon_state = "sniper"
	inhand_icon_state = "sniper"
	icon = 'icons/Fulpicons/energy_sniper.dmi'
	//lefthand_file = 'icons/Fulpicons/energy_sniper_l.dmi'
	//righthand_file = 'icons/Fulpicons/energy_sniper_r.dmi'
	fire_sound = 'sound/weapons/laser3.ogg'
	fire_sound_volume = 90
	vary_fire_sound = FALSE
	pin = null
	cell_type = /obj/item/stock_parts/cell/energy_sniper
	weapon_weight = WEAPON_HEAVY
	can_flashlight = FALSE
	charge_sections = 1
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	actions_types = list()
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)

/obj/item/gun/energy/sniper/Initialize()
	. = ..()
	fire_delay = 30

/obj/item/gun/energy/sniper/pin
	pin = /obj/item/firing_pin

/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/projectile/beam/laser/sniper
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/projectile/beam/laser/sniper
	damage = 80
	speed = 0.4
	name = "energy bullet"
	icon = 'icons/Fulpicons/energy_sniper.dmi'
	icon_state = "blue_bullet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	armour_penetration = 25

/obj/item/stock_parts/cell/energy_sniper //20 shots, very slow charge rate
	name = "pulse rifle power cell"
	maxcharge = 2000
	chargerate = 50
