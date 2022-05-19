/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo.dmi'

/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	alt_covers_chest = TRUE


/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skiiiiirts! They're comfy and easy to wear!"
	icon_state = "cargo_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	inhand_icon_state = "miner"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 80, ACID = 0, WOUND = 10)
	resistance_flags = NONE

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	inhand_icon_state = "explorer"
