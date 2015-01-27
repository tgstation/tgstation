
#define REM REAGENTS_EFFECT_MULTIPLIER

//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

datum/reagent/medicine
	name = "Medicine"
	id = "medicine"

datum/reagent/medicine/on_mob_life(var/mob/living/M as mob)
	holder.remove_reagent(src.id, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

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
	if(!M) M = holder.my_atom ///This can even heal dead people.
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
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
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
datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	id = "inacusiate"
	description = "Heals ear damage."
	color = "#6600FF" // rgb: 100, 165, 255

datum/reagent/medicine/inacusiate/on_mob_life(var/mob/living/M as mob)
	M.setEarDamage(0,0)
	..()
	return

datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	color = "#0000C8"

datum/reagent/medicine/cryoxadone/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD && M.bodytemperature < 270)
		M.adjustCloneLoss(-4)
		M.adjustOxyLoss(-10)
		M.adjustBruteLoss(-3)
		M.adjustFireLoss(-3)
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
	if(!data)
		data = 1
	data++
	switch(data)
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


// Undefine the alias for REAGENTS_EFFECT_MULTIPLER
#undef REM