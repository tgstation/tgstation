/datum/orderable_item/bitrunning_abilities
	category_index = CATEGORY_BITRUNNING_ABILITIES

/obj/item/bitrunning_disk/ability/monkestation_override
	name = "bitrunning program: someone forgot to give me a name, please help"
	icon = 'monkestation/code/modules/bitrunners/icons/ability_disks.dmi'
	icon_state = "i_am_error"
	monkeystation_override = TRUE

/obj/item/bitrunning_disk/ability/monkestation_override/Initialize(mapload)
	granted_action = selectable_actions
	RegisterSignal(src, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))
	return ..()

/**
 * Tier 1 abilities
 */

/datum/orderable_item/bitrunning_abilities/tier1
	cost_per_order = 1000
	item_path = /obj/item/bitrunning_disk/ability/tier1



/datum/orderable_item/bitrunning_abilities/tier1/conjure_cheese
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/conjure_cheese

/obj/item/bitrunning_disk/ability/monkestation_override/conjure_cheese
	name = "bitrunning program: conjure cheese"
	icon_state = "cheese"
	selectable_actions = /datum/action/cooldown/spell/conjure/cheese



/datum/orderable_item/bitrunning_abilities/tier1/basic_heal
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/basic_heal

/obj/item/bitrunning_disk/ability/monkestation_override/basic_heal
	name = "bitrunning program: basic heal"
	icon_state = "heal"
	selectable_actions = /datum/action/cooldown/spell/basic_heal

/**
 * Tier 2 abilities
 */

/datum/orderable_item/bitrunning_abilities/tier2
	cost_per_order = 1500
	item_path = /obj/item/bitrunning_disk/item/tier2



/datum/orderable_item/bitrunning_abilities/tier2/fireball
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/fireball

/obj/item/bitrunning_disk/ability/monkestation_override/fireball
	name = "bitrunning program: fireball"
	icon_state = "fireball"
	selectable_actions = /datum/action/cooldown/spell/pointed/projectile/fireball



/datum/orderable_item/bitrunning_abilities/tier2/lightningbolt
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/lightningbolt

/obj/item/bitrunning_disk/ability/monkestation_override/lightningbolt
	name = "bitrunning program: lightning bolt"
	icon_state = "lightning"
	selectable_actions = /datum/action/cooldown/spell/pointed/projectile/lightningbolt



/datum/orderable_item/bitrunning_abilities/tier2/forcewall
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/forcewall

/obj/item/bitrunning_disk/ability/monkestation_override/forcewall
	name = "bitrunning program: forcewall"
	icon_state = "forcewall"
	selectable_actions = /datum/action/cooldown/spell/forcewall



/**
 * Tier 3 abilities
 */

/datum/orderable_item/bitrunning_abilities/tier3
	cost_per_order = 2500
	item_path = /obj/item/bitrunning_disk/item/tier3



/datum/orderable_item/bitrunning_abilities/tier3/dragon
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/dragon

/obj/item/bitrunning_disk/ability/monkestation_override/dragon
	name = "bitrunning program: shapeshift, dragon"
	icon_state = "dragon"
	selectable_actions = /datum/action/cooldown/spell/shapeshift/dragon



/datum/orderable_item/bitrunning_abilities/tier3/polar_bear
	item_path = /obj/item/bitrunning_disk/ability/monkestation_override/polar_bear

/obj/item/bitrunning_disk/ability/monkestation_override/polar_bear
	name = "bitrunning program: shapeshift, polar bear"
	icon_state = "bear"
	selectable_actions = /datum/action/cooldown/spell/shapeshift/polar_bear
