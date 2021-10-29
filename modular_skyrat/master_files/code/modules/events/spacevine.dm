/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 10
	max_occurrences = 1
	min_players = 60

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	//list of all the empty floor turfs in the hallway areas
	var/list/turfs = list()
	var/obj/structure/spacevine/new_vine = new()

	for(var/area/maintenance/maint_area in world)
		for(var/turf/maint_turf in maint_area)
			if(maint_turf.Enter(new_vine))
				turfs += maint_turf

	qdel(new_vine)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/spawning_turf = pick(turfs)
		new /datum/spacevine_controller(spawning_turf, list(pick(subtypesof(/datum/spacevine_mutation))), rand(10,100), rand(1,6), src) //spawn a controller at turf with randomized stats and a single random mutation
		new /mob/living/simple_animal/hostile/venus_human_trap(spawning_turf)
		new /mob/living/simple_animal/hostile/venus_human_trap(spawning_turf)

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

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/aggressive_spread/proc/aggrospread_act(obj/structure/spacevine/S, mob/living/M)
	return

// Creates light
/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity, 0.3)


// Deals toxin damage when crossed or eaten
/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
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


// Explodes - chain reaction, or on death
/datum/spacevine_mutation/explosive
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		QDEL_IN(holder, 5)

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	explosion(holder, light_impact_range = severity, adminlog = FALSE)


// Immune to fire and fire damage
/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/weapon_used, expected_damage)
	if(weapon_used && weapon_used.damtype == BURN)
		. = 0
	else
		. = expected_damage


// Overrides existing vines when spreading to a tile
/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/// Destroys any vine on spread-target's tile. The checks for if this should be done are in the spread() proc.
/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/obj/structure/spacevine/prey in target)
		qdel(prey)


// Hurts mobs when interacting with a mob - either on spread or buckle
/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/// Checks mobs on spread-target's turf to see if they should be hit by a damaging proc or not.
/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/target, mob/living)
	for(var/mob/living/damaged_mob in target)
		if(!isvineimmune(damaged_mob) && damaged_mob.stat != DEAD) // Don't kill immune creatures. Dead check to prevent log spam when a corpse is trapped between vine eaters.
			aggrospread_act(holder, damaged_mob)

/// What happens if an aggr spreading vine buckles a mob.
/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	aggrospread_act(holder, buckled)

/// Hurts mobs. To be used when a vine with aggressive spread mutation spreads into the mob's tile or buckles them.
/datum/spacevine_mutation/aggressive_spread/aggrospread_act(obj/structure/spacevine/attacking_vine, mob/living/hit_mob)
	var/mob/living/carbon/hit_carbon = hit_mob //If the mob is carbon then it now also exists as hit_carbon, and not just hit_mob.
	if(!istype(hit_carbon)) //Living but not a carbon? Maybe a silicon? Can't be wounded so have a big chunk of simple bruteloss with no special effects. They can be entangled.
		hit_mob.adjustBruteLoss(75)
		playsound(hit_mob, 'sound/weapons/whip.ogg', 50, TRUE, -1)
		hit_mob.visible_message(span_danger("[hit_mob] is brutally threshed by [attacking_vine]!"), span_userdanger("You are brutally threshed by [attacking_vine]!"))
		log_combat(attacking_vine, hit_mob, "aggressively spread into") //You aren't being attacked by the vines. You just happen to stand in their way.
		return

	//If hit_mob IS a carbon subtype (hit_carbon) we move on to pick a more complex damage proc, with damage zones, wounds and armor mitigation.
	var/obj/item/bodypart/limb = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD, BODY_ZONE_CHEST) //Picks a random bodypart. Does not runtime even if it's missing.
	var/armor = hit_carbon.run_armor_check(limb, MELEE, null, null) //armor = the armor value of that randomly chosen bodypart. Nulls to not print a message, because it would still print on pierce.
	var/datum/spacevine_mutation/thorns/has_thorns = locate() in attacking_vine.mutations //Searches for the thorns mutation in the "mutations"-list inside obj/structure/spacevine, and defines T if it finds it.
	if(has_thorns && (prob(40))) //If we found the thorns mutation there is now a chance to get stung instead of lashed or smashed.
		hit_carbon.apply_damage(50, BRUTE, def_zone = limb, wound_bonus = rand(-20,10), sharpness = SHARP_POINTY) //This one gets a bit lower damage because it ignores armor.
		hit_carbon.Stun(1 SECONDS) //Stopped in place for a moment.
		playsound(hit_mob, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
		hit_mob.visible_message(span_danger("[hit_mob] is nailed by a sharp thorn!"), span_userdanger("You are nailed by a sharp thorn!"))
		log_combat(attacking_vine, hit_mob, "aggressively pierced") //"Aggressively" for easy ctrl+F'ing in the attack logs.
	else
		if(prob(80))
			hit_carbon.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = SHARP_EDGED)
			hit_carbon.Knockdown(2 SECONDS)
			playsound(hit_mob, 'sound/weapons/whip.ogg', 50, TRUE, -1)
			hit_mob.visible_message(span_danger("[hit_mob] is lacerated by an outburst of vines!"), span_userdanger("You are lacerated by an outburst of vines!"))
			log_combat(attacking_vine, hit_mob, "aggressively lacerated")
		else
			hit_carbon.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = NONE)
			hit_carbon.Knockdown(3 SECONDS)
			var/atom/throw_target = get_edge_target_turf(hit_carbon, get_dir(attacking_vine, get_step_away(hit_carbon, attacking_vine)))
			hit_carbon.throw_at(throw_target, 3, 6)
			playsound(hit_mob, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
			hit_mob.visible_message(span_danger("[hit_mob] is smashed by a large vine!"), span_userdanger("You are smashed by a large vine!"))
			log_combat(attacking_vine, hit_mob, "aggressively smashed")


// See-through
/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125


// Consumes oxygen gas on process
/datum/spacevine_mutation/oxy_eater
	name = "oxygen consuming"
	hue = "#ffff88"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/current_turf = holder.loc
	if(!istype(current_turf))
		return
	var/datum/gas_mixture/gas_mix = current_turf.air
	if(!gas_mix.gases[/datum/gas/oxygen])
		return
	gas_mix.gases[/datum/gas/oxygen][MOLES] = max(gas_mix.gases[/datum/gas/oxygen][MOLES] - severity * holder.energy, 0)
	gas_mix.garbage_collect()


// Consumes nitrogen gas on process
/datum/spacevine_mutation/nitro_eater
	name = "nitrogen consuming"
	hue = "#8888ff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/current_turf = holder.loc
	if(!istype(current_turf))
		return
	var/datum/gas_mixture/gas_mix = current_turf.air
	if(!gas_mix.gases[/datum/gas/nitrogen])
		return
	gas_mix.gases[/datum/gas/nitrogen][MOLES] = max(gas_mix.gases[/datum/gas/nitrogen][MOLES] - severity * holder.energy, 0)
	gas_mix.garbage_collect()


// Consumes carbon dioxide gas on process
/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#00ffff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/current_turf = holder.loc
	if(!istype(current_turf))
		return
	var/datum/gas_mixture/gas_mix = current_turf.air
	if(!gas_mix.gases[/datum/gas/carbon_dioxide])
		return
	gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] = max(gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] - severity * holder.energy, 0)
	gas_mix.garbage_collect()


// Consumes plasma gas on process
/datum/spacevine_mutation/plasma_eater
	name = "toxins consuming"
	hue = "#ffbbff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/current_turf = holder.loc
	if(!istype(current_turf))
		return
	var/datum/gas_mixture/gas_mix = current_turf.air
	if(!gas_mix.gases[/datum/gas/plasma])
		return
	gas_mix.gases[/datum/gas/plasma][MOLES] = max(gas_mix.gases[/datum/gas/plasma][MOLES] - severity * holder.energy, 0)
	gas_mix.garbage_collect()


// Deals damage to mobs that cross or attack it
/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		var/mob/living/living_crosser = crosser
		living_crosser.adjustBruteLoss(5)
		to_chat(living_crosser, span_alert("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(hitter))
		var/mob/living/attacking_mob = hitter
		attacking_mob.adjustBruteLoss(5)
		to_chat(attacking_mob, span_alert("You cut yourself on the thorny vines."))
	. = expected_damage


// Dense, with reduced damage from sharp weapons
/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.density = TRUE
	holder.modify_max_integrity(100)

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/weapon, expected_damage)
	if(weapon?.get_sharpness())
		. = expected_damage * 0.5
	else
		. = expected_damage


// Creates flower buds on growth - these spawn venus human traps
/datum/spacevine_mutation/flowering
	name = "flowering"
	hue = "#0A480D"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud) in range(5,holder))
		new/obj/structure/alien/resin/flower_bud(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)


// Slips on cross
/datum/spacevine_mutation/slipping
	name = "slipping"
	hue = "#97eaff"
	severity = 1
	quality = NEGATIVE

/datum/spacevine_mutation/slipping/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(ishuman(crosser))
		var/mob/living/carbon/human/living_crosser = crosser
		living_crosser.slip(20)
		to_chat(living_crosser, span_alert("The vines slip you!"))


// Teleports on hit
/datum/spacevine_mutation/teleporting
	name = "teleporting"
	hue = "#1105b6"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/teleporting/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(isliving(hitter))
		var/mob/living/attacking_mob = hitter
		if(isvineimmune(attacking_mob))
			return
		if(prob(25))
			do_teleport(attacking_mob, get_turf(attacking_mob), 8, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	. = expected_damage


// Has a chance to reflect melee damage
/datum/spacevine_mutation/meleereflecting
	name = "melee reflecting"
	hue = "#b6054f"
	severity = 2
	quality = NEGATIVE

/datum/spacevine_mutation/meleereflecting/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(isliving(hitter))
		var/mob/living/attacking_mob = hitter
		if(isvineimmune(attacking_mob))
			return
		if(prob(10))
			attacking_mob.adjustBruteLoss(expected_damage)
		else
			. = expected_damage


// Has a chance to plant more kudzu when crossed or hit
/datum/spacevine_mutation/seeding
	name = "seeding"
	hue = "#68b95d"
	severity = 3
	quality = NEGATIVE

/// Plants kudzu. To be used with vines with the seeding mutation
/mob/living/proc/plant_kudzu()
	var/turf/planted_turf = get_turf(src)
	var/list/added_mut_list = list()
	new /datum/spacevine_controller(planted_turf, added_mut_list, 50, 5)
	new /mob/living/simple_animal/hostile/venus_human_trap(planted_turf)

/datum/spacevine_mutation/seeding/on_cross(obj/structure/spacevine/holder, mob/crosser)
	if(isliving(crosser))
		var/mob/living/living_crosser = crosser
		if(isvineimmune(living_crosser) || living_crosser.stat == DEAD)
			return
		if(prob(10))
			addtimer(CALLBACK(living_crosser, /mob/living/proc/plant_kudzu), 1 MINUTES)

/datum/spacevine_mutation/seeding/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/weapon, expected_damage)
	if(isliving(hitter))
		var/mob/living/living_hitter = hitter
		if(isvineimmune(living_hitter))
			return
		if(prob(10))
			addtimer(CALLBACK(living_hitter, /mob/living/proc/plant_kudzu), 1 MINUTES)
	. = expected_damage

// Has a chance to electrocute mobs that hit it
/datum/spacevine_mutation/electrify
	name = "electrified"
	hue = "#f7eb86"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/electrify/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(isliving(hitter))
		var/mob/living/living_hitter = hitter
		if(isvineimmune(living_hitter))
			return
		if(prob(20))
			living_hitter.electrocute_act(10, holder)
	. = expected_damage


// EMP explosion on death
/datum/spacevine_mutation/emp
	name = "emp"
	hue = "#ffffff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/emp/on_death(obj/structure/spacevine/holder)
	empulse(holder, 1, 2)


// Has a chance to inject a random reagent into crossing mobs
/datum/spacevine_mutation/randreagent
	name = "reagent injecting"
	hue = "#003cff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/randreagent/on_cross(obj/structure/spacevine/holder, mob/crosser)
	if(isliving(crosser))
		var/mob/living/living_crosser = crosser
		if(isvineimmune(living_crosser))
			return
		if(prob(10))
			var/choose_reagent = pick(subtypesof(/datum/reagent))
			living_crosser.reagents.add_reagent(choose_reagent, 10)


// Pulses radiation on growth
/datum/spacevine_mutation/radiation
	name = "radiation pulsing"
	hue = "#ffef62"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/radiation/on_grow(obj/structure/spacevine/holder)
	radiation_pulse(holder, 100, 3)


// Generates miasma on growth
/datum/spacevine_mutation/miasmagenerating
	name = "miasma"
	hue = "#470566"
	severity = 5
	quality = NEGATIVE

/datum/spacevine_mutation/miasmagenerating/on_grow(obj/structure/spacevine/holder)
	var/turf/holder_turf = get_turf(holder)
	holder_turf.atmos_spawn_air("miasma=100;TEMP=293")


// Heals crossing or eating mobs
/datum/spacevine_mutation/fleshmending
	name = "flesh-mending"
	hue = "#470566"
	severity = 10
	quality = POSITIVE

/datum/spacevine_mutation/fleshmending/on_cross(obj/structure/spacevine/holder, mob/crosser)
	if(isliving(crosser))
		var/mob/living/living_crosser = crosser
		living_crosser.adjustBruteLoss(-1)
		living_crosser.adjustFireLoss(-1)
		living_crosser.adjustToxLoss(-1)

/datum/spacevine_mutation/fleshmending/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(isliving(eater))
		var/mob/living/living_eater = eater
		living_eater.adjustBruteLoss(-5)
		living_eater.adjustFireLoss(-5)
		living_eater.adjustToxLoss(-5)


//Produces oxygen gas on growth
/datum/spacevine_mutation/oxygen_producing
	name = "oxygen-producing"
	hue = "#4620ee"
	severity = 10
	quality = POSITIVE

/datum/spacevine_mutation/oxygen_producing/on_grow(obj/structure/spacevine/holder)
	var/turf/holder_turf = get_turf(holder)
	holder_turf.atmos_spawn_air("o2=100;TEMP=293")


//Produces nitrogen gas on growth
/datum/spacevine_mutation/nitrogen_producing
	name = "nitrogen-producing"
	hue = "#ce2929"
	severity = 10
	quality = POSITIVE

/datum/spacevine_mutation/nitrogen_producing/on_grow(obj/structure/spacevine/holder)
	var/turf/holder_turf = get_turf(holder)
	holder_turf.atmos_spawn_air("n2=100;TEMP=293")

//allows the vine to walk 1 tile away from turfs
/datum/spacevine_mutation/spacewalking
	name = "space-walking"
	hue = "#0a1330"
	severity = 5
	quality = NEGATIVE

// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
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
	var/list/mutations = list()
	var/plantbgone_resist = FALSE

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
	var/text = "This one is a"
	if(mutations.len)
		for(var/datum/spacevine_mutation/vine_mutation in mutations)
			text += " [vine_mutation.name]"
	else
		text += " normal"
	text += " vine."
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()


/// Checks for chemical resistant mutations and applied chemicals to see if it should be destroyed
/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/applied_reagent)
	var/override = 0
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		override += vine_mutation.on_chem(src, applied_reagent)
	if(!override && istype(applied_reagent, /datum/reagent/toxin/plantbgone) && !plantbgone_resist && prob(50))
		qdel(src)


/// Checks for eating-resistant mutations to see if it should be destroyed
/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		override += vine_mutation.on_eat(src, eater)
	if(!override)
		qdel(src)

// Take extra damage from weapons that are sharp or do burn damage, unless resistant through mutations
/obj/structure/spacevine/attacked_by(obj/item/weapon, mob/living/user)
	var/damage_dealt = weapon.force
	if(weapon.get_sharpness())
		damage_dealt *= 4
	if(weapon.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		damage_dealt = vine_mutation.on_hit(src, user, weapon, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, weapon.damtype, MELEE, 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)


/// Applies effects when a mob enters the same turf as a vine
/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	if(!isliving(moving_atom))
		return
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_cross(src, moving_atom)
	if(istype(moving_atom, /mob/living/simple_animal/hostile/venus_human_trap))
		var/mob/living/simple_animal/hostile/venus_human_trap/venus_trap = moving_atom
		if(venus_trap.health >= venus_trap.maxHealth)
			return
		venus_trap.adjustHealth(-clamp(venus_trap.health += 2, 0, venus_trap.maxHealth), TRUE, TRUE)
		to_chat(venus_trap, span_notice("The vines attempt to regenerate some of your wounds!"))
		return

// ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user, list/modifiers)
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_hit(src, user)
	user_unbuckle_mob(user, user)
	. = ..()

/obj/structure/spacevine/attack_paw(mob/living/user, list/modifiers)
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_hit(src, user)
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
	var/obj/structure/spacevine/spawned_vine = spawn_spacevine_piece(location, null, muts)
	if (event)
		event.announce_to_ghosts(spawned_vine)
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
		if(alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", "Yes", "No") == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines() //this is kill
	QDEL_LIST(vines) //this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/current_vine = new(location)
	growth_queue += current_vine
	vines += current_vine
	current_vine.master = src
	if(muts && muts.len)
		for(var/datum/spacevine_mutation/chosen_mutation in muts)
			chosen_mutation.add_mutation_to_vinepiece(current_vine)
	if(parent)
		current_vine.mutations |= parent.mutations
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		current_vine.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/randmut = pick(vine_mutations_list - current_vine.mutations)
			randmut.add_mutation_to_vinepiece(current_vine)

	for(var/datum/spacevine_mutation/vine_mutation in current_vine.mutations)
		vine_mutation.on_birth(current_vine)
	location.Entered(current_vine)
	return current_vine

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/destroyed_vine)
	destroyed_vine.master = null
	vines -= destroyed_vine
	growth_queue -= destroyed_vine
	if(!vines.len)
		var/obj/item/seeds/kudzu/kudzu_seed = new(destroyed_vine.loc)
		kudzu_seed.mutations |= destroyed_vine.mutations
		kudzu_seed.set_potency(mutativeness * 10)
		kudzu_seed.set_production(11 - (spread_cap / initial(spread_cap)) * 5) //Reverts spread_cap formula so resulting seed gets original production stat or equivalent back.
		qdel(src)

/datum/spacevine_controller/process(delta_time)
	if(!LAZYLEN(vines))
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = round(clamp(delta_time * 0.5 * vines.len / spread_multiplier, 1, spread_cap))
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/current_vine in growth_queue)
		if(QDELETED(current_vine))
			continue
		i++
		queue_end += current_vine
		growth_queue -= current_vine
		for(var/datum/spacevine_mutation/vine_mutation in current_vine.mutations)
			vine_mutation.process_mutation(current_vine)
		if(current_vine.energy < 2) //If tile isn't fully grown
			if(DT_PROB(50, delta_time)) //SKYRAT EDIT CHANGE
				current_vine.grow()
		else //If tile is fully grown
			current_vine.entangle_mob()

		current_vine.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/entangled_mob in src.loc)
			entangle(entangled_mob)
			if(has_buckled_mobs())
				break //only capture one mob at a time

/obj/structure/spacevine/proc/entangle(mob/living/entangled_mob)
	if(!entangled_mob || isvineimmune(entangled_mob))
		return
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		vine_mutation.on_buckle(src, entangled_mob)
	if((entangled_mob.stat != DEAD) && (entangled_mob.buckled != src)) //not dead or captured
		to_chat(entangled_mob, span_danger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(entangled_mob, 1)

/// Finds a target tile to spread to. If checks pass it will spread to it and also proc on_spread on target.
/obj/structure/spacevine/proc/spread()
	var/direction = pick(GLOB.cardinals)
	var/turf/stepturf = get_step(src,direction)
	for(var/obj/machinery/door/target_door in stepturf.contents)
		if(prob(50))
			target_door.open()
	var/datum/spacevine_mutation/spacewalking/space_mutation = locate() in mutations
	if(!isspaceturf(stepturf) && stepturf.Enter(src))
		spread_two(stepturf, direction)
	else if(space_mutation && isspaceturf(stepturf) && stepturf.Enter(src))
		var/turf/closed/wall/find_wall = locate() in range(2, src)
		var/turf/open/floor/find_floor = locate() in range(2, src)
		if(find_floor || find_wall)
			spread_two(stepturf, direction)

/obj/structure/spacevine/proc/spread_two(turf/target_turf, target_dir)
	//Locates any vine on target turf. Calls that vine "spot_taken".
	var/obj/structure/spacevine/spot_taken = locate() in target_turf

	//Locates the vine eating trait in our own seed and calls it eating_mutation.
	var/datum/spacevine_mutation/vine_eating/eating_mutation = locate() in mutations

	//Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't. Vines from other seeds are eaten regardless.
	if(!spot_taken || (eating_mutation && (spot_taken && !spot_taken.mutations.Find(eating_mutation))))
		if(!master)
			return
		for(var/datum/spacevine_mutation/vine_mutation in mutations)
			vine_mutation.on_spread(src, target_turf) //Only do the on_spread proc if it actually spreads.
			target_turf = get_step(src,target_dir) //in case turf changes, to make sure no runtimes happen
		master.spawn_spacevine_piece(target_turf, src)

/obj/structure/spacevine/ex_act(severity, target)
	var/i
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		i += vine_mutation.on_explosion(severity, target, src)
	if(!i && prob(34 * severity))
		qdel(src)

/obj/structure/spacevine/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD //if you're cold you're safe

/obj/structure/spacevine/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	var/volume = air.return_volume()
	for(var/datum/spacevine_mutation/vine_mutation in mutations)
		if(vine_mutation.process_temperature(src, exposed_temperature, volume)) //If it's ever true we're safe
			return
	qdel(src)

/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isvineimmune(mover))
		return TRUE

/proc/isvineimmune(atom/checked_atom)
	if(isliving(checked_atom))
		var/mob/living/checked_living = checked_atom
		if(("vines" in checked_living.faction) || ("plants" in checked_living.faction))
			return TRUE
	return FALSE
