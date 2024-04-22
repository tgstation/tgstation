//this isn't like zap because it doesn't generate power and actually arcs out like lightning (this is a lie for now but the plan is to create coiled paths.) It also spreads through liquids
/atom/proc/electrical_chain(radius = 0, power = 1, skip_center = TRUE)
	if(!radius)
		return

	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	var/mutable_appearance/chain_appearance = mutable_appearance('goon/icons/effects/electile.dmi', "holder", TURF_LAYER, src, ABOVE_LIGHTING_PLANE)
	chain_appearance.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	chain_appearance.icon_state = "[power][pick("a","b","c")]"

	var/sound = pick(list('goon/sounds/sparks/sparks1.ogg','goon/sounds/sparks/sparks2.ogg','goon/sounds/sparks/sparks3.ogg','goon/sounds/sparks/sparks4.ogg','goon/sounds/sparks/sparks5.ogg','goon/sounds/sparks/sparks6.ogg'))

	switch(power)
		if(4)
			sound = 'goon/sounds/sparks/elec_bzzz.ogg'
		if(3)
			sound = 'goon/sounds/sparks/electric_shock.ogg'
		if(2)
			sound = 'goon/sounds/sparks/electric_shock_short.ogg'

	var/list/chained_turfs = list()

	for(var/turf/turf in view(radius, source_turf)) // this looks like a mighty fine place to add the ability for shocks to travel through liquids
		if(skip_center && turf == source_turf)
			continue
		if(turf in chained_turfs)
			continue
		if(turf.liquids?.liquid_group)
			chained_turfs |= turf.liquids.liquid_group.members
		else
			chained_turfs |= turf


	var/list/effects = list()
	for(var/turf/turf as anything in chained_turfs)
		var/obj/effect/abstract/copier = new(turf)
		copier.appearance = chain_appearance
		effects |= copier
		turf.hotspot_expose(1000, 100)
		animate(copier, alpha = 0, time = 0.6 SECONDS + power * 0.1 SECONDS, easing = BOUNCE_EASING | EASE_IN)


	playsound(src, sound, 50, 1)
	addtimer(CALLBACK(src, PROC_REF(clear_list), effects), 3 SECONDS)


/atom/proc/clear_list(list/clear)
	for(var/item in clear)
		qdel(item)
