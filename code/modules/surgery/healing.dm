/datum/surgery/healing
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/heal,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = FALSE
	replaced_by = /datum/surgery
	ignore_clothes = TRUE
	var/healing_step_type
	var/antispam = FALSE

/datum/surgery/healing/can_start(mob/user, mob/living/patient)
	. = ..()
	if(isanimal(patient))
		var/mob/living/simple_animal/critter = patient
		if(!critter.healable)
			return FALSE
	if(!(patient.mob_biotypes & (MOB_ORGANIC|MOB_HUMANOID)))
		return FALSE

/datum/surgery/healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(/datum/surgery_step/incise/nobleed,
					healing_step_type, //hehe cheeky
					/datum/surgery_step/close)

/datum/surgery_step/heal
	name = "repair body"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCREWDRIVER = 65, /obj/item/pen = 55)
	repeatable = TRUE
	time = 25
	var/brutehealing = 0
	var/burnhealing = 0
	var/brutemultilpier = 0 //multiplies the damage that the patient has. if 0 the patient wont get any additional healing from the damage he has.
	var/burnmultiplier = 0

/datum/surgery_step/heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(brutehealing && burnhealing)
		woundtype = "wounds"
	else if(brutehealing)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	if(istype(surgery,/datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(user, target, "<span class='notice'>You attempt to patch some of [target]'s [woundtype].</span>",
		"<span class='notice'>[user] attempts to patch some of [target]'s [woundtype].</span>",
		"<span class='notice'>[user] attempts to patch some of [target]'s [woundtype].</span>")

/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
		if(!..())
			break

/datum/surgery_step/heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/umsg = "You succeed in fixing some of [target]'s wounds" //no period, add initial space to "addons"
	var/tmsg = "[user] fixes some of [target]'s wounds" //see above
	var/brutehealed = brutehealing
	var/burnhealed = burnhealing
	if(target.stat != DEAD)
		brutehealed += round((target.getBruteLoss() * brutemultilpier),0.1)
		burnhealed += round((target.getFireLoss() * burnmultiplier),0.1)
	else //less healing bonus for the dead since they're expected to have lots of damage to begin with (to make TW into defib not TOO simple)
		brutehealed += round((target.getBruteLoss() * (brutemultilpier * 0.2)),0.1)
		burnhealed += round((target.getFireLoss() * (burnmultiplier * 0.2)),0.1)
	if(!get_location_accessible(target, target_zone))
		brutehealed *= 0.55
		burnhealed *= 0.55
		umsg += " as best as you can while they have clothing on"
		tmsg += " as best as they can while [target] has clothing on"
	target.heal_bodypart_damage(brutehealed,burnhealed)
	display_results(user, target, "<span class='notice'>[umsg].</span>",
		"[tmsg].",
		"[tmsg].")
	if(istype(surgery, /datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		the_surgery.antispam = TRUE
	return ..()

/datum/surgery_step/heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screwed up!</span>",
		"<span class='warning'>[user] screws up!</span>",
		"<span class='notice'>[user] fixes some of [target]'s wounds.</span>", TRUE)
	var/brutedealt = brutehealing * 0.8
	var/burndealt = burnhealing * 0.8
	brutedealt	+= round((target.getBruteLoss() * (brutemultilpier * 0.5)),0.1)
	burndealt += round((target.getFireLoss() * (burnmultiplier * 0.5)),0.1)

	target.take_bodypart_damage(brutedealt, burndealt, wound_bonus=CANT_WOUND)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/healing/brute
	name = "Tend Wounds (Bruises)"

/datum/surgery/healing/brute/basic
	name = "Tend Wounds (Bruises, Basic)"
	replaced_by = /datum/surgery/healing/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/brute/basic
	desc = "A surgical procedure that provides basic treatment for a patient's brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded
	name = "Tend Wounds (Bruises, Adv.)"
	replaced_by = /datum/surgery/healing/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's brute traumas. Heals more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded/femto
	name = "Tend Wounds (Bruises, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's brute traumas. Heals considerably more when the patient is severely injured."

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/brute/basic
	name = "tend bruises"
	brutehealing = 5
	brutemultilpier = 0.07

/datum/surgery_step/heal/brute/upgraded
	brutehealing = 5
	brutemultilpier = 0.1

/datum/surgery_step/heal/brute/upgraded/femto
	brutehealing = 5
	brutemultilpier = 0.2

/***************************BURN***************************/
/datum/surgery/healing/burn
	name = "Tend Wounds (Burn)"

/datum/surgery/healing/burn/basic
	name = "Tend Wounds (Burn, Basic)"
	replaced_by = /datum/surgery/healing/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/burn/basic
	desc = "A surgical procedure that provides basic treatment for a patient's burns. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded
	name = "Tend Wounds (Burn, Adv.)"
	replaced_by = /datum/surgery/healing/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns. Heals more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded/femto
	name = "Tend Wounds (Burn, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns. Heals considerably more when the patient is severely injured."

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/basic
	name = "tend burn wounds"
	burnhealing = 5
	burnmultiplier = 0.07

/datum/surgery_step/heal/burn/upgraded
	burnhealing = 5
	burnmultiplier = 0.1

/datum/surgery_step/heal/burn/upgraded/femto
	burnhealing = 5
	burnmultiplier = 0.2

/***************************COMBO***************************/
/datum/surgery/healing/combo


/datum/surgery/healing/combo
	name = "Tend Wounds (Mixture, Basic)"
	replaced_by = /datum/surgery/healing/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/combo
	desc = "A surgical procedure that provides basic treatment for a patient's burns and brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/combo/upgraded
	name = "Tend Wounds (Mixture, Adv.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/combo/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns and brute traumas. Heals more when the patient is severely injured."


/datum/surgery/healing/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	name = "Tend Wounds (Mixture, Exp.)"
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/combo/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns and brute traumas. Heals considerably more when the patient is severely injured."

/********************COMBO STEPS********************/
/datum/surgery_step/heal/combo
	name = "tend physical wounds"
	brutehealing = 3
	burnhealing = 3
	brutemultilpier = 0.07
	burnmultiplier = 0.07
	time = 10

/datum/surgery_step/heal/combo/upgraded
	brutehealing = 3
	burnhealing = 3
	brutemultilpier = 0.1
	burnmultiplier = 0.1

/datum/surgery_step/heal/combo/upgraded/femto
	brutehealing = 1
	burnhealing = 1
	brutemultilpier = 0.4
	burnmultiplier = 0.4

/datum/surgery_step/heal/combo/upgraded/femto/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screwed up!</span>",
		"<span class='warning'>[user] screws up!</span>",
		"<span class='notice'>[user] fixes some of [target]'s wounds.</span>", TRUE)
	target.take_bodypart_damage(5,5)
