/datum/disease/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & Convermol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/c2/convermol)
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 2.5 //like hell are you getting out of hell
	desc = "A rare highly transmissible virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	required_organs = list(/obj/item/organ/lungs)
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.

/datum/disease/tuberculosis/stage_act(delta_time, times_fired) //it begins
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(1, delta_time))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>Your chest hurts.</span>")
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>Your stomach violently rumbles!</span>")
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a cold sweat form.</span>")
		if(4)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='userdanger'>You see four of everything!</span>")
				affected_mob.Dizzy(5)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a sharp pain from your lower chest!</span>")
				affected_mob.adjustOxyLoss(5, FALSE)
				affected_mob.emote("gasp")
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel air escape from your lungs painfully.</span>")
				affected_mob.adjustOxyLoss(25, FALSE)
				affected_mob.emote("gasp")
		if(5)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='userdanger'>[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]</span>")
				affected_mob.adjustStaminaLoss(70, FALSE)
			if(DT_PROB(5, delta_time))
				affected_mob.adjustStaminaLoss(100, FALSE)
				affected_mob.visible_message("<span class='warning'>[affected_mob] faints!</span>", "<span class='userdanger'>You surrender yourself and feel at peace...</span>")
				affected_mob.AdjustSleeping(100)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='userdanger'>You feel your mind relax and your thoughts drift!</span>")
				affected_mob.set_confusion(min(100, affected_mob.get_confusion() + 8))
			if(DT_PROB(5, delta_time))
				affected_mob.vomit(20)
			if(DT_PROB(1.5, delta_time))
				to_chat(affected_mob, "<span class='warning'><i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i></span>")
				affected_mob.overeatduration = max(affected_mob.overeatduration - (200 SECONDS), 0)
				affected_mob.adjust_nutrition(-100)
			if(DT_PROB(7.5, delta_time))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit...", "You feel like taking off some clothes...")]</span>")
				affected_mob.adjust_bodytemperature(40)
