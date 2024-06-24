/obj/item/clothing/under/rank/captain
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command_digi.dmi'
	//NOTE - TG uses "captain.dmi"; because we have a few non-captain items going in here for ease of access, this will just be "command.dmi"

/obj/item/clothing/under/rank/captain/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/command.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command.dmi'

/*
*	CAPTAIN
*/

/obj/item/clothing/under/rank/captain/nova/kilt
	name = "captain's kilt"
	desc = "A midnight blue kilt, padded with nano-kevlar and adorned with gold and a tartan sash."
	icon_state = "capkilt"

/obj/item/clothing/under/rank/captain/nova/imperial
	name = "captain's naval jumpsuit"
	desc = "A white naval suit adorned with golden epaulets and a rank badge denoting a Captain. There are two ways to destroy a person, kill him, or ruin his reputation."
	//Rank pins of the Grand Admiral, not a Captain.
	icon_state = "impcap"
	can_adjust = FALSE

//Donor item for Gandalf - all donors have access
/obj/item/clothing/under/rank/captain/nova/black
	name = "captain's black suit"
	desc = "A very sleek, albeit outdated, naval captain's uniform for those who think they're commanding a battleship."
	icon_state = "captainblacksuit"
	can_adjust = FALSE

/*
*	BLUESHIELD
*/
//Why is this in command.dm? Simple: Centcom.dmi will already be packed with CC/NTNavy/AD/LL/SOL/FTU - all of them more event-based clothes, while this will appear
//on-station often.

/obj/item/clothing/under/rank/blueshield
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/command.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command_digi.dmi'
	name = "blueshield's suit"
	desc = "A classic bodyguard's suit, with custom-fitted Blueshield-Blue cuffs and a Nanotrasen insignia over one of the pockets."
	icon_state = "blueshield"
	strip_delay = 50
	armor_type = /datum/armor/clothing_under/rank_blueshield
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	alt_covers_chest = TRUE

/datum/armor/clothing_under/rank_blueshield
	melee = 10
	bullet = 5
	laser = 5
	energy = 10
	bomb = 10
	fire = 50
	acid = 50

/obj/item/clothing/under/rank/blueshield/skirt
	name = "blueshield's suitskirt"
	desc = "A classic bodyguard's suitskirt, with custom-fitted Blueshield-Blue cuffs and a Nanotrasen insignia over one of the pockets."
	icon_state = "blueshieldskirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/under/rank/blueshield/turtleneck
	name = "blueshield's turtleneck"
	desc = "A tactical jumper fit for only the best of bodyguards, with plenty of tactical pockets for your tactical needs."
	icon_state = "bs_turtleneck"

/obj/item/clothing/under/rank/blueshield/turtleneck/skirt
	name = "blueshield's skirtleneck"
	desc = "A tactical jumper fit for only the best of bodyguards - instead of tactical pockets, this one has a tactical lack of leg protection."
	icon_state = "bs_skirtleneck"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/*
*	NT CONSULTANT
*/
//See Blueshield note - tl;dr, this role is a station role, while Centcom.dmi is more event roles

/obj/item/clothing/under/rank/nanotrasen_consultant
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/command.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/command_digi.dmi'
	desc = "It's a green jumpsuit with some gold markings denoting the rank of \"Nanotrasen Consultant\"."
	name = "nanotrasen consultant's jumpsuit"
	icon_state = "nt_consultant"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/nanotrasen_consultant/skirt
	name = "nanotrasen consultant's jumpskirt"
	desc = "It's a green jumpskirt with some gold markings denoting the rank of \"Nanotrasen Consultant\"."
	icon_state = "nt_consultant_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/*
*	UNASSIGNED (Any head of staff)
*/

/obj/item/clothing/under/rank/captain/nova/utility
	name = "command utility uniform"
	desc = "A utility uniform worn by Station Command."
	icon_state = "util_com"
	can_adjust = FALSE

/obj/item/clothing/under/rank/captain/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/captain/nova/imperial/generic
	desc = "A grey naval suit with a rank badge denoting an Officer. Doesn't protect against blaster fire."
	name = "grey officer's naval jumpsuit"
	icon_state = "impcom"

/obj/item/clothing/under/rank/captain/nova/imperial/generic/pants
	desc = "A grey naval suit over black pants, with a rank badge denoting an Officer. Doesn't protect against blaster fire."
	name = "officer's naval jumpsuit"
	icon_state = "impcom_pants"

/obj/item/clothing/under/rank/captain/nova/imperial/generic/grey
	desc = "A dark grey naval suit with a rank badge denoting an Officer. Doesn't protect against blaster fire."
	name = "dark grey officer's naval jumpsuit"
	icon_state = "impcom_dark"

/obj/item/clothing/under/rank/captain/nova/imperial/generic/red
	desc = "A red naval suit with a rank badge denoting an Officer. Doesn't protect against blaster fire."
	name = "red officer's naval jumpsuit"
	icon_state = "impcom_red"

/*
*	MISC
*/

/obj/item/clothing/under/rank/captain/nova/pilot
	name = "shuttle pilot's jumpsuit"
	desc = "It's a blue jumpsuit with some silver markings denoting the wearer as a certified pilot."
	icon_state = "pilot"
	can_adjust = FALSE

/obj/item/clothing/under/rank/captain/nova/pilot/skirt
	name = "shuttle pilot's jumpskirt"
	desc = "It's a blue jumpskirt with some silver markings denoting the wearer as a certified pilot."
	icon_state = "pilot_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
