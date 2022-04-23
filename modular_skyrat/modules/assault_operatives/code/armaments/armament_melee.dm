
// MELEE WEAPONS

/datum/armament_entry/assault_operatives/melee
	category = ARMAMENT_CATEGORY_MELEE
	category_item_limit = ARMAMENT_CATEGORY_MELEE_LIMIT

/datum/armament_entry/assault_operatives/melee/lethal
	subcategory = ARMAMENT_SUBCATEGORY_MELEE_LETHAL

/datum/armament_entry/assault_operatives/melee/lethal/survival_knife
	item_type = /obj/item/knife/combat/survival
	cost = 5

/datum/armament_entry/assault_operatives/melee/lethal/combat_knife
	item_type = /obj/item/knife/combat
	cost = 6

/datum/armament_entry/assault_operatives/melee/lethal/energy
	item_type = /obj/item/melee/energy/sword/saber
	cost = 10

/datum/armament_entry/assault_operatives/melee/nonlethal
	subcategory = ARMAMENT_SUBCATEGORY_MELEE_NONLETHAL

/datum/armament_entry/assault_operatives/melee/nonlethal/baton
	item_type = /obj/item/melee/baton/security/loaded
	cost = 3

/datum/armament_entry/assault_operatives/melee/nonlethal/baton_telescopic
	item_type = /obj/item/melee/baton/telescopic
	cost = 5

