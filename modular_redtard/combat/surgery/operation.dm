/// Ratwood's surgery (code/modules/surgery/_surgery_step.dm) on TG's operations: each step of Ratwood's is an operation of TG
/// (code/modules/surgery/operations/), done through TG's machinery - the radial menu, the do_after, the surgical states of the
/// limb - and counted Ratwood's way. A medieval body may be operated on without drapes, out of combat, standing or lying,
/// and offers Ratwood's operations only (the rogue_surgery element). A step needs its least rank of Medicine; its chance is the
/// implement's times the place (standing, a bed, a table, the floor) times the surgeon's rank against the step's median; its
/// speed is the tool's and the place's, quicker from Expert on. A strong right-hand intent fails a step done with a tool on
/// purpose, and a step done by hand fails unless the weak one is taken, as at Ratwood. A failed step may leave the patient a
/// fever of bad humours (/datum/reagent/rogue_infection), the worse the chance was; a step done teaches Medicine through
/// dreams, by intelligence. The steps themselves are in combat/surgery/steps.dm.

/// Ratwood can make a step quicker than this share of its time, no quicker.
#define ROGUE_SURGERY_SPEED_MIN 0.1

/datum/surgery_operation
	/// One of Ratwood's operations (combat/surgery/): a medieval body offers these and only these (rogue_surgery element).
	var/rogue_medieval = FALSE
	/// Ratwood accept_any_item: any item in hand will do, at full chance, when none of the implements is.
	var/rogue_any_item = FALSE

/// Ratwood implements: each tool behaviour, type path, ROGUE_IMPLEMENT_SHARP, ROGUE_IMPLEMENT_HOT or IMPLEMENT_HAND the step takes,
/// in Ratwood's order, to its chance in percent.
/datum/surgery_operation/proc/rogue_chances()
	return list()

/// Ratwood time: the deciseconds of the step for an average surgeon with an average tool.
/datum/surgery_operation/proc/rogue_time()
	return time

/// Ratwood skill_min: the rank of Medicine the step needs at least (0: none).
/datum/surgery_operation/proc/rogue_skill_min()
	return ROGUE_RANK_NOVICE

/// Ratwood skill_median: the rank of Medicine above which the step gets easier and below which harder.
/datum/surgery_operation/proc/rogue_skill_median()
	return ROGUE_RANK_JOURNEYMAN

/// Ratwood tool_check(): the first implement the tool answers to - its type, its tool behaviour, an edge or a point, heat enough
/// to burn - or the bare hand; any item for a step that takes any. Null for none.
/datum/surgery_operation/proc/rogue_implement(tool)
	var/list/chances = rogue_chances()
	if(!isitem(tool))
		return (tool == IMPLEMENT_HAND && (IMPLEMENT_HAND in chances)) ? IMPLEMENT_HAND : null
	var/obj/item/realtool = tool
	for(var/implement in chances)
		if(ispath(implement))
			if(istype(realtool, implement))
				return implement
			continue
		if(implement == IMPLEMENT_HAND)
			continue
		if(implement == ROGUE_IMPLEMENT_SHARP)
			if(realtool.get_sharpness())
				return implement
			continue
		if(implement == ROGUE_IMPLEMENT_HOT)
			if(realtool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
				return implement
			continue
		if(realtool.tool_behaviour && realtool.tool_behaviour == implement)
			return implement
	return rogue_any_item ? ROGUE_IMPLEMENT_ANY : null

/// The implement's chance in percent; any item takes full chance (Ratwood TOOL_NONE).
/datum/surgery_operation/proc/rogue_implement_chance(implement)
	if(implement == ROGUE_IMPLEMENT_ANY)
		return 100
	var/list/chances = rogue_chances()
	return implement ? (chances[implement] || 0) : 0

/// TG's tool quality, Ratwood's way: a step is offered to whatever the step takes, and to nothing else.
/datum/surgery_operation/proc/rogue_tool_quality(tool)
	return rogue_implement(tool) ? 1 : 0

/// Ratwood validate_user(): the surgeon has the rank of Medicine the step needs.
/datum/surgery_operation/proc/rogue_skilled(mob/living/surgeon)
	var/least = rogue_skill_min()
	return !least || surgeon.rogue_skill_rank(/datum/attribute/skill/misc/medicine) >= least

/// Ratwood get_location_modifier(): what the place gives the chance - standing, or lying on a bed, a table or the floor.
/datum/surgery_operation/proc/rogue_location_success(mob/living/patient)
	if(!IS_LYING_OR_CANNOT_LIE(patient))
		return rogue_value("surgery_standing_success")
	var/turf/spot = get_turf(patient)
	if(locate(/obj/structure/bed) in spot)
		return rogue_value("surgery_bed_success")
	if(locate(/obj/structure/table) in spot)
		return rogue_value("surgery_table_success")
	return rogue_value("surgery_floor_success")

/// Ratwood get_speed_location_modifier(): what the place does to the time.
/datum/surgery_operation/proc/rogue_location_speed(mob/living/patient)
	if(!IS_LYING_OR_CANNOT_LIE(patient))
		return rogue_value("surgery_standing_speed")
	var/turf/spot = get_turf(patient)
	if(locate(/obj/structure/bed) in spot)
		return rogue_value("surgery_bed_speed")
	if(locate(/obj/structure/table) in spot)
		return rogue_value("surgery_table_speed")
	return rogue_value("surgery_floor_speed")

/// Ratwood get_skill_modifier(): every rank of Medicine above the step's median adds to the chance, every rank below takes from it.
/datum/surgery_operation/proc/rogue_skill_modifier(mob/living/surgeon)
	var/difference = surgeon.rogue_skill_rank(/datum/attribute/skill/misc/medicine) - rogue_skill_median()
	var/modifier = 1
	if(difference > 0)
		modifier += rogue_surgery_skill_bonus(min(difference, ROGUE_SKILL_RANK_MAX))
	else if(difference < 0)
		modifier += rogue_surgery_skill_malus(min(-difference, ROGUE_SKILL_RANK_MAX))
	return max(modifier, 0)

/// Ratwood get_success_probability(): the implement's chance, times the place, times the surgeon's rank.
/datum/surgery_operation/proc/rogue_success_chance(atom/movable/operating_on, mob/living/surgeon, tool)
	var/chance = rogue_implement_chance(rogue_implement(tool))
	var/mob/living/patient = get_patient(operating_on)
	if(patient)
		chance *= rogue_location_success(patient)
	chance *= rogue_skill_modifier(surgeon)
	return max(chance, 0)

/// Ratwood get_speed_modifier(): the tool's speed and the place's, less a share from Expert on. The step's time is taken from
/// the values first. Kept under TG's threshold, so that TG's own roll never fails a step: Ratwood's roll does
/// (rogue_roll()).
/datum/surgery_operation/proc/rogue_speed(atom/movable/operating_on, mob/living/surgeon, tool)
	time = rogue_time()
	var/speed = 1
	if(isitem(tool))
		var/obj/item/realtool = tool
		speed *= realtool.toolspeed
	var/mob/living/patient = get_patient(operating_on)
	if(patient)
		speed *= rogue_location_speed(patient)
	switch(surgeon.rogue_skill_rank(/datum/attribute/skill/misc/medicine))
		if(ROGUE_RANK_EXPERT)
			speed -= rogue_value("surgery_expert_speed")
		if(ROGUE_RANK_MASTER)
			speed -= rogue_value("surgery_master_speed")
		if(ROGUE_RANK_LEGENDARY)
			speed -= rogue_value("surgery_legendary_speed")
	return clamp(round(speed, 0.01), ROGUE_SURGERY_SPEED_MIN, SURGERY_MODIFIER_FAILURE_THRESHOLD)

/// Ratwood: a strong right-hand intent fails a step done with a tool on purpose; a step done by hand fails on purpose unless the
/// weak one is taken (carbon.dm attackby(), carbon_defense.dm attack_hand()).
/datum/surgery_operation/proc/rogue_tries_to_fail(mob/living/surgeon, tool)
	if(isitem(tool))
		return surgeon.rogue_rmb_is(/datum/rogue_rmb_intent/strong)
	return !surgeon.rogue_rmb_is(/datum/rogue_rmb_intent/weak)

/// Ratwood initiate(): the step's roll, made as it starts. A step that loses it, or is failed on purpose, fails when its time
/// is up (TG's OPERATION_FORCE_FAIL); the chance is kept for the fever a failure may bring.
/datum/surgery_operation/proc/rogue_roll(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/chance = rogue_success_chance(operating_on, surgeon, tool)
	operation_args[ROGUE_OPERATION_CHANCE] = chance
	if(rogue_tries_to_fail(surgeon, tool) || !prob(chance))
		operation_args[OPERATION_FORCE_FAIL] = TRUE

/// Ratwood failure(): the surgeon screws up, and the worse the chance was, the worse the fever the patient may get.
/datum/surgery_operation/proc/rogue_fail(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	operation_args[ROGUE_OPERATION_FAILED] = TRUE
	var/mob/living/patient = get_patient(operating_on)
	display_results(surgeon, patient, span_warning("I screw up!"), span_warning("[surgeon] screws up!"), span_notice("[surgeon] finishes."), TRUE)
	rogue_surgery_infect(patient, operation_args[ROGUE_OPERATION_CHANCE])

/// Ratwood initiate(): a step done teaches Medicine through dreams, by intelligence and the step's least rank.
/datum/surgery_operation/proc/rogue_learn(mob/living/surgeon)
	if(!ishuman(surgeon))
		return
	var/amount = surgeon.rogue_stat(ROGUE_STAT_INTELLIGENCE) * rogue_skill_min() * rogue_value("surgery_experience")
	if(amount > 0)
		surgeon.rogue_craft_experience(/datum/attribute/skill/misc/medicine, amount)

/// Ratwood skill_bonuses: what each rank of Medicine above a step's median adds to its chance.
/proc/rogue_surgery_skill_bonus(ranks)
	switch(ranks)
		if(1)
			return rogue_value("surgery_skill_bonus_1")
		if(2)
			return rogue_value("surgery_skill_bonus_2")
		if(3)
			return rogue_value("surgery_skill_bonus_3")
		if(4)
			return rogue_value("surgery_skill_bonus_4")
		if(5)
			return rogue_value("surgery_skill_bonus_5")
		if(6)
			return rogue_value("surgery_skill_bonus_6")
	return 0

/// Ratwood skill_maluses: what each rank of Medicine below a step's median takes from its chance (a negative number).
/proc/rogue_surgery_skill_malus(ranks)
	switch(ranks)
		if(1)
			return rogue_value("surgery_skill_malus_1")
		if(2)
			return rogue_value("surgery_skill_malus_2")
		if(3)
			return rogue_value("surgery_skill_malus_3")
		if(4)
			return rogue_value("surgery_skill_malus_4")
		if(5)
			return rogue_value("surgery_skill_malus_5")
		if(6)
			return rogue_value("surgery_skill_malus_6")
	return 0

/// Ratwood failure(): a step failed at a poor chance leaves the patient bad humours - the worst under the lowest chances, a
/// mild touch of them up to a fair one, nothing above it.
/proc/rogue_surgery_infect(mob/living/patient, chance)
	if(isnull(chance) || !patient?.reagents)
		return
	var/infection
	var/amount = 0
	if(chance <= rogue_value("surgery_infection_major_to"))
		infection = /datum/reagent/rogue_infection/major
		amount = rand(rogue_value("surgery_infection_major_least"), rogue_value("surgery_infection_major_most"))
	else if(chance >= rogue_value("surgery_infection_from") && chance <= rogue_value("surgery_infection_to"))
		infection = /datum/reagent/rogue_infection
		amount = rand(rogue_value("surgery_infection_least"), rogue_value("surgery_infection_most"))
	else if(chance >= rogue_value("surgery_infection_minor_from") && chance <= rogue_value("surgery_infection_minor_to"))
		infection = /datum/reagent/rogue_infection/minor
		amount = rand(rogue_value("surgery_infection_minor_least"), rogue_value("surgery_infection_minor_most"))
	if(infection && amount > 0)
		patient.reagents.add_reagent(infection, amount)

/// The operations a medieval body offers: Ratwood's, the module's (rogue_medieval).
/proc/rogue_surgery_operations()
	var/static/list/operations
	if(isnull(operations))
		operations = list()
		for(var/operation_type in GLOB.operations.operations_by_typepath)
			var/datum/surgery_operation/operation = GLOB.operations.operations_by_typepath[operation_type]
			if(operation.rogue_medieval)
				operations += operation_type
	return operations

/// A step of Ratwood's done on a limb of the body: the base of the module's operations (combat/surgery/steps.dm). Locked, so
/// that TG's bodies never offer it; a medieval body offers it through the rogue_surgery element. Done standing or lying, on
/// oneself too, as at Ratwood.
/datum/surgery_operation/limb/rogue
	abstract_type = /datum/surgery_operation/limb/rogue
	operation_flags = OPERATION_LOCKED | OPERATION_NO_WIKI | OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED
	rogue_medieval = TRUE
	/// Ratwood requires_bodypart_type BODYPART_ORGANIC (and SURGERY_BLOODY): the step is done on a limb of flesh only.
	var/rogue_flesh_only = TRUE
	/// Ratwood possible_locs, as TG's limbs: the zones of the step; null for every zone.
	var/list/rogue_zones

/datum/surgery_operation/limb/rogue/get_tool_quality(tool = IMPLEMENT_HAND)
	return rogue_tool_quality(tool)

/datum/surgery_operation/limb/rogue/state_check(obj/item/bodypart/limb)
	if(rogue_flesh_only && !(limb.biological_state & BIO_FLESH))
		return FALSE
	if(rogue_zones && !(limb.body_zone in rogue_zones))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/rogue/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return rogue_skilled(surgeon)

/datum/surgery_operation/limb/rogue/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	return rogue_speed(limb, surgeon, tool)

/datum/surgery_operation/limb/rogue/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE
	rogue_roll(limb, surgeon, tool, operation_args)
	return TRUE

/datum/surgery_operation/limb/rogue/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	rogue_effect(limb, surgeon, tool, operation_args)
	rogue_learn(surgeon)

/datum/surgery_operation/limb/rogue/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	rogue_fail(limb, surgeon, tool, operation_args)

/// Ratwood success(): what the step does once it is done.
/datum/surgery_operation/limb/rogue/proc/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	return

/// A medieval body is operated on as at Ratwood: without drapes (TG's free operation, every limb ready), and with Ratwood's
/// operations in place of TG's.
/datum/element/rogue_surgery

/datum/element/rogue_surgery/Attach(datum/target)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE
	target.AddComponentFrom(ROGUE_SURGERY_SOURCE, /datum/component/free_operation)
	RegisterSignal(target, COMSIG_ATOM_BEING_OPERATED_ON, PROC_REF(on_operated_on))

/datum/element/rogue_surgery/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_BEING_OPERATED_ON)
	source.RemoveComponentSource(ROGUE_SURGERY_SOURCE, /datum/component/free_operation)
	return ..()

/// Ratwood's operations, and only those, are offered on the body.
/datum/element/rogue_surgery/proc/on_operated_on(mob/living/carbon/source, mob/living/surgeon, list/possible_operations)
	SIGNAL_HANDLER
	possible_operations.Cut()
	possible_operations += rogue_surgery_operations()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	if(rogue_combat_enabled())
		AddElement(/datum/element/rogue_surgery)

/// Ratwood's bad humours (roguecrafting/alchemy/reagents.dm /datum/reagent/infection), which a failed step of surgery leaves:
/// they poison slowly and bring a fever, a mild one that stops short of harm, the worst one without a bound.
/datum/reagent/rogue_infection
	name = "excess choleric humour"
	description = "Red-yellow pustulence - the carrier of disease, the enemy of all Pestrans."
	color = "#dfe36f"
	taste_description = "sickness"
	metabolization_rate = ROGUE_REAGENT_RATE(0.1)

/// Ratwood damage_tick: toxins each Ratwood tick.
/datum/reagent/rogue_infection/proc/rogue_toxin()
	return rogue_value("surgery_infection_toxin")

/// Ratwood fever_multiplier: how hot the fever runs.
/datum/reagent/rogue_infection/proc/rogue_fever()
	return 1

/// Ratwood lethal_fever: the fever is not held short of harm.
/datum/reagent/rogue_infection/proc/rogue_lethal()
	return FALSE

/datum/reagent/rogue_infection/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	var/heat = (BODYTEMP_AUTORECOVERY_MINIMUM + clamp(volume, rogue_value("surgery_infection_fever_least"), rogue_value("surgery_infection_fever_most"))) * rogue_fever() * ticks
	var/warn = SPT_PROB(rogue_value("surgery_infection_warning_chance") / ROGUE_REAGENT_TICK, seconds_per_tick)
	if(rogue_lethal())
		affected_mob.adjust_bodytemperature(heat)
		if(warn)
			to_chat(affected_mob, span_warning("A wicked heat settles within me... I feel ill. Very ill."))
	else
		affected_mob.adjust_bodytemperature(heat, 0, BODYTEMP_HEAT_DAMAGE_LIMIT - 1)
		if(warn)
			to_chat(affected_mob, span_warning("I feel a horrible chill despite the sweat rolling from my brow..."))
	if(affected_mob.adjust_tox_loss(rogue_toxin() * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/// Ratwood infection/minor: disrupted humours, a weak poison.
/datum/reagent/rogue_infection/minor
	name = "disrupted choleric humor"
	description = "Symptomatic of disrupted humours."

/datum/reagent/rogue_infection/minor/rogue_toxin()
	return rogue_value("surgery_infection_minor_toxin")

/// Ratwood infection/major, Kingsfield's Bane: a strong poison, a fever without a bound, and the unlucky catch more of it.
/datum/reagent/rogue_infection/major
	name = "excess melancholic humour"
	description = "Kingsfield's Bane. Excess melancholic has killed thousands, and even Pestra's greatest struggle against its insidious advance."

/datum/reagent/rogue_infection/major/rogue_toxin()
	return rogue_value("surgery_infection_major_toxin")

/datum/reagent/rogue_infection/major/rogue_fever()
	return rogue_value("surgery_infection_major_fever")

/datum/reagent/rogue_infection/major/rogue_lethal()
	return TRUE

/datum/reagent/rogue_infection/major/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(holder && affected_mob.rogue_badluck(1))
		holder.add_reagent(type, rand(rogue_value("surgery_infection_spread_least"), rogue_value("surgery_infection_spread_most")))
		to_chat(affected_mob, span_small("I feel even worse..."))

#undef ROGUE_SURGERY_SPEED_MIN
