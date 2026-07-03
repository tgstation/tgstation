/datum/body_modification/implants
	name = "Implants"
	abstract_type = /datum/body_modification/implants
	var/replacement_organ = null

/datum/body_modification/implants/robotic
	name = "Robotic implants"
	abstract_type = /datum/body_modification/implants/robotic

/datum/body_modification/implants/apply_to_human(mob/living/carbon/target, additional_params)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/organ_to_apply = new replacement_organ
	organ_to_apply.replace_into(target)
	return TRUE

/datum/body_modification/implants/robotic/eyes
	key = "robotic_eyes"
	name = "Робо-глаза"
	category = "Органы"
	replacement_organ = /obj/item/organ/eyes/robotic/basic

/datum/body_modification/implants/robotic/tongue
	key = "robotic_tongue"
	name = "Робо-язык"
	category = "Органы"
	replacement_organ = /obj/item/organ/tongue/robot

/datum/body_modification/implants/robotic/brain
	key = "cybernetic_brain"
	name = "Кибернетический мозг"
	category = "Органы"
	replacement_organ = /obj/item/organ/brain/cybernetic

/datum/body_modification/implants/robotic/ears
	key = "cybernetic_ears"
	name = "Кибернетические уши"
	category = "Органы"
	replacement_organ = /obj/item/organ/ears/cybernetic

/datum/body_modification/implants/robotic/liver
	key = "cybernetic_liver"
	name = "Кибернетическая печень"
	category = "Органы"
	replacement_organ = /obj/item/organ/liver/cybernetic

/datum/body_modification/implants/robotic/lungs
	key = "cybernetic_lungs"
	name = "Кибернетические лёгкие"
	category = "Органы"
	replacement_organ = /obj/item/organ/lungs/cybernetic

/datum/body_modification/implants/robotic/stomach
	key = "cybernetic_stomach"
	name = "Кибернетический желудок"
	category = "Органы"
	replacement_organ = /obj/item/organ/stomach/cybernetic

/datum/body_modification/implants/robotic/heart
	key = "cybernetic_heart"
	name = "Кибернетическое сердце"
	category = "Органы"
	replacement_organ = /obj/item/organ/heart/cybernetic
