/obj/item/organ/ears/fox
	name = "fox ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 3

	preference = "feature_fox_ears"

	dna_block = /datum/dna_block/feature/ears_fox
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears/fox
	sprite_accessory_override = /datum/sprite_accessory/ears_fox

/obj/item/organ/tail/fox
	name = "fox tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fox
	wag_flags = WAG_ABLE

/datum/bodypart_overlay/mutant/tail/fox
	feature_key = "fox_tail"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/fox/get_global_feature_list()
	return SSaccessories.tails_list_fox

/obj/item/organ/tongue/fox
	name = "kitsune tongue"
	desc = "A sharp, agile muscle, perfect for yips, barks, and the occasional mischievous bite."
	say_mod = "yips"
	liked_foodtypes = SEAFOOD | ORANGES | BUGS | GORE
	disliked_foodtypes = GROSS | CLOTH | RAW
	organ_traits = list(TRAIT_WOUND_LICKER)
	languages_native = list(/datum/language/spinwarder)
	actions_types = list(/datum/action/item_action/organ_action/go_feral)
	var/feral_mode = FALSE

/obj/item/organ/tongue/fox/on_bodypart_insert(obj/item/bodypart/head)
	. = ..()
	head.unarmed_damage_low += 4
	head.unarmed_damage_high += 7
	head.unarmed_effectiveness += 10
	head.unarmed_pummeling_bonus += 0.5
	head.unarmed_attack_effect = ATTACK_EFFECT_BITE
	head.unarmed_sharpness = SHARP_EDGED
	if(feral_mode)
		add_organ_trait(TRAIT_FERAL_BITER)

/obj/item/organ/tongue/fox/on_bodypart_remove(obj/item/bodypart/head)
	. = ..()
	head.unarmed_damage_low -= 4
	head.unarmed_damage_high -= 7
	head.unarmed_effectiveness -= 10
	head.unarmed_pummeling_bonus -= 0.5
	head.unarmed_attack_effect = initial(head.unarmed_attack_effect)
	head.unarmed_sharpness = initial(head.unarmed_sharpness)
	remove_organ_trait(TRAIT_FERAL_BITER)

/obj/item/organ/tongue/fox/proc/toggle_feral()
	feral_mode = !feral_mode
	if(feral_mode)
		add_organ_trait(TRAIT_FERAL_BITER)
	else
		remove_organ_trait(TRAIT_FERAL_BITER)

