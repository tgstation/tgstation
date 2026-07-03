/obj/item/gun/ballistic/automatic/pistol/cm23
	name = "GP-38"
	desc = "Стандартный служебный пистолет Нанотрейзен под патроны калибра .38."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "cm23"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "cm_pistol"
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm23.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/c38
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/cm23/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 18, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/pistol/cm23/no_mag
	spawnwithmagazine = FALSE
