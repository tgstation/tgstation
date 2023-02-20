/// Determines brightness of the light emitted by kudzu with the light mutation
#define LIGHT_MUTATION_BRIGHTNESS 4
/// Kudzu light states
#define PASS_LIGHT 0
#define BLOCK_LIGHT 1
/// Determines the probability that the toxicity mutation will harm someone who passes through it
#define TOXICITY_MUTATION_PROB 10
/// Determines the impact radius of kudzu's explosive mutation
#define EXPLOSION_MUTATION_IMPACT_RADIUS 2
/// Determines the scale factor for the amount of gas removed by kudzu with a gas removal mutation, which is this scale factor * the kudzu's energy level
#define GAS_MUTATION_REMOVAL_MULTIPLIER 3
/// Determines the probability that the thorn mutation will harm someone who passes through or attacks it
#define THORN_MUTATION_CUT_PROB 10
/// Determines the probability that a kudzu plant with the flowering mutation will spawn a venus flower bud
#define FLOWERING_MUTATION_SPAWN_PROB 10
/// Maximum energy used per atmos tick that the temperature stabilisation mutation will use to bring the temperature to T20C
#define TEMP_STABILISATION_MUTATION_MAXIMUM_ENERGY 40000

/// Temperature below which the kudzu can't spread
#define VINE_FREEZING_POINT 100

/// Kudzu severity values for traits, based on severity in terms of how severely it impacts the game, the lower the severity, the more likely it is to appear
#define SEVERITY_TRIVIAL 1
#define SEVERITY_MINOR 2
#define SEVERITY_AVERAGE 4
#define SEVERITY_ABOVE_AVERAGE 7
#define SEVERITY_MAJOR 10

/// Kudzu mutativeness is based on a scale factor * potency
#define MUTATIVENESS_SCALE_FACTOR 0.2

/// Kudzu maximum mutation severity is a linear function of potency
#define MAX_SEVERITY_LINEAR_COEFF 0.15
#define MAX_SEVERITY_CONSTANT_TERM 10

/// Additional maximum mutation severity given to kudzu spawned by a random event
#define MAX_SEVERITY_EVENT_BONUS 10

/// The maximum possible productivity value of a (normal) kudzu plant, used for calculating a plant's spread cap and multiplier
#define MAX_POSSIBLE_PRODUCTIVITY_VALUE 10

/// Kudzu spread cap is a scaled version of production speed, such that the better the production speed, ie. the lower the speed value is, the faster is spreads
#define SPREAD_CAP_LINEAR_COEFF 4
#define SPREAD_CAP_CONSTANT_TERM 20
/// Kudzu spread multiplier is a reciporal function of production speed, such that the better the production speed, ie. the lower the speed value is, the faster it spreads
#define SPREAD_MULTIPLIER_MAX 50

/// Kudzu's maximum possible maximum mutation severity (assuming ideal potency), used to balance mutation appearance chance
#define IDEAL_MAX_SEVERITY 20


/datum/round_event_control/spacevine
	name = "Space Vines"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10
	category = EVENT_CATEGORY_ENTITIES
	description = "Kudzu begins to overtake the station. Might spawn man-traps."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/vine = new()

	for(var/area/station/hallway/area in GLOB.areas)
		for(var/turf/floor as anything in area.get_contained_turfs())
			if(floor.Enter(vine))
				turfs += floor

	qdel(vine)

	if(length(turfs)) //Pick a turf to spawn at if we can
		var/turf/floor = pick(turfs)
		new /datum/spacevine_controller(floor, list(pick(subtypesof(/datum/spacevine_mutation))), rand(50,100), rand(1,4), src) //spawn a controller at turf with randomized stats and a single random mutation


/datum/spacevine_mutation
	/// Displayed name of mutation
	var/name = ""
	/// Severity of mutation in terms of gameplay, affects appearance chance and how many mutations can be on the same vine
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

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

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/additional_atmos_processes(obj/structure/spacevine/holder, datum/gas_mixture/air)
	return

/datum/spacevine_mutation/aggressive_spread/proc/aggrospread_act(obj/structure/spacevine/vine, mob/living/M)
	return

/datum/spacevine_mutation/light
	name = "Light"
	hue = "#B2EA70"
	quality = POSITIVE
	severity = SEVERITY_TRIVIAL

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(LIGHT_MUTATION_BRIGHTNESS, 0.3)

/datum/spacevine_mutation/toxicity
	name = "Toxic"
	hue = "#9B3675"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(TOXICITY_MUTATION_PROB) && istype(crosser) && !isvineimmune(crosser))
		to_chat(crosser, span_alert("You accidentally touch the vine and feel a strange sensation."))
		crosser.adjustToxLoss(20)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.adjustToxLoss(20)

/datum/spacevine_mutation/explosive  // JC IT'S A BOMB
	name = "Explosive"
	hue = "#D83A56"
	quality = NEGATIVE
	severity = SEVERITY_MAJOR

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		QDEL_IN(holder, 5)

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/item)
	explosion(holder, light_impact_range = EXPLOSION_MUTATION_IMPACT_RADIUS, adminlog = FALSE)

/datum/spacevine_mutation/fire_proof
	name = "Fire proof"
	hue = "#FF616D"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_ABOVE_AVERAGE

/datum/spacevine_mutation/fire_proof/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.trait_flags |= SPACEVINE_HEAT_RESISTANT

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/item, expected_damage)
	if(item && item.damtype == BURN)
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/cold_proof
	name = "Cold proof"
	hue = "#0BD5D9"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_AVERAGE

/datum/spacevine_mutation/cold_proof/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.trait_flags |= SPACEVINE_COLD_RESISTANT

/datum/spacevine_mutation/temp_stabilisation
	name = "Temperature stabilisation"
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
	hue = "#F4A442"
	quality = MINOR_NEGATIVE
	severity = SEVERITY_MINOR

/// Destroys any vine on spread-target's tile. The checks for if this should be done are in the spread() proc.
/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/obj/structure/spacevine/prey in target)
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "Aggressive spreading"
	hue = "#316b2f"
	severity = SEVERITY_MAJOR
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
		var/obj/item/bodypart/limb = victim.get_bodypart(victim.get_random_valid_zone(even_weights = TRUE)) //Picks a random bodypart.
		var/armor = victim.run_armor_check(limb, MELEE, null, null) //armor = the armor value of that randomly chosen bodypart. Nulls to not print a message, because it would still print on pierce.
		var/datum/spacevine_mutation/thorns/thorn = locate() in vine.mutations //Searches for the thorns mutation in the "mutations"-list inside obj/structure/spacevine, and defines T if it finds it.
		if(thorn && prob(40) && !HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE)) //If we found the thorns mutation there is now a chance to get stung instead of lashed or smashed.
			victim.apply_damage(50, BRUTE, def_zone = limb, wound_bonus = rand(-20,10), sharpness = SHARP_POINTY) //This one gets a bit lower damage because it ignores armor.
			victim.Stun(1 SECONDS) //Stopped in place for a moment.
			playsound(living_mob, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
			living_mob.visible_message(span_danger("[living_mob] is nailed by a sharp thorn!"), \
			span_userdanger("You are nailed by a sharp thorn!"))
			log_combat(vine, living_mob, "aggressively pierced") //"Aggressively" for easy ctrl+F'ing in the attack logs.
		else
			if(prob(80) && !HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
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
	severity = SEVERITY_TRIVIAL

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.light_state = PASS_LIGHT
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "Oxygen consuming"
	hue = "#28B5B5"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/oxygen])
			return
		gas_mix.gases[/datum/gas/oxygen][MOLES] = max(gas_mix.gases[/datum/gas/oxygen][MOLES] - GAS_MUTATION_REMOVAL_MULTIPLIER * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/nitro_eater
	name = "Nitrogen consuming"
	hue = "#FF7B54"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/nitrogen])
			return
		gas_mix.gases[/datum/gas/nitrogen][MOLES] = max(gas_mix.gases[/datum/gas/nitrogen][MOLES] - GAS_MUTATION_REMOVAL_MULTIPLIER * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#798777"
	severity = SEVERITY_MINOR
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/carbon_dioxide])
			return
		gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] = max(gas_mix.gases[/datum/gas/carbon_dioxide][MOLES] - GAS_MUTATION_REMOVAL_MULTIPLIER * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/plasma_eater
	name = "Plasma consuming"
	hue = "#9074b6"
	severity = SEVERITY_AVERAGE
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/turf = holder.loc
	if(istype(turf))
		var/datum/gas_mixture/gas_mix = turf.air
		if(!gas_mix.gases[/datum/gas/plasma])
			return
		gas_mix.gases[/datum/gas/plasma][MOLES] = max(gas_mix.gases[/datum/gas/plasma][MOLES] - GAS_MUTATION_REMOVAL_MULTIPLIER * holder.energy, 0)
		gas_mix.garbage_collect()

/datum/spacevine_mutation/thorns
	name = "Thorny"
	hue = "#9ECCA4"
	severity = SEVERITY_AVERAGE
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(istype(crosser) && HAS_TRAIT(crosser, TRAIT_PIERCEIMMUNE))
		return

	if(prob(THORN_MUTATION_CUT_PROB) && istype(crosser) && !isvineimmune(crosser))
		var/mob/living/victim = crosser
		victim.adjustBruteLoss(15)
		to_chat(victim, span_danger("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(iscarbon(hitter))
		var/mob/living/carbon/carbon_victim = hitter
		for(var/obj/item/clothing/worn_item in carbon_victim.get_equipped_items())
			if((worn_item.body_parts_covered & HANDS) && (worn_item.clothing_flags & THICKMATERIAL))
				return expected_damage

	if(HAS_TRAIT(hitter, TRAIT_PIERCEIMMUNE) || HAS_TRAIT(hitter, TRAIT_PLANT_SAFE))
		return expected_damage

	if(prob(THORN_MUTATION_CUT_PROB) && istype(hitter) && !isvineimmune(hitter))
		var/mob/living/victim = hitter
		victim.adjustBruteLoss(15)
		to_chat(victim, span_danger("You cut yourself on the thorny vines."))

	return expected_damage

/datum/spacevine_mutation/woodening
	name = "Hardened"
	hue = "#997700"
	quality = NEGATIVE
	severity = SEVERITY_ABOVE_AVERAGE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_density(TRUE)
	holder.modify_max_integrity(100)

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/item, expected_damage)
	if(item?.get_sharpness())
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/timid
	name = "Timid"
	hue = "#a4a9ac"
	quality = POSITIVE
	severity = SEVERITY_MINOR

//This specific mutation only covers floors instead of structures, items, mobs and cant tangle mobs
/datum/spacevine_mutation/timid/on_birth(obj/structure/spacevine/holder)
	SET_PLANE_IMPLICIT(holder, FLOOR_PLANE)
	holder.light_state = PASS_LIGHT
	holder.can_tangle = FALSE
	return ..()

/datum/spacevine_mutation/flowering
	name = "Flowering"
	hue = "#66DE93"
	quality = NEGATIVE
	severity = SEVERITY_MAJOR

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(FLOWERING_MUTATION_SPAWN_PROB) && !locate(/obj/structure/alien/resin/flower_bud) in range(5,holder))
		var/obj/structure/alien/resin/flower_bud/spawned_flower_bud = new/obj/structure/alien/resin/flower_bud(get_turf(holder))
		spawned_flower_bud.trait_flags = holder.trait_flags

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
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	/// Can this kudzu spread?
	var/can_spread = TRUE
	/// Can this kudzu buckle mobs in?
	var/can_tangle = TRUE
	var/datum/spacevine_controller/master = null
	/// List of mutations for a specific vine
	var/list/mutations = list()
	var/trait_flags = 0
	/// Should atmos always process this tile
	var/always_atmos_process = FALSE
	/// The kudzu blocks light on default once it grows
	var/light_state = BLOCK_LIGHT

/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
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
	set_opacity(PASS_LIGHT)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/chem)
	var/override = 0
	for(var/datum/spacevine_mutation/mutation in mutations)
		override += mutation.on_chem(src, chem)
	if(!override && istype(chem, /datum/reagent/toxin/plantbgone))
		if(prob(75))
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
	///Canonical list of all the vines we "own"
	var/list/obj/structure/spacevine/vines
	///Queue of vines to process
	var/list/growth_queue
	//List of currently processed vines, on this level to prevent runtime tomfoolery
	var/list/obj/structure/spacevine/queue_end
	///Spread multiplier, depends on productivity, affects how often kudzu spreads
	var/spread_multiplier = 5 // corresponds to artifical kudzu with production speed of 1, approaches 10% of total vines will spread per second
	///Maximum spreading limit (ie. how many kudzu can there be) for this controller
	var/spread_cap = 30 // corresponds to artifical kudzu with production speed of 3.5
	var/static/list/vine_mutations_list
	var/mutativeness = 1
	///Maximum sum of mutation severities
	var/max_mutation_severity = 20
	///Minimum spread rate per second
	var/minimum_spread_rate = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, datum/round_event/event = null)
	vines = list()
	growth_queue = list()
	queue_end = list()
	var/obj/structure/spacevine/vine = spawn_spacevine_piece(location, null, muts)
	if(event)
		event.announce_to_ghosts(vine)
	START_PROCESSING(SSobj, src)
	if(!vine_mutations_list)
		vine_mutations_list = list()
		init_subtypes(/datum/spacevine_mutation/, vine_mutations_list)
		for(var/datum/spacevine_mutation/mutation as anything in vine_mutations_list)
			vine_mutations_list[mutation] = IDEAL_MAX_SEVERITY - mutation.severity // the ideal maximum potency is used for weighting
	if(potency != null)
		mutativeness = potency * MUTATIVENESS_SCALE_FACTOR // If potency is 100, 20 mutativeness; if 1: 0.2 mutativeness
		max_mutation_severity = round(potency * MAX_SEVERITY_LINEAR_COEFF + MAX_SEVERITY_CONSTANT_TERM) // If potency is 100, 25 max mutation severity; if 1, 10 max mutation severity
	if(production != null && production <= MAX_POSSIBLE_PRODUCTIVITY_VALUE) //Prevents runtime in case production is set to 11.
		spread_cap = SPREAD_CAP_LINEAR_COEFF * (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) + SPREAD_CAP_CONSTANT_TERM //Best production speed of 1 increases spread_cap to 60, worst production speed of 10 lowers it to 24, even distribution
		spread_multiplier = SPREAD_MULTIPLIER_MAX / (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) // Best production speed of 1: 10% of total vines will spread per second, worst production speed of 10: 1% of total vines (with minimum of 1) will spread per second
	if(event != null) // spawned by space vine event
		max_mutation_severity += MAX_SEVERITY_EVENT_BONUS
		minimum_spread_rate = 3

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
	vines.Cut()
	growth_queue.Cut()
	queue_end.Cut()
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/vine = new(location)
	growth_queue += vine
	vines += vine
	vine.master = src
	for(var/datum/spacevine_mutation/mutation in muts)
		mutation.add_mutation_to_vinepiece(vine)
	if(parent)
		vine.mutations |= parent.mutations
		vine.trait_flags |= parent.trait_flags
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		vine.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/random_mutate = pick_weight(vine_mutations_list - vine.mutations)
			var/total_severity = random_mutate.severity
			for(var/datum/spacevine_mutation/mutation as anything in vine.mutations)
				total_severity += mutation.severity
			if(total_severity <= max_mutation_severity)
				random_mutate.add_mutation_to_vinepiece(vine)

	for(var/datum/spacevine_mutation/mutation in vine.mutations)
		mutation.on_birth(vine)
	location.Entered(vine, null)
	return vine

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/vine)
	vine.master = null
	vines -= vine
	growth_queue -= vine
	queue_end -= vine
	if(length(vines))
		return
	var/obj/item/seeds/kudzu/seed = new(vine.loc)
	seed.mutations |= vine.mutations
	seed.set_potency(mutativeness / MUTATIVENESS_SCALE_FACTOR)
	// Mathematical notes:
	// The formula for spread_multiplier is SPREAD_MULTIPLIER_MAX / (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production)
	// So (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) = SPREAD_MULTIPLIER_MAX / spread_multiplier
	// ie. production = MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - SPREAD_MULTIPLIER_MAX / spread_multiplier
	seed.set_production(MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - (SPREAD_MULTIPLIER_MAX / spread_multiplier)) //Reverts spread_multiplier formula so resulting seed gets original production stat or equivalent back.
	qdel(src)

/// Life cycle of a space vine
/datum/spacevine_controller/process(delta_time)
	var/vine_count = length(vines)
	if(!vine_count)
		qdel(src) //space vines exterminated. Remove the controller
		return

	/// Bonus spread for kudzu that has just started out (ie. with low vine count)
	var/start_spread_bonus = max(5 - spread_multiplier * (vine_count ** 2) / 400, 0)
	/// Base spread rate, depends solely on spread multiplier and vine count
	var/spread_base = 0.5 * vine_count / spread_multiplier
	/// Actual maximum spread rate for this process tick
	var/spread_max = round(clamp(delta_time * (spread_base + start_spread_bonus), max(delta_time * minimum_spread_rate, 1), spread_cap))
	var/amount_processed = 0
	for(var/obj/structure/spacevine/vine in growth_queue)
		if(!vine.can_spread)
			continue
		growth_queue -= vine
		queue_end += vine
		for(var/datum/spacevine_mutation/mutation in vine.mutations)
			mutation.process_mutation(vine)

		if(vine.energy >= 2) //If tile is fully grown
			vine.entangle_mob()
		else if(DT_PROB(10, delta_time)) //If tile isn't fully grown
			vine.grow()

		vine.spread()

		amount_processed++
		if(amount_processed >= spread_max)
			break

	//We can only do so much work per process, but we still want to process everything at some point
	//So we shift the queue a bit
	growth_queue += queue_end
	queue_end = list()

/// Updates the icon as the space vine grows
/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(light_state)
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
	if((victim.stat != DEAD) && (victim.buckled != src) && can_tangle) //not dead and not captured and can tangle
		to_chat(victim, span_userdanger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(victim, 1)

/// Finds a target tile to spread to. If checks pass it will spread to it and also proc on_spread on target.
/obj/structure/spacevine/proc/spread()
	var/direction = pick(GLOB.cardinals)
	var/turf/stepturf = get_step(src, direction)
	if(!istype(stepturf))
		return

	if(!isspaceturf(stepturf) && stepturf.Enter(src))
		var/obj/structure/spacevine/spot_taken = locate() in stepturf //Locates any vine on target turf. Calls that vine "spot_taken".
		var/datum/spacevine_mutation/vine_eating/eating = locate() in mutations //Locates the vine eating trait in our own seed and calls it E.
		if(!spot_taken || (eating && (spot_taken && !spot_taken.mutations?.Find(eating)))) //Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't. Vines from other seeds are eaten regardless.
			if(master)
				for(var/datum/spacevine_mutation/mutation in mutations)
					mutation.on_spread(src, stepturf) //Only do the on_spread proc if it actually spreads.
					stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
				var/obj/structure/spacevine/spawning_vine = master.spawn_spacevine_piece(stepturf, src) //Let's do a cool little animate
				if(NSCOMPONENT(direction))
					spawning_vine.pixel_y = direction == NORTH ? -32 : 32
					animate(spawning_vine, pixel_y = 0, time = 1 SECONDS)
				else
					spawning_vine.pixel_x = direction == EAST ? -32 : 32
					animate(spawning_vine, pixel_x = 0, time = 1 SECONDS)

/// Destroying an explosive vine sets off a chain reaction
/obj/structure/spacevine/ex_act(severity, target)
	var/index
	for(var/datum/spacevine_mutation/mutation in mutations)
		index += mutation.on_explosion(severity, target, src)
	if(!index && prob(34 * severity))
		qdel(src)

/obj/structure/spacevine/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (always_atmos_process || exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD || exposed_temperature < VINE_FREEZING_POINT || !can_spread)//if you're room temperature you're safe

/obj/structure/spacevine/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	for(var/datum/spacevine_mutation/mutation in mutations)
		mutation.additional_atmos_processes(src, air)
	if(!can_spread && (exposed_temperature >= VINE_FREEZING_POINT || (trait_flags & SPACEVINE_COLD_RESISTANT)))
		can_spread = TRUE // not returning here just in case its now a plasmafire and the kudzu should be deleted
	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD && !(trait_flags & SPACEVINE_HEAT_RESISTANT))
		qdel(src)
	else if (exposed_temperature < VINE_FREEZING_POINT && !(trait_flags & SPACEVINE_COLD_RESISTANT))
		can_spread = FALSE

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

#undef LIGHT_MUTATION_BRIGHTNESS
#undef PASS_LIGHT
#undef BLOCK_LIGHT
#undef TOXICITY_MUTATION_PROB
#undef EXPLOSION_MUTATION_IMPACT_RADIUS
#undef GAS_MUTATION_REMOVAL_MULTIPLIER
#undef THORN_MUTATION_CUT_PROB
#undef FLOWERING_MUTATION_SPAWN_PROB
#undef VINE_FREEZING_POINT
#undef SEVERITY_TRIVIAL
#undef SEVERITY_MINOR
#undef SEVERITY_AVERAGE
#undef SEVERITY_ABOVE_AVERAGE
#undef SEVERITY_MAJOR
#undef MUTATIVENESS_SCALE_FACTOR
#undef MAX_SEVERITY_LINEAR_COEFF
#undef MAX_SEVERITY_CONSTANT_TERM
#undef MAX_SEVERITY_EVENT_BONUS
#undef MAX_POSSIBLE_PRODUCTIVITY_VALUE
#undef SPREAD_CAP_LINEAR_COEFF
#undef SPREAD_CAP_CONSTANT_TERM
#undef SPREAD_MULTIPLIER_MAX
#undef IDEAL_MAX_SEVERITY
