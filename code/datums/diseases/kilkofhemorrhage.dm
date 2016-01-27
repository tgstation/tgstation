/datum/disease/kilkofhemorrhage
	name = "Kilkof Hemorrhagic fever"
	max_stages = 21
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Spaceacillin, Morphine, and Saline Glucose solution"
	cures = list("spaceacillin", "morphine", "salglu_solution")
	agent = "Kilkof Unomegavirales"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 75//three reagents to cure. this is only balance
	desc = "A deadly slow acting, deadly virus. Incubates in victims, before afflicting them with debilitating symptoms over a long time, finally resulting in death."
	severity = DANGEROUS

/datum/disease/kilkofhemorrhage/stage_act()
	..()

	switch(stage)
		if(1, 2, 3, 4, 5)
			affected_mob << "<span class='notice'>[pick("You feel off.", "You feel really off.", "Your head feels off.", "Your mouth feels off.", "Your stomach feels off.", "Your chest feels off.")]</span>"
		if(6, 7, 8, 9, 10)

			if(prob(15))
				affected_mob << "<span class='warning'>[pick("Your head hurts.", "Your head starts pounding.")]</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>[pick("You feel cold.")]</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>[pick("Your stomach, hungers.", "You chew your nails in desperation.")]</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>[pick("You feel weak.", "You clutch at your abdomen and in pain.")]</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>Your eyes itch.</span>"
			if(prob(15))
				affected_mob << "<span class='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>"
		if(11, 12, 13, 14, 15)
			if(prob(5))
				affected_mob.bodytemperature += 40
				affected_mob << "<span class='warning'>[pick("You feel really hot.")]</span>"
			if(prob(5))
				affected_mob.bodytemperature -= 60
				affected_mob << "<span class='warning'>[pick("Your teeth start chittering from the cold.")]</span>"
			if(prob(5))
				affected_mob.vomit(20)
			if(prob(5))
				affected_mob.reagents.add_reagent("itching_powder", 30)
			if(prob(5))
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.nutrition = max(affected_mob.nutrition - 100, 0)
			if(prob(5))
				affected_mob.emote("cough")
				var/obj/item/I = affected_mob.get_active_hand()
				if(I && I.w_class == 1)
					affected_mob.drop_item()
		if(16, 17, 18, 19, 20)
			if(prob(10))
				affected_mob << "<span class='warning'><b>Your eyes burn!</b></span>"
				affected_mob.eye_blurry = 10
				affected_mob.eye_stat += 1
			if(prob(10))
				affected_mob << "<span class='userdanger'>Your eyes burn horrificly!</span>"
				affected_mob.eye_blurry = 20
				affected_mob.eye_stat += 5
				if (affected_mob.eye_stat >= 10)
					affected_mob.disabilities |= NEARSIGHT
					if (prob(M.eye_stat - 10 + 1) && !(affected_mob.eye_blind))
						affected_mob << "<span class='userdanger'>You go blind!</span>"
						affected_mob.disabilities |= BLIND
						affected_mob.eye_blind = 1
			if(prob(10))
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.nutrition = max(affected_mob.nutrition - 100, 0)
			if(prob(10))
				affected_mob << "<span class='userdanger'>[pick("You feel tremendously weak!", "Your body trembles as exhaustion creeps over you.")]</span>"
				affected_mob.adjustStaminaLoss(30)
				if(affected_mob.getStaminaLoss() > 60 && !affected_mob.stat)
					affected_mob.visible_message("<span class='warning'>[affected_mob] faints!</span>", "<span class='userdanger'>You swoon and faint...</span>")
					affected_mob.sleeping += 5
			if(prob(10))
				affected_mob << "<span class='userdanger'>You can't think straight!</span>"
				affected_mob.confused = min(100, affected_mob.confused + 40)
			if(prob(10))
				affected_mob.reagents.add_reagent("mutagen", 15)
				if(prob(33))
					affected_mob.reagents.add_reagent("mutagen", 15)
					if(prob(16))
						affected_mob.reagents.add_reagent("mutagen", 15)
			if(prob(10))
				affected_mob.reagents.add_reagent("heparin", 30)
		if(21)
			affected_mob.visible_message("<span class='warning'>[affected_mob] seizes up and begins violently shaking, as if he's going into shock!</span>")
			affected_mob.visible_message("<span class='warning'>[affected_mob] begins a chilling deathrattle, as if he's going into cardiac arrest!</span>")
			affected_mob.visible_message("<span class='warning'>[affected_mob] begins to foam at the mouth, as if his stomach is releasing acid!</span>")
			if (affected_mob.reagents.get_reagent_amount("initropidril, mutagen, lexorin, venom, pancuronium, curare, coniine, sacid") < 50)
				affected_mob.reagents.add_reagent("initropidril, mutagen, lexorin, venom, pancuronium, curare, coniine, sacid", 50)
	return

