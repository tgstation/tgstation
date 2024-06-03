/obj/item/mop/proc/attack_on_liquids_turf(obj/item/mop/the_mop, turf/target, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!user.Adjacent(target))
		return FALSE
	var/free_space = max_reagent_volume - reagents.total_volume
	var/speed_mult = 1
	var/datum/liquid_group/targeted_group = target?.liquids?.liquid_group
	while(!QDELETED(targeted_group))
		if(speed_mult >= 0.2)
			speed_mult -= 0.05
		if(free_space <= 0)
			to_chat(user, span_warning("Your [src] can't absorb any more!"))
			return TRUE
		if(!do_after(user, src.mopspeed * speed_mult, target = target))
			break
		if(the_mop.reagents.total_volume == the_mop.max_reagent_volume)
			to_chat(user, span_warning("Your [src] can't absorb any more!"))
			break
		if(targeted_group?.reagents_per_turf)
			targeted_group?.trans_to_seperate_group(the_mop.reagents, min(targeted_group?.reagents_per_turf, 5))
			to_chat(user, span_notice("You soak up some liquids with \the [src]."))
		else if(!QDELETED(target?.liquids?.liquid_group))
			targeted_group = target.liquids.liquid_group
		else
			break
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE
