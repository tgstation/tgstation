/datum/research_tree/borer
	title="Evolutions"
	blurb="Select which path to evolve."

	var/mob/living/simple_animal/borer/borer

/datum/research_tree/borer/New(var/mob/living/simple_animal/borer/B)
	borer=B

/datum/research_tree/borer/get_avail_unlocks()
	switch(borer.limb_to_mode(borer.hostlimb))
		if(BORER_MODE_ATTACHED_HEAD) // 2
			return borer.borer_avail_unlocks_head
		if(BORER_MODE_ATTACHED_CHEST) // 3
			return borer.borer_avail_unlocks_chest
		if(BORER_MODE_ATTACHED_ARM) // 4
			return borer.borer_avail_unlocks_arm
		if(BORER_MODE_ATTACHED_LEG) // 5
			return borer.borer_avail_unlocks_leg

/datum/unlockable/borer
	cost_units = "C"
	var/remove_on_detach=1
	var/mob/living/simple_animal/borer/borer

/datum/unlockable/borer/head
/datum/unlockable/borer/chest
/datum/unlockable/borer/arm
/datum/unlockable/borer/leg

/datum/unlockable/borer/set_context(var/datum/research_tree/borer/T)
	..(T)
	borer=T.borer

// INTERNAL: Begin unlocking process.
/datum/unlockable/borer/begin_unlock()
	to_chat(borer, "<span class='warning'>You begin concentrating intensely on producing the necessary changes.</span>")
	to_chat(borer, "<span class='danger'>You will be unable to use any borer abilities until the process completes.</span>")

/datum/unlockable/borer/end_unlock()
//	to_chat(Redundant borer, "<span class='info'>You finally finish your task.</span>")
	tree.unlocked.Add(src.id)
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
/datum/unlockable/borer/head/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/head/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	borer.unlocked_chems_head[C.name]=C
	to_chat(borer, "<span class='info'>You learned how to secrete [C.name]!</span>")

/datum/unlockable/borer/head/chem_unlock/peridaxon
	id = "peridaxon"
	name = "Peridaxon Secretion"
	desc = "Learn how to synthesize peridaxon."
	cost = 200
	time = 2 MINUTES
	chem_type = /datum/borer_chem/head/unlockable/peridaxon

/datum/unlockable/borer/head/chem_unlock/space_drugs
	id = "space_drugs"
	name = "Space Drug Secretion"
	desc = "Learn how to synthesize space drugs."
	cost = 50
	time = 10 SECONDS
	chem_type = /datum/borer_chem/head/unlockable/space_drugs

/datum/unlockable/borer/head/chem_unlock/rezadone
	id = "rezadone"
	name = "Rezadone Secretion"
	desc = "Learn how to synthesize rezadone."
	cost = 200
	time = 2 MINUTES
	chem_type = /datum/borer_chem/head/unlockable/rezadone

// Burn treatment research tree.

/datum/unlockable/borer/head/chem_unlock/dermaline
	id = "dermaline"
	name = "Dermaline Secretion"
	desc = "Learn how to synthesize dermaline."
	cost = 150
	time = 20 SECONDS
	chem_type = /datum/borer_chem/head/unlockable/dermaline

// Oxygen research tree
/datum/unlockable/borer/head/chem_unlock/dexalin
	id = "dexalin"
	name = "Dexalin Secretion"
	desc = "Learn how to synthesize dexalin."
	cost = 100
	time = 10 SECONDS
	chem_type = /datum/borer_chem/head/unlockable/dexalin

/datum/unlockable/borer/head/chem_unlock/dexalinp
	id = "dexalinp"
	name = "Dexalin+ Secretion"
	desc = "Learn how to synthesize Dexalin+."
	cost = 150
	time = 20 SECONDS
	chem_type = /datum/borer_chem/head/unlockable/dexalinp
	prerequisites=list("dexalin")

////////////Chest Unlocks//////////////////////

/datum/unlockable/borer/chest/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/chest/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	borer.unlocked_chems_chest[C.name]=C
	to_chat(borer, "<span class='info'>You learned how to secrete [C.name]!</span>")

/datum/unlockable/borer/chest/chem_unlock/nutriment
	id = "nutriment"
	name = "Nutriment Secretion"
	desc = "Learn how to synthesize nutriment."
	cost = 50
	time = 5 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/nutriment

/datum/unlockable/borer/chest/chem_unlock/arithrazine
	id = "arithrazine"
	name = "Arithrazine Secretion"
	desc = "Learn how to synthesize arithrazine."
	cost = 50
	time = 10 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/arithrazine

/datum/unlockable/borer/chest/chem_unlock/capsaicin
	id = "capsaicin"
	name = "Capsaicin Secretion"
	desc = "Learn how to synthesize capsaicin."
	cost = 100
	time = 20 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/capsaicin
	prerequisites=list("nutriment")

/datum/unlockable/borer/chest/chem_unlock/frostoil
	id = "frostoil"
	name = "Frost Oil Secretion"
	desc = "Learn how to synthesize frost oil."
	cost = 100
	time = 20 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/frostoil
	prerequisites=list("nutriment")

/datum/unlockable/borer/chest/chem_unlock/paismoke
	id = "paismoke"
	name = "Smoke Solution Secretion"
	desc = "Learn how to synthesize pAI-brand liquid smoke."
	cost = 150
	time = 45 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/paismoke

/datum/unlockable/borer/chest/chem_unlock/clottingagent
	id = "clotting_agent"
	name = "Clotting Agent Secretion"
	desc = "Learn how to synthesize blood platelets, to stem bleeding."
	cost = 200
	time = 60 SECONDS
	chem_type = /datum/borer_chem/chest/unlockable/clottingagent

/////////////////Arm Unlocks////////////////////////

/datum/unlockable/borer/arm/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/arm/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	borer.unlocked_chems_arm[C.name]=C
	to_chat(borer, "<span class='info'>You learned how to secrete [C.name]!</span>")

/datum/unlockable/borer/arm/chem_unlock/cafe_latte
	id = "cafe_latte"
	name = "Latte Secretion"
	desc = "Learn how to synthesize latte."
	cost = 50
	time = 20 SECONDS
	chem_type = /datum/borer_chem/arm/unlockable/cafe_latte
	prerequisites=list("bone_sword")

/datum/unlockable/borer/arm/chem_unlock/iron
	id = "iron"
	name = "Iron Secretion"
	desc = "Learn how to synthesize iron."
	cost = 50
	time = 20 SECONDS
	chem_type = /datum/borer_chem/arm/unlockable/iron
	prerequisites=list("repair_bone")

///////////////Leg Unlocks//////////////////////////

/datum/unlockable/borer/leg/chem_unlock
	var/chem_type = null
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/leg/chem_unlock/unlock_action()
	var/datum/borer_chem/C = new chem_type()
	borer.avail_chems[C.name]=C
	borer.unlocked_chems_leg[C.name]=C
	to_chat(borer, "<span class='info'>You learned how to secrete [C.name]!</span>")

/datum/unlockable/borer/leg/chem_unlock/bustanut
	id = "bustanut"
	name = "Hardcores Secretion"
	desc = "Learn how to synthesize hardcores."
	cost = 50
	time = 20 SECONDS
	chem_type = /datum/borer_chem/leg/unlockable/bustanut

/datum/unlockable/borer/leg/chem_unlock/synaptizine
	id = "synaptizine"
	name = "Synaptizine Secretion"
	desc = "Learn how to synthesize synaptizine. Improves stun recovery, but is slightly toxic."
	cost = 100
	time = 45 SECONDS
	chem_type = /datum/borer_chem/leg/unlockable/synaptizine

// TODO: Ability to spray shit at people when outside of a host?

/////////////////////////////////
// HOST UNLOCKS
/////////////////////////////////

/datum/unlockable/borer/head/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/unlockable/borer/head/gene_unlock/unlock_action()
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

/datum/unlockable/borer/head/gene_unlock/relock_action()
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
/datum/unlockable/borer/head/gene_unlock/sober
	id = "sober"
	name = "Liver Function Boost"
	desc = "Your host's liver is able to handle massive quantities of alcohol."
	cost = 200
	time = 30 SECONDS
	gene_name = "SOBER"

// Vision tree
/datum/unlockable/borer/head/gene_unlock/farsight
	id = "farsight"
	name = "Telephoto Vision"
	desc = "Adjusts your host's eyes to see farther."
	cost = 200
	time = 1 MINUTES
	gene_name = "FARSIGHT"

/datum/unlockable/borer/head/gene_unlock/xray
	id = "xray"
	name = "High-Energy Vision"
	desc = "Adjusts your host's eyes to see in the X-Ray spectrum."
	cost = 200
	time = 2 MINUTES
	gene_name = "XRAY"
	prerequisites=list("farsight")

//////////////Chest Unlocks/////////////////

/datum/unlockable/borer/chest/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/unlockable/borer/chest/gene_unlock/unlock_action()
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

/datum/unlockable/borer/chest/gene_unlock/relock_action()
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

/datum/unlockable/borer/chest/gene_unlock/resist_cold
	id = "resist_cold"
	name = "Cold Resistance"
	desc = "Adjusts your host's skin to be capable of reducing heat lost to the environment."
	cost = 200
	time = 1 MINUTES
	gene_name = "FIRE"
	prerequisites=list("capsaicin")

/datum/unlockable/borer/chest/gene_unlock/resist_heat
	id = "resist_heat"
	name = "Heat Resistance"
	desc = "Adjusts your host's skin to be capable of reducing heat gained from the environment."
	cost = 200
	time = 1 MINUTES
	gene_name = "COLD"
	prerequisites=list("frostoil")

///////////////Arm Unlocks//////////////////////

/datum/unlockable/borer/arm/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/unlockable/borer/arm/gene_unlock/unlock_action()
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

/datum/unlockable/borer/arm/gene_unlock/relock_action()
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

/datum/unlockable/borer/arm/gene_unlock/strong
	id = "strong"
	name = "Increase Strength"
	desc = "Improves your host's musculature, increasing your host's strength."
	cost = 200
	time = 1 MINUTES
	gene_name = "STRONG"
	prerequisites=list("bone_sword")

/datum/unlockable/borer/arm/gene_unlock/regeneration
	id = "regeneration"
	name = "Regeneration"
	desc = "Modifies your host's immune system to provide a small amount of damage regeneration."
	cost = 200
	time = 1 MINUTES
	gene_name = "REGENERATE"
	prerequisites=list("bone_shield")

/datum/unlockable/borer/arm/gene_unlock/shock_immunity
	id = "shock_immunity"
	name = "Shock Immunity"
	desc = "Adjusts your host's skin to be more resistant to electrical currents."
	cost = 200
	time = 1 MINUTES
	gene_name = "SHOCKIMMUNITY"
	prerequisites=list("repair_bone")

///////////////Leg Unlocks////////////////////

/datum/unlockable/borer/leg/gene_unlock
	var/gene_name = null // Name of gene
	var/activate = 1     // 0 = deactivate on unlock
	remove_on_detach = 1

/datum/unlockable/borer/leg/gene_unlock/unlock_action()
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

/datum/unlockable/borer/leg/gene_unlock/relock_action()
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

/datum/unlockable/borer/leg/gene_unlock/run
	id = "run"
	name = "Improve Run"
	desc = "Improves your host's slow-twitch leg muscles to negate speed loss from environmental factors."
	cost = 150
	time = 20 SECONDS
	gene_name = "INCREASERUN"

/datum/unlockable/borer/leg/gene_unlock/jump
	id = "jump"
	name = "Improve Jump"
	desc = "Improves your host's fast-twitch leg muscles to enable huge leaps."
	cost = 200
	time = 30 SECONDS
	gene_name = "JUMP"
	prerequisites=list("run")

//////////////////////////
// VERBS
/datum/unlockable/borer/head/verb_unlock
	var/verb_type = null // USE VERB HOLDERS OR SHIT *WILL* BREAK.
	var/give_when_attached = 0
	var/give_when_detached = 0
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/head/verb_unlock/unlock_action()
	if(give_when_attached)
		borer.attached_verbs_head|=verb_type
	if(give_when_detached)
		borer.detached_verbs|=verb_type
	to_chat(borer, "<span class='info'>You learned [name]!</span>")
	borer.update_verbs(BORER_MODE_ATTACHED_HEAD)

/datum/unlockable/borer/head/verb_unlock/relock_action()
	if(give_when_attached)
		borer.attached_verbs_head-=verb_type
	if(give_when_detached)
		borer.detached_verbs-=verb_type
	to_chat(borer, "<span class='warning'>You forgot [name]!</span>")
	//borer.update_verbs(borer.attached)

/datum/unlockable/borer/head/verb_unlock/taste_blood
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

//////////Chest Verbs///////////////////

/datum/unlockable/borer/chest/verb_unlock
	var/verb_type = null // USE VERB HOLDERS OR SHIT *WILL* BREAK.
	var/give_when_attached = 0
	var/give_when_detached = 0
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/chest/verb_unlock/unlock_action()
	if(give_when_attached)
		borer.attached_verbs_chest|=verb_type
	if(give_when_detached)
		borer.detached_verbs|=verb_type
	to_chat(borer, "<span class='info'>You learned [name]!</span>")
	borer.update_verbs(BORER_MODE_ATTACHED_CHEST)

/datum/unlockable/borer/chest/verb_unlock/relock_action()
	if(give_when_attached)
		borer.attached_verbs_chest-=verb_type
	if(give_when_detached)
		borer.detached_verbs-=verb_type
	to_chat(borer, "<span class='warning'>You forgot [name]!</span>")
	//borer.update_verbs(borer.attached)

/datum/unlockable/borer/chest/verb_unlock/taste_blood
	id="taste_blood"
	name = "Taste Blood"
	desc = "Gain the ability to check your host's blood for chemicals."
	cost=50
	time=5 SECONDS
	verb_type = /obj/item/verbs/borer/attached/taste_blood
	give_when_attached=1

/datum/unlockable/borer/chest/verb_unlock/brute_resist
	id="brute_resist"
	name = "Brute Damage Resistance"
	desc = "Learn how to expend chemicals constantly in order to mitigate brute damage done to your host."
	cost=200
	time=60 SECONDS
	verb_type = /obj/item/verbs/borer/attached_chest/brute_resist
	give_when_attached=1

/datum/unlockable/borer/chest/verb_unlock/burn_resist
	id="burn_resist"
	name = "Burn Damage Resistance"
	desc = "Learn how to expend chemicals constantly in order to mitigate burn damage done to your host."
	cost=200
	time=60 SECONDS
	verb_type = /obj/item/verbs/borer/attached_chest/burn_resist
	give_when_attached=1

/////////Arm Verbs///////////////////////

/datum/unlockable/borer/arm/verb_unlock
	var/verb_type = null // USE VERB HOLDERS OR SHIT *WILL* BREAK.
	var/give_when_attached = 0
	var/give_when_detached = 0
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/arm/verb_unlock/unlock_action()
	if(give_when_attached)
		borer.attached_verbs_arm|=verb_type
	if(give_when_detached)
		borer.detached_verbs|=verb_type
	to_chat(borer, "<span class='info'>You learned [name]!</span>")
	borer.update_verbs(BORER_MODE_ATTACHED_ARM)

/datum/unlockable/borer/arm/verb_unlock/relock_action()
	if(give_when_attached)
		borer.attached_verbs_arm-=verb_type
	if(give_when_detached)
		borer.detached_verbs-=verb_type
	to_chat(borer, "<span class='warning'>You forgot [name]!</span>")
	//borer.update_verbs(borer.attached)

/datum/unlockable/borer/arm/verb_unlock/taste_blood
	id="taste_blood"
	name = "Taste Blood"
	desc = "Gain the ability to check your host's blood for chemicals."
	cost=50
	time=5 SECONDS
	verb_type = /obj/item/verbs/borer/attached/taste_blood
	give_when_attached=1

/datum/unlockable/borer/arm/verb_unlock/bone_sword
	id="bone_sword"
	name = "Bone Sword"
	desc = "Learn how to expend chemicals constantly in order to form a large blade of bone for your host. Learning this will lock you into the Offense tree."
	cost=100
	time=30 SECONDS
	verb_type = /obj/item/verbs/borer/attached_arm/bone_sword
	give_when_attached=1
	antirequisites=list("bone_shield","repair_bone")

/datum/unlockable/borer/arm/verb_unlock/bone_hammer
	id="bone_hammer"
	name = "Bone Hammer"
	desc = "Learn how to expend chemicals constantly in order to form a large, heavy mass of bone on your host's arm."
	cost=200
	time=1 MINUTES
	verb_type = /obj/item/verbs/borer/attached_arm/bone_hammer
	give_when_attached=1
	prerequisites=list("bone_sword")

/datum/unlockable/borer/arm/verb_unlock/bone_shield
	id="bone_shield"
	name = "Bone Shield"
	desc = "Learn how to expend chemicals constantly in order to form a large shield of bone for your host. Learning this will lock you into the Defense tree."
	cost=100
	time=30 SECONDS
	verb_type = /obj/item/verbs/borer/attached_arm/bone_shield
	give_when_attached=1
	antirequisites=list("bone_sword","repair_bone")

/datum/unlockable/borer/arm/verb_unlock/bone_cocoon
	id="bone_cocoon"
	name = "Bone Cocoon"
	desc = "Learn how to expend chemicals constantly in order to form a large protective cocoon of bone around your host."
	cost=200
	time=1 MINUTES
	verb_type = /obj/item/verbs/borer/attached_arm/bone_cocoon
	give_when_attached=1
	prerequisites=list("bone_shield")

/datum/unlockable/borer/arm/verb_unlock/em_pulse
	id="em_pulse"
	name = "Electromagnetic Pulse"
	desc = "Learn how to expend a great deal of chemicals to produce a small electromagnetic pulse."
	cost=150
	time=60 SECONDS
	verb_type = /obj/item/verbs/borer/attached_arm/em_pulse
	give_when_attached=1
	prerequisites=list("bone_shield")

/datum/unlockable/borer/arm/verb_unlock/repair_bone
	id="repair_bone"
	name = "Repair Bone"
	desc = "Learn how to expend chemicals in order to repair bones in your host's arm. Learning this will lock you into the Utility tree."
	cost=50
	time=10 SECONDS
	verb_type = /obj/item/verbs/borer/attached_arm/repair_bone
	give_when_attached=1
	antirequisites=list("bone_sword","bone_shield")

/datum/unlockable/borer/arm/extend_o_arm_unlock
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/arm/extend_o_arm_unlock/unlock_action()
	borer.extend_o_arm_unlocked = 1
	to_chat(borer, "<span class='info'>You learned [name]!</span>")

/datum/unlockable/borer/arm/extend_o_arm_unlock/extend_o_arm
	id="extend_o_arm"
	name = "Extensible Arm"
	desc = "Gain the ability to extrude a prehensile length of flesh from your host's arm."
	cost=200
	time=1 MINUTES
	prerequisites=list("repair_bone")

////////////Leg Verbs////////////////////////////

/datum/unlockable/borer/leg/verb_unlock
	var/verb_type = null // USE VERB HOLDERS OR SHIT *WILL* BREAK.
	var/give_when_attached = 0
	var/give_when_detached = 0
	remove_on_detach = 0 // Borer-side, so we don't lose it.

/datum/unlockable/borer/leg/verb_unlock/unlock_action()
	if(give_when_attached)
		borer.attached_verbs_leg|=verb_type
	if(give_when_detached)
		borer.detached_verbs|=verb_type
	to_chat(borer, "<span class='info'>You learned [name]!</span>")
	borer.update_verbs(BORER_MODE_ATTACHED_LEG)

/datum/unlockable/borer/leg/verb_unlock/relock_action()
	if(give_when_attached)
		borer.attached_verbs_leg-=verb_type
	if(give_when_detached)
		borer.detached_verbs-=verb_type
	to_chat(borer, "<span class='warning'>You forgot [name]!</span>")
	//borer.update_verbs(borer.attached)

/datum/unlockable/borer/leg/verb_unlock/taste_blood
	id="taste_blood"
	name = "Taste Blood"
	desc = "Gain the ability to check your host's blood for chemicals."
	cost=50
	time=5 SECONDS
	verb_type = /obj/item/verbs/borer/attached/taste_blood
	give_when_attached=1

/datum/unlockable/borer/leg/verb_unlock/speed_increase
	id="speed_increase"
	name = "Speed Increase"
	desc = "Learn how to expend chemicals constantly in order to elevate the performance of the limb in which you reside."
	cost=150
	time=30 SECONDS
	verb_type = /obj/item/verbs/borer/attached_leg/speed_increase
	give_when_attached=1

/datum/unlockable/borer/leg/verb_unlock/bone_talons
	id="bone_talons"
	name = "Bone Talons"
	desc = "Learn how to expend chemicals constantly in order to create strong bony talons on your host's foot."
	cost=50
	time=10 SECONDS
	verb_type = /obj/item/verbs/borer/attached_leg/bone_talons
	give_when_attached=1
