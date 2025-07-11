/datum/relic_trans
	var/datum/relic_node/next_node
	var/desc = "An unknown stimulus."

/datum/relic_trans/proc/check_cond(...)
	return TRUE
/datum/relic_trans/proc/get_user(mob/user)
	return user

/datum/relic_trans/proc/on_triggered()
	return
/datum/relic_trans/none //Automatically passes - lowest priority (checks other conditions, only procs if nothing has gone on)
	desc = "None, it is unstable!"
/datum/relic_trans/touch
	desc = "A(n) (un)willing participant's touch."
/datum/relic_trans/harm
	desc = "Give it a good thwack."
	var/mob/hit_user = null
/datum/relic_trans/harm/check_cond(...)
	if (args.len > 0 && istype(args.Copy(0), /mob))
		hit_user = args.Copy(0)
	return TRUE
/datum/relic_trans/harm/get_user(mob/user)
	if (hit_user != null)
		return hit_user
	return user

/datum/relic_trans/reagent
	desc = "Exposing to a reagent."
	// check_cond(...)
	// 	if (args.len > 0 && istype(args.Copy(0), /datum/reagent)) // maybe make it require a specific reagent?
	// 		return TRUE
	// 	return FALSE

/datum/relic_trans/vacuum
	desc = "Existing in a vacuum."
/datum/relic_trans/explode
	desc = "In range of an explosion."
/datum/relic_trans/emp
	desc = "In range of an EMP."
/datum/relic_trans/fire
	desc = "Lighting on fire."
/datum/relic_trans/paint
	desc = "Applying a new coat of paint."
/datum/relic_trans/irradiate
	desc = "Exposing to ionizing radiation."
/datum/relic_trans/hear
	desc = "Having casual conversation."
/datum/relic_trans/hear/on_triggered()
	playsound(next_node.parent_relic, SFX_MUFFLED_SPEECH, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return
/datum/relic_trans/tracked
	desc = "Keeping a close eye with a pinpointer."

/datum/relic_node
	var/node_id
	var/list/datum/relic_trans/relic_transes = list()
	var/obj/item/relic/parent_relic
	var/desc = ""

/datum/relic_node/proc/on_generate()
	return

/datum/relic_node/proc/reaction_power(mob/user)
	return

/datum/relic_node/proc/run_effect(mob/user)
	parent_relic.balloon_alert(user, "[parent_relic] shows increased activity...")
	// to_chat(user, span_warning("DEBUG: [parent_relic] is now at [node_id] : [src]"))
	if(!COOLDOWN_FINISHED(parent_relic, cooldown))
		playsound(parent_relic, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		parent_relic.lightning_fx(parent_relic, 1.0 SECONDS)
		if (!parent_relic.reacting_when_off_cooldown)
			addtimer(CALLBACK(src, PROC_REF(run_effect), user), COOLDOWN_TIMELEFT(parent_relic, cooldown))
			parent_relic.reacting_when_off_cooldown = TRUE
		return
	parent_relic.reacting_when_off_cooldown = FALSE
	COOLDOWN_START(parent_relic, cooldown, parent_relic.cooldown_timer)
	reaction_power(user)
	// Give time for other reactions to happen before procing none
	if (HAS_TRAIT(src, TRAIT_IRRADIATED))
		addtimer(CALLBACK(src, PROC_REF(check_trans), null, /datum/relic_trans/irradiate), parent_relic.cooldown_timer + 0.1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(check_trans), user, /datum/relic_trans/none), parent_relic.cooldown_timer + 5.0 SECONDS)


/datum/relic_node/proc/check_trans(mob/user, react_type, ...)
	if(parent_relic.reacting_when_off_cooldown)
		to_chat(user, span_notice("[parent_relic] doesn't seem ready, and does nothing."))
		return
	var/list/datum/relic_trans/_pot_trans = list()
	for (var/datum/relic_trans/_trans as anything in relic_transes)
		// to_chat(user, span_warning("DEBUG: [_trans] is [react_type] ? [istype(_trans, react_type)] AND [_trans.check_cond(arglist(args))]"))
		if (istype(_trans, react_type) && _trans.check_cond(arglist(args)))
			_pot_trans.Add(_trans)
	if (_pot_trans.len > 0)
		var/datum/relic_trans/_trans = pick(_pot_trans)
		_trans.on_triggered()
		parent_relic.current_node = _trans.next_node
		parent_relic.current_node.run_effect(_trans.get_user(user))
	return

/datum/relic_node/Destroy(force)
	for (var/datum/relic_trans/each as anything in relic_transes)
		QDEL_NULL(each)
	. = ..()

/datum/relic_node/no_effect
	desc = "This node didn't seem to do anything..."
/datum/relic_node/no_effect/reaction_power(mob/user)
		to_chat(user, span_notice("[parent_relic] seizes up, and seems to do nothing..."))
		return

/datum/relic_node/reagent
	desc = "This node made it release a foam!"
	var/datum/reagent/reagent
	var/method
	var/units
	var/range

/datum/relic_node/reagent/on_generate()
	reagent = pick(subtypesof(/datum/reagent))
	method = pick(TOUCH, INGEST, VAPOR, PATCH, INJECT, INHALE)
	units = rand(5, 100)
	range = rand(2, 6)
	return

/datum/relic_node/reagent/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] leaks [reagent.name] everywhere!"))
	playsound(get_turf(parent_relic), 'sound/effects/slosh.ogg', 25, TRUE)
	var/turf/src_turf = get_turf(parent_relic)
	var/datum/reagents/tmp_holder = new(units)
	tmp_holder.my_atom = src
	tmp_holder.add_reagent(reagent, units)

	var/datum/effect_system/fluid_spread/foam/fluid = new
	fluid.set_up(range = range, amount = units, holder = parent_relic, location = src_turf, carry = tmp_holder)
	fluid.start()
	// qdel(tmp_holder)
	return

/datum/relic_node/item
	desc = "This node made it create some items!"
	var/obj/item/item_type
	var/count
/datum/relic_node/item/on_generate()
	item_type = pick(subtypesof(/obj/item))
	count = rand(1,4)
	return

/datum/relic_node/item/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] spits out [count] of [item_type.name]!"))
	playsound(parent_relic, 'sound/items/fulton/fultext_launch.ogg', 50, TRUE, -5)
	for (var/i in 1 to count)
		new item_type(get_turf(parent_relic))
	return

/datum/relic_node/animal
	desc = "This node made it release some animals!"
	var/mob/living/basic/animal_type
	var/count
	// removing types that should be in admin hands
	var/list/invalid_types = list(/mob/living/basic/heretic_summon/star_gazer,
								/mob/living/basic/construct/harvester,
								/mob/living/basic/space_dragon,
								/mob/living/basic/revenant,
								/mob/living/basic/alien/queen)
/datum/relic_node/animal/on_generate()
	var/list/valid_types = subtypesof(/mob/living/basic);
	if (!parent_relic.very_dangerous)
		for (var/i as anything in invalid_types)
			valid_types.Remove(i)
	animal_type = pick(valid_types)
	count = rand(1,4)
	return

/datum/relic_node/animal/reaction_power(mob/user)
	to_chat(user, span_warning("[animal_type.name] come out of [parent_relic]!"))
	playsound(parent_relic, 'sound/items/fulton/fultext_launch.ogg', 50, TRUE, -5)
	for (var/i in 1 to count)
		new animal_type(get_turf(parent_relic))
	return

/datum/relic_node/vacuum
	desc = "This node made it absorb some gasses from the room!"
	var/amount
/datum/relic_node/vacuum/on_generate()
	amount = rand(1, 700)
	return

/datum/relic_node/vacuum/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] absorbs gasses in the room!"))
	playsound(parent_relic, SFX_RUSTLE, 50, TRUE, -5)
	var/turf/local_turf = get_turf(parent_relic)
	var/datum/gas_mixture/environment = local_turf.return_air()
	environment.remove(amount)
	environment.garbage_collect()
	local_turf.air_update_turf(FALSE, FALSE)
	return

/datum/relic_node/outgas
	desc = "This node made it release some gasses into the air!"
	var/amount
	var/datum/gas/gas_type

/datum/relic_node/outgas/on_generate()
	amount = rand(1, 80)
	gas_type = pick(subtypesof(/datum/gas/))

/datum/relic_node/outgas/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] releases [gas_type.name] into the air!"))
	playsound(parent_relic, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/turf/local_turf = get_turf(parent_relic)
	var/datum/gas_mixture/environment = local_turf.return_air()
	environment.assert_gas(gas_type)
	environment.gases[gas_type][MOLES] += amount
	local_turf.air_update_turf(FALSE, FALSE)
	return

/datum/relic_node/explode
	desc = "This node made it explode!!"
	var/light_impact_range
	var/flame_range
	var/flash_range

/datum/relic_node/explode/on_generate()
	light_impact_range = rand(1,5)
	flame_range = rand(1,5)
	flash_range = rand(1,5)
	return

/datum/relic_node/explode/reaction_power(mob/user)
	to_chat(user, span_danger("[parent_relic] starts hissing!"))
	playsound(parent_relic, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	addtimer(CALLBACK(src, PROC_REF(cause_explosion), user), rand(3.5 SECONDS, 6 SECONDS))
	return

/datum/relic_node/explode/proc/cause_explosion(mob/user)
	explosion(parent_relic, devastation_range = 0, heavy_impact_range = 0, light_impact_range = light_impact_range, flame_range = flame_range, flash_range = flash_range, adminlog = TRUE)
	parent_relic.warn_admins(user, "Explosion")
	return

/datum/relic_node/emp
	desc = "This node made it emit an EMP pulse."
	var/strong_range
	var/weak_range

/datum/relic_node/emp/on_generate()
	strong_range = rand(0,3)
	weak_range = rand(0,6)
	return

/datum/relic_node/emp/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] starts sparking!"))
	playsound(parent_relic, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, PROC_REF(cause_emp), user), rand(3.5 SECONDS, 6 SECONDS))
	return

/datum/relic_node/emp/proc/cause_emp(mob/user)
	parent_relic.sparks.start()
	empulse(parent_relic, strong_range, weak_range)
	return

/datum/relic_node/charge
	desc = "This node made it charge nearby devices!"
	var/amount
	var/range
	var/stunner

/datum/relic_node/charge/on_generate()
	amount = rand(1,500)
	range = rand(1, 6)
	stunner = rand(1.0, 3.0) SECONDS
	return

/datum/relic_node/charge/reaction_power(mob/user)
	to_chat(user, span_notice("Things near [parent_relic] surge with power!"))
	for(var/atom/target in view(range, parent_relic))
		if (istype(target, /obj/machinery))
			var/obj/machinery/mach = target
			for (var/each as anything in mach.component_parts)
				if (!istype(each, /obj/item/stock_parts/power_store))
					continue
				var/obj/item/stock_parts/power_store/cell = each
				var/datum/effect_system/spark_spread/_sparks = new
				_sparks.set_up(5, 1, mach)
				_sparks.attach(mach)
				_sparks.start()
				cell.give(min(amount, cell.used_charge()))
				playsound(mach, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				parent_relic.lightning_fx(mach, stunner)
		else
			if (isliving(target))
				var/list/chargeable_batteries = list()
				for(var/obj/item/stock_parts/power_store/C in target.get_all_contents())
					if(C.charge < (C.maxcharge * 0.95)) // otherwise the PDA always gets recharged
						chargeable_batteries |= C
				for(var/obj/item/stock_parts/power_store/to_charge as anything in chargeable_batteries)
					to_charge = pick(chargeable_batteries)
					to_charge.charge = to_charge.maxcharge
					// The device powered by the cell is assumed to be its location.
					var/obj/device = to_charge.loc
					// If it's not an object, or the loc's assigned power_store isn't the cell, undo.
					if(!istype(device) || (device.get_cell() != to_charge))
						device = to_charge
					device.update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
					to_chat(user, span_notice("[device] feels energized!"))
					parent_relic.lightning_fx(target, stunner)
				if(iscarbon(target))
					var/mob/living/carbon/carboner = target
					carboner.electrocute_act(15, parent_relic, flags = SHOCK_NOGLOVES, stun_duration = stunner)
				else if (isliving(target))
					var/mob/living/livign = target
					livign.electrocute_act(15, parent_relic, flags = SHOCK_NOGLOVES)
				parent_relic.lightning_fx(target, stunner)
				to_chat(target, span_bolddanger("You feel surged!"))

/datum/relic_node/harm
	desc = "This node made it change its implements..."
	var/force
	var/damtype

/datum/relic_node/harm/on_generate()
	damtype = pick(BRUTE, BURN, STAMINA, TOX, OXY, BRAIN)
	force = rand(-25, 25)
	return

/datum/relic_node/harm/reaction_power(mob/user)

	if (force == parent_relic.force)
		if (damtype == parent_relic.damtype)
			to_chat(user, span_notice("[parent_relic] seizes up, and seems to do nothing..."))
			return
	else
		if (force > 0)
			if (force < parent_relic.force)
				to_chat(user, span_notice("[parent_relic] transforms to look less harmful."))
			else if (force >= parent_relic.force)
				to_chat(user, span_notice("[parent_relic] transforms to look more harmful!"))
		else
			if (force < parent_relic.force)
				to_chat(user, span_nicegreen("[parent_relic] transforms to look more helpful!"))
			else if (force >= parent_relic.force)
				to_chat(user, span_notice("[parent_relic] transforms to look less helpful."))
	parent_relic.force = force

	if (damtype != parent_relic.damtype)
		to_chat(user, span_notice("The external implements of [parent_relic] look different!"))
		parent_relic.damtype = damtype
	return

/datum/mood_event/relic_sound
	timeout = 10 MINUTES

/datum/mood_event/relic_sound/add_effects(mood_effect)
	mood_change = mood_effect
	switch (mood_effect)
		if (-21 to -10)
			description = "The hollow echoes of that sound ring in my ears."
		if (-11 to 1)
			description = "That uneasing sound is still on my mind."
		if (0 to 10)
			description = "That pleasant sound is still on my mind."
		if (10 to 20)
			description = "Thinking about that sound makes me giddy!"
	return

/datum/relic_node/sound
	desc = "This node made it make a sound.."
	var/mood_effect = 0
	var/range = 0
	var/lowlow_sound
	var/low_sound
	var/high_sound
	var/highhigh_sound
/datum/relic_node/sound/on_generate()
		mood_effect = rand(-20, 20)
		range = rand(1,6)
		lowlow_sound = pick('sound/items/geiger/high4.ogg', 'sound/effects/alert.ogg', 'sound/items/nuke_toy_lowpower.ogg', 'sound/misc/scary_horn.ogg')
		low_sound = pick('sound/items/airhorn/airhorn.ogg', 'sound/items/haunted/ghostitemattack.ogg', 'sound/misc/metal_creak.ogg')
		high_sound = pick('sound/machines/ding.ogg', 'sound/items/can/can_open1.ogg', 'sound/items/rattling_keys.ogg')
		highhigh_sound = pick('sound/effects/achievement/tada_fanfare.ogg')
		return

/datum/relic_node/sound/reaction_power(mob/user)
	switch (mood_effect)
		if (-20 to -10)
			playsound(parent_relic, lowlow_sound, 30, TRUE)
		if (-11 to 1)
			playsound(parent_relic, low_sound, 40, TRUE)
		if (0 to 10)
			playsound(parent_relic, high_sound, 40, TRUE)
		if (10 to 20)
			playsound(parent_relic, highhigh_sound, 40, TRUE)
	for(var/mob/living/m in view(range, parent_relic))
		if (HAS_TRAIT(m, TRAIT_DEAF))
			continue
		switch (mood_effect)
			if (-20 to -10)
				to_chat(m, span_boldwarning("[parent_relic] whispers of something harrowing!"))
			if (-10 to 0)
				to_chat(m, span_warning("[parent_relic] made a noise that was unpleasant."))
			if (0 to 10)
				to_chat(m, span_notice("[parent_relic] made a noise that was pleasing."))
			if (10 to 20)
				to_chat(m, span_nicegreen("[parent_relic] made a noise that was immensely satisfying!"))
		if (m.has_quirk(/datum/quirk/empath))
			m.add_mood_event(REF(src), /datum/mood_event/relic_sound, 2 * mood_effect)
		else
			m.add_mood_event(REF(src), /datum/mood_event/relic_sound, mood_effect)

	return

/datum/relic_node/rad_pulse
	desc = "This node made it emit radiation!!"
	var/range
	var/delta_energy
/datum/relic_node/rad_pulse/on_generate()
	range = rand(1, 6)
	delta_energy = rand(5, 50)

/datum/relic_node/rad_pulse/reaction_power(mob/user)
	to_chat(user, span_warning("[parent_relic] seizes up, and seems to be warm to the touch..."))
	var/turf/local_turf = get_turf(parent_relic)
	var/datum/gas_mixture/turf_gasmix = local_turf.return_air()
	turf_gasmix.temperature += delta_energy / turf_gasmix.heat_capacity()
	local_turf.air_update_turf(FALSE, FALSE)
	radiation_pulse(source = parent_relic, max_range = range, threshold = RAD_MEDIUM_INSULATION)

/datum/relic_node/teleport
	desc = "This node made it teleport somewhere else!!"
/datum/relic_node/teleport/reaction_power(mob/user)
	for(var/mob/living/m in view(3, parent_relic))
		to_chat(m, span_notice("[parent_relic] vanishes into thin air!"))
	var/turf/t = find_safe_turf(zlevel = parent_relic.z)
	for (var/mob/living/m in range(0, parent_relic))
		do_teleport(teleatom = m, destination = t)
	do_teleport(teleatom = parent_relic, destination = t)
	for(var/mob/living/m in view(3, parent_relic))
		to_chat(m, span_notice("[parent_relic] appears out of nowhere!"))

/datum/relic_node/dimensional_shift
	desc = "This node made it the tiles change dimensional orientation..."
	var/new_theme_path

/datum/relic_node/dimensional_shift/on_generate()
	new_theme_path = pick(subtypesof(/datum/dimension_theme))
	return

/datum/relic_node/dimensional_shift/reaction_power(mob/user)
	to_chat(user, span_notice("[parent_relic] shifts the dimension around it!"))
	var/datum/dimension_theme/shifter = SSmaterials.dimensional_themes[new_theme_path]
	for(var/turf/shiftee in range(1, user))
		shifter.apply_theme(shiftee, show_effect = TRUE)
	return

/datum/relic_node/blood
	desc = "This node made the relic feast on flesh!"
	var/amount = 0

/datum/relic_node/blood/on_generate()
	amount = rand(10, 200)

/datum/relic_node/blood/reaction_power(mob/user)
	new /obj/effect/decal/cleanable/blood/old(get_turf(src))
	for(var/mob/living/m in view(1, parent_relic))
		new /obj/effect/decal/cleanable/blood/old(get_turf(m))
		if (istype(m, /mob/living/carbon/))
			var/mob/living/carbon/c = m
			playsound(parent_relic, SFX_DESECRATION, 50, TRUE)
			if (prob(80)) // Just blood.. blood..
				c.blood_volume -= amount
				to_chat(c, span_bolddanger("[parent_relic] drains some of your succulent lifeforce!"))
			else if (prob(95)) // Steal a non-brain organ
				var/obj/item/organ/remove_organ = pick(GLOB.bioscrambler_valid_organs)
				if (c.organs_slot.Find(remove_organ.slot))
					c.organs_slot[remove_organ.slot].mob_remove(c)
					to_chat(c, span_bolddanger("[parent_relic] demands something more, and you feel a little hollow."))
				else
					to_chat(c, span_warning("[parent_relic] demands something more, but you do not have what it wants."))
			else // get a gift :)
				to_chat(c, span_bolddanger("[parent_relic] offers a gift, and you feel your insides change to accept!"))
				var/gland_type = subtypesof(/obj/item/organ/heart/gland)
				var/obj/item/organ/heart/gland/new_gland = new gland_type()
				if (new_gland)
					new_gland.replace_into(c)
		else
			m.blood_volume -= amount
			to_chat(m, span_danger("[parent_relic] drains some of your lifeforce!"))

/datum/relic_node/rosetta
	desc = "This node offers thesaurical knowledge..."
	var/language
	var/percent

/datum/relic_node/rosetta/on_generate()
	language = pick(subtypesof(/datum/language/))
	percent = rand(1, 100)

// The Platforms PR changed how table pushing works and I (Cirr) am pushed for time, so this is getting commented out.
// FIXME!!!

// /datum/relic_node/tabled
// 	desc = "This node slammed things onto a table!"
// 	var/grapple_range
// 	var/table_range

// /datum/relic_node/tabled/on_generate()
// 	grapple_range = rand(1, 4)
// 	table_range = rand(6, 15)

// /datum/relic_node/tabled/reaction_power(mob/user)
// 	var/list/table_list = list()
// 	for (var/obj/structure/table/t in range(table_range, parent_relic))
// 		table_list.Add(t)
// 	var/obj/structure/table/chosen_one = pick(table_list)
// 	for (var/mob/living/m in view(table_range, parent_relic))
// 		chosen_one.tablepush(m, m)

/obj/item/relic
	desc = "What mysteries could this hold? Maybe Research & Development knows how to analyze it...."
	//Minimum possible cooldown.
	min_cooldown = 2 SECONDS
	//Max possible cooldown.
	max_cooldown = 12 SECONDS
	w_class = 3
	var/canhear_range = 5
	var/node_limit = 0
	var/list/relic_nodes = list()
	var/datum/relic_node/current_node
	var/very_dangerous = FALSE
	var/reacting_when_off_cooldown = FALSE //has a pending reaction
	var/static/list/existing_relics = list()

	var/static/list/relic_reactions = list(
		/datum/relic_node/no_effect = 10,
		/datum/relic_node/reagent 	= 10,
		/datum/relic_node/item		= 10,
		/datum/relic_node/animal	= 10,
		/datum/relic_node/emp		= 10,
		/datum/relic_node/charge	= 10,
		/datum/relic_node/explode	= 10,
		/datum/relic_node/harm		= 10,
		/datum/relic_node/vacuum	= 10,
		/datum/relic_node/outgas	= 10,
		/datum/relic_node/sound		= 10,
		/datum/relic_node/rad_pulse	= 10,
		/datum/relic_node/teleport	= 10,
		/datum/relic_node/dimensional_shift = 10,
		/datum/relic_node/blood		= 10,
		/datum/relic_node/rosetta	= 10,
		// /datum/relic_node/tabled	= 10,
	)

	var/static/list/relic_trans_types = list(
		/datum/relic_trans/none		= 10,
		/datum/relic_trans/touch	= 10,
		/datum/relic_trans/harm		= 10,
		/datum/relic_trans/fire		= 10,
		/datum/relic_trans/reagent	= 10,
		/datum/relic_trans/paint	= 10,
		// /datum/relic_trans/vacuum, // Requires adding a tick, not gonna do that.
		/datum/relic_trans/irradiate= 10,
		/datum/relic_trans/explode	= 10,
		/datum/relic_trans/tracked	= 10,
		/datum/relic_trans/hear		= 10,
	)

/obj/item/relic/Initialize()
	. = ..()
	existing_relics.Add(src)
	RegisterSignal(src, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emped))
	RegisterSignal(src, COMSIG_ATOM_FIRE_ACT, PROC_REF(on_fired))
	RegisterSignal(src, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))
	RegisterSignal(src, COMSIG_ATOM_AFTER_EXPOSE_REAGENTS, PROC_REF(on_exposure))
	RegisterSignal(src, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_clicked))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IRRADIATED), PROC_REF(on_radiated))

/obj/item/relic/Destroy(force)
	existing_relics.Remove(src)
	for (var/each as anything in relic_nodes)
		QDEL_NULL(each)
	. = ..()

/obj/item/relic/random_themed_appearance() // TODO: rewrite the original so adding shit is easier
	. = ..()
	if (prob(1.0))
		icon = 'troutstation/icons/obj/devices/artefacts.dmi'
		icon_state = "plushie_archytas"
	update_appearance()

/obj/item/relic/proc/on_emped(severity, protection)
	SIGNAL_HANDLER
	current_node.check_trans(null, /datum/relic_trans/emp)
	return

/obj/item/relic/proc/on_fired(exposed_temperature, exposed_volume)
	SIGNAL_HANDLER
	current_node.check_trans(null, /datum/relic_trans/fire)
	return

/obj/item/relic/proc/on_clicked(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	if(item.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		balloon_alert(user, "The heat transfer warms [src].")
		current_node.check_trans(user, /datum/relic_trans/fire)
	if (istype(item, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = item
		container.reagents.remove_all(container.amount_per_transfer_from_this)
		balloon_alert(user, "[container.amount_per_transfer_from_this] units splashed on [src]")
		current_node.check_trans(user, /datum/relic_trans/reagent)

		return ITEM_INTERACT_SUCCESS
	return

/obj/item/relic/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	SIGNAL_HANDLER
	current_node.check_trans(owner, /datum/relic_trans/harm, owner)
	return

/obj/item/relic/proc/on_painted()
	SIGNAL_HANDLER
	current_node.check_trans(null, /datum/relic_trans/paint)
	return

/obj/item/relic/proc/on_exposure(list/lists, /datum/reagents/the_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	current_node.check_trans(null, /datum/relic_trans/reagent)
	return

/obj/item/relic/proc/on_radiated()
	SIGNAL_HANDLER
	current_node.check_trans(null, /datum/relic_trans/irradiate)
	return


/obj/item/relic/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if (speaker == src || get_dist(src, speaker) > canhear_range || message_mods[MODE_RELAY])
		return .
	// to_chat(speaker, span_warning("DEBUG: [src] is listening to [speaker]...."))
	current_node.check_trans(null, /datum/relic_trans/hear)
	return .

// Rules:
// - Creates 3-15 nodes
// - Each node has 2-4 connections
// - Orphaned nodes are given a connection (this can break limits)
/obj/item/relic/proc/generate()
	become_hearing_sensitive(INNATE_TRAIT)
	var/list/datum/relic_node/not_orphaned = list()
	// Generate nodes up to limit
	node_limit = rand(3, 15)
	for (var/_i in 0 to node_limit)
		var/relic_type = pick_weight(relic_reactions)
		var/datum/relic_node/new_relic_node = new relic_type
		new_relic_node.parent_relic = src
		new_relic_node.node_id = _i
		new_relic_node.on_generate()
		relic_nodes.Add(new_relic_node)
	current_node = pick(relic_nodes)
	not_orphaned.Add(current_node)

	// Add connections between nodes
	for (var/datum/relic_node/it as anything in relic_nodes)
		for (var/i in 2 to 4)
			var/relic_trans_type = pick_weight(relic_trans_types)
			var/datum/relic_trans/new_relic_trans = new relic_trans_type
			do
				new_relic_trans.next_node = pick(relic_nodes)
			while (new_relic_trans.next_node == it)
			if (not_orphaned.Find(new_relic_trans.next_node))
				not_orphaned.Add(current_node)
			else if (not_orphaned.Find(current_node))
				not_orphaned.Add(new_relic_trans.next_node)
			it.relic_transes.Add(new_relic_trans)

	//FAILSAFE: Orphaned nodes need connections to a non-orphaned node generated
	for (var/datum/relic_node/it as anything in relic_nodes)
		if (not_orphaned.Find(it))
			continue

		var/relic_trans_type = pick(relic_trans_types)
		var/datum/relic_trans/new_relic_trans = new relic_trans_type
		new_relic_trans.next_node = pick(not_orphaned)
		it.relic_transes.Add(new_relic_trans)

		relic_trans_type = pick(relic_trans_types)
		var/datum/relic_trans/new_relic_trans2 = new relic_trans_type
		new_relic_trans2.next_node = it
		new_relic_trans.next_node.relic_transes.Add(new_relic_trans2)

	return

///Overrides for base methods

/obj/item/relic/attack_hand(mob/user, list/modifiers)
	if (!activated)
		return ..()
	var/mob/living/living_user = user
	if(istype(living_user) && living_user.combat_mode)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		to_chat(user, span_warning("You smack the [src]!"))
		current_node.check_trans(user, /datum/relic_trans/harm, user)
		return TRUE
	else
		if (istype(current_node, /datum/relic_node/rosetta) && istype(user, /mob/living))
			var/datum/relic_node/rosetta/r = current_node
			var/mob/living/l = user;
			to_chat(user, span_notice("[src] has unknown text that fills you with knowledge of a language."))
			l.grant_partial_language(r.language, r.percent, MAGIC_TRAIT)
		else
			to_chat(user, span_notice("You touch [src], its surface seems inviting."))
		current_node.check_trans(user, /datum/relic_trans/touch)
	return ..()

/obj/item/relic/attack_self(mob/user)
	if(!activated)
		to_chat(user, span_notice("[desc]"))
		return //..()

	var/mob/living/living_user = user
	if(istype(living_user) && living_user.combat_mode)
		to_chat(user, span_warning("You smack the [src]!"))
		current_node.check_trans(user, /datum/relic_trans/harm, user)
	else
		to_chat(user, span_notice("You touch [src], its surface seems inviting."))
		current_node.check_trans(user, /datum/relic_trans/touch)
	return //..()

/obj/item/relic/attack(mob/M, mob/user)
	if(!activated)
		to_chat(user, span_notice("[desc]"))
		return ..()

	var/mob/living/living_user = user
	if(istype(living_user) && living_user.combat_mode)
		if (M == user)
			to_chat(user, span_warning("You smack yourself with [src]!"))
		else
			to_chat(user, span_warning("You smack [M] with [src]!"))
		current_node.check_trans(user, /datum/relic_trans/harm, M)
	return ..()

/obj/item/relic/ex_act(severity, target)
	current_node.check_trans(null, /datum/relic_trans/explode)
	return

/obj/item/relic/Destroy(force)
	for (var/each as anything in relic_nodes)
		QDEL_NULL(each)
	. = ..()

/obj/item/relic/reveal()
	if(activated) //no rerolling
		return
	activated = TRUE
	name = real_name
	if(!cooldown_timer)
		cooldown_timer = rand(min_cooldown, max_cooldown)
	generate()
///


/datum/supply_pack/imports/relicorder
	name = "Spare Relic Dodads"
	desc = "We have zero clue what these do, and frankly they're piling up. Could you take some off our hands?"
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/relic = 3, /obj/item/pinpointer/relic = 1, /obj/item/relicanalyzer = 1)
	crate_name = "Spare Relics Crate"
	crate_type = /obj/structure/closet/crate/science
