/**
 * # Voucher Set
 *
 * A set consisting of a various equipment that can be then used as a reward for redeeming a mining voucher.
 *
 */
/datum/voucher_set
	/// Name of the set
	var/name
	/// Description of the set
	var/description
	/// Icon of the set
	var/icon
	/// Icon state of the set
	var/icon_state
	/// List of items contained in the set
	var/list/set_items = list()

/datum/voucher_set/crusher_kit
	name = "Crusher Kit"
	description = "Contains a kinetic crusher and a pocket fire extinguisher. Kinetic crusher is a versatile melee mining tool capable both of mining and fighting local fauna, however it is difficult to use effectively for anyone but most skilled and/or suicidal miners."
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	set_items = list(
		/obj/item/extinguisher/mini,
		/obj/item/kinetic_crusher,
		)

/datum/voucher_set/extraction_kit
	name = "Extraction and Rescue Kit"
	description = "Contains a fulton extraction pack and a beacon signaller, which allows you to send back home minerals, items and dead bodies without having to use the mining shuttle. And as a bonus, you get 30 marker beacons to help you better mark your path."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	set_items = list(
		/obj/item/extraction_pack,
		/obj/item/fulton_core,
		/obj/item/stack/marker_beacon/thirty,
		)

/datum/voucher_set/resonator_kit
	name = "Resonator Kit"
	description = "Contains a resonator and a pocket fire extinguisher. Resonator is a handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It does increased damage in low pressure."
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	set_items = list(
		/obj/item/extinguisher/mini,
		/obj/item/resonator,
		)

/datum/voucher_set/survival_capsule
	name = "Survival Capsule and Explorer's Webbing"
	description = "Contains an explorer's webbing, which allows you to carry even more mining equipment and already has a spare shelter capsule in it."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "explorer1"
	set_items = list(
		/obj/item/storage/belt/mining/vendor,
		)

/datum/voucher_set/minebot_kit
	name = "Minebot Kit"
	description = "Contains a little minebot companion that helps you in storing ore and hunting wildlife. Also comes with an upgraded industrial welding tool (80u), a welding mask and a KA modkit that allows shots to pass through the minebot."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "mining_drone"
	set_items = list(
		/mob/living/simple_animal/hostile/mining_drone,
		/obj/item/weldingtool/hugetank,
		/obj/item/clothing/head/utility/welding,
		/obj/item/borg/upgrade/modkit/minebot_passthrough,
		)

/datum/voucher_set/conscription_kit
	name = "Mining Conscription Kit"
	description = "Contains a whole new mining starter kit for one crewmember, consisting of a proto-kinetic accelerator, a survival knife, a seclite, an explorer's suit, a mesons, an automatic mining scanner, a mining satchel, a gas mask, a mining radio key and a special ID card with a basic mining access."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "duffel-explorer"
	set_items = list(
		/obj/item/storage/backpack/duffelbag/mining_conscript,
	)
