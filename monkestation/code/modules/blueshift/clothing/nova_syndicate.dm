#define RESKIN_CHARCOAL "Charcoal"
#define RESKIN_NT "NT Blue"
#define RESKIN_SYNDIE "Syndicate Red"

/obj/item/clothing/under/syndicate
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/syndicate_digi.dmi'

/obj/item/clothing/under/syndicate/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/syndicate.dmi'
	//These are pre-set for ease and reference, as syndie under items SHOULDNT have sensors and should have similar stats; also its better to start with adjust = false
	has_sensor = NO_SENSORS
	can_adjust = FALSE

//Related files:
// modular_nova\modules\Syndie_edits\code\syndie_edits.dm (this has the Overalls and non-Uniforms)
// modular_nova\modules\novaya_ert\code\uniform.dm (NRI uniform(s))

/*
*	TACTICOOL
*/

//This is an overwrite, not a fully new item, but still fits best here.

/obj/item/clothing/under/syndicate/tacticool //Overwrites the 'fake' one. Zero armor, sensors, and default blue. More Balanced to make station-available.
	name = "tacticool turtleneck"
	desc = "A snug turtleneck, in fabulous Nanotrasen-blue. Just looking at it makes you want to buy a NT-certifed coffee, go into the office, and -work-."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/syndicate.dmi' //Since its an overwrite it needs new icon linking. Woe.
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/syndicate.dmi'
	icon_state = "tactifool_blue"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	unique_reskin = list(
		RESKIN_NT = "tactifool_blue",
		RESKIN_CHARCOAL = "tactifool"
	)
	resistance_flags = FLAMMABLE

/obj/item/clothing/under/syndicate/tacticool/reskin_obj(mob/M)
	..()
	if(current_skin && current_skin == RESKIN_CHARCOAL)
		desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-." //Default decription of the normal tacticool
		inhand_icon_state = "bl_suit" //May as well, while we're updating it

/obj/item/clothing/under/syndicate/tacticool/skirt //Overwrites the 'fake' one. Zero armor, sensors, and default blue. More Balanced to make station-available.
	name = "tacticool skirtleneck"
	desc = "A snug skirtleneck, in fabulous Nanotrasen-blue. Just looking at it makes you want to buy a NT-certifed coffee, go into the office, and -work-."
	icon_state = "tactifool_blue_skirt"

	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/bloodred/sleepytime/sensors //Halloween-only
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/syndicate/nova/baseball
	name = "syndicate baseball tee"
	desc = "Aaand the Syndicate Snakes are up to bat, ready for one of their signature nuclear home-runs! Lets show these corpos a good time." //NT pitches their plasma/bluespace(something)
	icon_state = "syndicate_baseball"

/obj/item/clothing/under/syndicate/unarmoured
	name = "suspicious tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under

/obj/item/clothing/under/syndicate/unarmoured/skirt
	name = "suspicious tactical skirtleneck"
	desc = "A non-descript and slightly suspicious looking skirtleneck."
	icon_state = "syndicate_skirt"

	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured
	name = "suspicious tactical turtleneck"
	desc = "A snug syndicate-red turtleneck with charcoal-black cargo pants."
	icon_state = "syndicate_red"
	inhand_icon_state = "r_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under
	unique_reskin = null

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured/skirt
	name = "suspicious tactical skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_red_skirt"

	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured
	name = "suspicious utility overalls turtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, useful for both engineering and botanical work."
	icon_state = "syndicate_overalls"
	armor_type = /datum/armor/clothing_under
	has_sensor = HAS_SENSORS
	can_adjust = TRUE

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured/skirt
	name = "suspicious utility overalls skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_overallskirt"

	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/mask/gas/sechailer/half_mask
	name = "tacticool neck gaiter"
	desc = "A black techwear mask. Its low-profile design contrasts with the edge. Has a small respirator to be used with internals."
	actions_types = list(/datum/action/item_action/adjust)
	//alternate_worn_layer = BODY_FRONT_UNDER_CLOTHES
	icon_state = "half_mask"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/mask.dmi'
/*
*	TACTICAL (Real)
*/
//The red alts, for BLATANTLY syndicate stuff (Like DS2)
// (Multiple non-syndicate things use the base tactical turtleneck, they cant have it red nor reskinnable. OUR version, however, can be.)
/obj/item/clothing/under/syndicate/nova/tactical
	name = "tactical turtleneck"
	desc = "A snug syndicate-red turtleneck with charcoal-black cargo pants. Good luck arguing allegiance with this on."
	icon_state = "syndicate_red"
	inhand_icon_state = "r_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/syndicate
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	unique_reskin = list(
		RESKIN_SYNDIE = "syndicate_red",
		RESKIN_CHARCOAL = "syndicate"
	)

/datum/armor/clothing_under/syndicate/coldres
	melee = 20
	bullet = 10
	energy = 5
	fire = 25
	acid = 25

/datum/armor/clothing_under/syndicate
	melee = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/syndicate/nova/tactical/reskin_obj(mob/M)
	..()
	if(current_skin && current_skin == RESKIN_CHARCOAL)
		desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants." //(Digital camo? Brown? What?)
		inhand_icon_state = "bl_suit"

/obj/item/clothing/under/syndicate/nova/tactical/skirt
	name = "tactical skirtleneck"
	desc = "A snug syndicate-red skirtleneck with a charcoal-black skirt. Good luck arguing allegiance with this on."
	icon_state = "syndicate_red_skirt"
	inhand_icon_state = "r_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	unique_reskin = list(
		RESKIN_SYNDIE = "syndicate_red_skirt",
		RESKIN_CHARCOAL = "syndicate_skirt"
	)

/obj/item/clothing/under/syndicate/nova/tactical/skirt/reskin_obj(mob/M)
	..()
	if(current_skin && current_skin == RESKIN_CHARCOAL)
		desc = "A non-descript and slightly suspicious looking skirtleneck."
		inhand_icon_state = "bl_suit"


/obj/item/clothing/under/syndicate/skirt/coldres
	name = "insulated tactical turtleneck skirt"
	desc = "A non-descript and slightly suspicious looking skirtleneck. The interior has been padded with special insulation for both warmth and protection."
	armor_type = /datum/armor/clothing_under/syndicate/coldres
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT


/*
*	ENCLAVE
*/
/obj/item/clothing/under/syndicate/nova/enclave
	name = "neo-American sergeant uniform"
	desc = "Throughout the stars, rumors of mad scientists and angry drill sergeants run rampant; of creatures in armor black as night, being led by men or women wearing this uniform. They share one thing: a deep, natonalistic zeal of the dream of America."
	icon_state = "enclave"
	can_adjust = TRUE
	armor_type = /datum/armor/clothing_under

/obj/item/clothing/under/syndicate/nova/enclave/officer
	name = "neo-American officer uniform"
	icon_state = "enclaveo"

/obj/item/clothing/under/syndicate/nova/enclave/real
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/syndicate/nova/enclave/real/officer
	name = "neo-American officer uniform"
	icon_state = "enclaveo"

#undef RESKIN_CHARCOAL
#undef RESKIN_NT
#undef RESKIN_SYNDIE

//DS-2/Syndicate clothing.

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	icon = 'monkestation/code/modules/blueshift/icons/obj.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/worn.dmi'
	icon_state = "syndievest"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/suit/armor/vest/capcarapace/syndicate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate/winter
	name = "syndicate captain's winter vest"
	desc = "A sinister yet comfortable looking vest of advanced armor worn over a black and red fireproof jacket. The fur is said to be from wolves on the icemoon."
	icon = 'monkestation/code/modules/blueshift/icons/obj.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/worn.dmi'
	icon_state = "syndievest_winter"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate/winter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/head/hats/warden/syndicate
	name = "master at arms' police hat"
	desc = "A fashionable police cap emblazoned with a golden badge, issued to the Master at Arms. Protects the head from impacts."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "policehelm_syndie"
	dog_fashion = null

/obj/item/clothing/head/helmet/swat/ds
	name = "SWAT helmet"
	desc = "A robust and spaceworthy helmet with a small cross on it along with 'IP' written across the earpad."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/helmet.dmi'
	icon_state = "swat_ds"
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/head/beret/sec/syndicate
	name = "brig officer's beret"
	desc = "A stylish and protective beret, produced and manufactured by Interdyne Pharmaceuticals with help from the Gorlex Marauders."
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	icon_state = "beret_badge"
	greyscale_colors = "#3F3C40#DB2929"

/obj/item/clothing/mask/gas/syndicate/ds
	name = "balaclava"
	desc = "A fancy balaclava, while it doesn't muffle your voice, it's fireproof and has a miniature rebreather for internals. Comfy to boot!"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/mask.dmi'
	icon_state = "balaclava_ds"
	flags_inv = HIDEFACE | HIDEEARS | HIDEFACIALHAIR
	//alternate_worn_layer = LOW_FACEMASK_LAYER //This lets it layer below glasses and headsets; yes, that's below hair, but it already has HIDEHAIR

/obj/item/clothing/mask/gas/sechailer/syndicate
	name = "neck gaiter"
	desc = "For the agent wanting to keep a low profile whilst concealing their identity. Has a small respirator to be used with internals."
	actions_types = list(/datum/action/item_action/adjust)
	//alternate_worn_layer = BODY_FRONT_UNDER_CLOTHES
	icon_state = "half_mask"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/mask.dmi'

/obj/item/clothing/shoes/combat //TO-DO: Move these overrides out of a syndicate file!
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "combat"

/obj/item/clothing/gloves/combat
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "combat"

/obj/item/clothing/gloves/combat/wizard
	icon = 'icons/obj/clothing/gloves.dmi'
	worn_icon = null

/obj/item/clothing/gloves/tackler/combat/insulated
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "combat"

/obj/item/clothing/gloves/krav_maga/combatglovesplus
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "combat"

/obj/item/clothing/gloves/krav_maga/combatglovesplus/maa
	name = "master at arms' combat gloves"
	desc = "A set of combat gloves plus emblazoned with red knuckles, showing dedication to the trade while also hiding any blood left after use."
	icon_state = "maagloves"

/obj/item/storage/belt/security/webbing/ds
	name = "brig officer webbing"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'
	icon_state = "webbingds"
	worn_icon_state = "webbingds"
	uses_advanced_reskins = FALSE

/obj/item/clothing/suit/armor/bulletproof/old
	desc = "A Type III heavy bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "bulletproof"
	body_parts_covered = CHEST //TG's version has no groin/arm padding

/obj/item/clothing/under/syndicate/nova/overalls
	name = "utility overalls turtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, useful for both engineering and botanical work."
	icon_state = "syndicate_overalls"
	can_adjust = TRUE

/obj/item/clothing/under/syndicate/nova/overalls/skirt
	name = "utility overalls skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_overallskirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/soft/sec/syndicate
	name = "engine tech utility cover"
	desc = "A utility cover for an engine technician, there's a tag that reads 'IP-DS-2'."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "dssoft"
	soft_type = "ds"

//Maid Outfit
/obj/item/clothing/head/costume/maidheadband/syndicate
	name = "tactical maid headband"
	desc = "Tacticute."
	icon_state = "syndimaid_headband"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/costume.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/costume.dmi'

/obj/item/clothing/gloves/combat/maid
	name = "combat maid sleeves"
	desc = "These 'tactical' gloves and sleeves are fireproof and electrically insulated. Warm to boot."
	icon_state = "syndimaid_arms"

/obj/item/clothing/under/syndicate/nova/maid
	name = "tactical maid outfit"
	desc = "A 'tactical' skirtleneck fashioned to the likeness of a maid outfit. Why the Syndicate has these, you'll never know."
	icon_state = "syndimaid"
	//armor_type = /datum/armor/clothing_under/none
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/nova/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidcorset/syndicate/A = new (src)
	attach_accessory(A)

/obj/item/clothing/accessory/maidcorset/syndicate
	name = "syndicate maid apron"
	desc = "Practical? No. Tactical? Also no. Cute? Most definitely yes."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/accessories.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/accessories.dmi'
	icon_state = "syndimaid_corset"
	minimize_when_attached = FALSE
	attachment_slot = null

//Wintercoat & Hood
/obj/item/clothing/suit/hooded/wintercoat/nova/syndicate
	name = "syndicate winter coat"
	desc = "A sinister black coat with red accents and a fancy mantle, it feels like it can take a hit. The zipper tab looks like a triple headed snake in the shape of an S, spooky."
	icon_state = "coatsyndie"
	inhand_icon_state = "coatwinter"
	armor_type = /datum/armor/wintercoat_syndicate
	hoodtype = /obj/item/clothing/head/hooded/winterhood/nova/syndicate

/datum/armor/wintercoat_syndicate
	melee = 25
	bullet = 15
	laser = 30
	energy = 40
	bomb = 25
	acid = 45

/obj/item/clothing/suit/hooded/wintercoat/nova/syndicate/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/nova/syndicate
	desc = "A sinister black hood with armor padding."
	icon_state = "hood_syndie"
	armor_type = /datum/armor/winterhood_syndicate

/datum/armor/winterhood_syndicate
	melee = 25
	bullet = 15
	laser = 30
	energy = 40
	bomb = 25
	acid = 45

//Interdyne Clothing
/obj/item/clothing/under/syndicate/nova/interdyne
	name = "interdyne turtleneck"
	desc = "A sleek white turtleneck with a hint of interdyne-green, appropriately paired with some charcoal-black cargo pants."
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	icon_state = "ip_turtleneck"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/syndicate/nova/interdyne/miner
	name = "interdyne jumpsuit"
	desc = "A black and green Interdyne Pharmaceutics jumpsuit with reinforced fibers."
	//armor_type = /datum/armor/clothing_under/cargo_miner
	icon_state = "ip_miner"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/syndicate/nova/interdyne/deckofficer
	name = "deck officer's jumpsuit"
	desc = "A black and green Interdyne Pharmaceutics uniform complete with a golden belt buckle."
	armor_type = /datum/armor/clothing_under/syndicate
	icon_state = "ip_deckofficer"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/head/beret/medical/nova/interdyne
	name = "interdyne beret"
	desc = "A white and green beret denoting one's allegiance to Interdyne Pharmaceutics."
	greyscale_colors = "#FFFFFF#198019"

/obj/item/clothing/head/hats/syndicate/interdyne_deckofficer_black
	name = "black deck officer's cap"
	desc = "A black officer's cap that demands discipline from the one who wears it."
	icon_state = "ip_officercap_black"
	armor_type = /datum/armor/sec_navywarden
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'

/obj/item/clothing/head/hats/syndicate/interdyne_deckofficer_white
	name = "white deck officer's cap"
	desc = "A white officer's cap that demands discipline from the one who wears it."
	icon_state = "ip_officercap_white"
	armor_type = /datum/armor/sec_navywarden
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'

/obj/item/clothing/head/bio_hood/interdyne
	name = "interdyne biosuit helmet"
	desc = "An Interdyne Pharmaceutics biosuit helmet designed to keep the wearer safe from biohazardous materials."
	icon_state = "ip_biosuit_head"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'

/obj/item/clothing/suit/bio_suit/interdyne
	name = "interdyne biosuit"
	desc = "An Interdyne Pharmaceutics biosuit designed to keep the wearer safe from biohazardous materials. It's lighter than a typical biosuit."
	icon_state = "ip_biosuit"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	slowdown = 0.3
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/hos/deckofficer
	name = "deck officer's cloak"
	desc = "An armored trench-cloak with green accents worn by high-ranking interdyne staff."
	icon_state = "ip_officercloak"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi'
	current_skin = "ip_officercloak" //prevents reskinning

/obj/item/clothing/suit/toggle/labcoat/nova
	name = "MONKE LABCOAT SUIT DEBUG"
	desc = "REPORT THIS IF FOUND"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/labcoat.dmi'
	icon_state = null //Keeps this from showing up under the chameleon hat


/obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/black
	name = "interdyne black labcoat"
	desc = "A black labcoat accented with interdyne-green colors."
	icon_state = "ip_labcoatblack"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/white
	name = "interdyne white labcoat"
	desc = "A white labcoat accented with interdyne-green colors."
	icon_state = "ip_labcoatwhite"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/suit/syndicate/interdyne_jacket
	name = "interdyne jacket"
	desc = "A green high-visibility jacket bearing interdyne colors."
	icon_state = "ip_armorlabcoat"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/labcoat.dmi'
	armor_type = /datum/armor/wintercoat_syndicate
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/nova/rd/deckofficer
	name = "deck officer's labcoat"
	desc = "A white labcoat with interdyne-green accents and a particularly fancy collar."
	icon_state = "ip_officerlabcoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/wintercoat/medical/viro/interdyne
	name = "interdyne winter coat"
	desc = "A fuzzy winter coat bearing interdyne colors, complete with armored fibers."
	armor_type = /datum/armor/wintercoat_syndicate
//Interdyne Clothing End

/obj/item/clothing/glasses/hud/health/night/cultblind_unrestricted
	desc = "Where we are going, we won't need eyes to see."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/glasses/hud/health/night/cultblind_unrestricted/narsie
	desc = "May Nar'Sie guide you through the darkness and shield you from the light."
