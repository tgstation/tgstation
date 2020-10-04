/obj/item/clothing/head/helmet/space/hardsuit/spellcostume
	name = "Spellsword Helm"
	desc = "Well, I am sure that this plate armor has no evil spirits possessing it which may or may not be subtly affecting my mental psyche."
	icon = 'icons/misc/tourny_items.dmi'
	worn_icon = 'icons/misc/tourny_helm.dmi'
	icon_state = "spellhelm"
	worn_icon_state = "spellsword"
	inhand_icon_state = "hardsuit0-ert_commander"
	worn_x_dimension = 64
	worn_y_dimension = 30 // why couldn't we just keep the 32x64 file, man
	hardsuit_type = "spellsword"
	armor = list(MELEE = 90, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	strip_delay = 200
	light_system = NO_LIGHT_SUPPORT
	light_range = 0 //luminosity when on
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/spellcostume
	name = "ARMOR"
	desc = "Man, this plate armor looks like it would be an UNGODLY amount of weight to bare on your shoulders."
	icon = 'icons/misc/tourny_items.dmi'
	worn_icon = 'icons/misc/tourny_armor.dmi'
	icon_state = "spellsword"
	worn_icon_state = "spellsword"
	worn_x_dimension = 28.5 // bloody hell
	worn_y_dimension = 32
	inhand_icon_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/spellcostume
	allowed = list(/obj/item/nullrod, /obj/item/claymore, /obj/item/melee)
	armor = list(MELEE = 90, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	slowdown = 2
	strip_delay = 200
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cell = /obj/item/stock_parts/cell/bluespace

// ERT suit's gets EMP Protection
/obj/item/clothing/suit/space/hardsuit/ert/Initialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_CONTENTS)

/obj/item/clothing/suit/space/hardsuit/spellcostume/equipped(user,slot)
	if(slot == ITEM_SLOT_OCLOTHING)
		RegisterSignal(user,COMSIG_HUMAN_UPDATE_CLOTHING_OFFSETS,.proc/get_offsets)
		user.regenerate_icons()
	. = ..()

/obj/item/clothing/suit/space/hardsuit/spellcostume/proc/get_offsets(datum/source,list/offsets)
	offsets[OFFSET_BELT] = list(0,3) // SEE IF IT LOOKS GOOD LATER
	offsets[OFFSET_BACK] = list(0,6)
	offsets[OFFSET_EARS] = list(0,6)

/obj/item/clothing/suit/space/hardsuit/spellcostume/dropped(mob/user)
	UnregisterSignal(user,COMSIG_HUMAN_UPDATE_CLOTHING_OFFSETS)
	user.regenerate_icons()
	. = ..()