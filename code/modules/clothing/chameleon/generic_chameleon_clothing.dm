
#define BREAK_CHAMELEON_ACTION(item) \
do { \
	var/datum/action/item_action/chameleon/change/_action = locate() in item.actions; \
	_action?.emp_randomise(INFINITY); \
	item.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF); \
} while(FALSE)

// Cham jumpsuit
/datum/armor/clothing_under/chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/under/chameleon
	name = "black jumpsuit"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_worn = /datum/greyscale_config/jumpsuit/worn
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit/inhand_right
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor_type = /datum/armor/clothing_under/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/jumpsuit)

/obj/item/clothing/under/chameleon/broken

/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham suit / armor
/datum/armor/suit_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor_type = /datum/armor/suit_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/suit)

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed //should at least act like a vest

/obj/item/clothing/suit/chameleon/broken

/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham glasses
/datum/armor/glasses_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	flags_cover = GLASSESCOVERSEYES
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	armor_type = /datum/armor/glasses_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/glasses)

/obj/item/clothing/glasses/chameleon/broken

/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham gloves
/datum/armor/gloves_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	greyscale_colors = null

	resistance_flags = NONE
	body_parts_covered = HANDS|ARMS
	armor_type = /datum/armor/gloves_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/gloves)
	clothing_traits = list(TRAIT_FAST_CUFFING)

/obj/item/clothing/gloves/chameleon/broken

/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham hat
/datum/armor/head_chameleon
	melee = 5
	bullet = 5
	laser = 5
	fire = 50
	acid = 50

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	icon_state = "greysoft"
	resistance_flags = NONE
	armor_type = /datum/armor/head_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/hat)

/obj/item/clothing/head/chameleon/broken

/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/head/chameleon/drone
	actions_types = list(/datum/action/item_action/chameleon/change/hat, /datum/action/item_action/chameleon/drone/togglehatmask, /datum/action/item_action/chameleon/drone/randomise)
	item_flags = DROPDEL
	// The camohat, I mean, holographic hat projection, is part of the drone itself.
	armor_type = /datum/armor/none
	// which means it offers no protection, it's just air and light

/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	var/datum/action/item_action/chameleon/change/hat/hat = locate() in actions
	hat?.random_look()

// Cham mask, voice changer included
/datum/armor/mask_chameleon
	melee = 5
	bullet = 5
	laser = 5
	bio = 100
	fire = 50
	acid = 50

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	armor_type = /datum/armor/mask_chameleon
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/chameleon/change/mask)
	/// Is our voice changer enabled or disabled?
	var/voice_change = TRUE

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	voice_change = !voice_change
	to_chat(user, span_notice("The voice changer is now [voice_change ? "on" : "off"]!"))

/obj/item/clothing/mask/chameleon/broken

/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/mask/chameleon/drone
	actions_types = list(/datum/action/item_action/chameleon/change/mask, /datum/action/item_action/chameleon/drone/togglehatmask, /datum/action/item_action/chameleon/drone/randomise)
	item_flags = DROPDEL
	//Same as the drone chameleon hat, undroppable and no protection
	armor_type = /datum/armor/none
	voice_change = FALSE

/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	var/datum/action/item_action/chameleon/change/mask/mask = locate() in actions
	mask?.random_look()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, span_notice("[src] does not have a voice changer."))

// Cham shoes, including chameleon noslips
/datum/armor/shoes_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 90
	fire = 50
	acid = 50

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	desc = "A pair of black shoes."
	icon_state = "sneakers"
	inhand_icon_state = "sneakers_back"
	body_parts_covered = FEET|LEGS
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers/worn
	greyscale_config_inhand_left = /datum/greyscale_config/sneakers/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/sneakers/inhand_right
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/shoes)

/obj/item/clothing/shoes/chameleon/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/chameleon/broken

/obj/item/clothing/shoes/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/shoes/chameleon/noslip
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham backpack
/obj/item/storage/backpack/chameleon
	name = "backpack"
	actions_types = list(/datum/action/item_action/chameleon/change/backpack)

/obj/item/storage/backpack/chameleon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/storage/backpack/chameleon/broken

/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham belt (bonus: is silent)
/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	actions_types = list(/datum/action/item_action/chameleon/change/belt)

/obj/item/storage/belt/chameleon/Initialize(mapload)
	. = ..()
	atom_storage.silent = TRUE

/obj/item/storage/belt/chameleon/broken

/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham headset
/obj/item/radio/headset/chameleon
	name = "radio headset"
	actions_types = list(/datum/action/item_action/chameleon/change/headset)

/obj/item/radio/headset/chameleon/broken

/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham PDA
/obj/item/modular_computer/pda/chameleon
	name = "tablet"
	actions_types = list(/datum/action/item_action/chameleon/change/tablet)

/obj/item/modular_computer/pda/chameleon/broken

/obj/item/modular_computer/pda/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham Stamp
/obj/item/stamp/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/stamp)

/obj/item/stamp/chameleon/broken

/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

// Cham neck-thing
/datum/armor/neck_chameleon
	fire = 50
	acid = 50

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "detective" //we use this icon_state since the other ones are all generated by GAGS.
	resistance_flags = NONE
	armor_type = /datum/armor/neck_chameleon
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/chameleon/change/neck)

/obj/item/clothing/neck/chameleon/broken

/obj/item/clothing/neck/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

#undef BREAK_CHAMELEON_ACTION
