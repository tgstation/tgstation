//Affects all the turfs in the spells range, with an excluded inner area for the wizman to be protected in
//Should not be used for anything else, you cockwobblers

/atom/movable/spell/aoe_turf //affects all turfs in view or range (depends)
	spell_flags = IGNOREDENSE
	var/inner_radius = -1 //for all your ring spell needs

/atom/movable/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		if(!(target in view_or_range(inner_radius,user,selection_type)))
			if(target.density && (spell_flags & IGNOREDENSE))
				continue
			if(istype(target, /turf/space) && (spell_flags & IGNORESPACE))
				continue
			targets += target

	if(!targets.len) //doesn't waste the spell
		return

	return targets