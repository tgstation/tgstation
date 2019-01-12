/*
 * Don't use the apostrophe in name or desc. Causes script errors.//probably no longer true
 */

/datum/action/changeling
	name = "Prototype Sting - Debug button, ahelp this"
	background_icon_state = "bg_changeling"
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'
	var/needs_button = TRUE//for passive abilities like hivemind that dont need a button
	var/helptext = "" // Details
	var/chemical_cost = 0 // negative chemical cost is for passive abilities (chemical glands)
	var/dna_cost = -1 //cost of the sting in dna points. 0 = auto-purchase (see changeling.dm), -1 = cannot be purchased
	var/req_dna = 0  //amount of dna needed to use this ability. Changelings always have atleast 1
	var/req_human = 0 //if you need to be human to use this ability
	var/req_absorbs = 0 //similar to req_dna, but only gained from absorbing, not DNA sting
	var/req_stat = CONSCIOUS // CONSCIOUS, UNCONSCIOUS or DEAD
	var/ignores_fakedeath = FALSE // usable with the FAKEDEATH flag
	var/active = FALSE//used by a few powers that toggle

/*
changeling code now relies on on_purchase to grant powers.
if you override it, MAKE SURE you call parent or it will not be usable
the same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
*/

/datum/action/changeling/proc/on_purchase(mob/user, is_respec)
	if(!is_respec)
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, name)
	if(needs_button)
		Grant(user)//how powers are added rather than the checks in mob.dm

/datum/action/changeling/Trigger()
	var/mob/user = owner
	if(!user || !user.mind || !user.mind.has_antag_datum(/datum/antagonist/changeling))
		return
	try_to_sting(user)

/datum/action/changeling/proc/try_to_sting(mob/user, mob/target)
	if(!can_sting(user, target))
		return
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(sting_action(user, target))
		sting_feedback(user, target)
		c.chem_charges -= chemical_cost

/datum/action/changeling/proc/sting_action(mob/user, mob/target)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 0

/datum/action/changeling/proc/sting_feedback(mob/user, mob/target)
	return 0

//Fairly important to remember to return 1 on success >.<

/datum/action/changeling/proc/can_sting(mob/living/user, mob/target)
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

/datum/action/changeling/proc/can_be_used_by(mob/user)
	if(!user || QDELETED(user))
		return 0
	if(!ishuman(user) && !ismonkey(user))
		return FALSE
	if(req_human && !ishuman(user))
		return FALSE
	return TRUE
