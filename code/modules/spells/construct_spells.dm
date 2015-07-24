//////////////////////////////Construct Spells/////////////////////////

proc/findNullRod(var/atom/target)
	//writepanic("[__FILE__].[__LINE__] \\/proc/findNullRod() called tick#: [world.time]")
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-32,-32,MOB_LAYER+1,'sound/piano/Ab7.ogg')
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			if(findNullRod(A))
				return 1
	return 0

/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range, holder, selection_type))
		if(!(target in view_or_range(inner_radius, holder, selection_type)))
			if(target.density && (spell_flags & IGNOREDENSE))
				continue
			if(istype(target, /turf/space) && (spell_flags & IGNORESPACE))
				continue
			targets += target

	if(!targets.len) //doesn't waste the spell
		return

	return targets
