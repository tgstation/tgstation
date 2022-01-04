/datum/round_event_control/spacevine
	name = "Space Vines"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/vine = new()

	for(var/area/hallway/area in world)
		for(var/turf/floor in area)
			if(floor.Enter(vine))
				turfs += floor

	qdel(vine)

	if(length(turfs)) //Pick a turf to spawn at if we can
		var/turf/floor = pick(turfs)
		new /datum/spacevine_controller(floor, list(pick(subtypesof(/datum/spacevine_mutation))), rand(10,100), rand(1,6), src) //spawn a controller at turf with randomized stats and a single random mutation


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/item, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/chem)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/aggressive_spread/proc/aggrospread_act(obj/structure/spacevine/vine, mob/living/M)
	return

/datum/spacevine_mutation/light
	name = "Light"
	hue = "#B2EA70"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity, 0.3)

/datum/spacevine_mutation/toxicity
	name = "Toxic"
	hue = "#9B3675"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		to_chat(crosser, span_alert("You accidentally touch the vine and feel a strange sensation."))
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  // JC IT'S A BOMB
	name = "Explosive"
	hue = "#D83A56"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		QDEL_IN(holder, 5)

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/item)
	explosion(holder, light_impact_range = severity, adminlog = FALSE)

/datum/spacevine_mutation/fire_proof
	name = "Fire proof"
	hue = "#FF616D"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/item, expected_damage)
	if(item && item.damtype == BURN)
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/vine_eating
	name = "Vine eating"
	hue = "#F4A442"
	quality = MINOR_NEGATIVE

/// Destroys any vine on spread-target's tile. The checks for if this should be done are in the spread() proc.
/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/obj/structure/spacevine/prey in target)
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "Aggressive spreading"
	hue = "#316b2f"
	severity = 3
	quality = NEGATIVE

/// Checks mobs on spread-target's turf to see if they should be hit by a damaging proc or not.
/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/turf, mob/living)
	for(var/mob/living/victim in turf)
		if(!isvineimmune(victim) && victim.stat != DEAD) // Don't kill immune creatures. Dead check to prevent log spam when a corpse is trapped between vine eaters.
			aggrospread_act(holder, victim)

/// What happens if an aggr spreading vine buckles a mob.
/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	aggrospread_act(holder, buckled)

/// Hurts mobs. To be used when a vine with aggressive spread mutation spreads into the mob's tile or buckles them.
/datum/spacevine_mutation/aggressive_spread/aggrospread_act(obj/structure/spacevine/vine, mob/living/living_mob)
	var/mob/living/carbon/victim = living_mob //If the mob is carbon then it now also exists as a victim, and not just an living mob.
	if(istype(victim)) //If the mob (M) is a carbon subtype (C) we move on to pick a more complex damage proc, with damage zones, wounds and armor mitigation.
		var/obj/item/bodypart/limb = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD, BODY_ZONE_CHEST) //Picks a random bodypart. Does not runtime even if it's missing.
		var/armor = victim.run_armor_check(limb, MELEE, null, null) //armor = the armor value of that randomly chosen bodypart. Nulls to not print a message, because it would still print on pierce.
		var/datum/spacevine_mutation/thorns/thorn = locate() in vine.mutations //Searches for the thorns mutation in the "mutations"-list inside obj/structure/spacevine, and defines T if it finds it.
		if(thorn && (prob(40))) //If we found the thorns mutation there is now a chance to get stung instead of lashed or smashed.
			victim.apply_damage(50, BRUTE, def_zone = limb, wound_bonus = rand(-20,10), sharpness = SHARP_POINTY) //This one gets a bit lower damage because it ignores armor.
			victim.Stun(1 SECONDS) //Stopped in place for a moment.
			playsound(living_mob, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
			living_mob.visible_message(span_danger("[living_mob] is nailed by a sharp thorn!"), \
			span_userdanger("You are nailed by a sharp thorn!"))
			log_combat(vine, living_mob, "aggressively pierced") //"Aggressively" for easy ctrl+F'ing in the attack logs.
		else
			if(prob(80))
				victim.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = SHARP_EDGED)
				victim.Knockdown(2 SECONDS)
				playsound(victim, 'sound/weapons/whip.ogg', 50, TRUE, -1)
				living_mob.visible_message(span_danger("[living_mob] is lacerated by an outburst of vines!"), \
				span_userdanger("You are lacerated by an outburst of vines!"))
				log_combat(vine, living_mob, "aggressively lacerated")
			else
				victim.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = NONE)
				victim.Knockdown(3 SECONDS)
				var/atom/throw_target = get_edge_target_turf(living_mob, get_dir(vine, get_step_away(living_mob, vine)))
				victim.throw_at(throw_target, 3, 6)
				playsound(victim, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
				living_mob.visible_message(span_danger("[living_mob] is smashed by a large vine!"), \
				span_userdanger("You are smashed by a large vine!"))
				log_combat(vine, living_mob, "aggressively smashed")
	else //Living but not a carbon? Maybe a silicon? Can't be wounded so have a big chunk of simple bruteloss with no special effects. They can be entangled.
		living_mob.adjustBruteLoss(75)
		playsound(living_mob, 'sound/weapons/whip.ogg', 50, TRUE, -1)
		living_mob.visible_message(span_danger("[living_mob] is brutally threshed by [vine]!"), \
		span_userdanger("You are brutally threshed by [vine]!"))
		log_combat(vine, living_mob, "aggressively spread into") //You aren't being attacked by the vines. You just happen to stand in their way.

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "Oxygen consuming"
	hue = "#28B5B5"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/oxygen])
			return
		gas_mix.gases[/datum/gas/oxygen][MOLES] = max(gas_mix.gases[/datum/gas/oxygen][MOLES] - severity * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/nitro_eater
	name = "Nitrogen consuming"
	hue = "#FF7B54"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/nitrogen])
			return
		gas_mix.gases[/datum/gas/nitrogen][MOLES] = max(gas_mix.gases[/datum/gas/nitrogen][MOLES] - severity * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#798777"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/carbon_dioxide])
			return
		gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] = max(gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] - severity * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/plasma_eater
	name = "Plasma consuming"
	hue = "#9074b6"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/plasma])
			return
		gas_mix.gases[/datum/gas/plasma][MOLES] = max(gas_mix.gases[/datum/gas/plasma][MOLES] - severity * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/thorns
	name = "Thorny"
	hue = "#9ECCA4"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		var/mob/living/victim = crosser
		victim.adjustBruteLoss(5)
		to_chat(victim, span_danger("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(hitter))
		var/mob/living/victim = hitter
		victim.adjustBruteLoss(5)
		to_chat(victim, span_danger("You cut yourself on the thorny vines."))
	. = expected_damage

/datum/spacevine_mutation/woodening
	name = "Hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_density(TRUE)
	holder.modify_max_integrity(100)

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(item?.get_sharpness())
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/flowering
	name = "Flowering"
	hue = "#66DE93"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud) in range(5,holder))
		new/obj/structure/alien/resin/flower_bud(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)

// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vine"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	var/datum/spacevine_controller/master = null
	/// List of mutations for a specific vine
	var/list/mutations = list()

/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/spacevine/examine(mob/user)
	. = ..()
	if(!length(mutations))
		. += "This vine has no mutations."
		return
	var/text = "This vine has the following mutations:\n"
	for(var/datum/spacevine_mutation/mutation as anything in mutations)
		if(mutation.name == "transparent") /// Transparent has no hue
			text += "<font color='#346751'>Transparent</font> "
		else
			text += "<font color='[mutation.hue]'>[mutation.name]</font> "
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/chem)
	var/override = 0
	for(var/datum/spacevine_mutation/mutation in mutations)
		override += mutation.on_chem(src, chem)
	if(!override && istype(chem, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/mutation in mutations)
		override += mutation.on_eat(src, eater)
	if(!override)
		qdel(src)

/obj/structure/spacevine/attacked_by(obj/item/item, mob/living/user)
	var/damage_dealt = item.force
	if(item.get_sharpness())
		damage_dealt *= 4
	if(item.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/mutation in mutations)
		damage_dealt = mutation.on_hit(src, user, item, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, item.damtype, MELEE, 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(!isliving(movable))
		return
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_cross(src, movable)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user, list/modifiers)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_hit(src, user)
	user_unbuckle_mob(user, user)
	. = ..()

/obj/structure/spacevine/attack_paw(mob/living/user, list/modifiers)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user, list/modifiers)
	eat(user)

/datum/spacevine_controller
	var/list/obj/structure/spacevine/vines
	var/list/growth_queue
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/vine_mutations_list
	var/mutativeness = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, datum/round_event/event = null)
	vines = list()
	growth_queue = list()
	var/obj/structure/spacevine/vine = spawn_spacevine_piece(location, null, muts)
	if(event)
		event.announce_to_ghosts(vine)
	START_PROCESSING(SSobj, src)
	vine_mutations_list = list()
	init_subtypes(/datum/spacevine_mutation/, vine_mutations_list)
	if(potency != null)
		mutativeness = potency / 10
	if(production != null && production <= 10) //Prevents runtime in case production is set to 11.
		spread_cap *= (11 - production) / 5 //Best production speed of 1 doubles spread_cap to 60 while worst speed of 10 lowers it to 6. Even distribution.
		spread_multiplier /= (11 - production) / 5

/datum/spacevine_controller/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPACEVINE_PURGE, "Delete Vines")

/datum/spacevine_controller/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_SPACEVINE_PURGE])
		if(tgui_alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", list("Yes", "No")) == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines() //this is kill
	QDEL_LIST(vines) //this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/vine = new(location)
	growth_queue += vine
	vines += vine
	vine.master = src
	if(length(muts))
		for(var/datum/spacevine_mutation/mutation in muts)
			mutation.add_mutation_to_vinepiece(vine)
	if(parent)
		vine.mutations |= parent.mutations
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		vine.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/random_mutate = pick(vine_mutations_list - vine.mutations)
			random_mutate.add_mutation_to_vinepiece(vine)

	for(var/datum/spacevine_mutation/mutation in vine.mutations)
		mutation.on_birth(vine)
	location.Entered(vine, null)
	return vine

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/vine)
	vine.master = null
	vines -= vine
	growth_queue -= vine
	if(!length(vines))
		var/obj/item/seeds/kudzu/seed = new(vine.loc)
		seed.mutations |= vine.mutations
		seed.set_potency(mutativeness * 10)
		seed.set_production(11 - (spread_cap / initial(spread_cap)) * 5) //Reverts spread_cap formula so resulting seed gets original production stat or equivalent back.
		qdel(src)

/// Life cycle of a space vine
/datum/spacevine_controller/process(delta_time)
	if(!LAZYLEN(vines))
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = round(clamp(delta_time * 0.5 * length(vines) / spread_multiplier, 1, spread_cap))
	var/index = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/vine in growth_queue)
		if(QDELETED(vine))
			continue
		index++
		queue_end += vine
		growth_queue -= vine
		for(var/datum/spacevine_mutation/mutation in vine.mutations)
			mutation.process_mutation(vine)
		if(vine.energy < 2) //If tile isn't fully grown
			if(DT_PROB(10, delta_time))
				vine.grow()
		else //If tile is fully grown
			vine.entangle_mob()

		vine.spread()
		if(index >= length)
			break

	growth_queue = growth_queue + queue_end

/// Updates the icon as the space vine grows
/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_grow(src)

/// Buckles mobs trying to pass through it
/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/victim in src.loc)
			entangle(victim)
			if(has_buckled_mobs())
				break //only capture one mob at a time

/obj/structure/spacevine/proc/entangle(mob/living/victim)
	if(!victim || isvineimmune(victim))
		return
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.on_buckle(src, victim)
	if((victim.stat != DEAD) && (victim.buckled != src)) //not dead or captured
		to_chat(victim, span_userdanger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(victim, 1)

/// Finds a target tile to spread to. If checks pass it will spread to it and also proc on_spread on target.
/obj/structure/spacevine/proc/spread()
	var/direction = pick(GLOB.cardinals)
	var/turf/stepturf = get_step(src, direction)
	if(!isspaceturf(stepturf) && stepturf.Enter(src))
		var/obj/structure/spacevine/spot_taken = locate() in stepturf //Locates any vine on target turf. Calls that vine "spot_taken".
		var/datum/spacevine_mutation/vine_eating/eating = locate() in mutations //Locates the vine eating trait in our own seed and calls it E.
		if(!spot_taken || (eating && (spot_taken && !spot_taken.mutations?.Find(eating)))) //Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't. Vines from other seeds are eaten regardless.
			if(master)
				for(var/datum/spacevine_mutation/mutation in mutations)
					mutation.on_spread(src, stepturf) //Only do the on_spread proc if it actually spreads.
					stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
				master.spawn_spacevine_piece(stepturf, src)

/// Destroying an explosive vine sets off a chain reaction
/obj/structure/spacevine/ex_act(severity, target)
	var/index
	for(var/datum/spacevine_mutation/mutation in mutations)
		index += mutation.on_explosion(severity, target, src)
	if(!index && prob(34 * severity))
		qdel(src)

/obj/structure/spacevine/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD //if you're cold you're safe

/obj/structure/spacevine/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	var/volume = air.return_volume()
	for(var/datum/spacevine_mutation/mutation in mutations)
		if(mutation.process_temperature(src, exposed_temperature, volume)) //If it's ever true we're safe
			return
	qdel(src)

/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isvineimmune(mover))
		return TRUE

/**
 * Used to determine whether the mob is immune to actions by the vine.
 * Use cases: Stops vine from attacking itself, other plants.
 */
/proc/isvineimmune(atom/target)
	if(isliving(target))
		var/mob/living/victim = target
		if(("vines" in victim.faction) || ("plants" in victim.faction))
			return TRUE
	return FALSE
