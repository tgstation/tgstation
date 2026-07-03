/datum/body_modification/limb_amputation
	name = "Body Part Amputation"
	abstract_type = /datum/body_modification/limb_amputation
	var/limb_body_zone = null

/datum/body_modification/limb_amputation/apply_to_human(mob/living/carbon/target, additional_params)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(target, TRAIT_NODISMEMBER))
		return FALSE

	var/obj/item/bodypart/limb_to_remove = target.get_bodypart(limb_body_zone)
	if(!limb_to_remove)
		return FALSE

	limb_to_remove.drop_limb(special = TRUE)
	qdel(limb_to_remove)
	return TRUE

/datum/body_modification/limb_amputation/arm
	abstract_type = /datum/body_modification/limb_amputation/arm

/datum/body_modification/limb_amputation/arm/left
	key = "left_arm_amputation"
	name = "Ампутация левой руки"
	limb_body_zone = BODY_ZONE_L_ARM
	incompatible_body_modifications = list("left_arm_prosthesis")
	category = "Левая рука"

/datum/body_modification/limb_amputation/arm/right
	key = "right_arm_amputation"
	name = "Ампутация правой руки"
	limb_body_zone = BODY_ZONE_R_ARM
	incompatible_body_modifications = list("right_arm_prosthesis")
	category = "Правая рука"

/datum/body_modification/limb_amputation/leg
	abstract_type = /datum/body_modification/limb_amputation/leg

/datum/body_modification/limb_amputation/leg/left
	key = "left_leg_amputation"
	name = "Ампутация левой ноги"
	limb_body_zone = BODY_ZONE_L_LEG
	incompatible_body_modifications = list("left_leg_prosthesis")
	category = "Левая нога"

/datum/body_modification/limb_amputation/leg/right
	key = "right_leg_amputation"
	name = "Ампутация правой ноги"
	limb_body_zone = BODY_ZONE_R_LEG
	incompatible_body_modifications = list("right_leg_prosthesis")
	category = "Правая нога"
