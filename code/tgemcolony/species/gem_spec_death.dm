/datum/species/gem/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.summoneditem != null)
		QDEL_NULL(H.summoneditem)
		H.regenerate_icons()

	if(H.isfusion == FALSE)
		new /obj/effect/temp_visual/gem_poof(get_turf(H))
		if(H.suiciding)
			H.visible_message("<span class='danger'>[H] shattered themself!</span>")
			H.unequip_everything()
			for(var/atom/movable/A in H.stored_items)
				H.stored_items.Remove(A)
				A.forceMove(H.drop_location())
			var/obj/item/shard/gem/shard = new/obj/item/shard/gem
			shard.loc = H.loc
			shard.icon_state = "[id]shard"
			shard.name = "Shattered [id]"
			shard.desc = "It appears to be the remains of [H.name]"
			QDEL_NULL(H)
		else

			H.visible_message("<span class='danger'>[H] was poofed!</span>")
			new /obj/item/gem(get_turf(H), H)
	else
		for(var/atom/movable/A in H.fused_with)
			H.fused_with.Remove(A)
			A.forceMove(H.drop_location())
			if(ishuman(A))
				var/mob/living/carbon/human/M = A
				M.myfusion = FALSE
				M.reset_perspective()
				M.adjustStaminaLoss(H.getBruteLoss()+H.getFireLoss())
		H.visible_message("<span class='danger'>[H] unfused!</span>")
		var/mob/domfuse = H.dominantfuse
		domfuse.key = H.key
		H.unequip_everything()
		spawn(5)
		del(H)
	..()