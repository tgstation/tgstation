/obj/item/clothing/head/helmet/space/hardsuit/spellcostume
	name = "Spellsword Helm"
	desc = "Well, I am sure that this plate armor has no evil spirits possessing it which may or may not be subtly affecting my mental psyche."
	icon = 'icons/misc/tourny_items.dmi'
	worn_icon = 'icons/misc/tourny_helm2.dmi' // i fucking hate 64x64 helmets
	icon_state = "spellhelm"
	worn_icon_state = "spellsword"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "spellsword"
	armor = list(MELEE = 90, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	strip_delay = 200
	light_system = NO_LIGHT_SUPPORT
	light_range = 0 //luminosity when on
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/spellcostume
	name = "ARMOR"
	desc = "Man, this plate armor looks like it would be an UNGODLY amount of weight to bare on your shoulders."
	icon = 'icons/misc/tourny_items.dmi'
	worn_icon = 'icons/misc/tourny_armor.dmi'
	icon_state = "spellsword"
	worn_icon_state = "spellsword"
	inhand_icon_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/spellcostume
	allowed = list(/obj/item/nullrod, /obj/item/claymore, /obj/item/melee)
	armor = list(MELEE = 90, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	slowdown = 2
	strip_delay = 200
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cell = /obj/item/stock_parts/cell/bluespace

/obj/item/clothing/suit/space/hardsuit/spellcostume/equipped(mob/user,slot)
	var/mob/living/carbon/guy = user
	if(slot == ITEM_SLOT_OCLOTHING)
		var/matrix/M = matrix(guy.transform)
		M.Translate(0,6)
		guy.transform = M
		guy.dna.species.offset_features = list(OFFSET_UNIFORM = list(0,-6), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,3), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,3), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,-6), OFFSET_NECK = list(0,0))
		guy.regenerate_icons()
	. = ..()

/obj/item/clothing/suit/space/hardsuit/spellcostume/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/guy = user
	guy.dna.species.offset_features = initial(guy.dna.species.offset_features)
	guy.regenerate_icons()
	guy.transform = initial(guy.transform)
