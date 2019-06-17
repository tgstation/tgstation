/datum/surgery/healing
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/heal,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = 0
	var/healing_step_type
	replaced_by = /datum/surgery

/datum/surgery/healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(/datum/surgery_step/incise,
					/datum/surgery_step/retract_skin,
					/datum/surgery_step/incise,
					/datum/surgery_step/clamp_bleeders,
					healing_step_type, //hehe cheeky
					/datum/surgery_step/close)

/datum/surgery_step/heal
	name = "repair body"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25
	var/brutehealing = 0
	var/burnhealing = 0

/datum/surgery_step/heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(brutehealing && burnhealing)
		woundtype = "wounds"
	else if(brutehealing)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	display_results(user, target, "<span class='notice'>You attempt to patch some of [target]'s [woundtype].</span>",
		"[user] attempts to patch some of [target]'s [woundtype].",
		"[user] attempts to patch some of [target]'s [woundtype].")


/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
			if(!..())
				break

/datum/surgery_step/heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed in fixing some of [target]'s wounds.</span>",
		"[user] fixes some of [target]'s wounds.",
		"[user] fixes some of [target]'s wounds.")
	target.heal_bodypart_damage(brutehealing,burnhealing)
	return TRUE

/datum/surgery_step/heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] screws up!", "<span class='warning'>You screwed up!</span>")
	display_results(user, target, "<span class='warning'>You screwed up!</span>",
		"[user] screws up!",
		"[user] fixes some of [target]'s wounds.", TRUE)
	target.take_bodypart_damage(5,0)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/healing/brute
	name = "Tend Wounds (Bruises)"

/datum/surgery/healing/brute/basic
	replaced_by = /datum/surgery/healing/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/brute/basic

/datum/surgery/healing/brute/upgraded
	replaced_by = /datum/surgery/healing/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded

/datum/surgery/healing/brute/upgraded/femto
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded/femto

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/brute/basic
	name = "tend bruises"
	brutehealing = 5

/datum/surgery_step/heal/brute/upgraded
	brutehealing = 10

/datum/surgery_step/heal/brute/upgraded/femto
	brutehealing = 15

/***************************BURN***************************/
/datum/surgery/healing/burn
	name = "Tend Wounds (Burn)"

/datum/surgery/healing/burn/basic
	replaced_by = /datum/surgery/healing/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/burn/basic

/datum/surgery/healing/burn/upgraded
	replaced_by = /datum/surgery/healing/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded

/datum/surgery/healing/burn/upgraded/femto
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded/femto

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/basic
	name = "tend burn wounds"
	burnhealing = 5

/datum/surgery_step/heal/burn/upgraded
	burnhealing = 10

/datum/surgery_step/heal/burn/upgraded/femto
	burnhealing = 15

/***************************COMBO***************************/
/datum/surgery/healing/combo


/datum/surgery/healing/combo
	name = "Tend Wounds (Mixture)"
	replaced_by = /datum/surgery/healing/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/combo

/datum/surgery/healing/combo/upgraded
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/combo/upgraded


/datum/surgery/healing/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/combo/upgraded/femto

/********************COMBO STEPS********************/
/datum/surgery_step/heal/combo
	name = "tend physical wounds"
	brutehealing = 3
	burnhealing = 2
	time = 10

/datum/surgery_step/heal/combo/upgraded
	brutehealing = 5
	burnhealing = 5

/datum/surgery_step/heal/combo/upgraded/femto
	brutehealing = 8
	burnhealing = 7
