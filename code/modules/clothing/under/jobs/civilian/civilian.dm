//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/civilian
	icon = 'icons/obj/clothing/under/civilian.dmi'
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'

/obj/item/clothing/under/rank/civilian/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "barman"
	inhand_icon_state = "bar_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/bartender/purple
	desc = "It looks like it has lots of flair!"
	name = "purple bartender's uniform"
	icon_state = "purplebartender"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/bartender/skirt
	name = "bartender's skirt"
	desc = "It looks like it could use some more flair."
	icon_state = "barman_skirt"
	inhand_icon_state = "bar_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	name = "chaplain's jumpskirt"
	desc = "It's a black jumpskirt. If you wear this, you probably need religious help more than you will be providing it."
	icon_state = "chapblack_skirt"
	inhand_icon_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/chef
	name = "cook's suit"
	desc = "A suit which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/chef/skirt
	name = "cook's skirt"
	desc = "A skirt which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt
	name = "head of personnel's jumpskirt"
	desc = "It's a jumpskirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	inhand_icon_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt
	name = "teal suitskirt"
	desc = "A teal suitskirt and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit_skirt"
	inhand_icon_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	inhand_icon_state = "g_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	name = "botanist's jumpskirt"
	desc = "It's a jumpskirt designed to protect against minor plant-related hazards."
	icon_state = "hydroponics_skirt"
	inhand_icon_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = "It's the official skirt of the station's janitor. It has minor protection from biohazards."
	icon_state = "janitor_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/janitor/maid
	name = "maid uniform"
	desc = "A simple maid uniform for housekeeping."
	icon_state = "janimaid"
	inhand_icon_state = "janimaid"
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer
	desc = "Slick threads."
	name = "Lawyer suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer/dye_item(dye_color, dye_key_override)
	if(dye_color == DYE_COSMIC || dye_color == DYE_SYNDICATE)
		..(dye_color, DYE_LAWYER_SPECIAL)
	else
		..()

/obj/item/clothing/under/rank/civilian/lawyer/black
	name = "lawyer black suit"
	icon_state = "lawyer_black"
	inhand_icon_state = "lawyer_black"

/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	name = "lawyer black suitskirt"
	icon_state = "lawyer_black_skirt"
	inhand_icon_state = "lawyer_black"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/beige
	name = "good lawyer's suit"
	desc = "A tacky suit perfect for a CRIMINAL lawyer!"
	icon_state = "good_suit"
	inhand_icon_state = "good_suit"
	worn_icon = 'icons/mob/clothing/under/suits.dmi'

/obj/item/clothing/under/rank/civilian/lawyer/beige/skirt
	name = "good lawyer's suitskirt"
	desc = "A tacky suitskirt perfect for a CRIMINAL lawyer!"
	icon_state = "good_suit_skirt"
	inhand_icon_state = "good_suit"
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/red
	name = "lawyer red suit"
	icon_state = "lawyer_red"
	inhand_icon_state = "lawyer_red"

/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	name = "lawyer red suitskirt"
	icon_state = "lawyer_red_skirt"
	inhand_icon_state = "lawyer_red"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/blue
	name = "lawyer blue suit"
	icon_state = "lawyer_blue"
	inhand_icon_state = "lawyer_blue"

/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	name = "lawyer blue suitskirt"
	icon_state = "lawyer_blue_skirt"
	inhand_icon_state = "lawyer_blue"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit and tie."
	icon_state = "bluesuit"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	name = "blue suitskirt"
	desc = "A classy suitskirt and tie."
	icon_state = "bluesuit_skirt"
	inhand_icon_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	inhand_icon_state = "p_suit"
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	name = "purple suitskirt"
	icon_state = "lawyer_purp_skirt"
	inhand_icon_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/galaxy
	worn_icon = 'icons/mob/clothing/under/lawyer_galaxy.dmi'
	can_adjust = FALSE
	name = "blue galaxy suit"
	icon_state = "lawyer_galaxy_blue"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/rank/civilian/lawyer/galaxy/red
	name = "red galaxy suit"
	icon_state = "lawyer_galaxy_red"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/rank/civilian/cookjorts
	name = "grilling shorts"
	desc = "For when all you want in life is to grill for god's sake!"
	icon_state = "cookjorts"
	can_adjust = FALSE
