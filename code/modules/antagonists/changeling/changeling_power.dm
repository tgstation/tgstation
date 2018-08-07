/*
 * Don't use the apostrophe in name or desc. Causes script errors.
 * TODO: combine atleast some of the functionality with /proc_holder/spell
 */

/obj/effect/proc_holder/changeling
	panel = "Changeling"
	name = "Prototype Sting"
	desc = "" // Fluff
	var/helptext = "" // Details
	var/chemical_cost = 0 // negative chemical cost is for passive abilities (chemical glands)
	var/dna_cost = -1 //cost of the sting in dna points. 0 = auto-purchase, -1 = cannot be purchased
	var/req_dna = 0  //amount of dna needed to use this ability. Changelings always have atleast 1
	var/req_human = 0 //if you need to be human to use this ability
	var/req_absorbs = 0 //similar to req_dna, but only gained from absorbing, not DNA sting
	var/req_stat = CONSCIOUS // CONSCIOUS, UNCONSCIOUS or DEAD
	var/always_keep = 0 // important for abilities like revive that screw you if you lose them.
	var/ignores_fakedeath = FALSE // usable with the FAKEDEATH flag


/obj/effect/proc_holder/changeling/proc/on_purchase(mob/user, is_respec)
	if(!is_respec)
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, name)

/obj/effect/proc_holder/changeling/proc/on_refund(mob/user)
	return

/obj/effect/proc_holder/changeling/Click()
	var/mob/user = usr
	if(!user || !user.mind || !user.mind.has_antag_datum(/datum/antagonist/changeling))
		return
	try_to_sting(user)

/obj/effect/proc_holder/changeling/proc/try_to_sting(mob/user, mob/target)
	if(!can_sting(user, target))
		return
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(sting_action(user, target))
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
		sting_feedback(user, target)
		c.chem_charges -= chemical_cost

/obj/effect/proc_holder/changeling/proc/sting_action(mob/user, mob/target)
	return 0

/obj/effect/proc_holder/changeling/proc/sting_feedback(mob/user, mob/target)
	return 0

//Fairly important to remember to return 1 on success >.<
/obj/effect/proc_holder/changeling/proc/can_sting(mob/living/user, mob/target)
	if(!ishuman(user) && !ismonkey(user)) //typecast everything from mob to carbon from this point onwards
		return 0
	if(req_human && !ishuman(user))
		to_chat(user, "<span class='warning'>We cannot do that in this form!</span>")
		return 0
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(c.chem_charges < chemical_cost)
		to_chat(user, "<span class='warning'>We require at least [chemical_cost] unit\s of chemicals to do that!</span>")
		return 0
	if(c.absorbedcount < req_dna)
		to_chat(user, "<span class='warning'>We require at least [req_dna] sample\s of compatible DNA.</span>")
		return 0
	if(c.trueabsorbs < req_absorbs)
		to_chat(user, "<span class='warning'>We require at least [req_absorbs] sample\s of DNA gained through our Absorb ability.</span>")
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return 0
	if((user.has_trait(TRAIT_DEATHCOMA)) && (!ignores_fakedeath))
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return 0
	return 1

//used in /mob/Stat()
/obj/effect/proc_holder/changeling/proc/can_be_used_by(mob/user)
	if(QDELETED(user))
		return FALSE
	if(!ishuman(user) && !ismonkey(user))
		return FALSE
	if(req_human && !ishuman(user))
		return FALSE
	return TRUE
