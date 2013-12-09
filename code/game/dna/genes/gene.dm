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

	// Any of a number of GENE_ flags.
	var/flags=0

// Return 1 if we can activate.
// HANDLE MUTCHK_FORCED HERE!
/datum/dna/gene/proc/can_activate(var/mob/M, var/flags)
	return 0

// Called when the gene activates.  Do your magic here.
/datum/dna/gene/proc/activate(var/mob/M, var/connected, var/flags)
	return

// Called when the gene deactivates.  Undo your magic here.
// Only called when the block is deactivated.
/datum/dna/gene/proc/deactivate(var/mob/M, var/connected, var/flags)
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

	// Possible activation messages
	var/list/activation_messages=list()

	// Possible deactivation messages
	var/list/deactivation_messages=list()

/datum/dna/gene/basic/can_activate(var/mob/M,var/flags)
	if(mutation==0)
		return 0

	// Probability check
	if(flags & MUTCHK_FORCED || probinj(activation_prob,(flags&MUTCHK_FORCED)))
		return 1

	return 0

/datum/dna/gene/basic/activate(var/mob/M)
	M.mutations.Add(mutation)
	if(activation_messages.len)
		var/msg = pick(activation_messages)
		M << "\blue [msg]"

/datum/dna/gene/basic/deactivate(var/mob/M)
	M.mutations.Remove(mutation)
	if(deactivation_messages.len)
		var/msg = pick(deactivation_messages)
		M << "\red [msg]"