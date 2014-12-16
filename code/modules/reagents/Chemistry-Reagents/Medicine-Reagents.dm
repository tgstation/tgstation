
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

datum/reagent/medicine/ethylredoxrazine	// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72

datum/reagent/medicine/ethylredoxrazine/on_mob_life(var/mob/living/M as mob)
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1*REM, 0, 1)
	..()
	return

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

datum/reagent/medicine/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/hyperzine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		if(prob(5))
			M.emote(pick("twitch","blink_r","shiver"))
		M.status_flags |= GOTTAGOFAST
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

datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/inaprovaline/on_mob_life(var/mob/living/M as mob)
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)
	..()
	return

datum/reagent/medicine/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/ryetalyn/on_mob_life(var/mob/living/M as mob)

	var/needs_update = M.mutations.len > 0
	M.mutations = list()
	M.disabilities = 0
	M.sdisabilities = 0
	M.jitteriness = 0

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_mutations()
	..()
	return

datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/kelotane/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.heal_organ_damage(0,2*REM)
	..()
	return

datum/reagent/medicine/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/dermaline/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
		M.heal_organ_damage(0,3*REM)
	..()
	return

datum/reagent/medicine/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/dexalin/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.adjustOxyLoss(-2*REM)
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

datum/reagent/medicine/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/dexalinp/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.adjustOxyLoss(-M.getOxyLoss())
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	color = "#C8A5DC" // rgb: 200, 165, 220

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

datum/reagent/medicine/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	description = "Dylovene is a broad-spectrum antitoxin."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/anti_toxin/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.reagents.remove_all_type(/datum/reagent/toxin, 1*REM, 0, 1)
		M.drowsyness = max(M.drowsyness-2*REM, 0)
		M.hallucination = max(0, M.hallucination - 5*REM)
		M.adjustToxLoss(-2*REM)
	..()
	return

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
	M.sdisabilities = 0
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
	M.disabilities &= ~NEARSIGHTED
	M.eye_stat = max(M.eye_stat-5, 0)
//	M.sdisabilities &= ~1		Replaced by eye surgery
	..()
	return

datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	id = "inacusiate"
	description = "Heals ear damage."
	color = "#6600FF" // rgb: 100, 165, 255

datum/reagent/medicine/inacusiate/on_mob_life(var/mob/living/M as mob)
	M.ear_damage = 0
	M.ear_deaf = 0
	..()
	return

datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/bicaridine/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		M.heal_organ_damage(2*REM,0)
	..()
	return

datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/medicine/cryoxadone/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD && M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
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
		M.adjustCloneLoss(-3)
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