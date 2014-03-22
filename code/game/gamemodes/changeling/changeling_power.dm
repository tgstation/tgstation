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
	var/req_stat = CONSCIOUS // CONSCIOUS, UNCONSCIOUS or DEAD
	var/genetic_damage = 0 // genetic damage caused by using the sting. Nothing to do with cloneloss.
	var/max_genetic_damage = 100 // hard counter for spamming abilities. Not used/balanced much yet.


/obj/effect/proc_holder/changeling/proc/on_purchase(var/mob/user)
	return

/obj/effect/proc_holder/changeling/Click()
	var/mob/user = usr
	if(!user || !user.mind || !user.mind.changeling)
		return
	try_to_sting(user)

/obj/effect/proc_holder/changeling/proc/try_to_sting(var/mob/user, var/mob/target)
	if(!can_sting(user, target))
		return
	var/datum/changeling/c = user.mind.changeling
	if(sting_action(user, target))
		sting_feedback(user, target)
		take_chemical_cost(c)

/obj/effect/proc_holder/changeling/proc/sting_action(var/mob/user, var/mob/target)
	return 0

/obj/effect/proc_holder/changeling/proc/sting_feedback(var/mob/user, var/mob/target)
	return 0

/obj/effect/proc_holder/changeling/proc/take_chemical_cost(var/datum/changeling/changeling)
	changeling.chem_charges -= chemical_cost
	changeling.geneticdamage += genetic_damage

//Fairly important to remember to return 1 on success >.<
/obj/effect/proc_holder/changeling/proc/can_sting(var/mob/user, var/mob/target)
	if(!ishuman(user) && !ismonkey(user)) //typecast everything from mob to carbon from this point onwards
		return 0
	if(req_human && !ishuman(user))
		user << "<span class='warning'>We cannot do that in this form!</span>"
		return 0
	var/datum/changeling/c = user.mind.changeling
	if(c.chem_charges<chemical_cost)
		user << "<span class='warning'>We require at least [chemical_cost] unit\s of chemicals to do that!</span>"
		return 0
	if(c.absorbedcount<req_dna)
		user << "<span class='warning'>We require at least [req_dna] sample\s of compatible DNA.</span>"
		return 0
	if(req_stat < user.stat)
		user << "<span class='warning'>We are incapacitated.</span>"
		return 0
	if((user.status_flags & FAKEDEATH) && name!="Regenerate")
		user << "<span class='warning'>We are incapacitated.</span>"
		return 0
	if(c.geneticdamage > max_genetic_damage)
		user << "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>"
		return 0
	return 1

//used in /mob/Stat()
/obj/effect/proc_holder/changeling/proc/can_be_used_by(var/mob/user)
	if(!ishuman(user) && !ismonkey(user))
		return 0
	if(req_human && !ishuman(user))
		return 0
	return 1


