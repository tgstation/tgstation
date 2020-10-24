

//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	name = "Medicine"
	taste_description = "bitterness"

/datum/reagent/medicine/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(length(reagent_removal_skip_list))
		return
	holder.remove_reagent(type, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Leporazine will effectively regulate a patient's body temperature, ensuring it never leaves safe levels."
	color = "#DB90C6"

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > M.get_body_temp_normal(apply_change=FALSE))
		M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, M.get_body_temp_normal(apply_change=FALSE))
	else if(M.bodytemperature < (M.get_body_temp_normal(apply_change=FALSE) + 1))
		M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, M.get_body_temp_normal(apply_change=FALSE))
	..()

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#E0BB00" //golden for the gods
	can_synth = FALSE
	taste_description = "badmins"

// The best stuff there is. For testing/debugging.
/datum/reagent/medicine/adminordrazine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(type) * 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(type) * 1))
		mytray.adjustPests(-rand(1,5))
		mytray.adjustWeeds(-rand(1,5))
	if(chems.has_reagent(type, 3))
		switch(rand(100))
			if(66  to 100)
				mytray.mutatespecie()
			if(33	to 65)
				mytray.mutateweed()
			if(1   to 32)
				mytray.mutatepest(user)
			else if(prob(20))
				mytray.visible_message("<span class='warning'>Nothing happens...</span>")

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0, 0)
	M.setOxyLoss(0, 0)
	M.radiation = 0
	M.heal_bodypart_damage(5,5)
	M.adjustToxLoss(-5, 0, TRUE)
	M.hallucination = 0
	REMOVE_TRAITS_NOT_IN(M, list(SPECIES_TRAIT, ROUNDSTART_TRAIT, ORGAN_TRAIT))
	M.set_blurriness(0)
	M.set_blindness(0)
	M.SetKnockdown(0)
	M.SetStun(0)
	M.SetUnconscious(0)
	M.SetParalyzed(0)
	M.SetImmobilized(0)
	M.silent = FALSE
	M.dizziness = 0
	M.disgust = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.set_confusion(0)
	M.SetSleeping(0)
	M.jitteriness = 0
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = BLOOD_VOLUME_NORMAL

	M.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	for(var/organ in M.internal_organs)
		var/obj/item/organ/O = organ
		O.setOrganDamage(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == DISEASE_SEVERITY_POSITIVE)
			continue
		D.cure()
	..()
	. = 1

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rare and experimental particles, that apparently swap the user's body with one from an alternate dimension where it's completely healthy."
	taste_description = "science"

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Increases resistance to stuns as well as reducing drowsiness and hallucinations."
	color = "#FF00FF"

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustStun(-20)
	M.AdjustKnockdown(-20)
	M.AdjustUnconscious(-20)
	M.AdjustImmobilized(-20)
	M.AdjustParalyzed(-20)
	if(M.has_reagent(/datum/reagent/toxin/mindbreaker))
		M.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(M.has_reagent(/datum/reagent/toxin/mindbreaker))
		M.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	if(M.has_reagent(/datum/reagent/toxin/histamine))
		M.remove_reagent(/datum/reagent/toxin/histamine, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the patient's body temperature must be under 270K for it to metabolise correctly."
	color = "#0000C8"
	taste_description = "sludge"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/M)
	var/power = -0.00003 * (M.bodytemperature ** 2) + 3
	if(M.bodytemperature < T0C)
		M.adjustOxyLoss(-3 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-power, 0)
		M.adjustToxLoss(-power, 0, TRUE) //heals TOXINLOVERs
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (M.bodytemperature ** 2) + 0.5)
	..()

// Healing
/datum/reagent/medicine/cryoxadone/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.adjustHealth(round(chems.get_reagent_amount(type) * 3))
	mytray.adjustToxic(-round(chems.get_reagent_amount(type) * 3))

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "A chemical that derives from Cryoxadone. It specializes in healing clone damage, but nothing else. Requires very cold temperatures to properly metabolize, and metabolizes quicker than cryoxadone."
	color = "#3D3DC6"
	taste_description = "muscle"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < T0C)
		M.adjustCloneLoss(0.00006 * (M.bodytemperature ** 2) - 6, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (M.bodytemperature ** 2) + 0.75)
	..()

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "A mixture of cryoxadone and slime jelly, that apparently inverses the requirement for its activation."
	color = "#f7832a"
	taste_description = "spicy jelly"

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		var/power = 0
		switch(M.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(M.on_fire)
			power *= 2

		M.adjustOxyLoss(-2 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-1.5 * power, 0)
		M.adjustToxLoss(-power, 0, TRUE)
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds and restoring corpses husked by burns. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	taste_description = "fish"

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.heal_bodypart_damage(1,1)
	REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
	..()
	. = 1

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.Dizzy(5)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/medicine/rezadone/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return

	var/mob/living/carbon/patient = exposed_mob
	if(reac_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, BURN) && patient.getFireLoss() < UNHUSK_DAMAGE_THRESHOLD) //One carp yields 12u rezadone.
		patient.cure_husk(BURN)
		patient.visible_message("<span class='nicegreen'>[patient]'s body rapidly absorbs moisture from the environment, taking on a more healthy appearance.</span>")

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Spaceacillin will prevent a patient from conventionally spreading any diseases they are currently infected with. Also reduces infection in serious burns."
	color = "#E1F2E6"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Stimulates the healing of severe burns. Extremely rapidly heals severe burns and slowly heals minor ones. Overdose will worsen existing burns."
	reagent_state = LIQUID
	color = "#1E8BFF"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() > 25)
		M.adjustFireLoss(-4*REM, 0) //Twice as effective as AIURI for severe burns
	else
		M.adjustFireLoss(-0.5*REM, 0) //But only a quarter as effective for more minor ones
	..()
	. = 1

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/M)
	if(M.getFireLoss()) //It only makes existing burns worse
		M.adjustFireLoss(4.5*REM, FALSE, FALSE, BODYPART_ORGANIC) // it's going to be healing either 4 or 0.5
		. = 1
	..()

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Has a 33% chance per metabolism cycle to heal brute and burn damage. Can be used as a temporary blood substitute, as well as slowly speeding blood regeneration."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "sweetness and salt"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10	//So that normal blood regeneration can continue with salglu active
	var/extra_regen = 0.25 // in addition to acting as temporary blood, also add this much to their actual blood per tick

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/M)
	if(last_added)
		M.blood_volume -= last_added
		last_added = 0
	if(M.blood_volume < maximum_reachable)	//Can only up to double your effective blood level.
		var/amount_to_add = min(M.blood_volume, volume*5)
		var/new_blood_level = min(M.blood_volume + amount_to_add, maximum_reachable)
		last_added = new_blood_level - M.blood_volume
		M.blood_volume = new_blood_level + extra_regen
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
		. = TRUE
	..()

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/M)
	if(prob(3))
		to_chat(M, "<span class='warning'>You feel salty.</span>")
		holder.add_reagent(/datum/reagent/consumable/salt, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(prob(3))
		to_chat(M, "<span class='warning'>You feel sweet.</span>")
		holder.add_reagent(/datum/reagent/consumable/sugar, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(prob(33))
		M.adjustBruteLoss(0.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
		M.adjustFireLoss(0.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
		. = TRUE
	..()

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "A powerful painkiller. Restores bruising and burns in addition to making the patient believe they are fully healed. Also great for treating severe burn wounds in a pinch."
	reagent_state = LIQUID
	color = "#6D6374"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/C)
	C.hal_screwyhud = SCREWYHUD_HEALTHY
	C.adjustBruteLoss(-0.25*REM, 0)
	C.adjustFireLoss(-0.25*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/mine_salve/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(!iscarbon(exposed_mob) || (exposed_mob.stat == DEAD))
		return

	if(methods & (INGEST|VAPOR|INJECT))
		exposed_mob.adjust_nutrition(-5)
		if(show_message)
			to_chat(exposed_mob, "<span class='warning'>Your stomach feels empty and cramps!</span>")

	if(methods & (PATCH|TOUCH))
		var/mob/living/carbon/exposed_carbon = exposed_mob
		for(var/s in exposed_carbon.surgeries)
			var/datum/surgery/surgery = s
			surgery.speed_modifier = max(0.1, surgery.speed_modifier)

		if(show_message)
			to_chat(exposed_carbon, "<span class='danger'>You feel your injuries fade away to nothing!</span>" )

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = SCREWYHUD_NONE
	..()

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Slowly heals all damage types. Overdose will cause damage in all types instead."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	var/healing = 0.5

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-healing*REM, 0)
	M.adjustOxyLoss(-healing*REM, 0)
	M.adjustBruteLoss(-healing*REM, 0)
	M.adjustFireLoss(-healing*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M)
	M.adjustToxLoss(1.5*REM, 0)
	M.adjustOxyLoss(1.5*REM, 0)
	M.adjustBruteLoss(1.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustFireLoss(1.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

/datum/reagent/medicine/omnizine/protozine
	name = "Protozine"
	description = "A less environmentally friendly and somewhat weaker variant of omnizine."
	color = "#d8c7b7"
	healing = 0.2

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Quickly purges the body of all chemicals. Toxin damage is dealt if the patient is in good condition."
	reagent_state = LIQUID
	color = "#19C832"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "acid"

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,3)
	if(M.health > 20)
		M.adjustToxLoss(1*REM, 0)
		. = 1
	..()

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Efficiently restores low radiation damage."
	reagent_state = LIQUID
	color = "#BAA15D"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/M)
	if(M.radiation > 0)
		M.radiation -= min(M.radiation, 8)
	..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Reduces massive amounts of radiation and toxin damage while purging other chemicals from the body."
	reagent_state = LIQUID
	color = "#E6FFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/M)
	M.radiation -= max(M.radiation-RAD_MOB_SAFE, 0)/50
	M.adjustToxLoss(-2*REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,2)
	..()
	. = 1

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	description = "Stimulates the healing of severe bruises. Extremely rapidly heals severe bruising and slowly heals minor ones. Overdose will worsen existing bruising."
	reagent_state = LIQUID
	color = "#D2D2D2"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() > 25)
		M.adjustBruteLoss(-4*REM, 0)
	else
		M.adjustBruteLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/M)
	if(M.getBruteLoss()) //It only makes existing bruises worse
		M.adjustBruteLoss(4.5*REM, FALSE, FALSE, BODYPART_ORGANIC) // it's going to be healing either 4 or 0.5
		. = 1
	..()

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-3*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	..()
	. = 1

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Increases stun resistance and movement speed, giving you hand cramps. Overdose deals toxin damage and inhibits breathing."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25

/datum/reagent/medicine/ephedrine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)

/datum/reagent/medicine/ephedrine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	..()

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/M)
	if(prob(20) && iscarbon(M))
		var/obj/item/I = M.get_active_held_item()
		if(I && M.dropItemToGround(I))
			to_chat(M, "<span class='notice'>Your hands spaz out and you drop what you were holding!</span>")
			M.Jitter(10)

	M.AdjustAllImmobility(-20)
	M.adjustStaminaLoss(-1*REM, FALSE)
	..()
	return TRUE

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M)
	if(prob(2) && iscarbon(M))
		var/datum/disease/D = new /datum/disease/heart_failure
		M.ForceContractDisease(D)
		to_chat(M, "<span class='userdanger'>You're pretty sure you just felt your heart stop for a second there..</span>")
		M.playsound_local(M, 'sound/effects/singlebeat.ogg', 100, 0)

	if(prob(7))
		to_chat(M, "<span class='notice'>[pick("Your head pounds.", "You feel a tight pain in your chest.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]</span>")

	if(prob(33))
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	return TRUE

/datum/reagent/medicine/ephedrine/addiction_act_stage1(mob/living/M)
	if(prob(3) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(2*REM, 0)
		M.losebreath += 2
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage2(mob/living/M)
	if(prob(6) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(3*REM, 0)
		M.losebreath += 3
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage3(mob/living/M)
	if(prob(12) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(4*REM, 0)
		M.losebreath += 4
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage4(mob/living/M)
	if(prob(24) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(5*REM, 0)
		M.losebreath += 5
		. = 1
	..()

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Rapidly purges the body of Histamine and reduces jitteriness. Slight chance of causing drowsiness."
	reagent_state = LIQUID
	color = "#64FFE6"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.drowsyness += 1
	M.jitteriness -= 1
	M.remove_reagent(/datum/reagent/toxin/histamine,3)
	..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "A painkiller that allows the patient to move at full speed even when injured. Causes drowsiness and eventually unconsciousness in high doses. Overdose will cause a variety of effects, ranging from minor to lethal."
	reagent_state = LIQUID
	color = "#A9FBFB"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	..()

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= 5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "numb", /datum/mood_event/narcotic_medium, name)
	switch(current_cycle)
		if(11)
			to_chat(M, "<span class='warning'>You start to feel tired...</span>" )
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(40)
			. = 1
	..()

/datum/reagent/medicine/morphine/overdose_process(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Dizzy(2)
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(1*REM, 0)
		. = 1
		M.Dizzy(3)
		M.Jitter(3)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Dizzy(4)
		M.Jitter(4)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#404040" //oculine is dark grey, inacusiate is light grey
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "dull toxin"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	M.adjust_blindness(-2)
	M.adjust_blurriness(-2)
	if (!eyes)
		return
	eyes.applyOrganDamage(-2)
	if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
		if(prob(20))
			to_chat(M, "<span class='warning'>Your vision slowly returns...</span>")
			M.cure_blind(EYE_DAMAGE)
			M.cure_nearsighted(EYE_DAMAGE)
			M.blur_eyes(35)
	else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
		to_chat(M, "<span class='warning'>The blackness in your peripheral vision fades.</span>")
		M.cure_nearsighted(EYE_DAMAGE)
		M.blur_eyes(10)
	..()

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Rapidly repairs damage to the patient's ears to cure deafness, assuming the source of said deafness isn't from genetic mutations, chronic deafness, or a total defecit of ears." //by "chronic" deafness, we mean people with the "deaf" quirk
	color = "#606060" // ditto

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
	ears.adjustEarDamage(-4, -4)
	..()

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "If a patient is in critical condition, rapidly heals all damage types as well as regulating oxygen in the body. Excellent for stabilizing wounded patients."
	reagent_state = LIQUID
	color = "#1D3535" //slightly more blue, like epinephrine
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/M)
	if(M.health <= M.crit_threshold)
		M.adjustToxLoss(-2*REM, 0)
		M.adjustBruteLoss(-2*REM, 0)
		M.adjustFireLoss(-2*REM, 0)
		M.adjustOxyLoss(-5*REM, 0)
		. = 1
	M.losebreath = 0
	if(prob(20))
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/medicine/atropine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.5*REM, 0)
	. = 1
	M.Dizzy(1)
	M.Jitter(1)
	..()

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Very minor boost to stun resistance. Slowly heals damage if a patient is in critical condition, as well as regulating oxygen loss. Overdose causes weakness and toxin damage."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/epinephrine/on_mob_metabolize(mob/living/carbon/M)
	..()
	ADD_TRAIT(M, TRAIT_NOCRITDAMAGE, type)

/datum/reagent/medicine/epinephrine/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_NOCRITDAMAGE, type)
	..()

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/M)
	. = TRUE
	if(M.has_reagent(/datum/reagent/toxin/lexorin))
		M.remove_reagent(/datum/reagent/toxin/lexorin, 2)
		M.remove_reagent(/datum/reagent/medicine/epinephrine, 1)
		if(prob(20))
			M.reagents.add_reagent(/datum/reagent/toxin/histamine, 4)
		..()
		return
	if(M.health <= M.crit_threshold)
		M.adjustToxLoss(-0.5*REM, 0)
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
		M.adjustOxyLoss(-0.5*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	if(M.losebreath < 0)
		M.losebreath = 0
	M.adjustStaminaLoss(-0.5*REM, 0)
	if(prob(20))
		M.AdjustAllImmobility(-20)
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "A miracle drug capable of bringing the dead back to life. Works topically unless anotamically complex, in which case works orally. Only works if the target has less than 200 total brute and burn damage and hasn't been husked and requires more reagent depending on damage inflicted. Causes damage to the living."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "magnets"
	harmful = TRUE


// FEED ME SEYMOUR
/datum/reagent/medicine/strange_reagent/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.spawnplant()

/datum/reagent/medicine/strange_reagent/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(exposed_mob.stat != DEAD)
		return ..()
	if(exposed_mob.suiciding) //they are never coming back
		exposed_mob.visible_message("<span class='warning'>[exposed_mob]'s body does not react...</span>")
		return
	if(iscarbon(exposed_mob) && !(methods & INGEST)) //simplemobs can still be splashed
		return ..()
	var/amount_to_revive = round((exposed_mob.getBruteLoss()+exposed_mob.getFireLoss())/20)
	if(exposed_mob.getBruteLoss()+exposed_mob.getFireLoss() >= 200 || HAS_TRAIT(exposed_mob, TRAIT_HUSK) || reac_volume < amount_to_revive) //body will die from brute+burn on revive or you haven't provided enough to revive.
		exposed_mob.visible_message("<span class='warning'>[exposed_mob]'s body convulses a bit, and then falls still once more.</span>")
		exposed_mob.do_jitter_animation(10)
		return
	exposed_mob.visible_message("<span class='warning'>[exposed_mob]'s body starts convulsing!</span>")
	exposed_mob.notify_ghost_cloning("Your body is being revived with Strange Reagent!")
	exposed_mob.do_jitter_animation(10)
	var/excess_healing = 5*(reac_volume-amount_to_revive) //excess reagent will heal blood and organs across the board
	addtimer(CALLBACK(exposed_mob, /mob/living/carbon.proc/do_jitter_animation, 10), 40) //jitter immediately, then again after 4 and 8 seconds
	addtimer(CALLBACK(exposed_mob, /mob/living/carbon.proc/do_jitter_animation, 10), 80)
	addtimer(CALLBACK(exposed_mob, /mob/living.proc/revive, FALSE, FALSE, excess_healing), 79)
	..()

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/M)
	var/damage_at_random = rand(0,250)/100 //0 to 2.5
	M.adjustBruteLoss(damage_at_random*REM, FALSE)
	M.adjustFireLoss(damage_at_random*REM, FALSE)
	..()
	. = TRUE

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Efficiently restores brain damage."
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/C)
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2*REM)
	..()

//Having mannitol in you will pause the brain damage from brain tumor (so it heals an even 2 brain damage instead of 1.8)
/datum/reagent/medicine/mannitol/on_mob_metabolize(mob/living/carbon/C)
	. = ..()
	ADD_TRAIT(C, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)

/datum/reagent/medicine/mannitol/on_mob_end_metabolize(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	. = ..()

/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Reacts with neural tissue, helping reform damaged connections. Can cure minor traumas."
	color = "#C0C0C0" //ditto

/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/C)
	if(C.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		C.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5)
	if(prob(15))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Removes jitteriness and restores genetic defects."
	color = "#5096C8"
	taste_description = "acid"

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	if(M.has_dna())
		M.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA), TRUE)
	if(!QDELETED(M)) //We were a monkey, now a human
		..()

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects."
	color = "#00B4C8"
	taste_description = "raw egg"

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/M)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.set_confusion(0)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.drunkenness = max(H.drunkenness - 10, 0)
	..()
	. = 1

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	description = "Increases stun resistance and movement speed in addition to restoring minor damage and weakness. Overdose causes weakness and toxin damage."
	color = "#78008C"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

/datum/reagent/medicine/stimulants/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)

/datum/reagent/medicine/stimulants/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	..()

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/carbon/M)
	if(M.health < 50 && M.health > 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
	M.AdjustAllImmobility(-60)
	M.adjustStaminaLoss(-5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/stimulants/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#FFFFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/M)
	if(M.AdjustSleeping(-20))
		. = 1
	M.remove_reagent(/datum/reagent/consumable/sugar, 3)
	..()

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.

/datum/reagent/medicine/inaprovaline //is this used anywhere?
	name = "Inaprovaline"
	description = "Stabilizes the breathing of patients. Good for those in critical condition."
	reagent_state = LIQUID
	color = "#A4D8D8"

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/M)
	if(M.losebreath >= 5)
		M.losebreath -= 5
	..()

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy."
	reagent_state = LIQUID
	color = "#CC23FF"
	taste_description = "jelly"

/datum/reagent/medicine/regen_jelly/expose_mob(mob/living/exposed_mob, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob) || (reac_volume < 0.5))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	exposed_human.hair_color = "C2F"
	exposed_human.facial_hair_color = "C2F"
	exposed_human.update_hair()

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-1.5*REM, 0)
	M.adjustFireLoss(-1.5*REM, 0)
	M.adjustOxyLoss(-1.5*REM, 0)
	M.adjustToxLoss(-1.5*REM, 0, TRUE) //heals TOXINLOVERs
	..()
	. = 1

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Miniature medical robots that swiftly restore bodily damage."
	reagent_state = SOLID
	color = "#555555"
	overdose_threshold = 30

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-5*REM, 0) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REM, 0)
	M.adjustOxyLoss(-15, 0)
	M.adjustToxLoss(-5*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15*REM)
	M.adjustCloneLoss(-3*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/carbon/M) //wtb flavortext messages that hint that you're vomitting up robots
	if(prob(25))
		M.reagents.remove_reagent(type, metabolization_rate*15) // ~5 units at a rate of 0.4 but i wanted a nice number in code
		M.vomit(20) // nanite safety protocols make your body expel them to prevent harmies
	..()
	. = 1

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain. For some strange reason, it also induces temporary pacifism in those who imbibe it and semi-permanent pacifism in those who overdose on it."
	color = "#FFAF00"
	metabolization_rate = 0.4 //Math is based on specific metab rate so we want this to be static AKA if define or medicine metab rate changes, we want this to stay until we can rework calculations.
	overdose_threshold = 25

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/M)
	if(current_cycle <= 25) //10u has to be processed before u get into THE FUN ZONE
		M.adjustBruteLoss(-1 * REM, 0)
		M.adjustFireLoss(-1 * REM, 0)
		M.adjustOxyLoss(-0.5 * REM, 0)
		M.adjustToxLoss(-0.5 * REM, 0)
		M.adjustCloneLoss(-0.1 * REM, 0)
		M.adjustStaminaLoss(-0.5 * REM, 0)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM, 150) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	else
		M.adjustBruteLoss(-5 * REM, 0) //slow to start, but very quick healing once it gets going
		M.adjustFireLoss(-5 * REM, 0)
		M.adjustOxyLoss(-3 * REM, 0)
		M.adjustToxLoss(-3 * REM, 0)
		M.adjustCloneLoss(-1 * REM, 0)
		M.adjustStaminaLoss(-3 * REM, 0)
		M.jitteriness = min(max(0, M.jitteriness + 3), 30)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM, 150)
		if(prob(10))
			M.say(pick("Yeah, well, you know, that's just, like, uh, your opinion, man.", "Am I glad he's frozen in there and that we're out here, and that he's the sheriff and that we're frozen out here, and that we're in there, and I just remembered, we're out here. What I wanna know is: Where's the caveman?", "It ain't me, it ain't me...", "Make love, not war!", "Stop, hey, what's that sound? Everybody look what's going down...", "Do you believe in magic in a young girl's heart?"), forced = /datum/reagent/medicine/earthsblood)
	M.druggy = min(max(0, M.druggy + 10), 15) //See above
	..()
	. = 1

/datum/reagent/medicine/earthsblood/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/medicine/earthsblood/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	if(current_cycle > 25)
		M.adjustToxLoss(4 * REM, 0)
		if(current_cycle > 100) //podpeople get out reeeeeeeeeeeeeeeeeeeee
			M.adjustToxLoss(6 * REM, 0)
	if(iscarbon(M))
		var/mob/living/carbon/hippie = M
		hippie.gain_trauma(/datum/brain_trauma/severe/pacifism)
	..()
	. = 1

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Increases depletion rates for most stimulating/hallucinogenic drugs. Reduces druggy effects and jitteriness. Severe stamina regeneration penalty, causes drowsiness. Small chance of brain damage."
	reagent_state = LIQUID
	color = "#27870a"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/drug/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,5)
	M.drowsyness += 2
	if(M.jitteriness >= 3)
		M.jitteriness -= 3
	if (M.hallucination >= 5)
		M.hallucination -= 5
	if(prob(20))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1*REM, 50)
	M.adjustStaminaLoss(2.5*REM, 0)
	..()
	return TRUE

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Reduces the duration of unconciousness, knockdown and stuns. Restores stamina, but deals toxin damage when overdosed."
	color = "#C1151D"
	overdose_threshold = 30

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/M as mob)
	..()
	M.AdjustAllImmobility(-20)
	M.adjustStaminaLoss(-10, 0)
	M.Jitter(10)
	M.Dizzy(10)
	return TRUE

/datum/reagent/medicine/changelingadrenaline/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	L.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/changelingadrenaline/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	L.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	L.Dizzy(0)
	L.Jitter(0)

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/M as mob)
	M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Drastically increases movement speed, but deals toxin damage."
	color = "#AE151D"
	metabolization_rate = 1

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)
	..()

/datum/reagent/medicine/changelinghaste/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(2, 0)
	..()
	return TRUE

/datum/reagent/medicine/higadrite
	name = "Higadrite"
	description = "A medication utilized to treat ailing livers."
	color = "#FF3542"
	self_consuming = TRUE

/datum/reagent/medicine/higadrite/on_mob_metabolize(mob/living/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/higadrite/on_mob_end_metabolize(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/cordiolis_hepatico
	name = "Cordiolis Hepatico"
	description = "A strange, pitch-black reagent that seems to absorb all light. Effects unknown."
	color = "#000000"
	self_consuming = TRUE

/datum/reagent/medicine/cordiolis_hepatico/on_mob_add(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_STABLELIVER, type)
	ADD_TRAIT(M, TRAIT_STABLEHEART, type)

/datum/reagent/medicine/cordiolis_hepatico/on_mob_end_metabolize(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(M, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "A potent chemical that allows someone under its influence to be at full physical ability even when under massive amounts of pain."

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Long-lasting sleep suppressant that very slightly reduces stun and knockdown times. Overdosing has horrendous side effects and deals lethal oxygen damage, will knock you unconscious if not dealt with."
	reagent_state = LIQUID
	color = "#BEF7D8" // palish blue white
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "salt" // it actually does taste salty
	var/overdose_progress = 0 // to track overdose progress

/datum/reagent/medicine/modafinil/on_mob_metabolize(mob/living/M)
	ADD_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/M)
	if(!overdosed) // We do not want any effects on OD
		overdose_threshold = overdose_threshold + rand(-10,10)/10 // for extra fun
		M.AdjustAllImmobility(-5)
		M.adjustStaminaLoss(-0.5*REM, 0)
		M.Jitter(1)
		metabolization_rate = 0.01 * REAGENTS_METABOLISM * rand(5,20) // randomizes metabolism between 0.02 and 0.08 per tick
		. = TRUE
	..()

/datum/reagent/medicine/modafinil/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You feel awfully out of breath and jittery!</span>")
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.01 per tick on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/M)
	overdose_progress++
	switch(overdose_progress)
		if(1 to 40)
			M.jitteriness = min(M.jitteriness+1, 10)
			M.stuttering = min(M.stuttering+1, 10)
			M.Dizzy(5)
			if(prob(50))
				M.losebreath++
		if(41 to 80)
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
			M.jitteriness = min(M.jitteriness+1, 20)
			M.stuttering = min(M.stuttering+1, 20)
			M.Dizzy(10)
			if(prob(50))
				M.losebreath++
			if(prob(20))
				to_chat(M, "<span class='userdanger'>You have a sudden fit!</span>")
				M.emote("moan")
				M.Paralyze(20) // you should be in a bad spot at this point unless epipen has been used
		if(81)
			to_chat(M, "<span class='userdanger'>You feel too exhausted to continue!</span>") // at this point you will eventually die unless you get charcoal
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
		if(82 to INFINITY)
			M.Sleeping(100)
			M.adjustOxyLoss(1.5*REM, 0)
			M.adjustStaminaLoss(1.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Suppresses anxiety and other various forms of mental distress. Overdose causes hallucinations and minor toxin damage."
	reagent_state = LIQUID
	color = "#07E79E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/psicodine/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)

/datum/reagent/medicine/psicodine/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	..()

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(0, M.jitteriness-6)
	M.dizziness = max(0, M.dizziness-6)
	M.set_confusion(max(0, M.get_confusion()-6))
	M.disgust = max(0, M.disgust-6)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	if(mood != null && mood.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		mood.setSanity(min(mood.sanity+5, SANITY_NEUTRAL)) // set minimum to prevent unwanted spiking over neutral
	..()
	. = 1

/datum/reagent/medicine/psicodine/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	M.adjustToxLoss(1, 0)
	..()
	. = 1

/datum/reagent/medicine/metafactor
	name = "Mitogen Metabolism Factor"
	description = "This enzyme catalyzes the conversion of nutricious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	reagent_state = SOLID
	color = "#FFBE00"
	overdose_threshold = 10

/datum/reagent/medicine/metafactor/overdose_start(mob/living/carbon/M)
	metabolization_rate = 2  * REAGENTS_METABOLISM

/datum/reagent/medicine/metafactor/overdose_process(mob/living/carbon/M)
	if(prob(25))
		M.vomit()
	..()

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "A thistle derrived hepatoprotective flavolignan mixture that help reverse damage to the liver."
	reagent_state = SOLID
	color = "#FFFFD0"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -2)//Add a chance to cure liver trauma once implemented.
	..()
	. = 1

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "A purple mixture of short polyelectrolyte chains not easily synthesized in the laboratory. It is valued as an intermediate in the synthesis of the cutting edge pharmaceuticals."
	reagent_state = SOLID
	color = "#9423FF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "numbing bitterness"

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/M) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25)
	M.adjustBruteLoss(-0.35, 0)
	return TRUE

/datum/reagent/medicine/polypyr/expose_mob(mob/living/carbon/human/exposed_human, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_human) || (reac_volume < 0.5))
		return
	exposed_human.hair_color = "92f"
	exposed_human.facial_hair_color = "92f"
	exposed_human.update_hair()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5)
	..()
	. = 1

/datum/reagent/medicine/granibitaluri
	name = "Granibitaluri" //achieve "GRANular" amounts of C2
	description = "A mild painkiller useful as an additive alongside more potent medicines. Speeds up the healing of small wounds and burns, but is ineffective at treating severe injuries. Extremely large doses are toxic, and may eventually cause liver failure."
	color = "#E0E0E0"
	reagent_state = LIQUID
	overdose_threshold = 50
	metabolization_rate = 0.2 //same as C2s

/datum/reagent/medicine/granibitaluri/on_mob_life(mob/living/carbon/M)
	var/healamount = min(-0.5 + round(0.01 * (M.getBruteLoss() + M.getFireLoss()), 0.1), 0) //base of 0.5 healing per cycle and loses 0.1 healing for every 10 combined brute/burn damage you have
	M.adjustBruteLoss(healamount * REM, 0)
	M.adjustFireLoss(healamount * REM, 0)
	..()
	. = TRUE

/datum/reagent/medicine/granibitaluri/overdose_process(mob/living/M)
	. = TRUE
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.2 * REM)
	M.adjustToxLoss(0.2 * REM, 0) //Only really deadly if you eat over 100u
	..()

/datum/reagent/medicine/badstims  //These are bad for combat on purpose. Used in adrenal implant.
	name = "Experimental Stimulants"
	description = "Experimental Stimulants designed to get you away from trouble."
	reagent_state = LIQUID
	color = "#F5F5F5"

/datum/reagent/medicine/badstims/on_mob_life(mob/living/carbon/M)
	..()
	if(prob(30) && iscarbon(M))
		var/obj/item/I = M.get_active_held_item()
		if(I && M.dropItemToGround(I))
			to_chat(M, "<span class='notice'>Your hands spaz out and you drop what you were holding!</span>")
	M.adjustStaminaLoss(-10, 0)
	M.Jitter(10)
	M.Dizzy(15)

/datum/reagent/medicine/badstims/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/badstims)
	L.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/badstims/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/badstims)
	L.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	L.Dizzy(0)
	L.Jitter(0)

// helps bleeding wounds clot faster
/datum/reagent/medicine/coagulant
	name = "Sanguirite"
	description = "A proprietary coagulant used to help bleeding wounds clot faster."
	reagent_state = LIQUID
	color = "#bb2424"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 20
	/// How much base clotting we do per bleeding wound, multiplied by the below number for each bleeding wound
	var/clot_rate = 0.25
	/// If we have multiple bleeding wounds, we count the number of bleeding wounds, then multiply the clot rate by this^(n) before applying it to each cut, so more cuts = less clotting per cut (though still more total clotting)
	var/clot_coeff_per_wound = 0.75

/datum/reagent/medicine/coagulant/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!M.blood_volume || !M.all_wounds)
		return

	var/effective_clot_rate = clot_rate

	for(var/i in M.all_wounds)
		var/datum/wound/iter_wound = i
		if(iter_wound.blood_flow)
			effective_clot_rate *= clot_coeff_per_wound

	for(var/i in M.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.blood_flow = max(0, iter_wound.blood_flow - effective_clot_rate)

/datum/reagent/medicine/coagulant/overdose_process(mob/living/M)
	. = ..()
	if(!M.blood_volume)
		return

	if(prob(15))
		M.losebreath += rand(2,4)
		M.adjustOxyLoss(rand(1,3))
		if(prob(30))
			to_chat(M, "<span class='danger'>You can feel your blood clotting up in your veins!</span>")
		else if(prob(10))
			to_chat(M, "<span class='userdanger'>You feel like your blood has stopped moving!</span>")
			M.adjustOxyLoss(rand(3,4))

		if(prob(50))
			var/obj/item/organ/lungs/our_lungs = M.getorganslot(ORGAN_SLOT_LUNGS)
			our_lungs.applyOrganDamage(1)
		else
			var/obj/item/organ/heart/our_heart = M.getorganslot(ORGAN_SLOT_HEART)
			our_heart.applyOrganDamage(1)

// i googled "natural coagulant" and a couple of results came up for banana peels, so after precisely 30 more seconds of research, i now dub grinding banana peels good for your blood
/datum/reagent/medicine/coagulant/banana_peel
	name = "Pulped Banana Peel"
	description = "Ancient Clown Lore says that pulped banana peels are good for your blood, but are you really going to take medical advice from a clown about bananas?"
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "horribly stringy, bitter pulp"
	glass_name = "glass of banana peel pulp"
	glass_desc = "Ancient Clown Lore says that pulped banana peels are good for your blood, but are you really going to take medical advice from a clown about bananas?"
	metabolization_rate = REAGENTS_METABOLISM
	clot_coeff_per_wound = 0.6
