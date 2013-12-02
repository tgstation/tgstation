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