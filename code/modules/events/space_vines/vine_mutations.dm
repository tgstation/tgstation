/datum/spacevine_mutation
	/// Displayed name of mutation
	var/name = ""
	/// Description of mutation, shown in the plant analyzer
	var/description = ""
	/// Severity of mutation in terms of gameplay, affects appearance chance and how many mutations can be on the same vine
	var/severity = 1
	/// The mutation's contribution to a given vine's color
	var/hue
	/// The quality of our mutation (how good or bad is it?)
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	SHOULD_CALL_PARENT(TRUE)
	buckled.layer = SPACEVINE_MOB_LAYER
	RegisterSignal(buckled, COMSIG_MOB_UNBUCKLED, PROC_REF(on_unbuckle))

/datum/spacevine_mutation/proc/on_unbuckle(datum/source)
	SHOULD_CALL_PARENT(TRUE)
	SIGNAL_HANDLER
	if(!isliving(source))
		return
	var/mob/living/buckled = source
	buckled.layer = initial(buckled.layer)
	UnregisterSignal(buckled, COMSIG_MOB_UNBUCKLED)

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
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

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return FALSE

/datum/spacevine_mutation/proc/additional_atmos_processes(obj/structure/spacevine/holder, datum/gas_mixture/air)
	return

/datum/spacevine_mutation/aggressive_spread/proc/aggrospread_act(obj/structure/spacevine/vine, mob/living/M)
	return

/datum/spacevine_mutation/light
	name = "Light"
	description = "Emits light."
	hue = "#B2EA70"
	quality = POSITIVE
	severity = SEVERITY_TRIVIAL

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.growth_stage)
		holder.set_light(LIGHT_MUTATION_BRIGHTNESS, 0.3)

/datum/spacevine_mutation/toxicity
	name = "Toxic"
	description = "Releases toxins when touched or eaten."
	hue = "#9B3675"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE
	var/required_coverage = HEAD|CHEST|GROIN|LEGS|FEET|ARMS|HANDS

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(isvineimmune(crosser) || issilicon(crosser))
		return
	if(!prob(TOXICITY_MUTATION_PROB))
		return

	var/datum/spacevine_mutation/thorns/thorns = locate() in holder.mutations

	if(thorns)
		to_chat(crosser, span_alert("You are pricked by thorns and feel a strange sensation."))
		crosser.apply_damage(20, TOX)
		return

	var/body_parts_covered = 0
	for(var/obj/item/clothing/worn_item in crosser.get_equipped_items())
		if(!(worn_item.clothing_flags & THICKMATERIAL))
			continue
		body_parts_covered |= worn_item.body_parts_covered

		if((body_parts_covered & required_coverage) == required_coverage)
			return

	to_chat(crosser, span_alert("You accidentally touch the vine and feel a strange sensation."))
	crosser.apply_damage(20, TOX)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.apply_damage(20, TOX)

/datum/spacevine_mutation/explosive  // JC IT'S A BOMB
	name = "Explosive"
	description = "Causes an explosion when destroyed."
	hue = "#D83A56"
	quality = NEGATIVE
	severity = SEVERITY_MAJOR

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity >= EXPLODE_DEVASTATE)
		QDEL_IN(holder, 0.5 SECONDS)
		return TRUE

	qdel(holder)
	return FALSE

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/item)
	explosion(holder, light_impact_range = EXPLOSION_MUTATION_IMPACT_RADIUS, adminlog = FALSE)

/datum/spacevine_mutation/fire_proof
	name = "Fire proof"
	description = "Provides immunity to heat and burn damage."
	hue = "#FF616D"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_ABOVE_AVERAGE

/datum/spacevine_mutation/fire_proof/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.trait_flags |= SPACEVINE_HEAT_RESISTANT

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/attacking_item, expected_damage)
	if(attacking_item && attacking_item.damtype == BURN)
		return 0
	return expected_damage

/datum/spacevine_mutation/cold_proof
	name = "Cold proof"
	description = "Provides immunity to cold damage."
	hue = "#0BD5D9"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_AVERAGE

/datum/spacevine_mutation/cold_proof/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.trait_flags |= SPACEVINE_COLD_RESISTANT

/datum/spacevine_mutation/temp_stabilisation
	name = "Temperature stabilisation"
	description = "Stabilizes the temperature of the surrounding area."
	hue = "#B09856"
	quality = POSITIVE
	severity = SEVERITY_MINOR

/datum/spacevine_mutation/temp_stabilisation/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.always_atmos_process = TRUE

/datum/spacevine_mutation/temp_stabilisation/additional_atmos_processes(obj/structure/spacevine/holder, datum/gas_mixture/air)
	var/heat_capacity = air.heat_capacity()
	if(!heat_capacity) // No heating up space or vacuums
		return
	var/energy_used = min(abs(air.temperature - T20C) * heat_capacity, TEMP_STABILISATION_MUTATION_MAXIMUM_ENERGY)
	var/delta_temperature = energy_used / heat_capacity
	if(delta_temperature < 0.1)
		return
	if(air.temperature > T20C)
		delta_temperature *= -1
	air.temperature += delta_temperature
	holder.air_update_turf(FALSE, FALSE)

/datum/spacevine_mutation/vine_eating
	name = "Vine eating"
	description = "Destroys other Kudzu vines on spread."
	hue = "#F4A442"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_MINOR

/// Destroys any vine on spread-target's tile. The checks for if this should be done are in the spread() proc.
/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/obj/structure/spacevine/prey in target)
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "Aggressive spreading"
	description = "Heavily wounds mobs when spreading or tangling them."
	hue = "#316b2f"
	severity = SEVERITY_MAJOR
	quality = NEGATIVE

/// Checks mobs on spread-target's turf to see if they should be hit by a damaging proc or not.
/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/turf, mob/living)
	for(var/mob/living/victim in turf)
		aggrospread_act(holder, victim)

/// What happens if an aggr spreading vine buckles a mob.
/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	. = ..()
	aggrospread_act(holder, buckled)

/// Hurts mobs. To be used when a vine with aggressive spread mutation spreads into the mob's tile or buckles them.
/datum/spacevine_mutation/aggressive_spread/aggrospread_act(obj/structure/spacevine/vine, mob/living/living_mob)
	if(isvineimmune(living_mob) || living_mob.stat == DEAD)
		return

	if(!iscarbon(living_mob))
		living_mob.apply_damage(75, BRUTE, blocked = living_mob.run_armor_check(attack_flag = MELEE, silent = TRUE))
		playsound(living_mob, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
		living_mob.visible_message(span_danger("[living_mob] is brutally threshed by [vine]!"), \
		span_userdanger("You are brutally threshed by [vine]!"))
		log_combat(vine, living_mob, "aggressively spread into") //You aren't being attacked by the vines. You just happen to stand in their way.
		return

	var/mob/living/carbon/victim = living_mob
	var/obj/item/bodypart/limb = victim.get_bodypart(victim.get_random_valid_zone(even_weights = TRUE))
	var/armor = victim.run_armor_check(def_zone = limb, attack_flag = MELEE)


	if(!HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		var/datum/spacevine_mutation/thorns/thorn = locate() in vine.mutations

		if(thorn && prob(40)) //If we found the thorns mutation there is now a chance to get stung instead of lashed or smashed.
			victim.apply_damage(50, BRUTE, def_zone = limb, wound_bonus = rand(-20,10), sharpness = SHARP_POINTY) //This one gets a bit lower damage because it ignores armor.
			victim.Stun(1 SECONDS) //Stopped in place for a moment.
			playsound(living_mob, 'sound/items/weapons/pierce.ogg', 50, TRUE, -1)
			living_mob.visible_message(span_danger("[living_mob] is nailed by a sharp thorn!"), \
			span_userdanger("You are nailed by a sharp thorn!"))
			log_combat(vine, living_mob, "aggressively pierced") //"Aggressively" for easy ctrl+F'ing in the attack logs.
			return

		if(prob(80))
			victim.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = SHARP_EDGED)
			victim.Knockdown(2 SECONDS)
			playsound(victim, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
			living_mob.visible_message(span_danger("[living_mob] is lacerated by an outburst of vines!"), \
			span_userdanger("You are lacerated by an outburst of vines!"))
			log_combat(vine, living_mob, "aggressively lacerated")
			return

	victim.apply_damage(60, BRUTE, def_zone = limb, blocked = armor, wound_bonus = rand(-20,10), sharpness = NONE)
	victim.Knockdown(3 SECONDS)
	var/atom/throw_target = get_edge_target_turf(living_mob, get_dir(vine, get_step_away(living_mob, vine)))
	victim.throw_at(throw_target, 3, 6)
	playsound(victim, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	living_mob.visible_message(span_danger("[living_mob] is smashed by a large vine!"), \
	span_userdanger("You are smashed by a large vine!"))
	log_combat(vine, living_mob, "aggressively smashed")

/datum/spacevine_mutation/transparency
	name = "transparent"
	description = "Allows light to pass through."
	hue = ""
	quality = POSITIVE
	severity = SEVERITY_TRIVIAL

/datum/spacevine_mutation/transparency/on_birth(obj/structure/spacevine/holder)
	holder.light_state = PASS_LIGHT
	holder.alpha = 125

/datum/spacevine_mutation/gas_eater
	abstract_type = /datum/spacevine_mutation/gas_eater
	/// Type of gas consumed by this mutation
	var/datum/gas/gas_type = null

/datum/spacevine_mutation/gas_eater/process_mutation(obj/structure/spacevine/holder)
	if(isnull(gas_type))
		stack_trace("gas_type not set for gas_eater mutation [type]")
		return

	var/turf/open/floor/turf = holder.loc
	if(!istype(turf))
		return

	var/datum/gas_mixture/gas_mix = turf.air
	if(!gas_mix.gases[gas_type])
		return

	gas_mix.gases[gas_type][MOLES] = max(gas_mix.gases[gas_type][MOLES] - GAS_MUTATION_REMOVAL_MULTIPLIER * holder.growth_stage, 0)
	gas_mix.garbage_collect()

/datum/spacevine_mutation/gas_eater/oxy_eater
	name = "Oxygen consuming"
	description = "Consumes Oxygen from the surrounding area."
	hue = "#28B5B5"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE
	gas_type = /datum/gas/oxygen

/datum/spacevine_mutation/gas_eater/nitro_eater
	name = "Nitrogen consuming"
	description = "Consumes Nitrogen from the surrounding area."
	hue = "#FF7B54"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE
	gas_type = /datum/gas/nitrogen

/datum/spacevine_mutation/gas_eater/carbondioxide_eater
	name = "CO2 consuming"
	description = "Consumes Carbon Dioxide from the surrounding area."
	hue = "#798777"
	severity = SEVERITY_MINOR
	quality = POSITIVE
	gas_type = /datum/gas/carbon_dioxide

/datum/spacevine_mutation/gas_eater/plasma_eater
	name = "Plasma consuming"
	description = "Consumes Plasma from the surrounding area."
	hue = "#9074b6"
	severity = SEVERITY_AVERAGE
	quality = POSITIVE
	gas_type = /datum/gas/plasma

/datum/spacevine_mutation/thorns
	name = "Thorny"
	description = "Causes damage when hitting or passing through the vines."
	hue = "#9ECCA4"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(isvineimmune(crosser) || HAS_TRAIT(crosser, TRAIT_PIERCEIMMUNE))
		return
	if(prob(THORN_MUTATION_CUT_PROB))
		var/mob/living/victim = crosser
		if(victim.apply_damage(15, BRUTE, blocked = victim.run_armor_check(attack_flag = MELEE, silent = TRUE), spread_damage = TRUE))
			to_chat(victim, span_danger("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(isvineimmune(hitter) || HAS_TRAIT(hitter, TRAIT_PIERCEIMMUNE) || HAS_TRAIT(hitter, TRAIT_PLANT_SAFE))
		return expected_damage

	if(iscarbon(hitter))
		var/mob/living/carbon/carbon_victim = hitter
		for(var/obj/item/clothing/worn_item in carbon_victim.get_equipped_items())
			if((worn_item.body_parts_covered & HANDS) && (worn_item.clothing_flags & THICKMATERIAL))
				return expected_damage

	if(prob(THORN_MUTATION_CUT_PROB))
		var/mob/living/victim = hitter
		if(victim.apply_damage(15, BRUTE, blocked = victim.run_armor_check(attack_flag = MELEE, silent = TRUE), spread_damage = TRUE))
			to_chat(victim, span_danger("You cut yourself on the thorny vines."))

	return expected_damage

/datum/spacevine_mutation/hardened
	name = "Hardened"
	description = "Provides resistance to cutting attacks, makes vines hardier, and prevents light from passing through."
	hue = "#997700"
	quality = NEGATIVE
	severity = SEVERITY_ABOVE_AVERAGE

/datum/spacevine_mutation/hardened/on_grow(obj/structure/spacevine/holder)
	if(holder.growth_stage)
		holder.set_density(TRUE)
	holder.modify_max_integrity(100)

/datum/spacevine_mutation/hardened/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(item?.get_sharpness())
		return expected_damage * 0.5
	return expected_damage

/datum/spacevine_mutation/timid
	name = "Timid"
	description = "Hides the vines under structures and prevents them from tangling mobs."
	hue = "#a4a9ac"
	quality = POSITIVE
	severity = SEVERITY_MINOR

//This specific mutation only covers floors instead of structures, items, mobs and cant tangle mobs
/datum/spacevine_mutation/timid/on_birth(obj/structure/spacevine/holder)
	SET_PLANE_IMPLICIT(holder, FLOOR_PLANE)
	holder.layer = ABOVE_OPEN_TURF_LAYER
	holder.light_state = PASS_LIGHT
	holder.can_tangle = FALSE
	return ..()

/datum/spacevine_mutation/flowering
	name = "Flowering"
	description = "Causes the vine to grow flower buds which spawns man eating plants when fully grown."
	hue = "#66DE93"
	quality = NEGATIVE
	severity = SEVERITY_MAJOR

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(locate(/obj/structure/alien/resin/flower_bud) in range(5, holder))
		return
	if(holder.growth_stage == 2 && prob(FLOWERING_MUTATION_SPAWN_PROB))
		var/obj/structure/alien/resin/flower_bud/spawned_flower_bud = new(holder.loc)
		spawned_flower_bud.trait_flags = holder.trait_flags

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)
