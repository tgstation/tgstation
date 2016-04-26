/*
Aoe turf spells target a ring of tiles around the user
This ring has an outer radius (range) and an inner radius (inner_radius)
Aoe turf spells have two useful flags: IGNOREDENSE and IGNORESPACE. These are explained in setup.dm
*/

/spell/aoe_turf //affects all turfs in view or range (depends)
	spell_flags = IGNOREDENSE
	var/inner_radius = -1 //for all your ring spell needs

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

/spell/aoe_turf/perform(mob/user = usr, skipcharge = 0,var/turf/T = null)
	if(!holder)
		holder = user
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = list()
	if(T)
		targets = list(T)//adding a target override
	else
		targets = choose_targets(user)
	if(targets && targets.len)
		invocation(user, targets)
		take_charge(user, skipcharge)

		before_cast(targets)
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>[user.real_name] ([user.ckey]) cast the spell [name].</font>")
		if(prob(critfailchance))
			critfail(targets, user)
		else
			cast(targets, user)
		after_cast(targets)
