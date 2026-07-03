/obj/item/gun/ballistic/rocketlauncher/rpg
	name = "RPG-70"
	desc = "Ручной общецелевой гранатомет многоразового применения. На трубке нанесена стрелка, указывающая на переднюю часть пусковой установки, \
		а также надпись «Передней частью в сторону врага». Наклейка на задней части пусковой установки предупреждает: \
		«НЕ ВСТАВАТЬ ЗА ГРАНАТОМЕТОМ ПЕРЕД ВЫСТРЕЛОМ», что бы это ни значило."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/inhands_64_right.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/inhands_64_left.dmi'
	inhand_x_dimension = 64
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back64x32.dmi'
	worn_x_dimension = 64
	icon_state = "rpg"
	inhand_icon_state = "rpg"
	worn_icon_state = "rpg"
	base_icon_state = "rpg"
	SET_BASE_PIXEL(-16, 0)
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/rocketlauncher/rpg
	pin = /obj/item/firing_pin
	mag_display_ammo = TRUE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/rpg_fire.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/rpg_load.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/rpg_load.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/rpg_load.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/rpg_load.ogg'
	dry_fire_sound = 'modular_bandastation/weapon/sound/ranged/launcher_empty.ogg'
	recoil = 0.5
	slowdown = 0.5
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND

/obj/item/gun/ballistic/rocketlauncher/rpg/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/rocketlauncher/rpg/update_icon_state()
	. = ..()
	if(get_ammo())
		inhand_icon_state = "[base_icon_state]_loaded"
		worn_icon_state = "[base_icon_state]_loaded"
	else
		inhand_icon_state = "[base_icon_state]_empty"
		worn_icon_state = "[base_icon_state]_empty"
