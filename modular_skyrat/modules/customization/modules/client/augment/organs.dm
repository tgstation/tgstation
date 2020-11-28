/datum/augment_item/organ
	category = AUGMENT_CATEGORY_ORGANS

/datum/augment_item/organ/apply(mob/living/carbon/human/H, character_setup = FALSE, datum/preferences/prefs)
	if(character_setup)
		return
	var/obj/item/organ/new_organ = new path()
	new_organ.Insert(H,FALSE,FALSE)

//HEARTS
/datum/augment_item/organ/heart
	slot = AUGMENT_SLOT_HEART

/datum/augment_item/organ/heart/cybernetic
	name = "Cybernetic heart"
	path = /obj/item/organ/heart/cybernetic

//LUNGS
/datum/augment_item/organ/lungs
	slot = AUGMENT_SLOT_LUNGS

/datum/augment_item/organ/lungs/cybernetic
	name = "Cybernetic lungs"
	path = /obj/item/organ/lungs/cybernetic

//LIVERS
/datum/augment_item/organ/liver
	slot = AUGMENT_SLOT_LIVER

/datum/augment_item/organ/liver/cybernetic
	name = "Cybernetic liver"
	path = /obj/item/organ/liver/cybernetic

//STOMACHES
/datum/augment_item/organ/stomach
	slot = AUGMENT_SLOT_STOMACH

/datum/augment_item/organ/stomach/cybernetic
	name = "Cybernetic stomach"
	path = /obj/item/organ/stomach/cybernetic

//EYES
/datum/augment_item/organ/eyes
	slot = AUGMENT_SLOT_EYES

/datum/augment_item/organ/eyes/cybernetic
	name = "Cybernetic eyes"
	path = /obj/item/organ/eyes/robotic

/datum/augment_item/organ/eyes/highlumi
	name = "High-luminosity eyes"
	path = /obj/item/organ/eyes/robotic/glow
	allowed_biotypes = MOB_ORGANIC|MOB_ROBOTIC
	cost = 1

//TONGUES
/datum/augment_item/organ/tongue
	slot = AUGMENT_SLOT_TONGUE

/datum/augment_item/organ/tongue/normal
	name = "Organic tongue"
	path = /obj/item/organ/tongue

/datum/augment_item/organ/tongue/robo
	name = "Robotic voicebox"
	path = /obj/item/organ/tongue/robot

/datum/augment_item/organ/tongue/forked
	name = "Forked tongue"
	path = /obj/item/organ/tongue/lizard
