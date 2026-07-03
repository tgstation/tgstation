/obj/item/gun/ballistic/automatic/pistol/cm357
	name = "GP-357"
	desc = "Стандартный служебный пистолет Нанотрейзен под патроны калибра .357."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "cm357"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "cm_pistol"
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm357.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/cm357_cocked.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/c357
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0
	recoil = 1

/obj/item/gun/ballistic/automatic/pistol/cm357/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 22, \
		overlay_y = 12 \
	)

/obj/item/gun/ballistic/automatic/pistol/cm357/no_mag
	spawnwithmagazine = FALSE
