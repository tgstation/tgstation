/**
 * Bitrunning tech disks which let you load items or programs into the vdom on first avatar generation.
 * For the record: Balance shouldn't be a primary concern.
 * You can make the custom cheese spells you've always wanted.
 * Just make it fun and engaging, it's PvE content.
 */
/obj/item/bitrunning_disk
	name = "generic bitrunning program"
	desc = "A disk containing source code. Bring it on your person into a netpod."
	icon = 'icons/obj/assemblies/module.dmi'
	base_icon_state = "datadisk"
	icon_state = "datadisk0"
	/// The ability that this grants
	var/datum/action/granted_action
	/// Spawns this item in the user's inventory when they enter the virtual domain
	var/obj/granted_item

/obj/item/bitrunning_disk/Initialize(mapload)
	. = ..()

	icon_state = "[base_icon_state][rand(0, 7)]"
	update_icon()

/obj/item/bitrunning_disk/fireball
	name = "bitrunning program: fireball"
	granted_action = /datum/action/cooldown/spell/pointed/projectile/fireball

/obj/item/bitrunning_disk/lightningbolt
	name = "bitrunning program: lightning bolt"
	granted_action = /datum/action/cooldown/spell/pointed/projectile/lightningbolt

/obj/item/bitrunning_disk/cheese
	name = "bitrunning program: cheese"
	granted_action = /datum/action/cooldown/spell/conjure/cheese

/obj/item/bitrunning_disk/forcewall
	name = "bitrunning program: force wall"
	granted_action = /datum/action/cooldown/spell/forcewall

/obj/item/bitrunning_disk/chainsaw
	name = "bitrunning program: chainsaw"
	granted_item = /obj/item/chainsaw

/obj/item/bitrunning_disk/medbeam
	name = "bitrunning program: medbeam"
	granted_item = /obj/item/gun/medbeam

/obj/item/bitrunning_disk/pizza
	name = "bitrunning program: pizza"
	granted_item = /obj/item/pizzabox/infinite

/obj/item/bitrunning_disk/makarov
	name = "bitrunning program: makarov"
	granted_item = /obj/item/gun/ballistic/automatic/pistol
