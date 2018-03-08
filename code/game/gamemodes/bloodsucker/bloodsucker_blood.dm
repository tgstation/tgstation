/datum/reagent/blood/vampblood
	taste_description = "sweetness"
	metabolization_rate = 0.05  	// Blood is normally 5, which disappears fast.
	overdose_threshold = 9999		// Can't really OD.
	addiction_threshold = 10		// They always come back.
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
		// Ingest/Inject
		if(method in list(INGEST, INJECT)) // Types: TOUCH INGEST VAPOR INJECT PATCH
			if (M.mind && !M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) && M.stat != DEAD)
				M.adjustBruteLoss(-reac_volume) // Heal!
				if(show_message)
					to_chat(M, "<span class='danger'>A tingling warmth passes over you.</span>")
	..()



// On Metabolize:
/datum/reagent/blood/vampblood/on_mob_life(mob/living/M)
	// Bloodsuckers absorb this stuff instantly.
	if (M.mind && M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		volume = 0
		addiction_stage = 0
		overdosed = 0
		return

	M.adjustBruteLoss(-0.25, 0) // All heal values USED TO be multiplied by  * REM, the "REAGENTS_EFFECT_MULTIPLIER" found in reagents.dm. But comes up undefined here.
	M.adjustToxLoss(-0.1, 0)
	M.adjustBrainLoss(-0.05,0)

	M.adjustOxyLoss(-0.5, 0) 	// Better respiration.
	M.adjustStaminaLoss(-0.5,1)


	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		H.bleed_rate = max(H.bleed_rate - 0.2, 0)
	..()
	. = 1


///datum/reagent/blood/vampblood/overdose_start(mob/living/M)
//	to_chat(M, "<span class='userdanger'>Something changes. You suddenly feel a terrible craving for the immortal.</span>")
//	return

/datum/reagent/blood/vampblood/overdose_process(mob/living/M)
	//M.adjustStaminaLoss(1)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage1(mob/living/M)
	M.adjustStaminaLoss(3)
	M.Jitter(5)
	M.Dizzy(5)
	..()

/datum/reagent/blood/vampblood/addiction_act_stage2(mob/living/M)
	M.adjustStaminaLoss(3)
	M.adjustToxLoss(2, 0)
	M.Jitter(20)
	M.Dizzy(5)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage3(mob/living/M)
	M.adjustStaminaLoss(4)
	M.adjustBruteLoss(2, 0)
	M.Jitter(30)
	M.Dizzy(10)
	..()
	. = 1

/datum/reagent/blood/vampblood/addiction_act_stage4(mob/living/M)
	M.adjustStaminaLoss(5)
	M.adjustToxLoss(3, 0)
	M.adjustBruteLoss(3, 0)
	M.Jitter(50)
	M.Dizzy(15)
	..()
	. = 1




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/obj/effect/decal/cleanable/blood/vampblood// From objects/effects/decal/cleanable/humans.dm  &  cleanable.dm
	var/datum/mind/vamp_mind		// The Bloodsucker who made this puddle.
	//bloodiness = 10

	// VARIABLES for Reference:
	//name = "blood"
	//desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	//icon = 'icons/effects/blood.dmi'
	//icon_state = "floor1"
	//random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	//var/list/viruses = list()
	//blood_DNA = list()
	//blood_state = BLOOD_STATE_HUMAN
	//bloodiness = MAX_SHOE_BLOODINESS


/obj/effect/decal/cleanable/blood/vampblood/Initialize(mapload, datum/mind/bloodsucker, amount)
	..(mapload)
	bloodiness = amount * 10
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// LICK UP BLOOD PUDDLE //

/*
// DITCHED. There is no function for clicking a puddle with an empty hand. Just use a beaker to scoop up the blood anyway.
//
/obj/effect/decal/cleanable/blood/attack_self(mob/user)
	// Must be empty handed and "helping"
	message_admins("DEBUG1: attackby() [src] [user] ")
	if (user || user.a_intent != INTENT_HELP)
		return ..()
	message_admins("DEBUG2: attackby() [src] [user] ")
	// Lick it up. Lick it up off the floor!
	if (!do_mob(user, src, 30))
		return
	message_admins("DEBUG3: attackby() [src] [user] ")
	user.visible_message("<span class='notice'>[user] licks the [src] off the floor. What an idiot!</span>", \
					  "<span class='notice'>You lick the [src] from the floor.</span>")

	var/mob/living/carbon/C = user
	if(C.dna && C.dna.species && (DRINKSBLOOD in C.dna.species.species_traits))
		C.blood_volume = min(C.blood_volume + 0.5 + (bloodiness / 25), BLOOD_VOLUME_MAXIMUM)
	else
		C.reagents.add_reagent("toxin", 0.5 + bloodiness / 30)
		spawn()
			sleep(rand(50,300))
			C.vomit(5, 1, 0)  // (var/lost_nutrition = 10, var/blood = 0, var/stun = 1, var/distance = 0, var/message = 1, var/toxic = 0)

	qdel(src)
*/





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//	VAMPIRE LANGUAGE //

/datum/language/vampiric
	name = "Blah-Sucker"
	desc = "The native language of the Bloodsucker elders, learned intuitively by Fledglings as they pass from death into immortality."
	speech_verb = "growls"
	ask_verb = "growls"
	exclaim_verb = "snarls"
	whisper_verb = "hisses"
	key = "b"
	space_chance = 40
	default_priority = 90

	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD // Hide the icon next to your text if someone doesn't know this language.
	syllables = list(
		"luk","cha","no","kra","pru","chi","busi","tam","pol","spu","och",		// Start: Vampiric
		"umf","ora","stu","si","ri","li","ka","red","ani","lup","ala","pro",
		"to","siz","nu","pra","ga","ump","ort","a","ya","yach","tu","lit",
		"wa","mabo","mati","anta","tat","tana","prol",
		"tsa","si","tra","te","ele","fa","inz",									// Start: Romanian
		"nza","est","sti","ra","pral","tsu","ago","esch","chi","kys","praz",	// Start: Custom
		"froz","etz","tzil",
		"t'","k'","t'","k'","th'","tz'"
		)

	icon_state = "bloodsucker"

//datum/language
	//var/name = "an unknown language"  // Fluff name of language if any.
	//var/desc = "A language."          // Short description for 'Check Languages'.
	//var/speech_verb = "says"          // 'says', 'hisses', 'farts'.
	//var/ask_verb = "asks"             // Used when sentence ends in a ?
	//var/exclaim_verb = "exclaims"     // Used when sentence ends in a !
	//var/whisper_verb = "whispers"     // Optional. When not specified speech_verb + quietly/softly is used instead.
	//var/list/signlang_verb = list("signs", "gestures") // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	//var/key  							// If key is null, then the language isn't real or learnable.
	//var/flags                         // Various language flags.
	//var/list/syllables                // Used when scrambling text for a non-speaker.
	//var/sentence_chance = 5      // Likelihood of making a new sentence after each syllable.
	//var/space_chance = 55        // Likelihood of getting a space in the random scramble string
	//var/list/spans = list()
	//var/list/scramble_cache = list()
	//var/default_priority = 0          // the language that an atom knows with the highest "default_priority" is selected by default.

	// if you are seeing someone speak popcorn language, then something is wrong.
	//var/icon = 'icons/misc/language.dmi'
	//var/icon_state = "popcorn"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


