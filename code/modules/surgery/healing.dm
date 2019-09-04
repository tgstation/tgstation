/datum/surgery/heal
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/heal/four_damages,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = FALSE
	replaced_by = /datum/surgery
	var/healing_step_type

/datum/surgery/heal/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(/datum/surgery_step/incise/nobleed,
					healing_step_type, //hehe cheeky
					/datum/surgery_step/close)

/datum/surgery/heal/four_damages
	ignore_clothes = TRUE
	var/antispam = FALSE


/datum/surgery_step/heal
	name = "repair body"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 65, /obj/item/pen = 55)
	repeatable = TRUE
	time = 25

/datum/surgery_step/heal/four_damages/
	var/brutehealing = 0
	var/burnhealing = 0
	var/toxhealing = 0
	var/oxyhealing = 0
	var/woundtype = "wounds" //tells users what type of wound is being healed
	var/umsg_success_override //see success()
	var/umsg_attempt_override //see preop()
	var/tmsg_success_override
	var/tmsg_attempt_override

/datum/surgery_step/heal/four_damages/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery,/datum/surgery/heal/four_damages))
		var/datum/surgery/heal/four_damages/the_surgery = surgery
		if(!the_surgery.antispam)
			var/umsg_attempt = "You attempt to patch some of [target]'s [woundtype]"
			var/tmsg_attempt = "[user] attempts to patch some of [target]'s [woundtype]"
			if(umsg_attempt_override)
				umsg_attempt = umsg_attempt_override
			if(tmsg_attempt_override)
				tmsg_attempt = tmsg_attempt_override
			display_results(user, target, "<span class='notice'>[umsg_attempt].</span>",
		"<span class='notice'>[tmsg_attempt].</span>",
		"<span class='notice'>[tmsg_attempt].</span>")

/datum/surgery_step/heal/four_damages/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()) || (toxhealing && target.getToxLoss()) || (oxyhealing && target.getOxyLoss()))
			if(!..())
				break

/datum/surgery_step/heal/four_damages/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/umsg_success = "You succeed in fixing some of [target]'s [woundtype]"
	var/tmsg_success = "[user] fixes some of [target]'s [woundtype]"
	if(umsg_success_override)
		umsg_success = umsg_success_override
	if(tmsg_success_override)
		tmsg_success = tmsg_success_override

	if(get_location_accessible(target, target_zone))
		target.apply_damages(brutehealing,burnhealing,toxhealing,oxyhealing)
	else
		target.apply_damages(brutehealing*0.4,burnhealing*0.4,toxhealing*0.4,oxyhealing*0.4) //60% less healing if with clothes if applicable.
		umsg_success += " as best as you can while they have clothing on" //space please, no period
		tmsg_success += " as best as they can while [target] has clothing on"
	display_results(user, target, "<span class='notice'>[umsg_success].</span>",
		"[tmsg_success].",
		"[tmsg_success].")
	if(istype(surgery, /datum/surgery/heal/four_damages))
		var/datum/surgery/heal/four_damages/the_surgery = surgery
		the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/heal/four_damages/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screwed up!</span>",
		"<span class='warning'>[user] screws up!</span>",
		"<span class='notice'>[user] fixes some of [target]'s [woundtype].</span>", TRUE)
	target.apply_damages(brutehealing*0.8,burnhealing*0.8,toxhealing*0.8,oxyhealing*0.8)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/heal/four_damages/brute
	name = "Tend Wounds (Bruises)"

/datum/surgery/heal/four_damages/brute/basic
	name = "Tend Wounds (Bruises, Basic)"
	replaced_by = /datum/surgery/heal/four_damages/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/four_damages/brute/basic
	desc = "A surgical procedure that provides basic treatment for a patient's brute traumas."

/datum/surgery/heal/four_damages/brute/upgraded
	name = "Tend Wounds (Bruises, Adv.)"
	replaced_by = /datum/surgery/heal/four_damages/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/brute/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's brute traumas."

/datum/surgery/heal/four_damages/brute/upgraded/femto
	name = "Tend Wounds (Bruises, Exp.)"
	replaced_by = /datum/surgery/heal/four_damages/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/brute/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's brute traumas."

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/four_damages/brute/basic
	name = "tend bruises"
	brutehealing = 5
	woundtype = "bruises"

/datum/surgery_step/heal/four_damages/brute/upgraded
	brutehealing = 10

/datum/surgery_step/heal/four_damages/brute/upgraded/femto
	brutehealing = 15

/***************************BURN***************************/
/datum/surgery/heal/four_damages/burn
	name = "Tend Wounds (Burn)"

/datum/surgery/heal/four_damages/burn/basic
	name = "Tend Wounds (Burn, Basic)"
	replaced_by = /datum/surgery/heal/four_damages/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/four_damages/burn/basic
	desc = "A surgical procedure that provides basic treatment for a patient's burns."

/datum/surgery/heal/four_damages/burn/upgraded
	name = "Tend Wounds (Burn, Adv.)"
	replaced_by = /datum/surgery/heal/four_damages/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/burn/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns."

/datum/surgery/heal/four_damages/burn/upgraded/femto
	name = "Tend Wounds (Burn, Exp.)"
	replaced_by = /datum/surgery/heal/four_damages/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/burn/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns."

/********************BURN STEPS********************/
/datum/surgery_step/heal/four_damages/burn/basic
	name = "tend burns"
	burnhealing = 5
	woundtype = "burns"

/datum/surgery_step/heal/four_damages/burn/upgraded
	burnhealing = 10

/datum/surgery_step/heal/four_damages/burn/upgraded/femto
	burnhealing = 15

/***************************TOX***************************/
/datum/surgery/heal/four_damages/tox
	name = "Cleanse Patient (Toxin)"

/datum/surgery/heal/four_damages/tox/basic
	name = "Cleanse Patient (Toxin, Basic)"
	replaced_by = /datum/surgery/heal/four_damages/tox/upgraded
	healing_step_type = /datum/surgery_step/heal/four_damages/tox/basic
	desc = "A primitive procedure that removes harmful toxins from the patient."

/datum/surgery/heal/four_damages/tox/upgraded
	name = "Cleanse Patient (Toxin, Adv.)"
	replaced_by = /datum/surgery/heal/four_damages/tox/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/tox/upgraded
	desc = "A procedure that removes harmful toxins from the patient. Also slowly purges reagents from the bloodstream."

/datum/surgery/heal/four_damages/tox/upgraded/femto
	name = "Cleanse Patient (Toxin, Exp.)"
	replaced_by = null
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/tox/upgraded/femto
	desc = "An experimental procedure that removes harmful toxins from the patient. Also slowly purges harmful reagents (including medicines with harmful side-effects) from the bloodstream."

/********************TOX STEPS********************/

/datum/surgery_step/heal/four_damages/tox
	name = "cleanse patient"
	implements = list(/obj/item/reagent_containers/glass = 100)
	accept_hand = TRUE

/datum/surgery_step/heal/four_damages/tox/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	umsg_success_override = "You cleanse [target] of their toxicity" //if only
	tmsg_success_override = "[user] cleanses toxins from [target]'s body"
	umsg_attempt_override = "You attempt to cleanse toxins from [target]'s body"
	tmsg_attempt_override = "[user] attempts to cleanse toxins from [target]'s body'"
	..()

/datum/surgery_step/heal/four_damages/tox/basic
	toxhealing = 2 //tox damage is uncommon compared to the B's

/datum/surgery_step/heal/four_damages/tox/upgraded
	toxhealing = 5
	var/harmfulsonly = FALSE //only purge chems with harmful set to TRUE

/datum/surgery_step/heal/four_damages/tox/upgraded/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	var/obj/item/reagent_containers/glass/glass_tool
	if(istype(tool, /obj/item/reagent_containers/glass))
		glass_tool = tool
	var/datum/reagents/the_targets_reagentholder = target.reagents
	for(var/i in the_targets_reagentholder.reagent_list)
		var/datum/reagent/ree = i
		if(!harmfulsonly || ree.harmful)
			the_targets_reagentholder.remove_reagent(ree,1)
		if(ree.harmful && (glass_tool?.reagent_flags & OPENCONTAINER)) //toxin is only produced if the chem is naughty or has harmful side-effects
			the_targets_reagentholder.add_reagent(/datum/reagent/toxin,0.1) //who would have thought purging toxins gives way to make a good toxinhealer???

/datum/surgery_step/heal/four_damages/tox/upgraded/femto
	toxhealing = 10
	harmfulsonly = TRUE

/***************************OXY***************************/
/datum/surgery/heal/four_damages/oxy
	name = "Breathe Life (Oxy)"

/datum/surgery/heal/four_damages/burn/basic
	name = "Breathe Life (Oxy, Basic)"
	replaced_by = /datum/surgery/heal/four_damages/oxy/upgraded
	healing_step_type = /datum/surgery_step/heal/four_damages/oxy/basic
	desc = "A procedure that mitigates the effects of asphyxiation."

/datum/surgery/heal/four_damages/oxy/upgraded
	name = "Breathe Life (Oxy, Adv.)"
	replaced_by = /datum/surgery/heal/four_damages/oxy/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/oxy/upgraded
	desc = "A procedure that provides advanced treatment for asphyxiation. The procedure will also return breathing levels to normal, but slowly."

/datum/surgery/heal/four_damages/oxy/upgraded/femto
	name = "Breathe Life (Oxy, Exp.)"
	replaced_by = null
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/oxy/upgraded/femto
	desc = "A procedure that provides experimental treatment for asphyxiation. The procedure will also return breathing levels to normal."

/********************OXY STEPS********************/
/datum/surgery_step/heal/four_damages/oxy/basic
	name = "open airways"
	oxyhealing = 4 //less common than Bs but more common than tox
	implements = list()
	accept_hand = TRUE

/datum/surgery_step/heal/four_damages/oxy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	umsg_success_override = "You open [target]'s' airways"
	tmsg_success_override = "[user] breathes life into [target]"
	umsg_attempt_override = "You attempt to open [target]'s airways"
	tmsg_attempt_override = "[user] attempts to breathe life into [target]'"
	..()

/datum/surgery_step/heal/four_damages/oxy/upgraded
	oxyhealing = 8
	var/losebreath_fixer = 1

/datum/surgery_step/heal/four_damages/oxy/upgraded/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	target.losebreath -= losebreath_fixer


/datum/surgery_step/heal/four_damages/oxy/upgraded/femto
	oxyhealing = 12
	losebreath_fixer = 3

/***************************COMBO***************************/
/datum/surgery/heal/four_damages/combo


/datum/surgery/heal/four_damages/combo
	name = "Tend Wounds (Mixture, Basic)"
	replaced_by = /datum/surgery/heal/four_damages/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/four_damages/combo
	desc = "A surgical procedure that provides basic treatment for a patient's burns and brute traumas."

/datum/surgery/heal/four_damages/combo/upgraded
	name = "Tend Wounds (Mixture, Adv.)"
	replaced_by = /datum/surgery/heal/four_damages/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/four_damages/combo/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns and brute traumas."


/datum/surgery/heal/four_damages/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	name = "Tend Wounds (Mixture, Exp.)"
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/four_damages/combo/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns and brute traumas."

/********************COMBO STEPS********************/
/datum/surgery_step/heal/four_damages/combo
	name = "tend physical wounds"
	brutehealing = 3
	burnhealing = 2
	time = 10

/datum/surgery_step/heal/four_damages/combo/upgraded
	brutehealing = 5
	burnhealing = 5

/datum/surgery_step/heal/four_damages/combo/upgraded/femto
	brutehealing = 8
	burnhealing = 7
