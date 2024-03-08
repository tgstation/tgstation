/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	alt_covers_chest = TRUE
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	supports_variations_flags = CLOTHING_MONKEY_VARIATION

/datum/armor/clothing_under/syndicate
	melee = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/syndicate/skirt
	name = "tactical skirtleneck"
	desc = "A non-descript and slightly suspicious looking skirtleneck."
	icon_state = "syndicate_skirt"
	inhand_icon_state = "bl_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/bloodred
	name = "blood-red sneaksuit"
	desc = "It still counts as stealth if there are no witnesses."
	icon_state = "bloodred_pajamas"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/clothing_under/syndicate_bloodred
	resistance_flags = FIRE_PROOF | ACID_PROOF
	can_adjust = FALSE
	supports_variations_flags = NONE

/datum/armor/clothing_under/syndicate_bloodred
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/syndicate/bloodred/sleepytime
	name = "blood-red pajamas"
	desc = "Do operatives dream of nuclear sheep?"
	icon_state = "bloodred_pajamas"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/clothing_under/bloodred_sleepytime

/datum/armor/clothing_under/bloodred_sleepytime
	fire = 50
	acid = 40

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	inhand_icon_state = "bl_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate_tacticool
	stubborn_stains = TRUE

/datum/armor/clothing_under/syndicate_tacticool
	fire = 50
	acid = 40

/obj/item/clothing/under/syndicate/tacticool/examine(mob/user)
	. = ..()
	. += "It has a label that says cleaning this 'genuine' Waffle Corp. product with cleaning solutions other than Grime Liberator telelocational podcrystals will void the warranty."
	. += "What on earth is a <font color='red'>tele</font>locational pod<font color='red'>crystal</font>?"

/obj/item/clothing/under/syndicate/tacticool/dye_item(dye_color, dye_key_override)
	if(dye_color == DYE_SYNDICATE)
		if(dying_key == DYE_REGISTRY_JUMPSKIRT)
			special_wash(/obj/item/clothing/under/syndicate/skirt)
		else
			special_wash(/obj/item/clothing/under/syndicate)
		qdel(src)
		return
	return ..()

/obj/item/clothing/under/syndicate/tacticool/proc/special_wash(obj/item/clothing/under/syndicate/our_jumpsuit)
	new our_jumpsuit(loc)

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool_skirt"
	inhand_icon_state = "bl_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/sniper
	name = "tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian-grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "tactical_suit"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/camo
	name = "camouflage fatigues"
	desc = "A green military camouflage uniform."
	icon_state = "camogreen"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/soviet
	name = "Ratnik 5 tracksuit"
	desc = "Badly translated labels tell you to clean this in Vodka. Great for squatting in."
	icon_state = "trackpants"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_soviet
	resistance_flags = NONE

/datum/armor/clothing_under/syndicate_soviet
	melee = 10

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/rus_army
	name = "advanced military tracksuit"
	desc = "Military grade tracksuits for frontline squatting."
	icon_state = "rus_under"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_rus_army
	resistance_flags = NONE

/datum/armor/clothing_under/syndicate_rus_army
	melee = 5

/obj/item/clothing/under/syndicate/scrubs
	name = "tactical scrubs"
	desc = "A deep burgundy set of scrubs, made tactically for tactical reasons."
	icon = 'icons/obj/clothing/under/medical.dmi'
	worn_icon = 'icons/mob/clothing/under/medical.dmi'
	icon_state = "scrubswine"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_scrubs

/datum/armor/clothing_under/syndicate_scrubs
	melee = 10
	bio = 50
	fire = 50
	acid = 40

/obj/item/clothing/under/plasmaman/syndicate
	name = "tacticool envirosuit"
	desc = "A sinister looking envirosuit, for the boniest of operatives."
	icon_state = "syndie_envirosuit"
	has_sensor = NO_SENSORS
	resistance_flags = FIRE_PROOF
	inhand_icon_state = null
