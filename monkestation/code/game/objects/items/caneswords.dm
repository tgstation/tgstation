/obj/item/weapon/cane_sword
	name = "\improper cane sword"
	desc = "wrong one silly heads this one dont do damage haha"
	icon = 'monkestation/icons/obj/caneswords/caneswords.dmi'
	lefthand_file = 'monkestation/icons/obj/caneswords/caneswordinhandL.dmi'
	righthand_file = 'monkestation/icons/obj/caneswords/caneswordinhandR.dmi'

/obj/item/weapon/cane_sword/CentCom
	name = "\improper nanotrasen cane sword"
	desc = "OH GOD CENTCOM GENTLEMAN NINJA"
	icon_state = "CC_canesword1"
	inhand_icon_state = "CC_sword"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 20
	throwforce = 15
	demolition_mod = 0.75 //but not metal
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	wound_bonus = 15
	bare_wound_bonus = 25

/obj/item/weapon/cane_sword/syndicate
	name = "\improper syndicate cane sword"
	desc = "OH GOD SYNDICATE GENTLEMAN NINJA"
	icon_state = "S_canesword1"
	inhand_icon_state = "S_sword"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 20
	throwforce = 15
	demolition_mod = 0.75 //but not metal
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	wound_bonus = 15
	bare_wound_bonus = 25

/obj/item/weapon/cane_sword/civilian
	name = "\improper cane sword"
	desc = "OH GOD GENTLEMAN NINJA"
	icon_state = "canesword1"
	inhand_icon_state = "sword"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 12
	throwforce = 7
	demolition_mod = 0.75 //but not metal
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 25
	armour_penetration = 20
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	wound_bonus = 5
	bare_wound_bonus = 15

/obj/item/storage/canesword
	name = "canesword"
	desc = "this is the catch all and the wrong one"
	icon = 'monkestation/icons/obj/caneswords/caneswords.dmi'
	lefthand_file = 'monkestation/icons/obj/caneswords/caneswordinhandL.dmi'
	righthand_file = 'monkestation/icons/obj/caneswords/caneswordinhandR.dmi'

/obj/item/storage/canesword/civ
	name = "\improper cane"
	desc = "An ordinary civilian issue cane... or so it looks"
	icon_state = "canesword0"
	inhand_icon_state = "cane"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/canesword/civ/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_BELT)

	atom_storage.max_slots = 1
	atom_storage.rustle_sound = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(
		list(
			/obj/item/weapon/cane_sword/civilian,
		)
	)

/obj/item/storage/canesword/civ/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/canesword/civ/AltClick(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")

/obj/item/storage/canesword/civ/PopulateContents()
	new /obj/item/weapon/cane_sword/civilian(src)


/obj/item/storage/canesword/CentCom
	name = "\improper cane"
	desc = "An ordinary CentCom issue cane... or so it looks"
	icon_state = "CC_canesword0"
	inhand_icon_state = "CC_cane"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/canesword/CentCom/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_BELT)

	atom_storage.max_slots = 1
	atom_storage.rustle_sound = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(
		list(
			/obj/item/weapon/cane_sword/CentCom,
		)
	)

/obj/item/storage/canesword/CentCom/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/canesword/CentCom/PopulateContents()
	new /obj/item/weapon/cane_sword/CentCom(src)

/obj/item/storage/canesword/CentCom/AltClick(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")

/obj/item/storage/canesword/syndicate
	name = "\improper cane"
	desc = "An ordinary Syndicate issue cane... or so it looks"
	icon_state = "S_canesword0"
	inhand_icon_state = "S_cane"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/canesword/syndicate/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_BELT)

	atom_storage.max_slots = 1
	atom_storage.rustle_sound = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(
		list(
			/obj/item/weapon/cane_sword/syndicate,
		)
	)

/obj/item/storage/canesword/syndicate/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/canesword/syndicate/AltClick(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")

/obj/item/storage/canesword/syndicate/PopulateContents()
	new /obj/item/weapon/cane_sword/syndicate(src)
