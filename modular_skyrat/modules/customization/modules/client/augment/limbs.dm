/datum/augment_item/limb
	category = AUGMENT_CATEGORY_LIMBS
	allowed_biotypes = MOB_ORGANIC|MOB_ROBOTIC
	///Hardcoded styles that can be chosen from and apply to limb, if it's true
	var/uses_robotic_styles = TRUE

/datum/augment_item/limb/apply(mob/living/carbon/human/H, character_setup = FALSE, datum/preferences/prefs)
	if(character_setup)
		//Cheaply "faking" the appearance of the prosthetic. Species code sets this back if it doesnt exist anymore
		var/obj/item/bodypart/BP = path
		var/obj/item/bodypart/oldBP = H.get_bodypart(initial(BP.body_zone))
		oldBP.organic_render = FALSE
		if(uses_robotic_styles && prefs.augment_limb_styles[slot])
			oldBP.icon = GLOB.robotic_styles_list[prefs.augment_limb_styles[slot]]
		else
			oldBP.icon = initial(BP.icon)
		oldBP.rendered_bp_icon = initial(BP.icon)
		oldBP.icon_state = initial(BP.icon_state)
		oldBP.should_draw_greyscale = FALSE
		H.icon_render_key = "" //To force an update on the limbs
	else
		var/obj/item/bodypart/BP = new path(H)
		var/obj/item/bodypart/oldBP = H.get_bodypart(BP.body_zone)
		if(uses_robotic_styles && prefs.augment_limb_styles[slot])
			BP.icon = GLOB.robotic_styles_list[prefs.augment_limb_styles[slot]]
		BP.organic_render = FALSE
		BP.replace_limb(H)
		qdel(oldBP)

//HEADS
/datum/augment_item/limb/head
	slot = AUGMENT_SLOT_HEAD

//CHESTS
/datum/augment_item/limb/chest
	slot = AUGMENT_SLOT_CHEST

//LEFT ARMS
/datum/augment_item/limb/l_arm
	slot = AUGMENT_SLOT_L_ARM

/datum/augment_item/limb/l_arm/prosthetic
	name = "Prosthetic"
	path = /obj/item/bodypart/l_arm/robot/surplus
	cost = -1

/datum/augment_item/limb/l_arm/cyborg
	name = "Cyborg"
	path = /obj/item/bodypart/l_arm/robot/weak

//RIGHT ARMS
/datum/augment_item/limb/r_arm
	slot = AUGMENT_SLOT_R_ARM

/datum/augment_item/limb/r_arm/prosthetic
	name = "Prosthetic"
	path = /obj/item/bodypart/r_arm/robot/surplus
	cost = -1

/datum/augment_item/limb/r_arm/cyborg
	name = "Cyborg"
	path = /obj/item/bodypart/r_arm/robot/weak

//LEFT LEGS
/datum/augment_item/limb/l_leg
	slot = AUGMENT_SLOT_L_LEG

/datum/augment_item/limb/l_leg/prosthetic
	name = "Prosthetic"
	path = /obj/item/bodypart/l_leg/robot/surplus
	cost = -1

/datum/augment_item/limb/l_leg/cyborg
	name = "Cyborg"
	path = /obj/item/bodypart/l_leg/robot/weak

//RIGHT LEGS
/datum/augment_item/limb/r_leg
	slot = AUGMENT_SLOT_R_LEG

/datum/augment_item/limb/r_leg/prosthetic
	name = "Prosthetic"
	path = /obj/item/bodypart/r_leg/robot/surplus
	cost = -1

/datum/augment_item/limb/r_leg/cyborg
	name = "Cyborg"
	path = /obj/item/bodypart/r_leg/robot/weak
