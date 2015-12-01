/datum/research_tree/borer
	title="Evolutions"
	blurb="Select which path to evolve."

	var/mob/living/simple_animal/borer/borer

/datum/research_tree/borer/New(var/mob/living/simple_animal/borer/B)
	borer=B

/datum/research_tree/borer/get_avail_unlocks()
	return borer.borer_avail_unlocks

/datum/unlockable/borer
	cost_units = "C"
	var/remove_on_detach=1
	var/mob/living/simple_animal/borer/borer

/datum/unlockable/borer/set_context(var/datum/research_tree/borer/T)
	..(T)
	borer=T.borer

// INTERNAL: Begin unlocking process.
/datum/unlockable/borer/begin_unlock()
	to_chat(borer, "<span class='warning'>You begin concentrating intensely on producing the necessary changes.</span>")
	to_chat(borer, "<span class='danger'>You will be unable to use any borer abilities until the process completes.</span>")

/datum/unlockable/borer/end_unlock()
//	to_chat(Redundant borer, "<span class='info'>You finally finish your task.</span>")
	borer.chemicals -= cost

// additional checks to perform when unlocking things.
/datum/unlockable/borer/unlock_check()
	return (borer.chemicals >= cost)

/datum/unlockable/borer/can_buy()
	return ..() && borer.host && !borer.stat && !borer.controlling && borer.host.stat != DEAD

// When the borer detaches from a host.
/datum/unlockable/borer/proc/on_detached()
	return

// Ditto, but attached.
/datum/unlockable/borer/proc/on_attached()
	return


/////////////////////////
// Borer unlocks

// CHEMS!
/datum/unlockable/borer/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	to_chat(borer, "<span class='info'>You learned how to secrete [C.name]!</span>")

/datum/unlockable/borer/chem_unlock/peridaxon
	id = "peridaxon"
	name = "Peridaxon Secretion"
	desc = "Learn how to synthesize peridaxon."
	cost = 200
	time = 2 MINUTES
	chem_type = /datum/borer_chem/unlockable/peridaxon

/datum/unlockable/borer/chem_unlock/space_drugs
	id = "space_drugs"
	name = "Space Drug Secretion"
	desc = "Learn how to synthesize space drugs."
	cost = 50
	time = 10 SECONDS
	chem_type = /datum/borer_chem/unlockable/space_drugs

/datum/unlockable/borer/chem_unlock/rezadone
	id = "rezadone"
	name = "Rezadone Secretion"
	desc = "Learn how to synthesize rezadone."
	cost = 200
	time = 2 MINUTES
	chem_type = /datum/borer_chem/unlockable/rezadone

// Burn treatment research tree.

/datum/unlockable/borer/chem_unlock/dermaline
	id = "dermaline"
	name = "Dermaline Secretion"
	desc = "Learn how to synthesize dermaline."
	cost = 150
	time = 20 SECONDS
	chem_type = /datum/borer_chem/unlockable/dermaline

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

	to_chat(borer, "<span class='info'>You feel the genetic changes take hold in your host.</span>")

/datum/unlockable/borer/gene_unlock/relock_action()
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


//////////////////////////
// VERBS
/datum/unlockable/borer/verb_unlock
	var/verb_type = null // USE VERB HOLDERS OR SHIT *WILL* BREAK.
	var/give_when_attached = 0
	var/give_when_detached = 0
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/verb_unlock/unlock_action()
	if(give_when_attached)
		borer.attached_verbs|=verb_type
	if(give_when_detached)
		borer.detached_verbs|=verb_type
	to_chat(borer, "<span class='info'>You learned [name]!</span>")
	borer.update_verbs(borer.host != null)

/datum/unlockable/borer/verb_unlock/relock_action()
	if(give_when_attached)
		borer.attached_verbs-=verb_type
	if(give_when_detached)
		borer.detached_verbs-=verb_type
	to_chat(borer, "<span class='warning'>You forgot [name]!</span>")
	//borer.update_verbs(borer.attached)

/datum/unlockable/borer/verb_unlock/taste_blood
	id="taste_blood"
	name = "Taste Blood"
	desc = "Gain the ability to check your host's blood for chemicals."
	cost=50
	time=5 SECONDS
	verb_type = /obj/item/verbs/borer/attached/taste_blood
	give_when_attached=1


/obj/item/verbs/borer/attached/taste_blood/verb/taste_blood()
	set name = "Taste Blood"
	set desc = "See if there's anything within the blood of your host."
	set category = "Alien"

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.taste_blood()