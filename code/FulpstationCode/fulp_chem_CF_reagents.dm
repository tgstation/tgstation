//Fulp T5 Trekkie Chems and Comebacks Rework
//@Author: Saliferous
#define REMF REAGENTS_EFFECT_MULTIPLIER

//FulpChem rework/addition of old chems to fix the potatofarm that is tg development -Love, Saliferous
/datum/reagent/medicine/CF
	harmful = FALSE

var/l_1 = 0
var/bic1 = 0
var/l_2 = 0
var/kel1 = 0
var/l_3 = 0
var/tox1 = 0
var/l_4 = 0
var/tri1 = 0
var/l_5 = 0
var/chr1 = 0

var/bicarHeal = 2
var/keloHeal = 2
var/toxHeal = 2
var/tricHeal = 2
//Trekkie Chems :  Uses discarded recipes with new lock-reagent to keep it T4/5
//Bicaridine (Brute Heal)
/datum/reagent/medicine/CF/bicaridine
	name = "Bicaridine"
	description = "Advanced Brute Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "#FF1744"
	metabolization_rate = 0.4
	overdose_threshold = 40

/datum/reagent/medicine/CF/bicaridine/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(INJECT))
			if(show_message)
				to_chat(M, "<span class='notice'>You hear a distant comms chirp as your bruises heal.</span>")
			l_1 = 1
			//for(var/datum/reagent/medicine/CF/bicaridine/bicar in M.reagents.reagent_list)

	..()
	. = 1

/datum/reagent/medicine/CF/bicaridine/on_mob_metabolize(mob/living/M)
	bic1 = 1
	. = ..()

/datum/reagent/medicine/CF/bicaridine/on_mob_end_metabolize(mob/living/M)
	bic1 = 0
	l_1 = 0
	. = ..()

/datum/reagent/medicine/CF/bicaridine/on_mob_life(mob/living/carbon/M)
	if(l_1 == 1 && bic1 == 1)
		M.adjustBruteLoss(-bicarHeal*REMF, 0)
	. = ..()

/datum/reagent/medicine/CF/bicaridine/overdose_process(mob/living/M)
	l_1 = 0	
	M.adjustBruteLoss(bicarHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//Kelotane (Burn Heal)
/datum/reagent/medicine/CF/kelotane
	name = "Kelotane"
	description = "Advanced Burn Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "#C7FB34"
	metabolization_rate = 0.4
	overdose_threshold = 40

/datum/reagent/medicine/CF/kelotane/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(INJECT))
			if(show_message)
				to_chat(M, "<span class='notice'>You hear a distant comms chirp as your burns heal.</span>")
			l_2 = 1
	..()
	. = 1

/datum/reagent/medicine/CF/kelotane/on_mob_metabolize(mob/living/M)
	kel1 = 1
	. = ..()

/datum/reagent/medicine/CF/kelotane/on_mob_end_metabolize(mob/living/M)
	kel1 = 0
	l_1 = 0
	. = ..()

/datum/reagent/medicine/CF/kelotane/on_mob_life(mob/living/carbon/M)
	if(l_2 == 1 && kel1 == 1)
		M.adjustFireLoss(-keloHeal*REMF, 0)
	. = ..()

/datum/reagent/medicine/CF/kelotane/overdose_process(mob/living/M)
	l_2 = 0	
	M.adjustFireLoss(keloHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1
		
//Anti-Toxin (Toxin Heal)
/datum/reagent/medicine/CF/antitoxin
	name = "Anti-Toxin"
	description = "Advanced Toxin Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "#33B20C"
	metabolization_rate = 0.4
	overdose_threshold = 40

/datum/reagent/medicine/CF/antitoxin/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(INJECT))
			if(show_message)
				to_chat(M, "<span class='notice'>You hear a distant comms chirp as your body purges itself of toxins.</span>")
			l_3 = 1
	..()
	. = 1

/datum/reagent/medicine/CF/antitoxin/on_mob_metabolize(mob/living/M)
	tox1 = 1
	. = ..()

/datum/reagent/medicine/CF/antitoxin/on_mob_end_metabolize(mob/living/M)
	tox1 = 0
	l_3 = 0
	. = ..()

/datum/reagent/medicine/CF/antitoxin/on_mob_life(mob/living/carbon/M)
	if(l_3 == 1 && tox1 == 1)
		M.adjustToxLoss(-toxHeal*REMF, 0)
	. = ..()

/datum/reagent/medicine/CF/antitoxin/overdose_process(mob/living/M)
	l_3 = 0	
	M.adjustToxLoss(toxHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//Tricordrazine (All-Heal)
/datum/reagent/medicine/CF/tricordrazine
	name = "Tricordrazine"
	description = "Advanced All-Heal. Injection only, Scotty."
	reagent_state = LIQUID
	color = "#FDDA08"
	metabolization_rate = 0.4
	overdose_threshold = 60

/datum/reagent/medicine/CF/tricordrazine/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(INJECT))
			if(show_message)
				to_chat(M, "<span class='notice'>You hear a distant comms chirp as your body heals all wounds.</span>")
			l_4 = 1
		
	..()
	. = 1

/datum/reagent/medicine/CF/tricordrazine/on_mob_metabolize(mob/living/M)
	tri1 = 1
	. = ..()

/datum/reagent/medicine/CF/bicaridine/on_mob_end_metabolize(mob/living/M)
	tri1 = 0
	l_4 = 0
	. = ..()

/datum/reagent/medicine/CF/bicaridine/on_mob_life(mob/living/carbon/M)
	if(l_4 == 1 && tri1 == 1)
		M.adjustBruteLoss(-tricHeal*REMF, 0)
		M.adjustFireLoss(-tricHeal*REMF, 0)
		M.adjustToxLoss(-tricHeal*REMF, 0)
		M.adjustOxyLoss(-tricHeal*REMF, 0)
	. = ..()

/datum/reagent/medicine/CF/tricordrazine/overdose_process(mob/living/M)
	l_4 = 0	
	M.adjustBruteLoss(tricHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustFireLoss(tricHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustToxLoss(tricHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustOxyLoss(tricHeal*REMF, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//End Trek Chems

//Charcoal (Toxin Heal / Chem Purge)
/datum/reagent/medicine/CF/charcoal
	name = "Charcoal"
	description = "Reduces toxin damage and purges the body of all chemical reagents, both good and bad."
	reagent_state = SOLID
	metabolization_rate = 0.2

/datum/reagent/medicine/CF/charcoal/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(show_message)
			to_chat(M, "<span class='notice'>You taste chalky powder, it isn't great...</span>")
		l_5 = 1
	..()
	return TRUE

/datum/reagent/medicine/CF/charcoal/on_mob_metabolize(mob/living/M)
	chr1 = 1
	. = ..()

/datum/reagent/medicine/CF/charcoal/on_mob_end_metabolize(mob/living/M)
	chr1 = 0
	l_5 = 0
	. = ..()

/datum/reagent/medicine/CF/charcoal/on_mob_life(mob/living/carbon/M)
	if(l_5 == 1 && chr1 == 1)
		M.adjustToxLoss(-2.0*REMF, 0)
		for(var/datum/reagent/R in M.reagents.reagent_list)
			M.reagents.remove_reagent(R.type, 0.5)
	. = ..()

//Synthflesh Re-add, combo brute/burn. Retains old recipe.
/*
/datum/reagent/medicine/CF/synthflesh
	name = "Synthflesh"
	description = "Has a 100% chance of instantly healing brute and burn damage at the cost of toxicity (75% of damage healed). Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/CF/synthflesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1)
	if(iscarbon(M))
		var/mob/living/carbon/Carbies = M
		if (Carbies.stat == DEAD)
			show_message = 0
		if(method in list(PATCH, TOUCH))
			var/harmies = min(Carbies.getBruteLoss(),Carbies.adjustBruteLoss(-1.25 * reac_volume)*-1)
			var/burnies = min(Carbies.getFireLoss(),Carbies.adjustFireLoss(-1.25 * reac_volume)*-1)
			Carbies.adjustToxLoss((harmies+burnies)*0.75)
			if(show_message)
				to_chat(Carbies, "<span class='danger'>You feel your burns and bruises healing! It stings like hell!</span>")
			SEND_SIGNAL(Carbies, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()
	return TRUE
*/
//Perfluorodecalin Re-add (Oxy Heal) Retains old recipe
//**Commented-out as Convermol is just Perfluorodecalin with a new name**
/*/datum/reagent/medicine/CF/perfluorodecalin
	name = "Perfuorodecalin"
	description = "Converts 5u of Suffocation damage to 2u of Toxin damage per tick, also gives 0.2u of Toxin damage per tick."
	reagent_state = LIQUID
	color = "9A1000"
	metabolization_rate = 0.1
	overdose_threshold = 35

/datum/reagent/medicine/CF/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	if(iscarbon(M))
		for(OXYLOSS >= 5)
			M.adjustOxyLoss(-5.0*REMF, 0)
			M.adjustToxLoss(2.0*REMF, 0)
			M.adjustToxLoss(0.2*REMF, 0)
		for(OXYLOSS < 5)
			M.adjustOxyLoss(-5.0*REMF, 0)
			M.adjustToxLoss((OXYLOSS/2.5)*REMF, 0)
			M.adjustToxLoss(0.2*REMF, 0)
	..()
	return TRUE

/datum/reagent/medicine/CF/perfluorodecalin/overdose_process(mob/living/M)
	if(iscarbon(M))
		for(OXYLOSS >= 5)
			M.adjustOxyLoss(-5.0*REMF, 0)
			M.adjustToxLoss(2.0*REMF, 0)
			M.adjustToxLoss(1*REMF, 0)
		for(OXYLOSS < 5)
			M.adjustOxyLoss(-5.0*REMF, 0)
			M.adjustToxLoss((OXYLOSS/2.5)*REMF, 0)
			M.adjustToxLoss(1*REMF, 0)
	..()
	return TRUE
*/

//Styptic Powder (Brute Heal) Retains old recipe
/datum/reagent/medicine/CF/styptic
	name = "Styptic Powder"
	description = "If used in touch-based applications, immediately restores bruising as well as restoring more over time. If ingested through other means or overdosed, deals minor toxin damage."
	reagent_state = LIQUID
	color = "#FF9696"
	overdose_threshold = 45

/datum/reagent/medicine/CF/styptic/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(M, "<span class='warning'> You don't feel so good...</span>")
		else if(M.getBruteLoss())
			M.adjustBruteLoss(-reac_volume)
			if(show_message)
				to_chat(M, "<span class='danger'> You feel your bruises healing! It stings like hell!</span>")
				M.emote("scream")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()

/datum/reagent/medicine/CF/styptic/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-2*REMF, 0)
	..()
	.=1

/datum/reagent/medicine/CF/styptic/overdose_process(mob/living/M)
	M.adjustBruteLoss(2.5*REMF, 0)
	M.adjustToxLoss(0.5, 0)
	..()
	.=1

//Silver Sulfadiazine (Burn Heal) Retains old recipe
/datum/reagent/medicine/CF/silver_sulfadiazine
    name = "Silver Sulfadiazine"
    description = "If used in touch-based applications, immediately restores burn wounds as well as restoring more over time. If ingested through other means or overdosed, deals minor toxin damage."
    reagent_state = LIQUID
    color = "#C8A5DC"
    overdose_threshold = 45

/datum/reagent/medicine/CF/silver_sulfadiazine/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
    if(iscarbon(M) && M.stat != DEAD)
        if(method in list(INGEST, VAPOR, INJECT))
            M.adjustToxLoss(0.5*reac_volume)
            if(show_message)
                to_chat(M, "<span class='warning'>You don't feel so good...</span>")
        else if(M.getFireLoss())
            M.adjustFireLoss(-reac_volume)
            if(show_message)
                to_chat(M, "<span class='danger'>You feel your burns healing! It stings like hell!</span>")
            M.emote("scream")
            SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
    ..()

/datum/reagent/medicine/CF/silver_sulfadiazine/on_mob_life(mob/living/carbon/M)
    M.adjustFireLoss(-2*REMF, 0)
    ..()
    . = 1

/datum/reagent/medicine/CF/silver_sulfadiazine/overdose_process(mob/living/M)
    M.adjustFireLoss(2.5*REMF, 0)
    M.adjustToxLoss(0.5, 0)
    ..()
    . = 1

//REEE-starting those trek chems here
//Trekamol, that locking reagent required to make any of the trek chems
/datum/reagent/medicine/CF/trekamol
	name = "Trekamol"
	description = "A space-worthy activator for advanced chemicals."
	reagent_state = LIQUID
	color = "#00F9FF"
