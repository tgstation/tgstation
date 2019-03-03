/datum/disease/infectionminor
	name = "Minor Infection"
	max_stages = 3
	spread_text = "Open Wounds"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 100
	agent = "minor viron"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Feeds off dead cells and produces toxins. It can starve itself to death."
	severity = DISEASE_SEVERITY_MINOR

/datum/disease/infectionminor/stage_act()
	..()
	if(prob(stage*20))
		affected_mob.adjustToxLoss(stage/6)
		affected_mob.updatehealth()
	if(prob(5-stage))
		if(stage >= 2)
			to_chat(affected_mob, "<span class='notice'>You a tad bit better.</span>")
			stage--
		else
			to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
			cure()
	return

/datum/disease/infectionbad
	name = "Bad Infection"
	max_stages = 4
	spread_text = "Open Wounds"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "blood viron"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Feeds off blood cells and causes flu-like symptoms. The Immune system is currently fighting this off."
	severity = DISEASE_SEVERITY_MINOR

/datum/disease/infectionbad/stage_act()
	..()
	if(prob(stage*20))
		if(prob(50))
			to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
			affected_mob.take_bodypart_damage(1/4)
		else
			to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
			affected_mob.adjustToxLoss(stage/4)
		affected_mob.updatehealth()
	if(prob(5-stage))
		if(stage >= 2)
			to_chat(affected_mob, "<span class='notice'>You a tad bit better.</span>")
			stage--
		else
			to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
			cure()
	return

/datum/disease/infectionserious
	name = "Serious Infection"
	max_stages = 5
	spread_text = "Open Wounds"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 20
	agent = "immune viron"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Causes the immune system to overreact, attacking the Brain and filling the body with toxins. Fatal without treatment."
	severity = DISEASE_SEVERITY_MEDIUM

/datum/disease/infectionserious/stage_act()
	..()
	if(prob(stage*20))
		if(prob(50) && stage >= 3)
			to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			affected_mob.adjustBrainLoss(stage)
		else
			to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
			affected_mob.adjustToxLoss(stage/5)
		affected_mob.updatehealth()
	return

/datum/disease/infectionlethal
	name = "Lethal Infection"
	max_stages = 5
	spread_text = "Open Wounds"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 5
	agent = "necrosis viron"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Attacks the organs and limbs of it's victims and causes them to rot away. Fatal without treatment."
	severity = DISEASE_SEVERITY_DANGEROUS

/datum/disease/infectionlethal/stage_act()
	..()
	affected_mob.adjustToxLoss(stage/2.5)
	if(prob(6) && stage == 5) //limbs start falling off.
		affected_mob.adjustToxLoss(50)
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/C = affected_mob
			if(!istype(C.dna.species, /datum/species/krokodil_addict))
				to_chat(C, "<span class='userdanger'>Your skin begins rotting away!</span>")
				C.adjustBruteLoss(50, 0) // holy shit your skin just FELL THE FUCK OFF
				C.set_species(/datum/species/krokodil_addict)
			var/bodypart = pick("R_ARM","L_ARM","L_LEG","R_LEG","BRAIN")
			if(bodypart == "R_ARM")
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_R_ARM)
				if(BP)
					rot(BP,C)
			else if(bodypart == "L_ARM")
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_L_ARM)
				if(BP)
					rot(BP,C)
			else if(bodypart == "R_LEG")
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_R_LEG)
				if(BP)
					rot(BP,C)
			else if(bodypart == "L_LEG")
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_L_LEG)
				if(BP)
					rot(BP,C)
			else if(bodypart == "BRAIN")
				to_chat(affected_mob, "<span class='userdanger'>Your head REALLY hurts.</span>")
				affected_mob.adjustBrainLoss(50) //major drain bamage
	affected_mob.updatehealth()
	return

/datum/disease/infectionlethal/proc/rot(limb,mob)
	var/obj/item/bodypart/BP = limb
	var/mob/living/carbon/C = mob
	BP.drop_limb()
	C.visible_message("<span class='userdanger'>[C]'s [BP] blackens and rots off!</span>")
	BP.name = "Rotting [BP.name]"
	BP.brute_dam = 100
	BP.burn_dam = 100
	C.adjustToxLoss(40)
