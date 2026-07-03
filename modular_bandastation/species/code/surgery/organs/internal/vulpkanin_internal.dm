/obj/item/organ/tongue/vulpkanin
	name = "long tongue"
	desc = "Длинный и более чувствительный язык, может различить больше вкусов."
	icon_state = "tongue"
	taste_sensitivity = 10
	modifies_speech = FALSE
	languages_native = list(/datum/language/canilunzt)
	liked_foodtypes = RAW | MEAT | SEAFOOD
	disliked_foodtypes =  FRUIT | NUTS | GROSS | GRAIN

/obj/item/organ/tongue/get_possible_languages()
	return ..() + /datum/language/canilunzt

/obj/item/organ/tongue/vulpkanin/on_mob_insert(mob/living/carbon/owner)
	. = ..()
	add_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_howl)
	add_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_growl)
	add_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_purr)
	add_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_bark)
	add_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_wbark)

/obj/item/organ/tongue/vulpkanin/on_mob_remove(mob/living/carbon/owner)
	. = ..()
	remove_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_howl)
	remove_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_growl)
	remove_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_purr)
	remove_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_bark)
	remove_verb(owner, /mob/living/carbon/human/species/vulpkanin/proc/emote_wbark)

/obj/item/organ/stomach/vulpkanin
	hunger_modifier = 1.3

/obj/item/organ/liver/vulpkanin
	name = "vulpkanin liver"
	icon = 'icons/bandastation/mob/species/vulpkanin/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 2.5

/obj/item/organ/eyes/vulpkanin
	name = "vulpkanin eyeballs"
	icon = 'icons/bandastation/mob/species/vulpkanin/organs.dmi'

/obj/item/organ/ears/vulpkanin
	desc = "Большие ушки позволяют легче слышать шепот."
	damage_multiplier = 2

/obj/item/organ/ears/vulpkanin/on_mob_insert(mob/living/carbon/ear_owner)
	. = ..()
	ADD_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/obj/item/organ/ears/vulpkanin/on_mob_remove(mob/living/carbon/ear_owner)
	. = ..()
	REMOVE_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/obj/item/organ/heart/vulpkanin
	name = "vulpkanin heart"
	icon = 'icons/bandastation/mob/species/vulpkanin/organs.dmi'

/obj/item/organ/brain/vulpkanin
	icon = 'icons/bandastation/mob/species/vulpkanin/organs.dmi'
	actions_types = list(/datum/action/cooldown/sniff)

/obj/item/organ/lungs/vulpkanin
	name = "vulpkanin lungs"
	icon = 'icons/bandastation/mob/species/vulpkanin/organs.dmi'
