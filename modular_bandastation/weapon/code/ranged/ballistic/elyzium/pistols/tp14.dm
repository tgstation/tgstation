/obj/item/gun/ballistic/automatic/pistol/tp14
	name = "TP-14"
	desc = "Стандартный служебный пистолет калибра .45 используемый в армии Республики Элизиум."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "tp14"
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_light_2.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/hp_cocked.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/hp_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/hp_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/hp_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/hp_unload.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/c45
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0
	recoil = 0.5

/obj/item/gun/ballistic/automatic/pistol/tp14/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 18, \
		overlay_y = 9 \
	)

/obj/item/gun/ballistic/automatic/pistol/tp14/no_mag
	spawnwithmagazine = FALSE
