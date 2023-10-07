/datum/orderable_item/bitrunning_combat_gear
	category_index = CATEGORY_BITRUNNING_COMBAT_GEAR


/obj/item/bitrunning_disk/item/monkestation_override
	name = "bitrunning gear: someone forgot to give me a name, please help"
	icon = 'monkestation/code/modules/bitrunners/icons/item_disks.dmi'
	icon_state = "i_am_error"
	monkeystation_override = TRUE

/obj/item/bitrunning_disk/item/monkestation_override/Initialize(mapload)
	granted_item = selectable_items
	RegisterSignal(src, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))
	return ..()

/**
 * Tier 1 combat gear
 */

/datum/orderable_item/bitrunning_combat_gear/pizza
	cost_per_order = 1000
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/pizza

/obj/item/bitrunning_disk/item/monkestation_override/pizza
	name = "bitrunning gear: infinite pizzabox"
	icon_state = "pizza"
	selectable_items = /obj/item/pizzabox/infinite



/datum/orderable_item/bitrunning_combat_gear/medbeam
	cost_per_order = 1000
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/medbeam

/obj/item/bitrunning_disk/item/monkestation_override/medbeam
	name = "bitrunning gear: Medical Beamgun"
	icon_state = "beamgun"
	selectable_items = /obj/item/gun/medbeam



/datum/orderable_item/bitrunning_combat_gear/c4
	cost_per_order = 1000
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/c4

/obj/item/bitrunning_disk/item/monkestation_override/c4
	name = "bitrunning gear: C4 explosive charge"
	icon_state = "c4"
	selectable_items = /obj/item/grenade/c4

/**
 * Tier 2 combat gear
 */

/datum/orderable_item/bitrunning_combat_gear/chainsaw
	cost_per_order = 1800
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/chainsaw

/obj/item/bitrunning_disk/item/monkestation_override/chainsaw
	name = "bitrunning gear: chainsaw"
	icon_state = "chainsaw"
	selectable_items = /obj/item/chainsaw



/datum/orderable_item/bitrunning_combat_gear/pistol
	cost_per_order = 1800
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/pistol

/obj/item/bitrunning_disk/item/monkestation_override/pistol
	name = "bitrunning gear: makarov pistol"
	icon_state = "pistol"
	selectable_items = /obj/item/gun/ballistic/automatic/pistol



/datum/orderable_item/bitrunning_combat_gear/hardlight_blade
	cost_per_order = 1800
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/hardlight_blade

/obj/item/bitrunning_disk/item/monkestation_override/hardlight_blade
	name = "bitrunning gear: hardlight blade"
	icon_state = "hardlight_blade"
	selectable_items = /obj/item/melee/energy/blade/hardlight

/**
 * Tier 3 combat gear
 */

/datum/orderable_item/bitrunning_combat_gear/tesla_cannon
	cost_per_order = 3200
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/tesla_cannon

/obj/item/bitrunning_disk/item/monkestation_override/tesla_cannon
	name = "bitrunning gear: tesla cannon"
	icon_state = "tesla"
	selectable_items = /obj/item/gun/energy/tesla_cannon



/datum/orderable_item/bitrunning_combat_gear/dualsaber
	cost_per_order = 3200
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/dualsaber

/obj/item/bitrunning_disk/item/monkestation_override/dualsaber
	name = "bitrunning gear: double-bladed energy sword"
	icon_state = "energy_blade"
	selectable_items = /obj/item/dualsaber/green



/datum/orderable_item/bitrunning_combat_gear/beesword
	cost_per_order = 3200
	item_path = /obj/item/bitrunning_disk/item/monkestation_override/beesword

/obj/item/bitrunning_disk/item/monkestation_override/beesword
	name = "bitrunning gear: the stinger blade"
	icon_state = "bee"
	selectable_items = /obj/item/melee/beesword
