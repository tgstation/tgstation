/// Drops the target's tail
/datum/smite/tailess
	name = "Tailess"

/datum/smite/tailess/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/organ/tail_snip_candidate
	tail_snip_candidate = carbon_target.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail_snip_candidate)
		to_chat(user, "<span class='warning'>[carbon_target] does not have a tail.</span>")
		return

	tail_snip_candidate.Remove(carbon_target)
	tail_snip_candidate.forceMove(get_turf(carbon_target))
