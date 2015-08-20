
/datum/borer_unlock
	var/id = "" // Used in prerequisites.
	var/name=""
	var/desc=""
	var/cost=0 // Chems to unlock
	var/time=0 // Time to unlock
	var/unlocked=1
	var/remove_on_detach=1

	var/list/prerequisites=list()

/datum/borer_unlock/proc/check_prerequisites(var/mob/living/simple_animal/borer/B)
	for(var/prereq in prerequisites)
		if(!(prereq in B.unlocked))
			return 0
	return 1

// INTERNAL: Begin unlocking process.
/datum/borer_unlock/proc/unlock(var/mob/living/simple_animal/borer/B)
	if(B.unlocking)
		return
	// Freeze borer
	B.unlocking=1
	B << "<span class='warning'>You begin concentrating intensely on producing the necessary changes.</span>"
	B << "<span class='danger'>You will be unable to use any borer abilities until the process completes.</span>"
	if(unlock_check(B))
		sleep(time) // do_after has too many human-specific checks that don't work on a glorified datum.
		            //  We don't have hands, and we can't control if the host moves.
		if(unlock_check(B))
			unlock_action(B)
			B.chemicals -= cost
	B.unlocking=0

	B << "<span class='info'>You finally finish your task.</span>"

// additional checks to perform when unlocking things.
/datum/borer_unlock/proc/unlock_check(var/mob/living/simple_animal/borer/B)
	return (B.chemicals >= cost)

/**
 * What to do when unlocked.
 */
/datum/borer_unlock/proc/unlock_action(var/mob/living/simple_animal/borer/B)
	return

/**
 * How to remove the unlockable (such as when detached)
 */
/datum/borer_unlock/proc/remove_action(var/mob/living/simple_animal/borer/B)
	return

/////////////////////////
// Borer unlocks

// CHEMS!
/datum/borer_unlock/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/borer_unlock/chem_unlock/unlock_action(var/mob/living/simple_animal/borer/B)
	var/datum/borer_chem/C = new chem_type()
	B.avail_chems[C.name]=C
	B << "<span class='info'>You learned how to secrete [C.name]!</span>"

/datum/borer_unlock/chem_unlock/inaprovaline
	id = "inaprovaline"
	name = "Inaprovaline Secretion"
	desc = "Learn how to synthesize inaprovaline."
	cost = 20
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/inaprovaline

/datum/borer_unlock/chem_unlock/space_drugs
	id = "space_drugs"
	name = "Space Drug Secretion"
	desc = "Learn how to synthesize space drugs."
	cost = 10
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/space_drugs

/datum/borer_unlock/chem_unlock/paracetamol
	id = "paracetamol"
	name = "Paracetamol Secretion"
	desc = "Learn how to synthesize painkillers."
	cost = 20
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/paracetamol

// Burn treatment research tree.
/datum/borer_unlock/chem_unlock/kelotane
	id = "kelotane"
	name = "Kelotane Secretion"
	desc = "Learn how to synthesize kelotane."
	cost = 20
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/kelotane

/datum/borer_unlock/chem_unlock/dermaline
	id = "dermaline"
	name = "Dermaline Secretion"
	desc = "Learn how to synthesize dermaline."
	cost = 30
	time = 20 SECONDS
	chem_type = /datum/borer_chem/unlockable/dermaline
	prerequisites=list("kelotane")

// Oxygen research tree
/datum/borer_unlock/chem_unlock/dexalin
	id = "dexalin"
	name = "Dexalin Secretion"
	desc = "Learn how to synthesize dexalin."
	cost = 20
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/dexalin

/datum/borer_unlock/chem_unlock/dexalinp
	id = "dexalinp"
	name = "Dexalin+ Secretion"
	desc = "Learn how to synthesize Dexalin+."
	cost = 30
	time = 20 SECONDS
	chem_type = /datum/borer_chem/unlockable/dexalinp
	prerequisites=list("dexalin")

// TODO: Ability to spray shit at people when outside of a host?

/////////////////////////////////
// HOST UNLOCKS
/////////////////////////////////

/datum/borer_unlock/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/borer_unlock/gene_unlock/unlock_action(var/mob/living/simple_animal/borer/B)

	// This is inefficient, but OK because it doesn't happen often.
	for(var/block=1;block<DNA_SE_LENGTH;block++)
		if(assigned_blocks[block] == gene_name)
			testing("  Found [assigned_blocks[block]] ([block])")
			var/mob/living/carbon/host=B.host
			if(host && host.dna)
				host.dna.SetSEState(block,activate)
				domutcheck(host,null,MUTCHK_FORCED)
				host.update_mutations()
				break

	B << "<span class='info'>You feel the genetic changes take hold in your host.</span>"

/datum/borer_unlock/gene_unlock/remove_action(var/mob/living/simple_animal/borer/B)
	// This is inefficient, but OK because it doesn't happen often.
	for(var/block=1;block<DNA_SE_LENGTH;block++)
		if(assigned_blocks[block] == gene_name)
			testing("  Found [assigned_blocks[block]] ([block])")
			var/mob/living/carbon/host=B.host
			if(host && host.dna)
				host.dna.SetSEState(block,!activate)
				domutcheck(host,null,MUTCHK_FORCED)
				host.update_mutations()
				break

// Metabolism tree
/datum/borer_unlock/gene_unlock/sober
	id = "sober"
	name = "Liver Function Boost"
	desc = "Your host's liver is able to handle massive quantities of alcohol."
	cost = 35
	time = 30 SECONDS
	gene_name = "SOBER"

/datum/borer_unlock/gene_unlock/run
	id = "run"
	name = "Enhanced Metabolism"
	desc = "Modifies your host to run faster."
	cost = 30
	time = 20 SECONDS
	gene_name = "INCREASERUN"
	prerequisites=list("sober")

// Vision tree
/datum/borer_unlock/gene_unlock/farsight
	id = "farsight"
	name = "Telephoto Vision"
	desc = "Adjusts your host's eyes to see farther."
	cost = 40
	time = 1 MINUTES
	gene_name = "FARSIGHT"

/datum/borer_unlock/gene_unlock/xray
	id = "run"
	name = "High-Energy Vision"
	desc = "Adjusts your host's eyes to see in the X-Ray spectrum."
	cost = 40
	time = 2 MINUTES
	gene_name = "XRAYBLOCK"
	prerequisites=list("farsight")