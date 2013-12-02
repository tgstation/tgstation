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