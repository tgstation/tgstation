/* Hippie Bad Traits */

/datum/trait/flatulence
	name = "Involuntary flatulence"
	desc = "A spasm in the patient's sphincter will cause them to uncontrollably fart at random intervals."
	value = -1
	gain_text = "<span class='danger'>Your butt starts to twitch!</span>"
	lose_text = "<span class='notice'>Your butt settles down.</span>"
	medical_record_text = "Patient has a muscular spasm in their rectal sphincter, gaseous discharge may occour."

/datum/trait/flatulence/on_process()
	if(prob(3))
		var/obj/item/organ/butt/B = trait_holder.getorgan(/obj/item/organ/butt)
		if(!B)
			to_chat(trait_holder, "<span class='warning'>The building pressure in your colon hurts!</span>")
			trait_holder.adjustBruteLoss(rand(2,6))
		else if(prob(1))
			trait_holder.emote("superfart")
		else
			trait_holder.emote("fart")


/datum/trait/smallbutt
	name = "Small anal cavity"
	desc = "Muscular contractions cause the patient's anal cavity to be undersized."
	value = -1
	gain_text = "<span class='danger'>Your butt tenses up!</span>"
	lose_text = "<span class='notice'>Your butt muscles relax.</span>"
	medical_record_text = "Tension in the patient's butt muscles has caused their anal cavity to become small."

/datum/trait/smallbutt/add()
	var/obj/item/organ/butt/B = trait_holder.getorgan(/obj/item/organ/butt)
	if(!B)
		to_chat(trait_holder, "<span class='warning'>You somehow gained this trait without a butt, contact an admin.</span>")
		qdel(src)
	else if(B.storage_slots > 0)
		B.inv.storage_slots = initial(B.inv.storage_slots) - 1
	else
		to_chat(trait_holder, "<span class='warning'>Dat booty can't get any smaller!</span>")
		qdel(src)

/datum/trait/smallbutt/remove()
	var/obj/item/organ/butt/B = trait_holder.getorgan(/obj/item/organ/butt)
	if(!B)
		return
	else
		B.inv.storage_slots = initial(B.inv.storage_slots)

/datum/trait/nonviolent
	name = "Hippie Anti-Griff system."
	desc = "A foolproof system that will eiliminate any and all grief, while it's listed here, this is non-optional."
	value = 0
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of griefing!</span>"
	lose_text = "<span class='notice'>Error, Anti-Griff offline, contact an admin.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/trait/nonviolent/on_process()
	if(trait_holder.mind && LAZYLEN(trait_holder.mind.antag_datums))
		to_chat(trait_holder, "<span class='boldannounce'>Your antagonistic nature allows you to buypass the otherwise foolproof hippie anti-griff system.</span>")
		qdel(src)
