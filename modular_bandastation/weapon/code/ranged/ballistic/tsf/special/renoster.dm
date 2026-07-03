/datum/atom_skin/renoster
	abstract_type = /datum/atom_skin/renoster
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/renoster/default
	preview_name = "Default"
	new_icon_state = "renoster"

/datum/atom_skin/renoster/green
	preview_name = "Green"
	new_icon_state = "renoster_green"

// MARK: SolFed shotgun (this was gonna be in a proprietary shotgun shell type outside of 12ga at some point, wild right?)
/obj/item/gun/ballistic/shotgun/riot/renoster
	name = "Renoster shotgun"
	desc = "Тяжелый дробовик двенадцатого калибра, вмещающий шесть патронов. Производится для различных военных подразделений ТСФ и используется ими."
	sawn_desc = "Обрез тяжелого дробовика двенадцатого калибра, вмещающий шесть патронов. Главное не сломать себе руки."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "renoster"
	base_icon_state = "renoster"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "renoster"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "renoster"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	SET_BASE_PIXEL(-8, 0)
	fire_sound = 'modular_bandastation/weapon/sound/ranged/shotgun_heavy.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/shotgun_rack.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 9
	recoil = 2
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	projectile_damage_multiplier = 1.2
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot

/obj/item/gun/ballistic/shotgun/riot/renoster/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/renoster)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/shotgun/riot/renoster/update_icon_state()
	. = ..()
	if(sawn_off)
		lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
		righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
		inhand_icon_state = "[base_icon_state]_sawn"
		worn_icon_state = "[base_icon_state]_sawn"
		suppressor_x_offset = 0
		recoil = 3
	else
		inhand_icon_state = "[base_icon_state]"
		worn_icon_state = "[base_icon_state]"

/obj/item/gun/ballistic/shotgun/riot/renoster/add_seclight_point()
	AddComponent(
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 32, \
		overlay_y = 10 \
	)

/obj/item/gun/ballistic/shotgun/riot/renoster/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/shotgun/riot/renoster/examine_more(mob/user)
	. = ..()
	. += "По своей сути \"Реностэр\" был разработан как тяжелый полицейский дробовик. \
		Следовательно, он обладает всеми качествами, необходимыми полицейским структурам. \
		Большая вместимость патронов, прочная рама, достаточно большие \
		возможности для модификации, чтобы удовлетворить даже самые обеспеченные \
		миротворческие силы. Неизбежно было и появление этого оружия на гражданских \
		рынках, а заодно и продажи нескольким военным структурам, которые также \
		сочли полезным иметь тяжелый дробовик."

/obj/item/gun/ballistic/shotgun/riot/renoster/black
	name = "tactical Renoster shotgun"
	base_icon_state = "renoster_black"
	icon_state = "renoster_black"
	worn_icon_state = "renoster_black"
	inhand_icon_state = "renoster_black"
	recoil = 1
	projectile_damage_multiplier = 1.3
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot/lethal

/obj/item/gun/ballistic/shotgun/riot/renoster/black/examine_more(mob/user)
	. = ..()
	. += "На этот вариант установлен более удобный и усовершенственный приклад, что \
		позволяет серьезно уменьшить отдачу. Внутренний механизм также был усилен, \
		что позволяет выстреливать более мощные боеприпасы. Этот экземлпяр покрашен в черные \
		и красные цвета для повышения тактикульности и серьезности намерений владельца."

/obj/item/gun/ballistic/shotgun/riot/renoster/sawoff
	sawn_off = TRUE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/shotgun/riot/renoster/black/sawoff
	sawn_off = TRUE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/magazine/internal/shot/riot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
