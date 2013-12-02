/**
* Gene Datum
*
* domutcheck was getting pretty hairy.  This is the solution.
*
* All genes are stored in a global variable to cut down on memory
* usage.
*
* @author N3X15 <nexisentertainment@gmail.com>
*/

/datum/dna/gene
	// Display name
	var/name="BASE GENE"

	// Probably won't get used but why the fuck not
	var/desc="Oh god who knows what this does."

	// Set in initialize()!
	//  What gene activates this?
	var/block=0

// Called when the gene is loaded by the game. Do initial setup here
/datum/dna/gene/proc/initialize()
	return

// Return 1 if we can activate
/datum/dna/gene/proc/can_activate(var/mob/M,var/list/old_mutations,var/flags)
	return 0

// Called when the gene activates.  Do your magic here.
/datum/dna/gene/proc/activate(var/mob/M)
	return


/////////////////////
// BASIC GENES
//
// These just chuck in a mutation and display a message.
//
// Gene is activated:
//  1. If mutation already exists in mob
//  2. If the probability roll succeeds
//  3. Activation is forced (done in domutcheck)
/////////////////////


/datum/dna/gene/basic
	name="BASIC GENE"

	// Mutation to give
	var/mutation=0

	// Activation probability
	var/activation_prob=45

	// Activation message
	var/activation_message=""

/datum/dna/gene/basic/can_activate(var/mob/M,var/list/old_mutations,var/flags)
	if(mutation==0)
		return 0

	// Mutation already set?
	if(mutation in old_mutations)
		return 1

	// Probability check
	if(probinj(activation_prob,(flags&MUTCHK_FROM_INJECTOR)))
		return 1

	return 0

/datum/dna/gene/basic/activate(var/mob/M)
	M.mutations.Add(mutation)
	M << "\blue [activation_message]"


/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability, or sdisability.
//
// Gene is always activated.
/////////////////////


/datum/dna/gene/disability
	name="DISABILITY"

	// Mutation to give (or 0)
	var/mutation=0

	// Disability to give (or 0)
	var/disability=0

	// SDisability to give (or 0)
	var/sdisability=0

	// Activation message
	var/activation_message=""

/datum/dna/gene/disability/can_activate(var/mob/M,var/list/old_mutations,var/flags)
	return 1 // Always set!

/datum/dna/gene/disability/activate(var/mob/living/carbon/M)
	if(mutation)
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(mutation)
		M.sdisabilities|=sdisability
	M << "\red [activation_message]"

/datum/dna/gene/disability/hallucinate
	name="Hallucinate"
	activation_message="Your mind says 'Hello'."
	mutation=mHallucination

	initialize()
		block=HALLUCINATIONBLOCK

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_message="You get a headache."
	disability=EPILEPSY

	initialize()
		block=HEADACHEBLOCK

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_message="You start coughing."
	disability=COUGHING

	initialize()
		block=COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_message="You feel lightheaded."
	mutation=CLUMSY

	initialize()
		block=CLUMSYBLOCK

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_message="You twitch."
	disability=TOURETTES

	initialize()
		block=TWITCHBLOCK

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_message="The walls suddenly disappear."
	mutation=XRAY

	initialize()
		block=XRAYBLOCK

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_message="You feel nervous."
	disability=NERVOUS

	initialize()
		block=NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_message="You can't seem to see anything."
	sdisability=BLIND

	initialize()
		block=BLINDBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_message="You feel smarter."
	mutation=TK
	activation_prob=15

	initialize()
		block=TELEBLOCK

/datum/dna/gene/disability/deaf
	name="Deafness"
	activation_message="It's kinda quiet."
	sdisability=DEAF

	initialize()
		block=DEAFBLOCK

	activate(var/mob/M)
		..(M)
		M.ear_deaf = 1

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_message="Your eyes feel weird..."
	disability=NEARSIGHTED

	initialize()
		block=GLASSESBLOCK