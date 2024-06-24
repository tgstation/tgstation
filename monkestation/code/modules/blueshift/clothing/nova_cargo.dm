/obj/item/clothing/under/rank/cargo
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/cargo_digi.dmi'

/obj/item/clothing/under/rank/cargo/tech/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/cargo.dmi'

/obj/item/clothing/under/rank/cargo/qm/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/cargo.dmi'

// Add a /obj/item/clothing/under/rank/cargo/miner/nova if you add miner uniforms

/*
*	CARGO TECH
*/

/obj/item/clothing/under/rank/cargo/tech/nova/utility
	name = "supply utility uniform"
	desc = "A utility uniform worn by employees of the Supply department."
	icon_state = "util_cargo"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/cargo/tech/nova/long
	name = "cargo technician's long jumpsuit"
	desc = "For crate-pushers who'd rather protect their legs than show them off."
	icon_state = "cargo_long"
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/gorka
	name = "supply gorka"
	desc = "A rugged, utilitarian gorka worn by the Supply department."
	icon_state = "gorka_cargo"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck
	name = "supply turtleneck"
	desc = "A snug turtleneck sweater worn by the Supply department.."
	icon_state = "turtleneck_cargo"

/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck/skirt
	name = "supply skirtleneck"
	desc = "A snug turtleneck sweater worn by Supply, this time with a skirt attached!"
	icon_state = "skirtleneck"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/tech/nova/evil
	name = "black cargo uniform"
	desc = "A standard cargo uniform with a more... Venerable touch to it."
	icon_state = "qmsynd"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/casualman
	name = "cargo technician casualwear"
	desc = "A pair of stylish black jeans and a regular sweater for the relaxed technician."
	icon_state = "cargotechjean"
	can_adjust = FALSE

/*
*	QUARTERMASTER
*/

/obj/item/clothing/under/rank/cargo/qm/nova/gorka
	name = "quartermaster's gorka"
	desc = "A rugged, utilitarian gorka with silver markings. Unlike the regular employees', this one is lined with silk on the inside."
	icon_state = "gorka_qm"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck
	name = "quartermaster's turtleneck"
	desc = "A snug turtleneck sweater worn by the Quartermaster, characterized by the expensive-looking pair of suit pants."
	icon_state = "turtleneck_qm"

/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck/skirt
	name = "quartermaster's skirtleneck"
	desc = "A snug turtleneck sweater worn by the Quartermaster, as shown by the elegant double-lining of its silk skirt."
	icon_state = "skirtleneckQM"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/qm/nova/interdyne
	name = "deck officer's jumpsuit"
	desc = "A dark suit with a classic cargo vest. For the ultimate master of all things paper."
	icon_state = "qmsynd"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/nova_interdyne
	can_adjust = FALSE

/datum/armor/clothing_under/nova_interdyne
	melee = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/rank/cargo/qm/nova/formal
	name = "quartermaster's formal jumpsuit"
	desc = "A western-like alternate uniform for the old fashioned QM."
	icon_state = "supply_chief"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/qm/nova/formal/skirt
	name = "quartermaster's formal jumpskirt"
	desc = "A western-like alternate uniform for the old fashioned QM. Skirt included!"
	icon_state = "supply_chief_skirt"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/qm/nova/casual
	name = "quartermaster's casualwear"
	desc = "A brown jacket with matching trousers for the relaxed Quartermaster."
	icon_state = "qmc"
