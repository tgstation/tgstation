/obj/item/clothing/suit/caution
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	icon_state = "caution"
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")
	armor_type = /datum/armor/suit_caution
	species_exception = list(/datum/species/golem)
	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun,
	)

/datum/armor/suit_caution
	melee = 5
