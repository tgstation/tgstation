
//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

datum/reagent/medicine
	name = "Medicine"
	id = "medicine"

datum/reagent/medicine/on_mob_life(var/mob/living/M as mob)
	current_cycle++
	holder.remove_reagent(src.id, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

datum/reagent/medicine/ethylredoxrazine	// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72

datum/reagent/medicine/ethylredoxrazine/on_mob_life(var/mob/living/M as mob)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM)
	..()

datum/reagent/medicine/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	color = "#BBEDA4" // rgb: 187, 237, 164

datum/reagent/medicine/lipozine/on_mob_life(var/mob/living/M as mob)
	M.nutrition -= 10 * REAGENTS_METABOLISM
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()

datum/reagent/medicine/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

datum/reagent/medicine/hyperzine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		if(prob(5))
			M.emote(pick("twitch","blink_r","shiver"))
		M.status_flags |= GOTTAGOFAST
	..()

datum/reagent/medicine/hyperzine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(0.5*REM)
		M.losebreath++
	..()
	return

datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

datum/reagent/medicine/inaprovaline/on_mob_life(var/mob/living/M as mob)
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-0.5*REM)
		M.adjustBruteLoss(-0.5*REM)
		M.adjustFireLoss(-0.5*REM)
	if(M.oxyloss > 35)
		M.setOxyLoss(35)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	if(M.losebreath < 0)
		M.losebreath = 0
	M.adjustStaminaLoss(-0.5*REM)
	if(prob(20))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	..()
	return

datum/reagent/medicine/inaprovaline/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return

datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/kelotane/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.heal_organ_damage(0,2*REM)
	..()

datum/reagent/medicine/kelotane/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(3*REM)
	..()
	return

datum/reagent/medicine/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/dermaline/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
		M.heal_organ_damage(0,3*REM)
	..()

datum/reagent/medicine/dermaline/overdose_process(var/mob/living/M as mob)
	M.adjustBruteLoss(3*REM)
	M.adjustToxLoss(3*REM)
	..()
	return


datum/reagent/medicine/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/dexalin/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.adjustOxyLoss(-3*REM)
		if(M.losebreath >= 4)
			M.losebreath -= 2
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()

datum/reagent/medicine/dexalin/overdose_process(var/mob/living/M as mob)
	if(prob(50))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return


datum/reagent/medicine/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/dexalinp/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.adjustOxyLoss(-12)
		if(M.losebreath > 0)
			M.losebreath -= 2
		if(M.losebreath < 0)
			M.losebreath = 0
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()

datum/reagent/medicine/dexalinp/overdose_process(var/mob/living/M as mob)
	M.adjustStaminaLoss(2.5*REM)
	M.adjustToxLoss(2.5*REM)
	M.losebreath++
	..()
	return

datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/tricordrazine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		if(M.getOxyLoss() && prob(80))
			M.adjustOxyLoss(-1*REM)
		if(M.getBruteLoss() && prob(80))
			M.heal_organ_damage(1*REM,0)
		if(M.getFireLoss() && prob(80))
			M.heal_organ_damage(0,1*REM)
		if(M.getToxLoss() && prob(80))
			M.adjustToxLoss(-1*REM)
	..()
	return

datum/reagent/medicine/tricordrazine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(1.5*REM)
	M.adjustOxyLoss(1.5*REM)
	M.adjustBruteLoss(1.5*REM)
	M.adjustFireLoss(1.5*REM)
	..()
datum/reagent/medicine/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	description = "Dylovene is a broad-spectrum antitoxin."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/anti_toxin/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
		M.drowsyness = max(M.drowsyness-2*REM, 0)
		M.hallucination = max(0, M.hallucination - 5*REM)
		M.adjustToxLoss(-2*REM)
	..()
	return


datum/reagent/medicine/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/leporazine/on_mob_life(var/mob/living/M as mob)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/adminordrazine/on_mob_life(var/mob/living/carbon/M as mob)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.eye_covered = 0
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.sleeping = 0
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		if(D.severity == NONTHREAT)
			continue
		D.spread_text = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()
	return

datum/reagent/medicine/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Tiny machines capable of rapid cellular regeneration."

datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat various diseases."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/synaptizine/on_mob_life(var/mob/living/M as mob)
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(60))
		M.adjustToxLoss(1)
	..()
	return

datum/reagent/medicine/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/hyronalin/on_mob_life(var/mob/living/M as mob)
	M.radiation = max(M.radiation-3*REM,0)
	..()
	return

datum/reagent/medicine/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/arithrazine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.radiation = max(M.radiation-7*REM,0)
		M.adjustToxLoss(-1*REM)
		if(prob(15))
			M.take_organ_damage(1, 0)
	..()
	return

datum/reagent/medicine/alkysine
	name = "Alkysine"
	id = "alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/alkysine/on_mob_life(var/mob/living/M as mob)
	if(M != DEAD)
		M.adjustBrainLoss(-3*REM)
	..()
	return

datum/reagent/medicine/imidazoline
	name = "Imidazoline"
	id = "imidazoline"
	description = "Heals eye damage."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/imidazoline/on_mob_life(var/mob/living/M as mob)
	M.eye_blurry = max(M.eye_blurry-5 , 0)
	M.eye_blind = max(M.eye_blind-5 , 0)
	M.eye_covered = max(M.eye_covered-5 , 0)
	M.disabilities &= ~NEARSIGHT
	M.eye_stat = max(M.eye_stat-5, 0)
	..()
	return

datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	id = "inacusiate"
	description = "Heals ear damage."
	color = "#6600FF" // rgb: 100, 165, 255

datum/reagent/medicine/inacusiate/on_mob_life(var/mob/living/M as mob)
	M.setEarDamage(0,0)
	if(M.disabilities & DEAF)
		M.disabilities &= ~DEAF
	..()
	return

datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 60

datum/reagent/medicine/bicaridine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.heal_organ_damage(2*REM,0)
	..()
	return
datum/reagent/medicine/bicaridine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(3*REM)
	M.adjustOxyLoss(1.5*REM)
	..()
	return

datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/cryoxadone/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD && M.bodytemperature < 170)
		M.adjustCloneLoss(-2)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)
	..()
	return

datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' clones that get ejected early when used in conjunction with a cryo tube."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/clonexadone/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD && M.bodytemperature < 170)
		M.adjustCloneLoss(-4)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)
		M.status_flags &= ~DISFIGURED
	..()
	return

datum/reagent/medicine/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat cellular damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0

datum/reagent/medicine/rezadone/on_mob_life(var/mob/living/M as mob)
	switch(current_cycle)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1,1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2,1)
			M.status_flags &= ~DISFIGURED
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)

	..()
	return

datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antiviral agent."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM




//------------------------------------------------------------------------------------------------------
								//GOON MEDICINE
//------------------------------------------------------------------------------------------------------


datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "On touch, quickly heals burn damage. Basic anti-burn healing drug. On ingestion, deals minor toxin damage."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M))
		if((method == VAPOR || method == TOUCH || method == PATCH) && M.stat != DEAD)
			M.adjustFireLoss(-reac_volume)
			if(show_message)
				M << "<span class='notice'>You feel your burns healing!</span>"
			if(!M.stat)
				M.emote("scream")
		if(method == INGEST && M.stat != DEAD)
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				M << "<span class='notice'>You probably shouldn't have eaten that. Maybe you should of splashed it on, or applied a patch?</span>"
	..()
	return


datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "On touch, quickly heals brute damage. Basic anti-brute healing drug. On ingestion, deals minor toxin damage."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M))
		if((method == VAPOR || method == TOUCH || method == PATCH) && M.stat != DEAD)
			M.adjustBruteLoss(-reac_volume)
			if(show_message)
				M << "<span class='notice'>You feel your wounds knitting back together!</span>"
			if(!M.stat)
				M.emote("scream")
		if(method == INGEST && M.stat != DEAD)
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				M << "<span class='notice'>You feel kind of ill. Maybe you ate a medicine you shouldn't have?</span>"
	..()
	return

datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	description = "Has a 33% chance per metabolism cycle to heal brute and burn damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/salglu_solution/on_mob_life(var/mob/living/M as mob)
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM)
		M.adjustFireLoss(-0.5*REM)
	..()
	return
/*
datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	description = "Has a 100% chance of instantly healing brute and burn damage. One unit of the chemical will heal one point of damage. Touch application only."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/synthflesh/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume,var/show_message = 1)
	if(iscarbon(M))
		if(method == TOUCH)
			M.adjustBruteLoss(-1.5*volume)
			M.adjustFireLoss(-1.5*volume)
			if(show_message)
				M << "<span class='notice'>You feel your burns healing and your flesh knitting together!</span>"
	..()
	return

datum/reagent/medicine/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Heals toxin damage, and will also slowly remove any other chemicals."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/charcoal/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(-2*REM)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,1)
	..()
	return
*/
datum/reagent/medicine/omnizine  //I guess I'll keep this for the cruel OD
	name = "Omnizine"
	id = "omnizine"
	description = "Heals 1 of each damage type a cycle. If overdosed it will deal significant amounts of each damage type."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

datum/reagent/medicine/omnizine/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(-0.5*REM)
	M.adjustOxyLoss(-0.5*REM)
	M.adjustBruteLoss(-0.5*REM)
	M.adjustFireLoss(-0.5*REM)
	..()
	return

datum/reagent/medicine/omnizine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(1.5*REM)
	M.adjustOxyLoss(1.5*REM)
	M.adjustBruteLoss(1.5*REM)
	M.adjustFireLoss(1.5*REM)
	..()
	return

datum/reagent/medicine/calomel //
	name = "Calomel"
	id = "calomel"
	description = "Quickly purges the body of all chemicals. If your health is above 20, toxin damage is dealt. When you hit 20 health or lower, the damage will cease."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/calomel/on_mob_life(var/mob/living/M as mob)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,2.5)
	if(M.health > 20)
		M.adjustToxLoss(2.5*REM)
	..()
	return

datum/reagent/medicine/potass_iodide //
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "Reduces low radiation damage very effectively."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 2 * REAGENTS_METABOLISM

datum/reagent/medicine/potass_iodide/on_mob_life(var/mob/living/M as mob)
	if(M.radiation > 0)
		M.radiation--
	if(M.radiation < 0)
		M.radiation = 0
	..()
	return

datum/reagent/medicine/pen_acid //
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Reduces massive amounts of radiation and toxin damage while purging other chemicals from the body. Has a chance of dealing brute damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/pen_acid/on_mob_life(var/mob/living/M as mob)
	if(M.radiation > 0)
		M.radiation -= 4
	M.adjustToxLoss(-2*REM)
	if(prob(33))
		M.adjustBruteLoss(0.5*REM)
	if(M.radiation < 0)
		M.radiation = 0
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,2)
	..()
	return
/*
datum/reagent/medicine/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	description = "If you have less than 50 brute damage, it heals 0.25 unit. If overdosed it will deal 0.5 brute damage if the patient has less than 50 brute damage already."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

datum/reagent/medicine/sal_acid/on_mob_life(var/mob/living/M as mob)
	if(M.getBruteLoss() < 50)
		M.adjustBruteLoss(-0.25*REM)
	..()
	return

datum/reagent/medicine/sal_acid/overdose_process(var/mob/living/M as mob)
	if(M.getBruteLoss() < 50)
		M.adjustBruteLoss(0.5*REM)
	..()
	return

datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Quickly heals oxygen damage while slowing down suffocation. Great for stabilizing critical patients!"
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

datum/reagent/medicine/salbutamol/on_mob_life(var/mob/living/M as mob)
	M.adjustOxyLoss(-3*REM)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	..()
	return

datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "Heals suffocation damage so quickly that you could have a spacewalk, but it mutes your voice. Has a 33% chance of healing brute and burn damage per cycle as well."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

datum/reagent/medicine/perfluorodecalin/on_mob_life(var/mob/living/carbon/human/M as mob)
	M.adjustOxyLoss(-12*REM)
	M.silent = max(M.silent, 5)
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM)
		M.adjustFireLoss(-0.5*REM)
	..()
	return
*/
datum/reagent/medicine/ephedrine //
	name = "Ephedrine"
	id = "ephedrine"
	description = "Reduces stun times, increases run speed. If overdosed it will deal toxin and oxyloss damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 45
	addiction_threshold = 30

datum/reagent/medicine/ephedrine/on_mob_life(var/mob/living/M as mob)
	M.status_flags |= GOTTAGOFAST
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REM)
	..()
	return

datum/reagent/medicine/ephedrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(0.5*REM)
		M.losebreath++
	..()
	return

datum/reagent/medicine/ephedrine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(2*REM)
		M.losebreath += 2
	..()
	return
datum/reagent/medicine/ephedrine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(3*REM)
		M.losebreath += 3
	..()
	return
datum/reagent/medicine/ephedrine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(4*REM)
		M.losebreath += 4
	..()
	return
datum/reagent/medicine/ephedrine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(5*REM)
		M.losebreath += 5
	..()
	return

datum/reagent/medicine/diphenhydramine //
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Purges body of lethal Histamine and reduces jitteriness while causing minor drowsiness."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/diphenhydramine/on_mob_life(var/mob/living/M as mob)
	if(prob(50))
		M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent("histamine",1.5)
	..()
	return

datum/reagent/medicine/morphine //
	name = "Morphine"
	id = "morphine"
	description = "Will allow you to ignore slowdown from equipment and damage. Will eventually knock you out if you take too much. If overdosed it will cause jitteriness, dizziness, force the victim to drop items in their hands and eventually deal toxin damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = REAGENTS_METABOLISM //WAKE ME UP INSIDE
	overdose_threshold = 30
	addiction_threshold = 25


datum/reagent/medicine/morphine/on_mob_life(var/mob/living/M as mob)
	M.status_flags |= IGNORESLOWDOWN
	if(current_cycle >= 12) //CAN'T WAKE UP
		M.sleeping += 1
	..()
	return

datum/reagent/medicine/morphine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()
	return

datum/reagent/medicine/morphine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()
	return
datum/reagent/medicine/morphine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(1*REM)
		M.Dizzy(3)
		M.Jitter(3)
	..()
	return
datum/reagent/medicine/morphine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(2*REM)
		M.Dizzy(4)
		M.Jitter(4)
	..()
	return
datum/reagent/medicine/morphine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(3*REM)
		M.Dizzy(5)
		M.Jitter(5)
	..()
	return

datum/reagent/medicine/oculine
	name = "Oculine"
	id = "oculine"
	description = "Cures blindness and heals eye damage over time."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

datum/reagent/medicine/oculine/on_mob_life(var/mob/living/M as mob)
	if(M.eye_blind > 0 && current_cycle > 20)
		if(prob(30))
			M.eye_blind = 0
		else if(prob(80))
			M.eye_blind = 0
			M.eye_blurry = 1
		if(M.eye_blurry > 0)
			if(prob(80))
				M.eye_blurry = 0
	..()
	return

datum/reagent/medicine/atropine //
	name = "Atropine"
	id = "atropine"
	description = "If patients health is below -25 it will heal 1.5 brute and burn damage per cycle, as well as stop any oxyloss. Good for stabilising critical patients."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35

datum/reagent/medicine/atropine/on_mob_life(var/mob/living/M as mob)
	if(M.health > -60)
		M.adjustToxLoss(0.5*REM)
	if(M.health < -25)
		M.adjustBruteLoss(-1.5*REM)
		M.adjustFireLoss(-1.5*REM)
	if(M.oxyloss > 65)
		M.setOxyLoss(65)
	if(M.losebreath > 5)
		M.losebreath = 5
	if(prob(20))
		M.Dizzy(5)
		M.Jitter(5)
	..()
	return

datum/reagent/medicine/atropine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(0.5*REM)
	M.Dizzy(1)
	M.Jitter(1)
	..()
	return
/*
datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	description = "Reduces most of the knockout/stun effects, minor stamina regeneration buff. Attempts to stop you taking too much oxygen damage. If the patient is in low to severe crit, heals toxins, brute, and burn very effectively. Will not heal patients who are almost dead. If overdosed will stun and deal toxin damage"
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

datum/reagent/medicine/epinephrine/on_mob_life(var/mob/living/M as mob)
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-0.5*REM)
		M.adjustBruteLoss(-0.5*REM)
		M.adjustFireLoss(-0.5*REM)
	if(M.oxyloss > 35)
		M.setOxyLoss(35)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	if(M.losebreath < 0)
		M.losebreath = 0
	M.adjustStaminaLoss(-0.5*REM)
	if(prob(20))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	..()
	return

datum/reagent/medicine/epinephrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return
*/
datum/reagent/medicine/strange_reagent //
	name = "Strange Reagent"
	id = "strange_reagent"
	description = "A miracle drug that can bring a dead body back to life! If the corpse has suffered too much damage, however, no change will occur to the body. If used on a living person it will deal Brute and Burn damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/strange_reagent/reaction_mob(mob/living/carbon/human/M, method=TOUCH, reac_volume)
	if(M.stat == DEAD)
		if(M.getBruteLoss() >= 100 || M.getFireLoss() >= 100)
			M.visible_message("<span class='warning'>[M]'s body convulses a bit, and then falls still once more.</span>")
			return
		var/mob/dead/observer/ghost = M.get_ghost()
		M.visible_message("<span class='warning'>[M]'s body convulses a bit.</span>")
		if(!M.suiciding && !(NOCLONE in M.mutations))
			if(ghost)
				ghost << "<span class='ghostalert'>Someone is trying to revive you. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)"
				ghost << sound('sound/effects/genetics.ogg')
			else
				M.stat = 1
				M.adjustOxyLoss(-20)
				M.adjustToxLoss(-20)
				dead_mob_list -= M
				living_mob_list |= list(M)
				M.emote("gasp")
				add_logs(M, M, "revived", object="strange reagent")
	..()
	return

datum/reagent/medicine/strange_reagent/on_mob_life(var/mob/living/M as mob)
	M.adjustBruteLoss(0.5*REM)
	M.adjustFireLoss(0.5*REM)
	..()
	return


datum/reagent/medicine/ryetalyn //
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/ryetalyn/on_mob_life(mob/living/carbon/human/M)
	M.jitteriness = 0

	// Might need to update appearance for hulk etc.
	if(istype(M) && M.dna)
		M.dna.remove_all_mutations()
	..()
	return

datum/reagent/medicine/antihol //
	name = "Antihol"
	id = "antihol"
	description = "Helps remove Alcohol from someone's body, as well as eliminating its side effects."
	color = "#C8A5DC"

datum/reagent/medicine/antihol/on_mob_life(var/mob/living/M as mob)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM)
	..()

/datum/reagent/medicine/stimulants //
	name = "Stimulants"
	id = "stimulants"
	description = "Increases run speed and eliminates stuns, can heal minor damage. If overdosed it will deal toxin damage and stun."
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

datum/reagent/medicine/stimulants/on_mob_life(var/mob/living/M as mob)
	M.status_flags |= GOTTAGOFAST
	if(prob(33))
		M.adjustOxyLoss(-1*REM)
		M.adjustToxLoss(-1*REM)
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-2.5*REM)
	..()

datum/reagent/medicine/stimulants/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return

datum/reagent/medicine/insulin //
	name = "Insulin"
	id = "insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/insulin/on_mob_life(var/mob/living/M as mob)
	if(M.sleeping)
		M.sleeping--
	M.reagents.remove_reagent("sugar", 3)
	..()
	return
