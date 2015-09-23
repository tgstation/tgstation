/datum/research_tree/borer
	title="Evolutions"
	blurb="Select which path to evolve."

	var/mob/living/simple_animal/borer/borer

/datum/research_tree/borer/New(var/mob/living/simple_animal/borer/B)
	borer=B

/datum/research_tree/borer/get_avail_unlocks()
	return borer_avail_unlocks

/datum/unlockable/borer
	cost_units = "C"
	var/remove_on_detach=1
	var/mob/living/simple_animal/borer/borer

/datum/unlockable/borer/set_context(var/datum/research_tree/borer/T)
	..(T)
	borer=T.borer

// INTERNAL: Begin unlocking process.
/datum/unlockable/borer/begin_unlock()
	borer << "<span class='warning'>You begin concentrating intensely on producing the necessary changes.</span>"
	borer << "<span class='danger'>You will be unable to use any borer abilities until the process completes.</span>"

/datum/unlockable/borer/end_unlock()
	//Redundant borer << "<span class='info'>You finally finish your task.</span>"
	borer.chemicals -= cost

// additional checks to perform when unlocking things.
/datum/unlockable/borer/unlock_check()
	return (borer.chemicals >= cost)

/datum/unlockable/borer/can_buy()
	return ..() && borer.host && !borer.stat && !borer.controlling && borer.host.stat != DEAD


/////////////////////////
// Borer unlocks

// CHEMS!
/datum/unlockable/borer/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	borer << "<span class='info'>You learned how to secrete [C.name]!</span>"

/datum/unlockable/borer/chem_unlock/inaprovaline
	id = "inaprovaline"
	name = "Inaprovaline Secretion"
	desc = "Learn how to synthesize inaprovaline."
	cost = 100
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/inaprovaline

/datum/unlockable/borer/chem_unlock/space_drugs
	id = "space_drugs"
	name = "Space Drug Secretion"
	desc = "Learn how to synthesize space drugs."
	cost = 50
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/space_drugs

/datum/unlockable/borer/chem_unlock/paracetamol
	id = "paracetamol"
	name = "Paracetamol Secretion"
	desc = "Learn how to synthesize painkillers."
	cost = 100
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/paracetamol

// Burn treatment research tree.
/datum/unlockable/borer/chem_unlock/kelotane
	id = "kelotane"
	name = "Kelotane Secretion"
	desc = "Learn how to synthesize kelotane."
	cost = 100
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/kelotane

/datum/unlockable/borer/chem_unlock/dermaline
	id = "dermaline"
	name = "Dermaline Secretion"
	desc = "Learn how to synthesize dermaline."
	cost = 150
	time = 20 SECONDS
	chem_type = /datum/borer_chem/unlockable/dermaline
	prerequisites=list("kelotane")

// Oxygen research tree
/datum/unlockable/borer/chem_unlock/dexalin
	id = "dexalin"
	name = "Dexalin Secretion"
	desc = "Learn how to synthesize dexalin."
	cost = 100
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/dexalin

/datum/unlockable/borer/chem_unlock/dexalinp
	id = "dexalinp"
	name = "Dexalin+ Secretion"
	desc = "Learn how to synthesize Dexalin+."
	cost = 150
	time = 20 SECONDS
	chem_type = /datum/borer_chem/unlockable/dexalinp
	prerequisites=list("dexalin")

// TODO: Ability to spray shit at people when outside of a host?

/////////////////////////////////
// HOST UNLOCKS
/////////////////////////////////

/datum/unlockable/borer/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/unlockable/borer/gene_unlock/unlock_action()
	// This is inefficient, but OK because it doesn't happen often.
	for(var/block=1;block<DNA_SE_LENGTH;block++)
		if(assigned_blocks[block] == gene_name)
			testing("  Found [assigned_blocks[block]] ([block])")
			var/mob/living/carbon/host=borer.host
			if(host && host.dna)
				host.dna.SetSEState(block,activate)
				domutcheck(host,null,MUTCHK_FORCED)
				host.update_mutations()
				break

	borer << "<span class='info'>You feel the genetic changes take hold in your host.</span>"

/datum/unlockable/borer/gene_unlock/remove_action()
	// This is inefficient, but OK because it doesn't happen often.
	for(var/block=1;block<DNA_SE_LENGTH;block++)
		if(assigned_blocks[block] == gene_name)
			testing("  Found [assigned_blocks[block]] ([block])")
			var/mob/living/carbon/host=borer.host
			if(host && host.dna)
				host.dna.SetSEState(block,!activate)
				domutcheck(host,null,MUTCHK_FORCED)
				host.update_mutations()
				break

// Metabolism tree
/datum/unlockable/borer/gene_unlock/sober
	id = "sober"
	name = "Liver Function Boost"
	desc = "Your host's liver is able to handle massive quantities of alcohol."
	cost = 200
	time = 30 SECONDS
	gene_name = "SOBER"

/datum/unlockable/borer/gene_unlock/run
	id = "run"
	name = "Enhanced Metabolism"
	desc = "Modifies your host to run faster."
	cost = 150
	time = 20 SECONDS
	gene_name = "INCREASERUN"
	prerequisites=list("sober")

// Vision tree
/datum/unlockable/borer/gene_unlock/farsight
	id = "farsight"
	name = "Telephoto Vision"
	desc = "Adjusts your host's eyes to see farther."
	cost = 200
	time = 1 MINUTES
	gene_name = "FARSIGHT"

/datum/unlockable/borer/gene_unlock/xray
	id = "run"
	name = "High-Energy Vision"
	desc = "Adjusts your host's eyes to see in the X-Ray spectrum."
	cost = 200
	time = 2 MINUTES
	gene_name = "XRAYBLOCK"
	prerequisites=list("farsight")