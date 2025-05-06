/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo.dmi'

/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's uniform"
	desc = "A brown dress shirt, coupled with a pair of black slacks. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's skirt"
	desc = "A brown dress shirt, coupled with a long pleated black skirt. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's uniform"
	desc = "A brown sweater and black jeans, because, honestly, who likes shorts?"
	icon_state = "cargotech"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/tech/alt
	name = "cargo technician's shorts"
	desc = "I like shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech_alt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	/// DOPPLER SHIFT ADDITION BEGIN
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = DEFAULT_UNIFORM_FILE, BODYSHAPE_DIGITIGRADE_T = DIGITIGRADE_UNIFORM_FILE)
	/// DOPPLER SHIFT ADDITION END

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's skirt"
	desc = "A brown sweater and a black skirt to match."
	icon_state = "cargo_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/tech/skirt/alt
	name = "cargo technician's shortskirt"
	desc = "I like skiiiiirts! They're comfy and easy to wear!"
	icon_state = "cargo_skirt_alt"

/obj/item/clothing/under/rank/cargo/miner
	name = "shaft miner's jumpsuit"
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	icon_state = "miner"
	inhand_icon_state = null
	armor_type = /datum/armor/clothing_under/cargo_miner
	resistance_flags = NONE

/datum/armor/clothing_under/cargo_miner
	fire = 80
	wound = 10

/obj/item/clothing/under/rank/cargo/miner/lavaland
	name = "shaft miner's jumpsuit"
	desc = "A grey uniform for operating in hazardous environments."
	icon_state = "explorer"
	inhand_icon_state = null

/obj/item/clothing/under/rank/cargo/bitrunner
	name = "bitrunner's jumpsuit"
	desc = "It's a leathery jumpsuit worn by a bitrunner. Tacky, but comfortable to wear if sitting for prolonged periods of time."
	icon_state = "bitrunner"
	inhand_icon_state = "w_suit"
