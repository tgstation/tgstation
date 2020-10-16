/datum/surgery/transorbital_lobotomy
	name = "Transorbital Lobotomy"
	steps = list(/datum/surgery_step/pick, /datum/surgery_step/drive, /datum/surgery_step/tlobotomize, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_PRECISE_EYES)

/datum/surgery/transorbital_lobotomy/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/tlobotomize
	name = "perform transorbital lobotomy"
	implements = list(TOOL_ORBITOCLAST = 75, /obj/item/melee/transforming/energy/sword = 50, /obj/item/stack/rods = 10)
	time = 75

/datum/surgery_step/tlobotomize/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform a lobotomy on [target]'s brain...</span>",
		"<span class='notice'>[user] begins to perform a lobotomy on [target]'s brain.</span>",
		"<span class='notice'>[user] begins to perform surgery on [target]'s brain.</span>")
/datum/surgery_step/tlobotomize/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform a lobotomy on [target]'s brain...</span>",
		"<span class='notice'>[user] begins to perform a lobotomy on [target]'s brain.</span>",
		"<span class='notice'>[user] begins to perform surgery on [target]'s brain.</span>")

/datum/surgery_step/tlobotomize/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You succeed in lobotomizing [target].</span>",
			"<span class='notice'>[user] successfully lobotomizes [target]!</span>",
			"<span class='notice'>[user] completes the surgery on [target]'s brain.</span>")
	target.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	switch(rand(1,4))//Now let's see what hopefully-not-important part of the brain we cut off
		if(1)
			target.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(target, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
	return ..()

/datum/surgery_step/tlobotomize/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		display_results(user, target, "<span class='warning'>You remove the wrong part, causing more damage!</span>",
			"<span class='notice'>[user] successfully lobotomizes [target]!</span>",
			"<span class='notice'>[user] completes the surgery on [target]'s brain.</span>")
		B.applyOrganDamage(80)
		switch(rand(1,3))
			if(1)
				target.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
			if(2)
				if(HAS_TRAIT(target, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
					target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
				else
					target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
			if(3)
				target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.</span>", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE
