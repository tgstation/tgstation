/obj/item/organ/tail/cat/tcat
	icon = 'hippiestation/icons/obj/surgery.dmi'
	var/been_colored = FALSE

/obj/item/organ/tail/cat/tcat/Insert(mob/living/carbon/human/M, special = 0, drop_if_replaced = TRUE)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(src))
		else
			qdel(replaced)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	loc = null
	if(!been_colored)
		color = "#" + M.dna.features["mcolor"]
	been_colored = TRUE //even if no mutcolor is applied
	M.dna.features["tail_human"] = "TCat"
	M.update_body()

/obj/item/organ/tail/cat/tcat/Remove(mob/living/carbon/human/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
	M.endTailWag()
	M.dna.features["tail_human"] = "None"
	M.update_body()