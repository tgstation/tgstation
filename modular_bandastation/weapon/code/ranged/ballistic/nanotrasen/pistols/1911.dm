/datum/atom_skin/m1911
	abstract_type = /datum/atom_skin/m1911
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/m1911/default
	preview_name = "Default"
	new_icon_state = "m1911"

/datum/atom_skin/m1911/m1911blue
	preview_name = "Blue"
	new_icon_state = "m1911blue"

/obj/item/gun/ballistic/automatic/pistol/m1911
	desc = "Классический пистолет калибра .45 с небольшой емкостью магазина."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	recoil = 0.5

/obj/item/gun/ballistic/automatic/pistol/m1911/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/m1911)

/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun
	desc = "Для обезьяны-мафиози, которая всегда в движении. Использует патроны калибра .45 и имеет характерный запах бананов."
	icon_state = "m1911gold"
	recoil = 0.1

/datum/atom_skin/m1911/gold
	abstract_type = /datum/atom_skin/m1911/gold
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/m1911/gold/m1911gold
	preview_name = "Default"
	new_icon_state = "m1911gold"

/datum/atom_skin/m1911/gold/m1911gold_blue
	preview_name = "Blue"
	new_icon_state = "m1911gold_blue"

/obj/item/gun/ballistic/automatic/pistol/m1911/gold
	name = "gold trimmed m1911"
	desc = parent_type::desc + "<br>Мастерски отделанный золотом."
	icon_state = "m1911gold"

/obj/item/gun/ballistic/automatic/pistol/m1911/gold/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/m1911/gold)

/obj/item/gun/ballistic/automatic/pistol/m45a5
	name = "M45A5 'Rowland'"
	desc = "Модернизированная версия легендарного M1911 в калибре .456 Magnum, в настоящее время широко распространенная среди высокопоставленных сотрудников Нанотрейзен."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	icon_state = "m45a5"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45a5
	can_suppress = FALSE
	fire_sound = 'sound/items/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	recoil = 1
	fire_sound_volume = 100
