/datum/reagent/blood/vampblood
	taste_description = "sweetness"
	metabolization_rate = 0.25  	// Blood is normally 5, which disappears fast.
	//overdose_threshold = 10
	addiction_threshold = 20		// They always come back.
	id = "vampblood"

		// NOTES:
		// holder.dm has most transfer procs.
		// reagents.dm has all basic reagent info.
		// other_reagents.dm contains the entry for the reagent "blood"
		// medicine_reagentsmedicine_reagents.dm has examples of medicine, addiction, and effects.

// On Contact:
/datum/reagent/blood/vampblood/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)

	// NOTE: If drinking from a container, this datum/reagent is actually the container itself.

	if(iscarbon(M))
		// Vamps don't benefit.
		//if (M.mind.bloodsuckerinfo)
			//if(show_message)
			//	to_chat(M, "<span class='warning'>You taste the presence of Vampiric blood.</span>")
		// Ingest/Inject
		// else
		if(method in list(INGEST, INJECT)) // Types: TOUCH INGEST VAPOR INJECT PATCH
			if (M.mind && !M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) && M.stat != DEAD)
				M.adjustBruteLoss(-reac_volume) // Heal!
				if(show_message)
					to_chat(M, "<span class='danger'>A tingling warmth passes over you.</span>")
		// Spray/Touch
		//else
		//	return 0

	..()



// On Metabolize:
/datum/reagent/blood/vampblood/on_mob_life(mob/living/M)
	// Bloodsuckers absorb this stuff instantly.
	if (M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		volume = 0
		addiction_stage = 0
		return
	M.adjustBruteLoss(-1, 0) // All heal values USED TO be multiplied by  * REM, the "REAGENTS_EFFECT_MULTIPLIER" found in reagents.dm. But comes up undefined here.
	M.adjustToxLoss(-1, 0)
	M.adjustBrainLoss(-0.5,0)
	M.adjustStaminaLoss(-1,0)
	..()
	. = 1


///datum/reagent/blood/vampblood/overdose_start(mob/living/M)
//	to_chat(M, "<span class='userdanger'>Something changes. You suddenly feel a terrible craving for the immortal.</span>")
//	return

/datum/reagent/blood/vampblood/overdose_process(mob/living/M)
	M.adjustStaminaLoss(1)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage1(mob/living/M)
	M.adjustStaminaLoss(3)
	M.Jitter(5)
	M.Dizzy(5)
	..()

/datum/reagent/blood/vampblood/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(4, 0)
	M.Jitter(5)
	M.Dizzy(5)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5, 0)
	M.Jitter(10)
	M.Dizzy(10)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage4(mob/living/M)
	M.adjustStaminaLoss(1)
	M.adjustToxLoss(1, 0)
	M.adjustBruteLoss(1, 0)
	M.Jitter(15)
	M.Dizzy(15)
	..()
	. = 1




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/obj/effect/decal/cleanable/blood/vampblood// From objects/effects/decal/cleanable/humans.dm  &  cleanable.dm
	var/datum/mind/vamp_mind		// The Bloodsucker who made this puddle.
	bloodiness = 10

	//name = "blood"
	//desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	//icon = 'icons/effects/blood.dmi'
	//icon_state = "floor1"
	//random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	//var/list/viruses = list()
	//blood_DNA = list()
	//blood_state = BLOOD_STATE_HUMAN
	//bloodiness = MAX_SHOE_BLOODINESS


/obj/effect/decal/cleanable/blood/vampblood/Initialize(mapload, datum/mind/bloodsucker)
	..(mapload)
	vamp_mind = bloodsucker
	var/datum/antagonist/bloodsucker/antagdatum = vamp_mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (antagdatum)
		antagdatum.desecrateBlood |= src


/obj/effect/decal/cleanable/blood/vampblood/proc/MatchToCreator(mob/living/caller)																// TO-DO: Apply diseases! The whole virus system changed.
	//vamp_creator = caller.mind
	transfer_mob_blood_dna(caller) // From cleanable blood in humans.dm
	//for(var/datum/disease/D in caller.viruses)
	//	var/datum/disease/ND = D.Copy(1)
	//	viruses += ND
	//	ND.holder = src

/obj/effect/decal/cleanable/blood/vampblood/Destroy()
	// Taken from crayon.dm
	//var/area/territory = get_area(src)
	if(vamp_mind)
		var/datum/antagonist/bloodsucker/antagdatum = vamp_mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		//message_admins("[vamp_mind] DEBUG BLOOD: Does SRC exist in desecrateBlood?")
		//if (vamp_creator.desecrateBlood & src)
		if (antagdatum)
			antagdatum.desecrateBlood -= src
			to_chat(vamp_mind.current, "You sense that your bloody desacration of the [get_area(src)] has been cleansed.")

	return ..()
