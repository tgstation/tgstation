/// How much damage and progress is reduced when on stasis.
#define ELECTRICAL_DAMAGE_ON_STASIS_MULT 0.1
/// How much damage and progress is reduced when limb is grasped.
#define ELECTRICAL_DAMAGE_GRASPED_MULT 0.5
/// How much damage and progress is reduced when our victim lies down.
#define ELECTRICAL_DAMAGE_LYING_DOWN_MULT 0.5

/// Base time for a wirecutter being used.
#define ELECTRICAL_DAMAGE_WIRECUTTER_BASE_DELAY 4 SECONDS
/// Base time for a cable coil being used.
#define ELECTRICAL_DAMAGE_SUTURE_WIRE_BASE_DELAY 1 SECONDS

/datum/wound/electrical_damage
	name = "Electrical (Wires) Wound"

	wound_flags = (ACCEPTS_GAUZE)

	treatable_tool = TOOL_WIRECUTTER
	treatable_by = list(/obj/item/stack/medical/suture)
	treatable_by_grabbed = list(/obj/item/stack/cable_coil)

	/// If our wiring is safe to manually manipultae. If false, attempts to use sutures/coils will shock the helper.
	var/wiring_reset = FALSE

	/// How many sparks do we spawn when we're gained?
	var/initial_sparks_amount

	/// How much of our damage is reduced if the target is shock immune. Percent.
	var/shock_immunity_self_damage_reduction = 75

	/// Mult for our damage if we are unimportant.
	var/limb_unimportant_damage_mult = 1
	/// Mult for our progress if we are unimportant.
	var/limb_unimportant_progress_mult = 1

	/// The overall "intensity" of this wound. Goes up to [processing_full_shock_threshold], and is used for determining our effect scaling. Measured in deciseconds.
	var/intensity
	/// The time, in deciseconds, it takes to reach 100% power.
	var/processing_full_shock_threshold
	/// If [intensity] is at or below this, we remove ourselves.
	var/minimum_intensity = 0

	/// How much shock power we add to [processing_shock_power_this_tick] per tick. Lower bound
	var/processing_shock_power_per_second_min
	/// How much shock power we add to [processing_shock_power_this_tick] per tick. Upper bound
	var/processing_shock_power_per_second_max

	/// In the case we get below 1 power, we add the power to this buffer and use it next tick.
	var/processing_shock_power_this_tick
	/// The chance for each processed shock to stun the user.
	var/processing_shock_stun_chance
	/// The chance for each processed shock to spark.
	var/processing_shock_spark_chance
	/// The chance for each processed shock to message the user.
	var/process_shock_message_chance = 80

	/// Simple mult for how much of real time is added to [intensity].
	var/seconds_per_intensity_mult = 1

	/// How many sparks we spawn if a shock sparks. Lower bound
	var/process_shock_spark_count_min
	/// How many sparks we spawn if a shock sparks. Upper bound
	var/process_shock_spark_count_max

	var/wirecut_repair_percent
	var/wire_repair_percent

	var/overall_effect_mult = 1

	scar_file = ROBOTIC_METAL_SCAR_FILE

	processes = TRUE

/datum/wound_pregen_data/electrical_damage
	abstract = TRUE

	required_limb_biostate = (BIO_WIRED)

/datum/wound/electrical_damage/handle_process(seconds_per_tick, times_fired)
	. = ..()

	/*if (!(limb.body_zone == BODY_ZONE_CHEST || limb.body_zone == BODY_ZONE_HEAD))
		return*/

	var/base_mult = get_base_mult()

	var/seconds_per_tick_for_intensity = seconds_per_tick * get_progress_mult()
	modify_seconds_for_intensity_after_mult(seconds_per_tick_for_intensity)

	adjust_intensity(seconds_per_tick_for_intensity SECONDS)

	if (!victim || victim.stat == DEAD)
		return

	var/damage_mult = base_mult * get_damage_mult(victim)
	var/intensity_mult = get_intensity_mult()

	damage_mult *= seconds_per_tick
	damage_mult *= intensity_mult

	var/picked_damage = LERP(processing_shock_power_per_second_min, processing_shock_power_per_second_max, rand())
	processing_shock_power_this_tick += (picked_damage * damage_mult)
	if (processing_shock_power_this_tick > 1)
		var/stun_chance = (processing_shock_stun_chance * intensity_mult) * base_mult
		var/spark_chance = (processing_shock_spark_chance * intensity_mult) * base_mult

		//var/jitter_time = seconds_per_tick
		//var/stutter_time = 0

		var/should_stun = SPT_PROB(stun_chance, seconds_per_tick)
		var/should_message = SPT_PROB(process_shock_message_chance, seconds_per_tick)

		zap(victim,
			processing_shock_power_this_tick,
			stun = should_stun,
			spark = SPT_PROB(spark_chance, seconds_per_tick),
			animation = should_stun, message = FALSE,
			message = should_stun,
			tell_victim_if_no_message = should_message,
			ignore_immunity = TRUE,
			jitter_time = seconds_per_tick,
			stutter_time = 0,
			delay_stun = TRUE,
			knockdown = TRUE,
			ignore_gloves = TRUE
		)
		processing_shock_power_this_tick = 0

/datum/wound/electrical_damage/proc/get_progress_mult()
	var/progress_mult = get_base_mult() * seconds_per_intensity_mult

	if (limb_unimportant())
		progress_mult *= limb_unimportant_progress_mult

	return get_base_mult() * seconds_per_intensity_mult

/datum/wound/electrical_damage/proc/get_damage_mult(mob/living/target)
	SHOULD_BE_PURE(TRUE)

	var/damage_mult = get_base_mult()

	if (HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
		if (target == victim)
			damage_mult *= shock_immunity_self_damage_reduction
		else
			return 0

	if (limb_unimportant())
		damage_mult *= limb_unimportant_damage_mult

	return damage_mult

/datum/wound/electrical_damage/proc/get_base_mult()
	var/base_mult = 1

	if (victim)
		if (IS_IN_STASIS(victim))
			base_mult *= ELECTRICAL_DAMAGE_ON_STASIS_MULT
		if (victim.body_position == LYING_DOWN)
			base_mult *= ELECTRICAL_DAMAGE_LYING_DOWN_MULT
	if (limb.grasped_by)
		base_mult *= ELECTRICAL_DAMAGE_GRASPED_MULT

	var/splint_mult = (limb.current_gauze ? limb.current_gauze.splint_factor : 1)
	base_mult *= splint_mult

	return overall_effect_mult * base_mult

/datum/wound/electrical_damage/proc/modify_seconds_for_intensity_after_mult(seconds_for_intensity)
	return

/datum/wound/electrical_damage/proc/adjust_intensity(to_adjust)
	intensity = clamp((intensity + to_adjust), 0, processing_full_shock_threshold)

/datum/wound/electrical_damage/wound_injury(datum/wound/electrical_damage/old_wound, attack_direction)
	. = ..()

	if (old_wound)
		intensity = max(intensity, old_wound.intensity)
		processing_shock_power_this_tick = old_wound.processing_shock_power_this_tick

	do_sparks(initial_sparks_amount, FALSE, victim)

/datum/wound/electrical_damage/modify_desc_before_span(desc, mob/user)
	. = ..()

	if (limb.current_gauze)
		return

	var/intensity_mult = get_intensity_mult()
	if (intensity_mult < 0.2 || (victim.stat == DEAD))
		return

	. += ", and "

	var/extra
	switch (intensity_mult)
		if (0.2 to 0.4)
			extra += "[span_deadsay("is letting out some sparks")]"
		if (0.4 to 0.6)
			extra += "[span_deadsay("is sparking quite a bit")]"
		if (0.6 to 0.8)
			extra += "[span_deadsay("is practically hemorrhaging sparks")]"
		if (0.8 to 1)
			extra += "[span_deadsay("has golden bolts of electricity constantly striking the surface")]"

	. += extra

/datum/wound/electrical_damage/get_scanner_description(mob/user)
	. = ..()

	. += " Fault intensity is currently at [span_bold("[get_intensity_mult() * 100]")]%."

/datum/wound/electrical_damage/item_can_treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_HEMOSTAT)
		return TRUE

	if (istype(potential_treater, /obj/item/stack/cable_coil) && (limb.burn_dam <= 5))
		return TRUE

	return ..()

/datum/wound/electrical_damage/treat(obj/item/treating_item, mob/user)
	if (treating_item.tool_behaviour == TOOL_WIRECUTTER || treating_item.tool_behaviour == TOOL_HEMOSTAT)
		return wirecut(treating_item, user)

	if (istype(treating_item, /obj/item/stack/medical/suture) || istype(treating_item, /obj/item/stack/cable_coil))
		return suture_wires(treating_item, user)

	return ..()

/datum/wound/electrical_damage/proc/suture_wires(obj/item/stack/suturing_item, mob/living/carbon/human/user)
	if (!suturing_item.tool_start_check())
		return TRUE

	var/is_suture = (istype(suturing_item, /obj/item/stack/medical/suture))

	var/change = (processing_full_shock_threshold * wire_repair_percent)
	var/delay_mult = 1
	if (user == victim)
		delay_mult *= 4.5
	if (is_suture)
		delay_mult *= 3
		change *= 0.6
		var/obj/item/stack/medical/suture/suture_item = suturing_item
		var/obj/item/stack/medical/suture/base_suture = /obj/item/stack/medical/suture
		change += (suture_item.heal_brute - initial(base_suture.heal_brute))
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	var/your_or_other = (user == victim ? "your" : "[user]'s")
	var/replacing_or_suturing = (is_suture ? "repairing some" : "replacing")
	if (!wiring_reset)
		to_chat(user, span_warning("You notice the wiring within [your_or_other] [limb.plaintext_zone] is still loose... you might shock yourself!"))
		delay_mult *= 9

	while (suturing_item.tool_start_check())
		user?.visible_message(span_warning("[user] begins [replacing_or_suturing] wiring within [their_or_other] [limb.plaintext_zone] with [suturing_item]..."), ignored_mobs = list(user))
		if (!suturing_item.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_SUTURE_WIRE_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] mangles some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_intensity(change)
			set_wiring_status(FALSE, user)
		else
			var/repairs_or_replaces = (is_suture ? "repairs" : "replaces")
			user?.visible_message(span_green("[user] [repairs_or_replaces] some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_intensity(-change)

			if (!wiring_reset)
				user?.electrocute_act(max(process_shock_spark_count_max * get_intensity_mult(), 1), limb)
				set_wiring_status(TRUE, user)

			suturing_item.use(1)

		if (remove_if_fixed())
			return TRUE
	return TRUE

/datum/wound/electrical_damage/proc/wirecut(obj/item/wirecutting_tool, mob/living/carbon/human/user)
	if (!wirecutting_tool.tool_start_check())
		return TRUE

	var/is_hemostat = (wirecutting_tool.tool_behaviour == TOOL_HEMOSTAT)

	var/change = (processing_full_shock_threshold * wirecut_repair_percent)
	var/delay_mult = 1
	if (user == victim)
		delay_mult *= 3
	if (is_hemostat)
		delay_mult *= 2
		change *= 0.8
	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		delay_mult *= 0.75
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.75

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	while (wirecutting_tool.tool_start_check())
		user?.visible_message(span_warning("[user] begins resetting misplaced wiring within [their_or_other] [limb.plaintext_zone]..."), ignored_mobs = list(user))
		if (!wirecutting_tool.use_tool(target = victim, user = user, delay = ELECTRICAL_DAMAGE_WIRECUTTER_BASE_DELAY * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
			return TRUE

		if (user != victim && user.combat_mode)
			user?.visible_message(span_danger("[user] mangles some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_intensity(change)
			set_wiring_status(FALSE, user)
		else
			user?.visible_message(span_green("[user] resets some of [their_or_other] [limb.plaintext_zone]'s wiring!"))
			adjust_intensity(-change)
			set_wiring_status(TRUE, user)

		if (remove_if_fixed())
			return TRUE
	return TRUE

/datum/wound/electrical_damage/proc/set_wiring_status(reset, mob/user)
	if (!wiring_reset && reset)
		if (user)
			var/your_or_other = (user == victim ? "your" : "[user]'s")
			to_chat(user, span_green("The wires in [your_or_other]'s [limb.plaintext_zone] are set! You can now safely use wires/sutures."))
	wiring_reset = reset

/datum/wound/electrical_damage/proc/remove_if_fixed()
	if (intensity <= minimum_intensity)
		to_chat(victim, span_green("Your [limb.plaintext_zone] has recovered from its [name]!"))
		remove_wound()
		return TRUE
	return FALSE

/datum/wound/electrical_damage/proc/get_intensity_mult()
	return (min((intensity / processing_full_shock_threshold), 1))

/datum/wound/electrical_damage/proc/zap(
		mob/living/target,
		damage,
		coeff = 1,
		stun,
		spark = TRUE,
		animation = TRUE,
		message = TRUE,
		ignore_immunity = FALSE,
		delay_stun = FALSE,
		knockdown = FALSE,
		ignore_gloves = FALSE,
		tell_victim_if_no_message = TRUE,
		jitter_time = 20 SECONDS,
		stutter_time = 4 SECONDS)

	var/flags = NONE
	if (!stun)
		flags |= SHOCK_NOSTUN
	if (!animation)
		flags |= SHOCK_NOHUMANANIM
	if (!message)
		flags |= SHOCK_SUPPRESS_MESSAGE
		if (tell_victim_if_no_message && target == victim)
			to_chat(target, span_warning("Your [limb.plaintext_zone] short-circuits and zaps you!"))
	if (ignore_immunity)
		flags |= SHOCK_IGNORE_IMMUNITY
	if (delay_stun)
		flags |= SHOCK_DELAY_STUN
	if (knockdown)
		flags |= SHOCK_KNOCKDOWN
	if (ignore_gloves)
		flags |= SHOCK_NOGLOVES

	target.electrocute_act(damage, limb, coeff, flags, jitter_time, stutter_time)
	if (spark)
		do_sparks(rand(process_shock_spark_count_min, process_shock_spark_count_max), FALSE, victim)

/datum/wound/electrical_damage/proc/can_zap(atom/target = victim, atom/connecting_item, uses_victim_hands, uses_target_hands)
	if (!isliving(target))
		return FALSE
	if (target != victim)
		if (!isnull(connecting_item))
			return FALSE
		if (HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
			return FALSE
		if (uses_victim_hands && victim.wearing_shock_proof_gloves())
			return FALSE
		if (uses_target_hands && iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			if (carbon_target.wearing_shock_proof_gloves())
				return FALSE

	return TRUE

/datum/wound/electrical_damage/slash
	wound_type = WOUND_SLASH
	wound_series = WOUND_SERIES_WIRE_SLASH_ELECTRICAL_DAMAGE

/datum/wound/electrical_damage/slash/moderate
	name = "Frayed Wiring"
	desc = "Internal wiring has suffered a slight abrasion, causing a very slow electrical fault that will intensify over time."
	occur_text = "lets out a few sparks, as a few frayed wires stick out"
	examine_desc = "has a few frayed wires sticking out"
	treat_text = "Replacing of damaged wiring, though repairs via wirecutting instruments or sutures may suffice, albiet at limited efficiency."

	sound_effect = 'sound/effects/wounds/robotic_slash_T1.ogg'

	severity = WOUND_SEVERITY_MODERATE

	sound_volume = 30

	threshold_minimum = 35
	threshold_penalty = 20

	intensity = 10 SECONDS
	processing_full_shock_threshold = 3.5 MINUTES

	processing_shock_power_per_second_max = 0.2
	processing_shock_power_per_second_min = 0.1

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 30

	process_shock_spark_count_max = 1
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.20 //20% per wirecut
	wire_repair_percent = 0.08 //8% per suture

	wiring_reset = TRUE

	initial_sparks_amount = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/slash/moderate

	a_or_from = "from"

	scar_keyword = "robotic_slashmoderate"

/datum/wound_pregen_data/electrical_damage/slash/moderate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/moderate
/datum/wound/electrical_damage/slash/severe
	name = "Severed Conduits"
	desc = "A number of wires have been completely cut, resulting in electrical faults that will intensify at a worrying rate."
	occur_text = "sends some electrical fiber in the direction of the blow, beginning to profusely spark"
	examine_desc = "has multiple severed wires visible to the outside"
	treat_text = "Containment of damaged wiring via gauze, securing of wires via a wirecutter/hemostat, then application of fresh wiring or sutures."

	sound_effect = 'sound/effects/wounds/robotic_slash_T2.ogg'

	severity = WOUND_SEVERITY_SEVERE

	sound_volume = 15

	threshold_minimum = 60
	threshold_penalty = 30

	intensity = 20 SECONDS
	processing_full_shock_threshold = 3 MINUTES

	processing_shock_power_per_second_max = 0.4
	processing_shock_power_per_second_min = 0.2

	processing_shock_stun_chance = 0
	processing_shock_spark_chance = 60

	process_shock_spark_count_max = 2
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.018 //18% per wirecut
	wire_repair_percent = 0.06 //6% per suture

	initial_sparks_amount = 3

	status_effect_type = /datum/status_effect/wound/electrical_damage/slash/severe

	a_or_from = "from"

	scar_keyword = "robotic_slashsevere"

/datum/wound_pregen_data/electrical_damage/slash/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/severe
/datum/wound/electrical_damage/slash/critical
	name = "Systemic Fault"
	desc = "A significant portion of the power distribution network has been cut open, resulting in massive power loss and runaway electrocution."
	occur_text = "lets out a violent \"zhwarp\" sound as angry electric arcs attack the surrounding air"
	examine_desc = "has lots of wires mauled wires sticking out"
	treat_text = "Immediate securing via gauze, followed by emergency cable replacement and securing via wirecutters or hemostat."

	severity = WOUND_SEVERITY_CRITICAL
	wound_flags = (ACCEPTS_GAUZE|MANGLES_FLESH)

	sound_effect = 'sound/effects/wounds/robotic_slash_T3.ogg'

	sound_volume = 30

	threshold_minimum = 100
	threshold_penalty = 50

	intensity = 30 SECONDS
	processing_full_shock_threshold = 2 MINUTES

	processing_shock_power_per_second_max = 1
	processing_shock_power_per_second_min = 0.8

	processing_shock_stun_chance = 5
	processing_shock_spark_chance = 90

	process_shock_spark_count_max = 3
	process_shock_spark_count_min = 2

	wirecut_repair_percent = 0.016 //16% per wirecut
	wire_repair_percent = 0.05 //5% per suture

	initial_sparks_amount = 8

	status_effect_type = /datum/status_effect/wound/electrical_damage/slash/critical

	a_or_from = "a"

	scar_keyword = "robotic_slashcritical"

/datum/wound_pregen_data/electrical_damage/slash/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/slash/critical

#undef ELECTRICAL_DAMAGE_ON_STASIS_MULT
#undef ELECTRICAL_DAMAGE_GRASPED_MULT
#undef ELECTRICAL_DAMAGE_LYING_DOWN_MULT

#undef ELECTRICAL_DAMAGE_WIRECUTTER_BASE_DELAY
#undef ELECTRICAL_DAMAGE_SUTURE_WIRE_BASE_DELAY
