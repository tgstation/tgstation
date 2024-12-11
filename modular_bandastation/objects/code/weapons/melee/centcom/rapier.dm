/obj/item/melee/sabre/centcom_sabre
	name = "fleet officer's rapier"
	desc = "Элегантное оружие более цивилизованной эпохи. Выполнено в классическом стиле с данью флотским традициям прошлого."
	icon = 'modular_bandastation/objects/icons/melee.dmi'
	icon_state = "centcom_sabre"
	inhand_icon_state = "centcom_sabre"
	lefthand_file = 'modular_bandastation/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/melee_righthand.dmi'
	force = 55
	demolition_mod = 1
	block_chance = 95
	armour_penetration = 100

/obj/item/melee/sabre/centcom_katana
	name = "fleet officer's katana"
	desc = "Элегантное оружие более цивилизованной эпохи. Выполнено в азиатском стиле с данью Земным культурам прошлого."
	icon = 'modular_bandastation/objects/icons/melee.dmi'
	icon_state = "centcom_katana"
	inhand_icon_state = "centcom_katana"
	lefthand_file = 'modular_bandastation/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/melee_righthand.dmi'
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	force = 55
	demolition_mod = 1
	block_chance = 95
	armour_penetration = 100

/obj/item/storage/belt/centcom_sabre
	name = "fleet officer's rapier sheath"
	desc = "Богато украшенные ножны, предназначенные для хранения офицерской рапиры."
	icon = 'modular_bandastation/objects/icons/belt.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt/belt.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/inhands/belt_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/belt_righthand.dmi'
	icon_state = "centcom_sheath"
	worn_icon_state = "centcom_sheath"
	inhand_icon_state = "centcom_sheath"

/obj/item/storage/belt/centcom_sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

	atom_storage.max_slots = 1
	atom_storage.do_rustle = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(/obj/item/melee/sabre/centcom_sabre)
	atom_storage.click_alt_open = FALSE

/obj/item/storage/belt/centcom_sabre/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/centcom_sabre/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/centcom_sabre/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/centcom_sabre/PopulateContents()
	new /obj/item/melee/sabre/centcom_sabre(src)
	update_appearance()

/obj/item/storage/belt/centcom_katana
	name = "fleet officer's katana sheath"
	desc = "Богато украшенные деревянные ножны, предназначенные для хранения офицерской катаны."
	icon = 'modular_bandastation/objects/icons/belt.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt/belt.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/inhands/belt_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/belt_righthand.dmi'
	icon_state = "katana_sheath"
	worn_icon_state = "katana_sheath"
	inhand_icon_state = "katana_sheath"

/obj/item/storage/belt/centcom_katana/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

	atom_storage.max_slots = 1
	atom_storage.do_rustle = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(/obj/item/melee/sabre/centcom_katana)
	atom_storage.click_alt_open = FALSE

/obj/item/storage/belt/centcom_katana/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/centcom_katana/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/centcom_katana/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/centcom_katana/PopulateContents()
	new /obj/item/melee/sabre/centcom_katana(src)
	update_appearance()
