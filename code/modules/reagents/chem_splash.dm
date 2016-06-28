// Replaces chemgrenade stuff, allowing reagent explosions to be called from anywhere.
// It should be called using a location, the range, and a list of reagents involved.

// Threatscale is a multiplier for the 'threat' of the grenade. If you're increasing the affected range drastically, you might want to improve this.
// Extra heat affects the temperature of the mixture, and may cause it to react in different ways.


proc/chem_splash(turf/epicenter, affected_range = 3, list/datum/reagents/reactants = list(), extra_heat = 0, threatscale = 1, adminlog = 1)
	if(!istype(epicenter, /turf) || !reactants.len || threatscale <= 0)
		return
	var/has_reagents
	var/total_reagents
	for(var/datum/reagents/R in reactants)
		if(R.total_volume)
			has_reagents = 1
			total_reagents += R.total_volume

	if(!has_reagents)
		return

	var/datum/reagents/splash_holder = new/datum/reagents(total_reagents*threatscale)
	splash_holder.my_atom = epicenter // For some reason this is setting my_atom to null, and causing runtime errors.
	var/total_temp = 0

	for(var/datum/reagents/R in reactants)
		R.trans_to(splash_holder, R.total_volume, threatscale, 1, 1)
		total_temp += R.chem_temp
	splash_holder.chem_temp = (total_temp/reactants.len) + extra_heat // Average temperature of reagents + extra heat.
	splash_holder.handle_reactions() // React them now.

	if(splash_holder.total_volume && affected_range >= 0)	//The possible reactions didnt use up all reagents, so we spread it around.
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, epicenter)
		steam.attach(epicenter)
		steam.start()

		var/list/viewable = view(affected_range, epicenter)

		var/list/accessible = list(epicenter)
		for(var/i=1; i<=affected_range; i++)
			var/list/turflist = list()
			for(var/turf/T in (orange(i, epicenter) - orange(i-1, epicenter)))
				turflist |= T
			for(var/turf/T in turflist)
				if( !(get_dir(T,epicenter) in cardinal) && (abs(T.x - epicenter.x) == abs(T.y - epicenter.y) ))
					turflist.Remove(T)
					turflist.Add(T) // we move the purely diagonal turfs to the end of the list.
			for(var/turf/T in turflist)
				if(T in accessible) continue
				for(var/turf/NT in orange(1, T))
					if(!(NT in accessible)) continue
					if(!(get_dir(T,NT) in cardinal)) continue
					if(!NT.CanAtmosPass(T)) continue
					accessible |= T
					break
		var/list/reactable = accessible
		for(var/turf/T in accessible)
			for(var/atom/A in T.GetAllContents())
				if(!(A in viewable)) continue
				reactable |= A
			if(extra_heat >= 300)
				T.hotspot_expose(extra_heat*2, 5)
		if(!reactable.len) //Nothing to react with. Probably means we're in nullspace.
			return
		var/fraction = 0.5/accessible.len // In a 100u mix. A small grenade spreads ~1.5u units per affected tile. A large grenade spreads ~0.75u, and a bomb spreads ~0.4u
		for(var/atom/A in reactable)
			splash_holder.reaction(A, TOUCH, fraction)

	qdel(splash_holder)
	return 1


